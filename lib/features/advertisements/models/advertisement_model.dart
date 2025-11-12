import '../../../core/models/approval_status.dart';

class AdvertisementModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String businessName;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;
  final String businessAddress;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String submittedBy;
  final DateTime submittedDate;
  final ApprovalStatus status;
  final String? rejectionReason;
  final DateTime? approvedDate;

  AdvertisementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.businessName,
    required this.contactPerson,
    required this.contactEmail,
    required this.contactPhone,
    required this.businessAddress,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.submittedBy,
    required this.submittedDate,
    required this.status,
    this.rejectionReason,
    this.approvedDate,
  });

  // Firebase methods removed - using mock data instead

  AdvertisementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? businessName,
    String? contactPerson,
    String? contactEmail,
    String? contactPhone,
    String? businessAddress,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    double? price,
    String? submittedBy,
    DateTime? submittedDate,
    ApprovalStatus? status,
    String? rejectionReason,
    DateTime? approvedDate,
  }) {
    return AdvertisementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      businessName: businessName ?? this.businessName,
      contactPerson: contactPerson ?? this.contactPerson,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      businessAddress: businessAddress ?? this.businessAddress,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      price: price ?? this.price,
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
}