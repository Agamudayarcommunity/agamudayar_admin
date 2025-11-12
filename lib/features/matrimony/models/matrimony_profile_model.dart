import '../../../core/models/approval_status.dart';

class MatrimonyProfile {
  final String id;
  final String name;
  final String gender;
  final DateTime dateOfBirth;
  final double height; // in cm
  final String education;
  final String occupation;
  final String maritalStatus;
  final String motherTongue;
  final String religion;
  final String caste;
  final String? subCaste;
  final String? gothram;
  final bool dosham;
  final String aboutMe;
  final String familyDetails;
  final String contactEmail;
  final String contactPhone;
  final String submittedBy;
  final DateTime submittedDate;
  final ApprovalStatus status;
  final String? rejectionReason;
  final DateTime? approvedDate;

  MatrimonyProfile({
    required this.id,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.height,
    required this.education,
    required this.occupation,
    required this.maritalStatus,
    required this.motherTongue,
    required this.religion,
    required this.caste,
    this.subCaste,
    this.gothram,
    required this.dosham,
    required this.aboutMe,
    required this.familyDetails,
    required this.contactEmail,
    required this.contactPhone,
    required this.submittedBy,
    required this.submittedDate,
    required this.status,
    this.rejectionReason,
    this.approvedDate,
  });

  // Firebase methods removed - using mock data instead

  MatrimonyProfile copyWith({
    String? id,
    String? name,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
    String? education,
    String? occupation,
    String? maritalStatus,
    String? motherTongue,
    String? religion,
    String? caste,
    String? subCaste,
    String? gothram,
    bool? dosham,
    String? aboutMe,
    String? familyDetails,
    String? contactEmail,
    String? contactPhone,
    String? submittedBy,
    DateTime? submittedDate,
    ApprovalStatus? status,
    String? rejectionReason,
    DateTime? approvedDate,
  }) {
    return MatrimonyProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      motherTongue: motherTongue ?? this.motherTongue,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      subCaste: subCaste ?? this.subCaste,
      gothram: gothram ?? this.gothram,
      dosham: dosham ?? this.dosham,
      aboutMe: aboutMe ?? this.aboutMe,
      familyDetails: familyDetails ?? this.familyDetails,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedDate: submittedDate ?? this.submittedDate,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedDate: approvedDate ?? this.approvedDate,
    );
  }
}