import 'package:equatable/equatable.dart';
import '../../../core/models/approval_status.dart';

abstract class MatrimonyEvent extends Equatable {
  const MatrimonyEvent();

  @override
  List<Object?> get props => [];
}

class LoadMatrimonyProfiles extends MatrimonyEvent {
  final ApprovalStatus? filterStatus;

  const LoadMatrimonyProfiles({this.filterStatus});

  @override
  List<Object?> get props => [filterStatus];
}

class UpdateMatrimonyProfileStatus extends MatrimonyEvent {
  final String profileId;
  final ApprovalStatus newStatus;
  final String? rejectionReason;

  const UpdateMatrimonyProfileStatus({
    required this.profileId,
    required this.newStatus,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [profileId, newStatus, rejectionReason];
}

class AddSampleMatrimonyProfiles extends MatrimonyEvent {}