import '../../../core/models/approval_status.dart';
import '../models/matrimony_profile_model.dart';

class MatrimonyRepository {
  // Mock data for demonstration
  final List<MatrimonyProfile> _mockProfiles = [
    MatrimonyProfile(
      id: '1',
      name: 'Priya Sharma',
      dateOfBirth: DateTime.now().subtract(const Duration(days: 25 * 365)),
      gender: 'Female',
      religion: 'Hindu',
      caste: 'Agamudayar',
      subCaste: 'Thuluva Vellalar',
      education: 'B.Tech Computer Science',
      occupation: 'Software Engineer',
      height: 164.0,
      maritalStatus: 'Never Married',
      motherTongue: 'Tamil',
      dosham: false,
      aboutMe: 'Looking for a well-educated partner',
      familyDetails: 'Nuclear family, middle class background',
      contactEmail: 'priya@example.com',
      contactPhone: '+91 9876543210',
      submittedBy: 'Priya Sharma',
      status: ApprovalStatus.pending,
      submittedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MatrimonyProfile(
      id: '2',
      name: 'Arjun Kumar',
      dateOfBirth: DateTime.now().subtract(const Duration(days: 28 * 365)),
      gender: 'Male',
      religion: 'Hindu',
      caste: 'Agamudayar',
      subCaste: 'Thuluva Vellalar',
      education: 'MBA Finance',
      occupation: 'Business Analyst',
      height: 172.0,
      maritalStatus: 'Never Married',
      motherTongue: 'Tamil',
      dosham: false,
      aboutMe: 'Seeking a caring and understanding life partner',
      familyDetails: 'Joint family, upper middle class background',
      contactEmail: 'arjun@example.com',
      contactPhone: '+91 9876543211',
      submittedBy: 'Arjun Kumar',
      status: ApprovalStatus.approved,
      submittedDate: DateTime.now().subtract(const Duration(days: 2)),
      approvedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<MatrimonyProfile>> getAllProfiles() async {
    return _mockProfiles;
  }

  Future<List<MatrimonyProfile>> getProfilesByStatus(ApprovalStatus status) async {
    return _mockProfiles.where((profile) => profile.status == status).toList();
  }

  Future<MatrimonyProfile?> getProfileById(String id) async {
    try {
      return _mockProfiles.firstWhere((profile) => profile.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfileStatus({
    required String profileId,
    required ApprovalStatus newStatus,
    String? rejectionReason,
  }) async {
    final index = _mockProfiles.indexWhere((profile) => profile.id == profileId);
    if (index != -1) {
      _mockProfiles[index] = _mockProfiles[index].copyWith(
        status: newStatus,
        approvedDate: newStatus == ApprovalStatus.approved ? DateTime.now() : null,
        rejectionReason: newStatus == ApprovalStatus.rejected ? rejectionReason : null,
      );
    }
  }

  Future<void> addSampleProfiles() async {
    // Mock implementation - profiles are already added in _mockProfiles
    return;
  }

  List<MatrimonyProfile> _generateSampleProfiles() {
    final now = DateTime.now();
    return [
      MatrimonyProfile(
        id: 'sample1',
        name: 'Rajesh Kumar',
        gender: 'Male',
        dateOfBirth: DateTime(1990, 5, 15),
        height: 175.0,
        education: 'B.Tech in Computer Science',
        occupation: 'Software Engineer',
        maritalStatus: 'Never Married',
        motherTongue: 'Tamil',
        religion: 'Hindu',
        caste: 'Agamudayar',
        subCaste: null,
        gothram: 'Kashyapa',
        dosham: false,
        aboutMe: 'I am a software engineer working in a multinational company. I enjoy reading books and traveling.',
        familyDetails: 'Father is a retired government employee. Mother is a homemaker. One younger sister who is married.',
        contactEmail: 'rajesh.kumar@example.com',
        contactPhone: '+91 9876543210',
        submittedBy: 'Self',
        submittedDate: now.subtract(const Duration(days: 5)),
        status: ApprovalStatus.pending,
      ),
      MatrimonyProfile(
        id: 'sample2',
        name: 'Priya Lakshmi',
        gender: 'Female',
        dateOfBirth: DateTime(1992, 8, 23),
        height: 162.0,
        education: 'M.Sc in Mathematics',
        occupation: 'Teacher',
        maritalStatus: 'Never Married',
        motherTongue: 'Tamil',
        religion: 'Hindu',
        caste: 'Agamudayar',
        subCaste: null,
        gothram: 'Bharadwaja',
        dosham: false,
        aboutMe: 'I am a mathematics teacher in a private school. I love teaching and have a passion for classical dance.',
        familyDetails: 'Father is a businessman. Mother is a homemaker. One elder brother who is married and settled in Chennai.',
        contactEmail: 'priya.lakshmi@example.com',
        contactPhone: '+91 9876543211',
        submittedBy: 'Parent',
        submittedDate: now.subtract(const Duration(days: 10)),
        status: ApprovalStatus.pending,
      ),
      MatrimonyProfile(
        id: 'sample3',
        name: 'Karthik Rajan',
        gender: 'Male',
        dateOfBirth: DateTime(1988, 12, 7),
        height: 180.0,
        education: 'MBA in Finance',
        occupation: 'Bank Manager',
        maritalStatus: 'Divorced',
        motherTongue: 'Tamil',
        religion: 'Hindu',
        caste: 'Agamudayar',
        subCaste: null,
        gothram: 'Atri',
        dosham: true,
        aboutMe: 'I am a bank manager with 8 years of experience. I enjoy playing cricket and watching movies.',
        familyDetails: 'Father is a retired army officer. Mother is a retired teacher. One younger brother who is working in IT sector.',
        contactEmail: 'karthik.rajan@example.com',
        contactPhone: '+91 9876543212',
        submittedBy: 'Self',
        submittedDate: now.subtract(const Duration(days: 15)),
        status: ApprovalStatus.approved,
        approvedDate: now.subtract(const Duration(days: 10)),
      ),
      MatrimonyProfile(
        id: 'sample4',
        name: 'Divya Shankar',
        gender: 'Female',
        dateOfBirth: DateTime(1991, 3, 18),
        height: 165.0,
        education: 'MBBS, MD',
        occupation: 'Doctor',
        maritalStatus: 'Never Married',
        motherTongue: 'Tamil',
        religion: 'Hindu',
        caste: 'Agamudayar',
        subCaste: null,
        gothram: 'Vasishtha',
        dosham: false,
        aboutMe: 'I am a pediatrician working in a government hospital. I love children and enjoy painting in my free time.',
        familyDetails: 'Father is a doctor. Mother is a homemaker. One elder sister who is married and settled in Bangalore.',
        contactEmail: 'divya.shankar@example.com',
        contactPhone: '+91 9876543213',
        submittedBy: 'Parent',
        submittedDate: now.subtract(const Duration(days: 20)),
        status: ApprovalStatus.rejected,
        rejectionReason: 'Incomplete information provided. Please update the profile with more details about family background.',
      ),
      MatrimonyProfile(
        id: 'sample5',
        name: 'Suresh Venkat',
        gender: 'Male',
        dateOfBirth: DateTime(1989, 7, 30),
        height: 178.0,
        education: 'B.E in Mechanical Engineering',
        occupation: 'Project Manager',
        maritalStatus: 'Never Married',
        motherTongue: 'Tamil',
        religion: 'Hindu',
        caste: 'Agamudayar',
        subCaste: null,
        gothram: 'Gautama',
        dosham: false,
        aboutMe: 'I am a project manager in an automobile company. I enjoy traveling and photography.',
        familyDetails: 'Father is a businessman. Mother is a homemaker. Two younger sisters, one married and one studying.',
        contactEmail: 'suresh.venkat@example.com',
        contactPhone: '+91 9876543214',
        submittedBy: 'Self',
        submittedDate: now.subtract(const Duration(days: 25)),
        status: ApprovalStatus.pending,
      ),
    ];
  }
}