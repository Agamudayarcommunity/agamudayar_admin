import '../../../core/models/approval_status.dart';

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final String requirements;
  final String salary;
  final String contactEmail;
  final String contactPhone;
  final String postedBy;
  final DateTime postedDate;
  final DateTime expiryDate;
  final ApprovalStatus status;
  final String? rejectionReason;
  final DateTime? approvedDate;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.requirements,
    required this.salary,
    required this.contactEmail,
    required this.contactPhone,
    required this.postedBy,
    required this.postedDate,
    required this.expiryDate,
    required this.status,
    this.rejectionReason,
    this.approvedDate,
  });

  // Firebase methods removed - using mock data instead

  JobModel copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? description,
    String? requirements,
    String? salary,
    String? contactEmail,
    String? contactPhone,
    String? postedBy,
    DateTime? postedDate,
    DateTime? expiryDate,
    ApprovalStatus? status,
    String? rejectionReason,
    DateTime? approvedDate,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      salary: salary ?? this.salary,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      postedBy: postedBy ?? this.postedBy,
      postedDate: postedDate ?? this.postedDate,
      expiryDate: expiryDate ?? this.expiryDate,
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