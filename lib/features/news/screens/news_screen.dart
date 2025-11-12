import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/approval_status.dart';
import '../../../widgets/approval_actions.dart';
import '../../../widgets/sidebar.dart';
import '../../../widgets/status_badge.dart';
import '../providers/news_provider.dart';
import '../models/news_model.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Approval'),
        actions: [
          Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  newsProvider.loadNews();
                },
              );
            },
          ),
          Consumer<NewsProvider>(
            builder: (context, newsProvider, child) {
              return IconButton(
                icon: const Icon(Icons.cloud_download),
                onPressed: () {
                  newsProvider.loadNews();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Loading news from API...'),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: const Sidebar(currentRoute: '/news'),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (newsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${newsProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => newsProvider.loadNews(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return _buildNewsTable(context, newsProvider.news);
          }
        },
      ),
    );
  }

  Widget _buildNewsTable(BuildContext context, List<NewsModel> news) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildFilterChip(
                context,
                'All',
                null,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Pending',
                ApprovalStatus.pending,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Approved',
                ApprovalStatus.approved,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Rejected',
                ApprovalStatus.rejected,
              ),
            ],
          ),
        ),
        Expanded(
          child: news.isEmpty
              ? const Center(child: Text('No news items found'))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Submitted By')),
                        DataColumn(label: Text('Submitted Date')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: news.map((newsItem) {
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 200,
                                child: Text(
                                  newsItem.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewsDetailScreen(
                                      newsId: newsItem.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            DataCell(Text(newsItem.category)),
                            DataCell(Text(newsItem.submittedBy)),
                            DataCell(Text(_formatDate(newsItem.submittedDate))),
                            DataCell(StatusBadge(status: newsItem.status)),
                            DataCell(
                              ApprovalActions(
                                status: newsItem.status,
                                onApprove: () => _showApproveDialog(context, newsItem),
                                onReject: () => _showRejectDialog(context, newsItem),
                                onView: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewsDetailScreen(
                                        newsId: newsItem.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, ApprovalStatus? status) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {
        // Filter functionality can be implemented later if needed
        // For now, we'll just reload all news
        context.read<NewsProvider>().loadNews();
      },
    );
  }

  void _showApproveDialog(BuildContext context, NewsModel newsItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve News'),
        content: Text('Are you sure you want to approve "${newsItem.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NewsProvider>().updateNewsStatus(
                newsItem.id,
                ApprovalStatus.approved,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('News approved successfully')),
              );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, NewsModel newsItem) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject News'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${newsItem.title}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for rejection'),
                  ),
                );
                return;
              }
              context.read<NewsProvider>().updateNewsStatus(
                newsItem.id,
                ApprovalStatus.rejected,
                rejectionReason: reasonController.text.trim(),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('News rejected')),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}