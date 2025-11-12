import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../core/models/approval_status.dart';
import '../../../widgets/status_badge.dart';
import '../bloc/matrimony_bloc.dart';
import '../bloc/matrimony_event.dart';
import '../models/matrimony_profile_model.dart';
import '../repositories/matrimony_repository.dart';

class MatrimonyDetailScreen extends StatefulWidget {
  final String profileId;

  const MatrimonyDetailScreen({super.key, required this.profileId});

  @override
  State<MatrimonyDetailScreen> createState() => _MatrimonyDetailScreenState();
}

class _MatrimonyDetailScreenState extends State<MatrimonyDetailScreen> {
  late Future<MatrimonyProfile?> _profileFuture;
  final MatrimonyRepository _repository = MatrimonyRepository();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = _repository.getProfileById(widget.profileId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matrimony Profile Details'),
      ),
      body: FutureBuilder<MatrimonyProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Profile not found'));
          }

          final profile = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(profile),
                const SizedBox(height: 24),
                _buildPersonalDetailsCard(profile),
                const SizedBox(height: 24),
                _buildFamilyDetailsCard(profile),
                const SizedBox(height: 24),
                _buildContactCard(profile),
                const SizedBox(height: 24),
                if (profile.status == ApprovalStatus.pending)
                   _buildActionButtons(context, profile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(MatrimonyProfile profile) {
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
                    profile.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                StatusBadge(status: profile.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${profile.gender}, ${_calculateAge(profile.dateOfBirth)} years',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              profile.occupation,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsCard(MatrimonyProfile profile) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildDetailRow('Date of Birth', _formatDate(profile.dateOfBirth)),
            _buildDetailRow('Height', '${profile.height.toStringAsFixed(1)} cm'),
            _buildDetailRow('Education', profile.education),
            _buildDetailRow('Occupation', profile.occupation),
            _buildDetailRow('Marital Status', profile.maritalStatus),
            _buildDetailRow('Mother Tongue', profile.motherTongue),
            _buildDetailRow('Religion', profile.religion),
            _buildDetailRow('Caste', profile.caste),
            if (profile.subCaste != null && profile.subCaste!.isNotEmpty)
              _buildDetailRow('Sub Caste', profile.subCaste!),
            if (profile.gothram != null && profile.gothram!.isNotEmpty)
              _buildDetailRow('Gothram', profile.gothram!),
            _buildDetailRow('Dosham', profile.dosham ? 'Yes' : 'No'),
            _buildDetailRow('About Me', profile.aboutMe),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyDetailsCard(MatrimonyProfile profile) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Family Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildDetailRow('Family Information', profile.familyDetails),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(MatrimonyProfile profile) {
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
            _buildDetailRow('Email', profile.contactEmail),
            _buildDetailRow('Phone', profile.contactPhone),
            _buildDetailRow('Submitted By', profile.submittedBy),
            _buildDetailRow('Submitted Date', _formatDate(profile.submittedDate)),
            if (profile.status == ApprovalStatus.approved && profile.approvedDate != null)
              _buildDetailRow('Approved Date', _formatDate(profile.approvedDate!)),
            if (profile.status == ApprovalStatus.rejected && profile.rejectionReason != null)
              _buildDetailRow('Rejection Reason', profile.rejectionReason!),
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

  Widget _buildActionButtons(BuildContext context, MatrimonyProfile profile) {
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
          onPressed: () => _showApproveDialog(context, profile),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.close),
          label: const Text('Reject'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF44336), // Red
            foregroundColor: AppColors.white,
          ),
          onPressed: () => _showRejectDialog(context, profile),
        ),
      ],
    );
  }

  void _showApproveDialog(BuildContext context, MatrimonyProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Matrimony Profile'),
        content: Text('Are you sure you want to approve "${profile.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<MatrimonyBloc>().add(
                    UpdateMatrimonyProfileStatus(
                      profileId: profile.id,
                      newStatus: ApprovalStatus.approved,
                    ),
                  );
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Matrimony profile approved successfully')),
              );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, MatrimonyProfile profile) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Matrimony Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${profile.name}"?'),
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
              context.read<MatrimonyBloc>().add(
                    UpdateMatrimonyProfileStatus(
                      profileId: profile.id,
                      newStatus: ApprovalStatus.rejected,
                      rejectionReason: reasonController.text.trim(),
                    ),
                  );
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Matrimony profile rejected')),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  int _calculateAge(DateTime birthDate) {
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}