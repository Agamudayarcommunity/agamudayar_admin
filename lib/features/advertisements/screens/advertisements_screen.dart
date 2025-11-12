import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/approval_status.dart';
import '../../../widgets/approval_actions.dart';
import '../../../widgets/sidebar.dart';
import '../../../widgets/status_badge.dart';
import '../bloc/advertisement_bloc.dart';
import '../bloc/advertisement_event.dart';
import '../bloc/advertisement_state.dart';
import '../models/advertisement_model.dart';
import '../repositories/advertisement_repository.dart';
import 'advertisement_detail_screen.dart';

class AdvertisementsScreen extends StatelessWidget {
  const AdvertisementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdvertisementBloc(
        advertisementRepository: AdvertisementRepository(),
      )..add(const LoadAdvertisements()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Advertisements Approval'),
          actions: [
            BlocBuilder<AdvertisementBloc, AdvertisementState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<AdvertisementBloc>().add(const LoadAdvertisements());
                  },
                );
              },
            ),
            BlocBuilder<AdvertisementBloc, AdvertisementState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    context.read<AdvertisementBloc>().add(AddSampleAdvertisements());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sample advertisements added for demonstration'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        drawer: const Sidebar(currentRoute: '/advertisements'),
        body: BlocBuilder<AdvertisementBloc, AdvertisementState>(
          builder: (context, state) {
            if (state is AdvertisementInitial) {
              context.read<AdvertisementBloc>().add(const LoadAdvertisements());
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdvertisementLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdvertisementLoaded) {
              return _buildAdvertisementsTable(context, state.advertisements);
            } else if (state is AdvertisementError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildAdvertisementsTable(BuildContext context, List<AdvertisementModel> advertisements) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildFilterChip(
                context,
                'All',
                null,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Pending',
                ApprovalStatus.pending,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Approved',
                ApprovalStatus.approved,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Rejected',
                ApprovalStatus.rejected,
              ),
            ],
          ),
        ),
        Expanded(
          child: advertisements.isEmpty
              ? const Center(child: Text('No advertisements found'))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Business')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Start Date')),
                        DataColumn(label: Text('End Date')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: advertisements.map((ad) {
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 200,
                                child: Text(
                                  ad.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdvertisementDetailScreen(
                                      advertisementId: ad.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            DataCell(Text(ad.businessName)),
                            DataCell(Text(ad.category)),
                            DataCell(Text(_formatDate(ad.startDate))),
                            DataCell(Text(_formatDate(ad.endDate))),
                            DataCell(Text('₹${ad.price.toStringAsFixed(2)}')),
                            DataCell(StatusBadge(status: ad.status)),
                            DataCell(
                              ApprovalActions(
                                status: ad.status,
                                onApprove: () => _showApproveDialog(context, ad),
                                onReject: () => _showRejectDialog(context, ad),
                                onView: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdvertisementDetailScreen(
                                        advertisementId: ad.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, ApprovalStatus? status) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {
        context.read<AdvertisementBloc>().add(LoadAdvertisements(filterStatus: status));
      },
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