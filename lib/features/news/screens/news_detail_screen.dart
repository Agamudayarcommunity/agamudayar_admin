import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/approval_status.dart';
import '../../../widgets/status_badge.dart';
import '../models/news_model.dart';
import '../providers/news_provider.dart';

// This screen is now a StatefulWidget to manage the editing state
class NewsDetailScreen extends StatefulWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  // Controllers for text editing
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  // ... add more controllers here for other fields you want to edit

  // Local state to manage the UI
  bool _isEditing = false;
  bool _hasChanges = false;
  bool _isSaving = false;

  List<PlatformFile> _newSelectedImages = [];

  @override
  void initState() {
    super.initState();

    // 1. Get the initial data from the provider.
    // We use context.read() because we are in initState.
    final newsItem = context.read<NewsProvider>().getNewsById(widget.newsId);

    // 2. Initialize the text controllers with the data
    _titleController = TextEditingController(text: newsItem?.title ?? '');
    _contentController = TextEditingController(text: newsItem?.content ?? '');

    // 3. Add listeners to detect when the user is typing
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // 4. Clean up the controllers to prevent memory leaks
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// This function runs every time the user types in an editable field.
  /// It checks if the current text is different from the original data.
  void _onTextChanged() {
    if (!_isEditing) return; // Only check for changes if in edit mode

    // Get the most up-to-date data from the provider
    final newsItem = context.read<NewsProvider>().getNewsById(widget.newsId);
    if (newsItem == null) return;

    final hasTitleChanged = _titleController.text != newsItem.title;
    final hasContentChanged = _contentController.text != newsItem.content;

    // Check if anything has changed
    final anyChanges =
        hasTitleChanged || hasContentChanged; // Add other fields here

    // Only call setState if the _hasChanges flag needs to change
    if (anyChanges != _hasChanges) {
      setState(() {
        _hasChanges = anyChanges;
      });
    }
  }

  /// Toggles the UI between "View" mode and "Edit" mode
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      _hasChanges = false; // Reset changes on toggle
      _newSelectedImages = [];

      // If user clicked "Cancel", reset text to original data
      if (!_isEditing) {
        final newsItem = context.read<NewsProvider>().getNewsById(
          widget.newsId,
        );
        _titleController.text = newsItem?.title ?? '';
        _contentController.text = newsItem?.content ?? '';
      }
    });
  }

  /// Saves all changes by calling the provider's update method
  void _saveChanges() async {
    // Prevent double-taps
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final provider = context.read<NewsProvider>();
    final newsItem = provider.getNewsById(widget.newsId);
    if (newsItem == null) {
      setState(() => _isSaving = false);
      return; // Should not happen
    }

    // Create the updateData map that the provider's function expects
    final updateData = {
      'newsId': newsItem.id,
      'title': _titleController.text,
      'contentMessage': _contentController.text,
      // Add other fields here as you make them editable
    };

    try {
      // Call the provider to update the API and local state
      await provider.updateNewsDetails(updateData);

      // Call our new provider function later
      // await provider.saveEditedNews(
      //   newsId: newsItem.id,
      //   title: _titleController.text,
      //   content: _contentController.text,
      //   newImages: _newSelectedImages.isNotEmpty ? _newSelectedImages : null,
      // );

      // We check 'mounted' in case the widget was removed during the await
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditing = false;
          _hasChanges = false;
          _isSaving = false;
          _newSelectedImages = [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  /// Placeholder for editing images
  void _editImages() {
    // This is where you would launch a file picker
    // e.g., FilePicker.platform.pickFiles(allowMultiple: true)
    // This is a complex feature and should be part of Phase 2.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image editing not implemented yet.')),
    );
  }

  // void _editImages() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     allowMultiple: true,
  //     type: FileType.image,
  //     withData: true, // <-- CRITICAL: This ensures file.bytes is not null
  //   );

  //   if (result != null) {
  //     setState(() {
  //       _newSelectedImages = result.files; // result.files is List<PlatformFile>
  //       _onTextChanged(); // <-- CRITICAL: This enables the "Save" button
  //     });
  //   }
  // }

  Widget _buildNewImage(PlatformFile file) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: 300,
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          file.bytes!, // Use the file's bytes (works on web and mobile)
          fit: BoxFit.cover,
          //errorBuilder: (context, error, stackTrace) => _buildImageError(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We use Consumer so this 'builder' function re-runs
    // whenever 'notifyListeners()' is called in the NewsProvider.
    // This is what fixes the "status not refreshing" bug.
    return Consumer<NewsProvider>(
      builder: (context, provider, child) {
        final newsItem = provider.getNewsById(widget.newsId);
        final theme = Theme.of(context);

        // Handle case where news item is not found or has been deleted
        if (newsItem == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('News item not found.')),
          );
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface, // Dark mode aware
          appBar: AppBar(
            title: const Text('News Details'),
            backgroundColor: theme.colorScheme.surface, // Dark mode aware
            foregroundColor: theme.colorScheme.onSurface,
            actions: [
              // Show "Edit" button if NOT editing, or "Cancel" button IF editing
              // 1. If in Edit Mode, always show "Cancel"
              if (_isEditing)
                TextButton(
                  onPressed: _toggleEditMode,
                  child: const Text('Cancel'),
                )
              // 2. If NOT in Edit Mode AND status is "pending", show "Edit"
              else if (newsItem.status == ApprovalStatus.pending)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit News',
                  onPressed: _toggleEditMode,
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            // Add padding for the bottom bar so it doesn't cover content
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Details Card ---
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- CONDITIONAL TITLE (Text or TextField) ---
                              Expanded(
                                child: _isEditing
                                    ? TextFormField(
                                        controller: _titleController,
                                        style: theme.textTheme.headlineMedium,
                                        decoration: const InputDecoration(
                                          labelText: 'Title',
                                          border: OutlineInputBorder(),
                                        ),
                                      )
                                    : Text(
                                        newsItem.title,
                                        style: theme.textTheme.headlineMedium,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              StatusBadge(status: newsItem.status),
                            ],
                          ),
                          // const SizedBox(height: 16),
                          // Text(
                          //   'Category: ${newsItem.category}',
                          //   style: theme.textTheme.titleMedium,
                          // ),
                          const SizedBox(height: 8),
                          Text(
                            'Submitted by: ${newsItem.submittedBy}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            'Submitted on: ${_formatDate(newsItem.submittedDate)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (newsItem.status == ApprovalStatus.approved &&
                              newsItem.approvedDate != null)
                            Text(
                              'Approved on: ${_formatDate(newsItem.approvedDate!)}',
                            ),
                          if (newsItem.status == ApprovalStatus.rejected &&
                              newsItem.rejectionReason != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Rejection reason: ${newsItem.rejectionReason}',
                                style: TextStyle(
                                  color: theme
                                      .colorScheme
                                      .error, // Dark mode aware
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Images Card ---
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'News Images',
                                style: theme.textTheme.titleLarge,
                              ),
                              // if (_isEditing)
                              //   IconButton(
                              //     icon: Icon(
                              //       Icons.edit,
                              //       color: theme.colorScheme.primary,
                              //     ),
                              //     onPressed: _editImages,
                              //   ),
                            ],
                          ),
                        ),

                        // --- Image Scroller ---
                        (newsItem.imageUrls.isEmpty &&
                                newsItem.imageUrl.isEmpty)
                            ? Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Text('No images provided.'),
                                ),
                              )
                            : SizedBox(
                                height: 200,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children:
                                        (newsItem.imageUrls.isNotEmpty
                                                ? newsItem.imageUrls
                                                : [newsItem.imageUrl])
                                            .where((u) => u.isNotEmpty)
                                            .map(
                                              (u) => Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                                width: 300,
                                                height: 200,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.network(
                                                    u,
                                                    height: 200,
                                                    width: 300,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Container(
                                                            height: 200,
                                                            width: 300,
                                                            color: Colors
                                                                .grey[200],
                                                            child: const Center(
                                                              child: Text(
                                                                'Image not available',
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 16), // Padding at the bottom
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Content Card ---
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Content', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          // --- CONDITIONAL CONTENT (Text or TextField) ---
                          _isEditing
                              ? TextFormField(
                                  controller: _contentController,
                                  minLines: 10,
                                  maxLines: 20, // Allows for a long message
                                  decoration: const InputDecoration(
                                    labelText: 'Content',
                                    border: OutlineInputBorder(),
                                  ),
                                )
                              : Text(
                                  newsItem.content,
                                  style: theme.textTheme.bodyLarge,
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- CONDITIONAL BOTTOM ACTION BAR ---
          bottomNavigationBar: _buildBottomBar(context, newsItem),
        );
      },
    );
  }

  /// Builds the correct bottom bar based on the current state
  Widget _buildBottomBar(BuildContext context, NewsModel newsItem) {
    final theme = Theme.of(context);

    // --- STATE 1: "EDIT MODE" ---
    // Show "Save Changes" button, only enabled if _hasChanges is true
    if (_isEditing) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _hasChanges && !_isSaving
              ? _saveChanges
              : null, // Enabled only if there are changes
          icon: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(_isSaving ? "Submitting..." : "Save Changes"),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );
    }

    // --- STATE 2: "PENDING STATUS" ---
    // Show "Approve" and "Reject" buttons, only if NOT editing
    if (newsItem.status == ApprovalStatus.pending) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showApproveDialog(context, newsItem),
                icon: const Icon(Icons.check),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showRejectDialog(context, newsItem),
                icon: const Icon(Icons.close),
                label: const Text('Reject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // --- STATE 3: (Approved or Rejected) ---
    // Show no buttons
    return const SizedBox.shrink();
  }

  // --- DIALOGS (No longer need l10n) ---
  void _showApproveDialog(BuildContext context, NewsModel newsItem) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve News'),
        content: Text('Are you sure you want to approve "${newsItem.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close the dialog

              final snackbar = ScaffoldMessenger.of(context);
              snackbar.showSnackBar(
                const SnackBar(content: Text('Approving...')),
              );

              await context.read<NewsProvider>().updateNewsStatus(
                widget.newsId,
                ApprovalStatus.approved,
              );

              // Close the detail screen as you requested
              if (mounted) {
                Navigator.pop(context);
                snackbar.showSnackBar(
                  const SnackBar(
                    content: Text('News approved successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
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
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for rejection'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext); // Close the dialog

              final snackbar = ScaffoldMessenger.of(context);
              snackbar.showSnackBar(
                const SnackBar(content: Text('Rejecting...')),
              );

              await context.read<NewsProvider>().updateNewsStatus(
                widget.newsId,
                ApprovalStatus.rejected,
                rejectionReason: reasonController.text.trim(),
              );

              if (mounted) {
                snackbar.showSnackBar(
                  const SnackBar(
                    content: Text('News rejected'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../../config/theme.dart';
// import '../../../core/models/approval_status.dart';
// import '../../../widgets/status_badge.dart';
// import '../models/news_model.dart';
// import '../providers/news_provider.dart';

// // import 'package:file_picker/file_picker.dart';
// import '../../../config/theme.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../core/models/approval_status.dart';
// import '../../../widgets/status_badge.dart';
// import '../bloc/news_bloc.dart';
// import '../bloc/news_event.dart';
// import '../bloc/news_state.dart';
// import '../models/news_model.dart';
// import '../providers/news_provider.dart';
// import '../repositories/news_repository.dart';

// class NewsDetailScreen extends StatefulWidget {
//   final String newsId;

//   const NewsDetailScreen({super.key, required this.newsId});

//   @override
//   State<NewsDetailScreen> createState() => _NewsDetailScreenState();
// }

// class _NewsDetailScreenState extends State<NewsDetailScreen> {
//   // Controllers to manage text editing
//   late TextEditingController _titleController;
//   late TextEditingController _contentController;

//   // State to manage UI
//   bool _isEditing = false;
//   bool _hasChanges = false;
//   bool _isSaving = false;

//   // We'll store the news item in our state
//   // NewsModel? _newsItem;

//   //late NewsRepository _newsRepository;

//   //bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     // _newsRepository = NewsRepository();
//     // _loadNewsItem();
//     // 1. Get the initial data from the provider
//     final newsItem = context.read<NewsProvider>().getNewsById(widget.newsId);

//     // 2. Initialize controllers
//     _titleController = TextEditingController(text: newsItem?.title ?? '');
//     _contentController = TextEditingController(text: newsItem?.content ?? '');

//     // 3. Listen for changes to enable the "Save" button
//     _titleController.addListener(_onTextChanged);
//     _contentController.addListener(_onTextChanged);
//   }

//   @override
//   void dispose() {
//     _titleController.removeListener(_onTextChanged);
//     _contentController.removeListener(_onTextChanged);
//     _titleController.dispose();
//     _contentController.dispose();
//     super.dispose();
//   }

//   /// Checks if the text in the controllers is different from the original data.
//   void _onTextChanged() {
//     if (!_isEditing) return; // Only check for changes if in edit mode

//     final newsItem = context.read<NewsProvider>().getNewsById(widget.newsId);
//     if (newsItem == null) return;

//     final hasTitleChanged = _titleController.text != newsItem.title;
//     final hasContentChanged = _contentController.text != newsItem.content;

//     final anyChanges =
//         hasTitleChanged || hasContentChanged; // Add other fields here

//     if (anyChanges != _hasChanges) {
//       setState(() {
//         _hasChanges = anyChanges;
//       });
//     }
//   }

//   /// Toggles the UI between "View" mode and "Edit" mode
//   void _toggleEditMode() {
//     setState(() {
//       _isEditing = !_isEditing;
//       _hasChanges = false; // Reset changes on toggle

//       // If user clicked "Cancel", reset text to original
//       if (!_isEditing) {
//         final newsItem = context.read<NewsProvider>().getNewsById(
//           widget.newsId,
//         );
//         _titleController.text = newsItem?.title ?? '';
//         _contentController.text = newsItem?.content ?? '';
//       }
//     });
//   }

//   /// Saves all changes by calling the provider's update method
//   void _saveChanges() async {
//     setState(() => _isSaving = true);

//     final provider = context.read<NewsProvider>();
//     final newsItem = provider.getNewsById(widget.newsId);
//     if (newsItem == null) return; // Should not happen

//     // Create the updateData map that the provider expects
//     final updateData = {
//       'newsId': newsItem.id,
//       'title': _titleController.text,
//       'contentMessage': _contentController.text,
//       // Add other fields you made editable
//     };

//     // Call the provider to update the API and local state
//     await provider.updateNewsDetails(updateData);

//     // We check 'mounted' in case the widget was removed
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Changes saved successfully!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       setState(() {
//         _isEditing = false;
//         _hasChanges = false;
//         _isSaving = false;
//       });
//     }
//   }

//   /// Placeholder for editing images
//   void _editImages() {
//     // This is where you would launch a file picker
//     // e.g., FilePicker.platform.pickFiles(allowMultiple: true)
//     // This is a complex feature and should be part of Phase 2.
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Image editing not implemented yet.')),
//     );
//   }

//   // Future<void> _loadNewsItem() async {
//   //   setState(() {
//   //     _isLoading = true;
//   //   });

//   //   try {
//   //     final newsItem = await _newsRepository.getNewsById(widget.newsId);
//   //     setState(() {
//   //       _newsItem = newsItem;
//   //       _isLoading = false;
//   //     });
//   //   } catch (e) {
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('Error loading news: ${e.toString()}')),
//   //       );
//   //     }
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return
//     // BlocProvider(
//     //   create: (context) => NewsBloc(newsRepository: _newsRepository),
//     //   child: Scaffold(
//     //     appBar: AppBar(title: const Text('News Details')),
//     //     body: _isLoading
//     //         ? const Center(child: CircularProgressIndicator())
//     //         : _newsItem == null
//     //         ? const Center(child: Text('News item not found'))
//     //         : _buildNewsDetails(context),
//     //   ),
//     // );
//   }

//   Widget _buildNewsDetails(BuildContext context) {
//     return BlocListener<NewsBloc, NewsState>(
//       listener: (context, state) {
//         if (state is NewsStatusUpdated) {
//           _loadNewsItem();
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('News status updated successfully')),
//           );
//         } else if (state is NewsStatusUpdatedViaApi) {
//           _loadNewsItem();
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text(state.message)));
//         } else if (state is NewsError) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
//         }
//       },
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             _newsItem!.title,
//                             style: const TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         StatusBadge(status: _newsItem!.status),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Category: ${_newsItem!.category}',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     Text('Submitted by: ${_newsItem!.submittedBy}'),
//                     Text(
//                       'Submitted on: ${_formatDate(_newsItem!.submittedDate)}',
//                     ),
//                     if (_newsItem!.status == ApprovalStatus.approved &&
//                         _newsItem!.approvedDate != null)
//                       Text(
//                         'Approved on: ${_formatDate(_newsItem!.approvedDate!)}',
//                       ),
//                     if (_newsItem!.status == ApprovalStatus.rejected &&
//                         _newsItem!.rejectionReason != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Text(
//                           'Rejection reason: ${_newsItem!.rejectionReason}',
//                           style: const TextStyle(
//                             color: Color(0xFFD32F2F),
//                           ), // Dark red
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (_newsItem!.imageUrls.isNotEmpty ||
//                 _newsItem!.imageUrl.isNotEmpty)
//               Card(
//                 elevation: 4,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Text(
//                         'News Images',
//                         style: Theme.of(context).textTheme.titleLarge,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 200,
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children:
//                               (_newsItem!.imageUrls.isNotEmpty
//                                       ? _newsItem!.imageUrls
//                                       : [_newsItem!.imageUrl])
//                                   .where((u) => u.isNotEmpty)
//                                   .map(
//                                     (u) => Container(
//                                       margin: const EdgeInsets.only(
//                                         left: 12,
//                                         right: 12,
//                                       ),
//                                       width: 300,
//                                       height: 200,
//                                       color: AppColors.grey.withOpacity(0.1),
//                                       child: Image.network(
//                                         u,
//                                         height: 200,
//                                         width: 300,
//                                         fit: BoxFit.cover,
//                                         errorBuilder:
//                                             (context, error, stackTrace) {
//                                               return Container(
//                                                 height: 200,
//                                                 width: 300,
//                                                 color: AppColors.grey
//                                                     .withOpacity(0.3),
//                                                 child: const Center(
//                                                   child: Text(
//                                                     'Image not available',
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                       ),
//                                     ),
//                                   )
//                                   .toList(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             const SizedBox(height: 16),
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Content',
//                       style: Theme.of(context).textTheme.titleLarge,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(_newsItem!.content),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             if (_newsItem!.status == ApprovalStatus.pending)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: () => _showApproveDialog(context),
//                     icon: const Icon(Icons.check),
//                     label: const Text('Approve'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.secondary,
//                       foregroundColor: AppColors.white,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   ElevatedButton.icon(
//                     onPressed: () => _showRejectDialog(context),
//                     icon: const Icon(Icons.close),
//                     label: const Text('Reject'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFF44336), // Red
//                       foregroundColor: AppColors.white,
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showApproveDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Approve News'),
//         content: Text(
//           'Are you sure you want to approve "${_newsItem!.title}"?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               // context.read<NewsBloc>().add(
//               //       UpdateNewsStatusViaApi(
//               //         newsId: _newsItem!.id,
//               //         status: 'Approved',
//               //       ),
//               //     );
//               // Navigator.pop(context);
//               context.read<NewsProvider>().updateNewsStatus(
//                 widget.newsId,
//                 ApprovalStatus.approved,
//               );
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('News approved successfully')),
//               );
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: const Text('Approve'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showRejectDialog(BuildContext context) {
//     final reasonController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Reject News'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Are you sure you want to reject "${_newsItem!.title}"?'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: reasonController,
//               decoration: const InputDecoration(
//                 labelText: 'Reason for rejection',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               if (reasonController.text.trim().isEmpty) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Please provide a reason for rejection'),
//                   ),
//                 );
//                 return;
//               }
//               // context.read<NewsBloc>().add(
//               //   UpdateNewsStatusViaApi(
//               //     newsId: _newsItem!.id,
//               //     status: 'Rejected',
//               //   ),
//               // );
//               // Navigator.pop(context);
//               context.read<NewsProvider>().updateNewsStatus(
//                 widget.newsId,
//                 ApprovalStatus.rejected,
//                 rejectionReason: reasonController.text.trim(),
//               );
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(const SnackBar(content: Text('News rejected')));
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: const Text('Reject'),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
