import 'package:equatable/equatable.dart';
import '../../../core/models/approval_status.dart';

abstract class AdvertisementEvent extends Equatable {
  const AdvertisementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdvertisements extends AdvertisementEvent {
  final ApprovalStatus? filterStatus;

  const LoadAdvertisements({this.filterStatus});

  @override
  List<Object?> get props => [filterStatus];
}

class UpdateAdvertisementStatus extends AdvertisementEvent {
  final String advertisementId;
  final ApprovalStatus newStatus;
  final String? rejectionReason;

  const UpdateAdvertisementStatus({
    required this.advertisementId,
    required this.newStatus,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [advertisementId, newStatus, rejectionReason];
}

class AddSampleAdvertisements extends AdvertisementEvent {}