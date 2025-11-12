import '../models/advertisement_model.dart';
import '../../../core/models/approval_status.dart';

class AdvertisementRepository {
  // Default constructor
  AdvertisementRepository();

  // Mock data for demonstration
  final List<AdvertisementModel> _mockAdvertisements = [
    AdvertisementModel(
      id: '1',
      title: 'Local Business Promotion',
      description: 'Promote your local business with us.',
      imageUrl: 'https://via.placeholder.com/300x200',
      businessName: 'ABC Store',
      contactPerson: 'John Doe',
      contactEmail: 'john@abcstore.com',
      contactPhone: '+91 9876543210',
      businessAddress: '123 Main Street, Chennai',
      category: 'Business',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      price: 5000.0,
      submittedBy: 'John Doe',
      submittedDate: DateTime.now().subtract(const Duration(days: 1)),
      status: ApprovalStatus.pending,
    ),
    AdvertisementModel(
      id: '2',
      title: 'Community Event',
      description: 'Join our community celebration event.',
      imageUrl: 'https://via.placeholder.com/300x200',
      businessName: 'Community Center',
      contactPerson: 'Jane Smith',
      contactEmail: 'jane@community.org',
      contactPhone: '+91 9876543211',
      businessAddress: '456 Community Road, Mumbai',
      category: 'Event',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 15)),
      price: 2500.0,
      submittedBy: 'Jane Smith',
      submittedDate: DateTime.now().subtract(const Duration(days: 2)),
      status: ApprovalStatus.approved,
      approvedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Get all advertisements
  Stream<List<AdvertisementModel>> getAllAdvertisements() {
    return Stream.value(_mockAdvertisements);
  }

  // Get advertisements by status
  Stream<List<AdvertisementModel>> getAdvertisementsByStatus(ApprovalStatus status) {
    final filteredAds = _mockAdvertisements.where((ad) => ad.status == status).toList();
    return Stream.value(filteredAds);
  }

  // Get a single advertisement
  Future<AdvertisementModel?> getAdvertisementById(String id) async {
    try {
      return _mockAdvertisements.firstWhere((ad) => ad.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update advertisement status
  Future<void> updateAdvertisementStatus(String id, ApprovalStatus status,
      {String? rejectionReason}) async {
    final index = _mockAdvertisements.indexWhere((ad) => ad.id == id);
    if (index != -1) {
      _mockAdvertisements[index] = _mockAdvertisements[index].copyWith(
        status: status,
        approvedDate: status == ApprovalStatus.approved ? DateTime.now() : null,
        rejectionReason: status == ApprovalStatus.rejected ? rejectionReason : null,
      );
    }
  }

  // For demo purposes - add sample advertisements
  Future<void> addSampleAdvertisements() async {
    final now = DateTime.now();
    final sampleAds = [
      AdvertisementModel(
        id: 'sample1',
        title: 'Grand Opening Sale',
        description: 'Join us for our grand opening sale with discounts up to 50% off...',
        imageUrl: 'https://example.com/ad1.jpg',
        businessName: 'Fashion Boutique',
        contactPerson: 'Priya Sharma',
        contactEmail: 'priya@fashionboutique.com',
        contactPhone: '+91 9876543210',
        businessAddress: '123 Fashion Street, Chennai, Tamil Nadu',
        category: 'Retail',
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 15)),
        price: 5000.0,
        submittedBy: 'user123',
        submittedDate: now.subtract(const Duration(days: 3)),
        status: ApprovalStatus.pending,
      ),
      AdvertisementModel(
        id: 'sample2',
        title: 'Wedding Photography Services',
        description: 'Professional wedding photography services at affordable prices...',
        imageUrl: 'https://example.com/ad2.jpg',
        businessName: 'Capture Moments Photography',
        contactPerson: 'Rajesh Kumar',
        contactEmail: 'rajesh@capturemoments.com',
        contactPhone: '+91 9876543211',
        businessAddress: '456 Photography Lane, Coimbatore, Tamil Nadu',
        category: 'Services',
        startDate: now.add(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 32)),
        price: 7500.0,
        submittedBy: 'user456',
        submittedDate: now.subtract(const Duration(days: 2)),
        status: ApprovalStatus.pending,
      ),
    ];

    // Add sample advertisements to mock data
    _mockAdvertisements.addAll(sampleAds);
  }
}