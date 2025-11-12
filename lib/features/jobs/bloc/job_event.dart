import 'package:equatable/equatable.dart';
import '../../../core/models/approval_status.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

class LoadJobs extends JobEvent {
  final ApprovalStatus? filterStatus;

  const LoadJobs({this.filterStatus});

  @override
  List<Object?> get props => [filterStatus];
}

class UpdateJobStatus extends JobEvent {
  final String jobId;
  final ApprovalStatus newStatus;
  final String? rejectionReason;

  const UpdateJobStatus({
    required this.jobId,
    required this.newStatus,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [jobId, newStatus, rejectionReason];
}

class AddSampleJobs extends JobEvent {}