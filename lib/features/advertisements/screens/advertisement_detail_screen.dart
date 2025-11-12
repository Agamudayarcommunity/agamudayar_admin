import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/approval_status.dart';
import '../../../widgets/status_badge.dart';
import '../bloc/advertisement_bloc.dart';
import '../bloc/advertisement_event.dart';
import '../models/advertisement_model.dart';
import '../repositories/advertisement_repository.dart';

class AdvertisementDetailScreen extends StatefulWidget {
  final String advertisementId;

  const AdvertisementDetailScreen({super.key, required this.advertisementId});

  @override
  State<AdvertisementDetailScreen> createState() => _AdvertisementDetailScreenState();
}

class _AdvertisementDetailScreenState extends State<AdvertisementDetailScreen> {
  late Future<AdvertisementModel?> _advertisementFuture;
  final AdvertisementRepository _repository = AdvertisementRepository();

  @override
  void initState() {
    super.initState();
    _loadAdvertisement();
  }

  void _loadAdvertisement() {
    _advertisementFuture = _repository.getAdvertisementById(widget.advertisementId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advertisement Details'),
      ),
      body: FutureBuilder<AdvertisementModel?>(
        future: _advertisementFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Advertisement not found'));
          }

          final advertisement = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(advertisement),
                const SizedBox(height: 24),
                _buildDetailsCard(advertisement),
                const SizedBox(height: 24),
                _buildContactCard(advertisement),
                const SizedBox(height: 24),
                if (advertisement.status == ApprovalStatus.pending.name)
                  _buildActionButtons(context, advertisement),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AdvertisementModel advertisement) {
    return Card(
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
                    advertisement.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                StatusBadge(status: advertisement.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              advertisement.businessName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Category: ${advertisement.category}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(AdvertisementModel advertisement) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advertisement Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildDetailRow('Description', advertisement.description),
            _buildDetailRow('Start Date', _formatDate(advertisement.startDate)),
            _buildDetailRow('End Date', _formatDate(advertisement.endDate)),
            _buildDetailRow('Price', '₹${advertisement.price.toStringAsFixed(2)}'),
            _buildDetailRow('Submitted By', advertisement.submittedBy),
            _buildDetailRow('Submitted Date', _formatDate(advertisement.submittedDate)),
            if (advertisement.status == ApprovalStatus.approved)
              _buildDetailRow('Approved Date', _formatDate(advertisement.approvedDate!)),
            if (advertisement.status == ApprovalStatus.rejected) ...[              
              _buildDetailRow('Rejection Reason', advertisement.rejectionReason ?? 'Not provided'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(AdvertisementModel advertisement) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildDetailRow('Contact Person', advertisement.contactPerson),
            _buildDetailRow('Email', advertisement.contactEmail),
            _buildDetailRow('Phone', advertisement.contactPhone),
            _buildDetailRow('Address', advertisement.businessAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AdvertisementModel advertisement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Approve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.white,
          ),
          onPressed: () => _showApproveDialog(context, advertisement),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.close),
          label: const Text('Reject'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF44336), // Red
            foregroundColor: AppColors.white,
          ),
          onPressed: () => _showRejectDialog(context, advertisement),
        ),
      ],
    );
  }

  void _showApproveDialog(BuildContext context, AdvertisementModel advertisement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Advertisement'),
        content: Text('Are you sure you want to approve "${advertisement.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdvertisementBloc>().add(
                    UpdateAdvertisementStatus(
                      advertisementId: advertisement.id,
                      newStatus: ApprovalStatus.approved,
                    ),
                  );
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Advertisement approved successfully')),
              );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AdvertisementModel advertisement) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Advertisement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${advertisement.title}"?'),
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
              context.read<AdvertisementBloc>().add(
                    UpdateAdvertisementStatus(
                      advertisementId: advertisement.id,
                      newStatus: ApprovalStatus.rejected,
                      rejectionReason: reasonController.text.trim(),
                    ),
                  );
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Advertisement rejected')),
              );
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