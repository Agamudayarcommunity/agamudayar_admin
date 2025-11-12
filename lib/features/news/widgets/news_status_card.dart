import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../config/theme.dart';
import '../../../core/models/approval_status.dart';
import '../providers/news_provider.dart';
import '../models/news_model.dart';
import '../../../widgets/status_badge.dart';

class NewsStatusCard extends StatefulWidget {
  const NewsStatusCard({Key? key}) : super(key: key);

  @override
  State<NewsStatusCard> createState() => _NewsStatusCardState();
}

class _NewsStatusCardState extends State<NewsStatusCard> {
  @override
  void initState() {
    super.initState();
    // Fetch news data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().loadNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'News Status Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<NewsProvider>().loadNews();
                  },
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<NewsProvider>(
              builder: (context, newsProvider, child) {
                // Show error message if there's an error
                if (newsProvider.error != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(newsProvider.error!),
                        backgroundColor: Colors.red,
                      ),
                    );
                    newsProvider.clearError();
                  });
                }

                if (newsProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (newsProvider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${newsProvider.error}',
                            style: TextStyle(color: Colors.red[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              newsProvider.loadNews();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return _buildNewsStatusList(newsProvider.news);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsStatusList(List<NewsModel> newsList) {
    if (newsList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.article_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No news items found',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Summary row
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusCount(
                'Total',
                newsList.length,
                AppColors.primary,
              ),
              _buildStatusCount(
                'Approved',
                newsList.where((item) => item.status == ApprovalStatus.approved).length,
                AppColors.secondary,
              ),
              _buildStatusCount(
                'Pending',
                newsList.where((item) => item.status == ApprovalStatus.pending).length,
                Colors.orange,
              ),
              _buildStatusCount(
                'Rejected',
                newsList.where((item) => item.status == ApprovalStatus.rejected).length,
                Colors.red,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // News items list
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final newsItem = newsList[index];
              return _buildNewsStatusItem(newsItem);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCount(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNewsStatusItem(NewsModel newsItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // News Images (show all thumbnails if available)
                SizedBox(
                  width: 160,
                  child: (newsItem.imageUrls.isNotEmpty)
                      ? Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: newsItem.imageUrls
                              .where((u) => u.isNotEmpty)
                              .map((u) => ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 72,
                                      height: 72,
                                      color: Colors.grey[200],
                                      child: _buildNewsImage(u),
                                    ),
                                  ))
                              .toList(),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: newsItem.imageUrl.isNotEmpty
                                ? _buildNewsImage(newsItem.imageUrl)
                                : Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                    size: 40,
                                  ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // News Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        newsItem.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (newsItem.content.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          newsItem.content,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              newsItem.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge(status: _getApprovalStatus(newsItem.status)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleApproval(newsItem),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleRejection(newsItem),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleEdit(newsItem),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsImage(String imageData) {
    try {
      if (imageData.startsWith('data:image')) {
        // Handle base64 image
        final base64String = imageData.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.broken_image,
              color: Colors.grey[400],
              size: 40,
            );
          },
        );
      } else {
        // Handle URL image
        return Image.network(
          imageData,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.broken_image,
              color: Colors.grey[400],
              size: 40,
            );
          },
        );
      }
    } catch (e) {
      return Icon(
        Icons.broken_image,
        color: Colors.grey[400],
        size: 40,
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.secondary;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check;
      case 'pending':
        return Icons.schedule;
      case 'rejected':
        return Icons.close;
      default:
        return Icons.help_outline;
    }
  }

  ApprovalStatus _getApprovalStatus(ApprovalStatus status) {
    return status;
  }

  void _handleApproval(NewsModel newsItem) {
    _showConfirmationDialog(
      title: 'Approve News',
      message: 'Are you sure you want to approve "${newsItem.title}"?',
      onConfirm: () {
        context.read<NewsProvider>().updateNewsStatus(
          newsItem.id,
          ApprovalStatus.approved,
        );
      },
    );
  }

  void _handleRejection(NewsModel newsItem) {
    _showConfirmationDialog(
      title: 'Reject News',
      message: 'Are you sure you want to reject "${newsItem.title}"?',
      onConfirm: () {
        context.read<NewsProvider>().updateNewsStatus(
          newsItem.id,
          ApprovalStatus.rejected,
        );
      },
    );
  }

  void _handleEdit(NewsModel newsItem) {
    _showEditDialog(newsItem);
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(NewsModel newsItem) {
    ApprovalStatus selectedStatus = newsItem.status;
    final titleController = TextEditingController(text: newsItem.title);
    final subtitleController = TextEditingController(text: newsItem.category);
    final contentController = TextEditingController(text: newsItem.content);
    final locationController = TextEditingController();
    List<String> images = [];
    if (newsItem.imageUrls.isNotEmpty) {
      images = List<String>.from(newsItem.imageUrls);
    } else if (newsItem.imageUrl.isNotEmpty) {
      images = [newsItem.imageUrl];
    }
    final newImageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit News'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'Subtitle',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Content Message',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ApprovalStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ApprovalStatus.values
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Images',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(images.length, (index) {
                    final img = images[index];
                    if (img.isEmpty) {
                      // Skip rendering empty placeholders, but keep them in payload
                      return const SizedBox.shrink();
                    }
                    return Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: _buildNewsImage(img),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  // Set to empty string to indicate removal in payload
                                  images[index] = '';
                                });
                              },
                              tooltip: 'Remove',
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: newImageController,
                        decoration: const InputDecoration(
                          labelText: 'Add Image URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final url = newImageController.text.trim();
                        if (url.isNotEmpty) {
                          setState(() {
                            images.add(url);
                            newImageController.clear();
                          });
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                final payload = {
                  'newsId': newsItem.id,
                  'status': selectedStatus.name,
                  'title': titleController.text.trim(),
                  'subtitle': subtitleController.text.trim(),
                  'contentMessage': contentController.text.trim(),
                  'location': locationController.text.trim(),
                  'images': images,
                };
                context.read<NewsProvider>().updateNewsDetails(payload);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }


}