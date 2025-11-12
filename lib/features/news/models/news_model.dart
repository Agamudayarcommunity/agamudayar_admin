import '../../../core/models/approval_status.dart';

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final List<String> imageUrls;
  final String category;
  final String submittedBy;
  final DateTime submittedDate;
  final ApprovalStatus status;
  final String? rejectionReason;
  final DateTime? approvedDate;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.imageUrls,
    required this.category,
    required this.submittedBy,
    required this.submittedDate,
    required this.status,
    this.rejectionReason,
    this.approvedDate,
  });

  // Firebase methods removed - using mock data instead

  NewsModel copyWith({
    String? id,
    String? title,
    String? content,
    String? imageUrl,
    List<String>? imageUrls,
    String? category,
    String? submittedBy,
    DateTime? submittedDate,
    ApprovalStatus? status,
    String? rejectionReason,
    DateTime? approvedDate,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedDate: submittedDate ?? this.submittedDate,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedDate: approvedDate ?? this.approvedDate,
    );
  }

  static ApprovalStatus _statusFromString(String status) {
    switch (status) {
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      case 'pending':
      default:
        return ApprovalStatus.pending;
    }
  }

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    final dynamic imgs = map['imageUrls'];
    final List<String> parsedImages = imgs is List
        ? imgs.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList()
        : (map['imageUrl'] != null && (map['imageUrl'] as String).isNotEmpty)
            ? [map['imageUrl']]
            : <String>[];
    return NewsModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      imageUrls: parsedImages,
      category: map['category'] ?? '',
      submittedBy: map['submittedBy'] ?? '',
      submittedDate: map['submittedDate'] is DateTime 
          ? map['submittedDate'] 
          : DateTime.now(),
      status: _statusFromString(map['status'] ?? 'pending'),
      rejectionReason: map['rejectionReason'],
      approvedDate: map['approvedDate'],
    );
  }
}