import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/approval_status.dart';
import '../../../widgets/approval_actions.dart';
import '../../../widgets/sidebar.dart';
import '../../../widgets/status_badge.dart';
import '../bloc/job_bloc.dart';
import '../bloc/job_event.dart';
import '../bloc/job_state.dart';
import '../models/job_model.dart';
import '../repositories/job_repository.dart';
import 'job_detail_screen.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JobBloc(
        jobRepository: JobRepository(),
      )..add(const LoadJobs()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jobs Approval'),
          actions: [
            BlocBuilder<JobBloc, JobState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<JobBloc>().add(const LoadJobs());
                  },
                );
              },
            ),
            BlocBuilder<JobBloc, JobState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    context.read<JobBloc>().add(AddSampleJobs());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sample jobs added for demonstration'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        drawer: const Sidebar(currentRoute: '/jobs'),
        body: BlocBuilder<JobBloc, JobState>(
          builder: (context, state) {
            if (state is JobInitial) {
              context.read<JobBloc>().add(const LoadJobs());
              return const Center(child: CircularProgressIndicator());
            } else if (state is JobLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is JobLoaded) {
              return _buildJobsTable(context, state.jobs);
            } else if (state is JobError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildJobsTable(BuildContext context, List<JobModel> jobs) {
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
          child: jobs.isEmpty
              ? const Center(child: Text('No jobs found'))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Company')),
                        DataColumn(label: Text('Location')),
                        DataColumn(label: Text('Posted Date')),
                        DataColumn(label: Text('Expiry Date')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: jobs.map((job) {
                        return DataRow(
                          cells: [
                            DataCell(
                              SizedBox(
                                width: 200,
                                child: Text(
                                  job.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => JobDetailScreen(
                                      jobId: job.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            DataCell(Text(job.company)),
                            DataCell(Text(job.location)),
                            DataCell(Text(_formatDate(job.postedDate))),
                            DataCell(Text(_formatDate(job.expiryDate))),
                            DataCell(StatusBadge(status: job.status)),
                            DataCell(
                              ApprovalActions(
                                status: job.status,
                                onApprove: () => _showApproveDialog(context, job),
                                onReject: () => _showRejectDialog(context, job),
                                onView: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JobDetailScreen(
                                        jobId: job.id,
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
        context.read<JobBloc>().add(LoadJobs(filterStatus: status));
      },
    );
  }

  void _showApproveDialog(BuildContext context, JobModel job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Job'),
        content: Text('Are you sure you want to approve "${job.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<JobBloc>().add(
                    UpdateJobStatus(
                      jobId: job.id,
                      newStatus: ApprovalStatus.approved,
                    ),
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Job approved successfully')),
              );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, JobModel job) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Job'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "${job.title}"?'),
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
              context.read<JobBloc>().add(
                    UpdateJobStatus(
                      jobId: job.id,
                      newStatus: ApprovalStatus.rejected,
                      rejectionReason: reasonController.text.trim(),
                    ),
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Job rejected')),
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