import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/models/approval_status.dart';
import '../../../widgets/approval_actions.dart';
import '../../../widgets/sidebar.dart';
import '../../../widgets/status_badge.dart';
import '../bloc/matrimony_bloc.dart';
import '../bloc/matrimony_event.dart';
import '../bloc/matrimony_state.dart';
import '../models/matrimony_profile_model.dart';
import '../repositories/matrimony_repository.dart';
import 'matrimony_detail_screen.dart';

class MatrimonyScreen extends StatelessWidget {
  const MatrimonyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MatrimonyBloc(
        matrimonyRepository: MatrimonyRepository(),
      )..add(const LoadMatrimonyProfiles()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Matrimony Profiles Approval'),
          actions: [
            BlocBuilder<MatrimonyBloc, MatrimonyState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<MatrimonyBloc>().add(const LoadMatrimonyProfiles());
                  },
                );
              },
            ),
            BlocBuilder<MatrimonyBloc, MatrimonyState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    context.read<MatrimonyBloc>().add(AddSampleMatrimonyProfiles());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sample matrimony profiles added for demonstration'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        drawer: const Sidebar(currentRoute: '/matrimony'),
        body: BlocBuilder<MatrimonyBloc, MatrimonyState>(
          builder: (context, state) {
            if (state is MatrimonyInitial) {
              context.read<MatrimonyBloc>().add(const LoadMatrimonyProfiles());
              return const Center(child: CircularProgressIndicator());
            } else if (state is MatrimonyLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MatrimonyLoaded) {
              return _buildMatrimonyProfilesTable(context, state.profiles);
            } else if (state is MatrimonyError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildMatrimonyProfilesTable(BuildContext context, List<MatrimonyProfile> profiles) {
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
          child: profiles.isEmpty
              ? const Center(child: Text('No matrimony profiles found'))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Gender')),
                        DataColumn(label: Text('Date of Birth')),
                        DataColumn(label: Text('Occupation')),
                        DataColumn(label: Text('Submitted Date')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: profiles.map((profile) {
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  profile.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MatrimonyDetailScreen(
                                      profileId: profile.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            DataCell(Text(profile.gender)),
                            DataCell(Text(_formatDate(profile.dateOfBirth))),
                            DataCell(Text(profile.occupation)),
                            DataCell(Text(_formatDate(profile.submittedDate))),
                            DataCell(StatusBadge(status: profile.status)),
                            DataCell(
                              ApprovalActions(
                                status: profile.status,
                                onApprove: () => _showApproveDialog(context, profile),
                                onReject: () => _showRejectDialog(context, profile),
                                onView: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MatrimonyDetailScreen(
                                        profileId: profile.id,
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
        context.read<MatrimonyBloc>().add(LoadMatrimonyProfiles(filterStatus: status));
      },
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
}