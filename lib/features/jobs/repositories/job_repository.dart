import '../models/job_model.dart';
import '../../../core/models/approval_status.dart';

class JobRepository {
  // Mock data for demonstration
  final List<JobModel> _mockJobs = [
    JobModel(
      id: '1',
      title: 'Software Developer',
      company: 'Tech Corp',
      location: 'Chennai',
      description: 'Looking for a skilled software developer.',
      requirements: 'Flutter, Dart, Firebase',
      salary: '₹5,00,000 - ₹8,00,000',
      status: ApprovalStatus.pending,
      postedDate: DateTime.now().subtract(const Duration(days: 1)),
      contactEmail: 'hr@techcorp.com',
      contactPhone: '+91 9876543210',
      postedBy: 'Admin',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
    ),
    JobModel(
      id: '2',
      title: 'Marketing Manager',
      company: 'Business Solutions',
      location: 'Mumbai',
      description: 'Experienced marketing manager needed.',
      requirements: 'MBA, 5+ years experience',
      salary: '₹8,00,000 - ₹12,00,000',
      status: ApprovalStatus.approved,
      postedDate: DateTime.now().subtract(const Duration(days: 2)),
      approvedDate: DateTime.now().subtract(const Duration(days: 1)),
      contactEmail: 'careers@business.com',
      contactPhone: '+91 9876543211',
      postedBy: 'Admin',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
    ),
  ];

  // Get all jobs
  Stream<List<JobModel>> getAllJobs() {
    return Stream.value(_mockJobs);
  }

  // Get jobs by status
  Stream<List<JobModel>> getJobsByStatus(ApprovalStatus status) {
    final filteredJobs = _mockJobs.where((job) => job.status == status.name).toList();
    return Stream.value(filteredJobs);
  }

  // Get a single job
  Future<JobModel?> getJobById(String id) async {
    try {
      return _mockJobs.firstWhere((job) => job.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update job status
  Future<void> updateJobStatus(String id, ApprovalStatus status, {String? rejectionReason}) async {
    final index = _mockJobs.indexWhere((job) => job.id == id);
    if (index != -1) {
      _mockJobs[index] = _mockJobs[index].copyWith(
        status: status,
        approvedDate: status == ApprovalStatus.approved ? DateTime.now() : null,
        rejectionReason: status == ApprovalStatus.rejected ? rejectionReason : null,
      );
    }
  }

  // For demo purposes - add sample jobs
  Future<void> addSampleJobs() async {
    final now = DateTime.now();
    final sampleJobs = [
      JobModel(
        id: 'sample1',
        title: 'Software Developer',
        company: 'Tech Solutions Ltd',
        location: 'Chennai, Tamil Nadu',
        description: 'We are looking for a skilled software developer to join our team...',
        requirements: 'Bachelor\'s degree in Computer Science, 2+ years experience in Flutter development',
        salary: '₹6,00,000 - ₹8,00,000 per annum',
        contactEmail: 'careers@techsolutions.com',
        contactPhone: '+91 9876543210',
        postedBy: 'user123',
        postedDate: now.subtract(const Duration(days: 5)),
        expiryDate: now.add(const Duration(days: 25)),
        status: ApprovalStatus.pending,
      ),
      JobModel(
        id: 'sample2',
        title: 'Marketing Manager',
        company: 'Global Marketing Inc',
        location: 'Coimbatore, Tamil Nadu',
        description: 'We are seeking a dynamic marketing manager to lead our marketing efforts...',
        requirements: 'MBA in Marketing, 5+ years experience in digital marketing',
        salary: '₹8,00,000 - ₹12,00,000 per annum',
        contactEmail: 'hr@globalmarketing.com',
        contactPhone: '+91 9876543211',
        postedBy: 'user456',
        postedDate: now.subtract(const Duration(days: 3)),
        expiryDate: now.add(const Duration(days: 27)),
        status: ApprovalStatus.pending,
      ),
    ];

    // Sample jobs are already in _mockJobs - no need to add them again
    return;
  }
}