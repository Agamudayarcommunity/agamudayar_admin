import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/approval_status.dart';
import '../../../widgets/status_badge.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../models/news_model.dart';
import '../providers/news_provider.dart';
import '../repositories/news_repository.dart';

class NewsDetailScreen extends StatefulWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late NewsRepository _newsRepository;
  NewsModel? _newsItem;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _newsRepository = NewsRepository();
    _loadNewsItem();
  }

  Future<void> _loadNewsItem() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newsItem = await _newsRepository.getNewsById(widget.newsId);
      setState(() {
        _newsItem = newsItem;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading news: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewsBloc(newsRepository: _newsRepository),
      child: Scaffold(
        appBar: AppBar(title: const Text('News Details')),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _newsItem == null
            ? const Center(child: Text('News item not found'))
            : _buildNewsDetails(context),
      ),
    );
  }

  Widget _buildNewsDetails(BuildContext context) {
    return BlocListener<NewsBloc, NewsState>(
      listener: (context, state) {
        if (state is NewsStatusUpdated) {
          _loadNewsItem();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('News status updated successfully')),
          );
        } else if (state is NewsStatusUpdatedViaApi) {
          _loadNewsItem();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is NewsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _newsItem!.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        StatusBadge(status: _newsItem!.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Category: ${_newsItem!.category}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Submitted by: ${_newsItem!.submittedBy}'),
                    Text(
                      'Submitted on: ${_formatDate(_newsItem!.submittedDate)}',
                    ),
                    if (_newsItem!.status == ApprovalStatus.approved &&
                        _newsItem!.approvedDate != null)
                      Text(
                        'Approved on: ${_formatDate(_newsItem!.approvedDate!)}',
                      ),
                    if (_newsItem!.status == ApprovalStatus.rejected &&
                        _newsItem!.rejectionReason != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Rejection reason: ${_newsItem!.rejectionReason}',
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                          ), // Dark red
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_newsItem!.imageUrls.isNotEmpty ||
                _newsItem!.imageUrl.isNotEmpty)
              Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'News Images',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              (_newsItem!.imageUrls.isNotEmpty
                                      ? _newsItem!.imageUrls
                                      : [_newsItem!.imageUrl])
                                  .where((u) => u.isNotEmpty)
                                  .map(
                                    (u) => Container(
                                      margin: const EdgeInsets.only(
                                        left: 12,
                                        right: 12,
                                      ),
                                      width: 300,
                                      height: 200,
                                      color: AppColors.grey.withOpacity(0.1),
                                      child: Image.network(
                                        u,
                                        height: 200,
                                        width: 300,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                height: 200,
                                                width: 300,
                                                color: AppColors.grey
                                                    .withOpacity(0.3),
                                                child: const Center(
                                                  child: Text(
                                                    'Image not available',
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_newsItem!.content),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_newsItem!.status == ApprovalStatus.pending)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showRejectDialog(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF44336), // Red
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve News'),
        content: Text(
          'Are you sure you want to approve "${_newsItem!.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // context.read<NewsBloc>().add(
              //       UpdateNewsStatusViaApi(
              //         newsId: _newsItem!.id,
              //         status: 'Approved',
              //       ),
              //     );
              // Navigator.pop(context);
              context.read<NewsProvider>().updateNewsStatus(
                widget.newsId,
                ApprovalStatus.approved,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('News approved successfully')),
              );
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject News'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${_newsItem!.title}"?'),
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
              // context.read<NewsBloc>().add(
              //   UpdateNewsStatusViaApi(
              //     newsId: _newsItem!.id,
              //     status: 'Rejected',
              //   ),
              // );
              // Navigator.pop(context);
              context.read<NewsProvider>().updateNewsStatus(
                widget.newsId,
                ApprovalStatus.rejected,
                rejectionReason: reasonController.text.trim(),
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('News rejected')));
              Navigator.pop(context);
              Navigator.pop(context);
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
