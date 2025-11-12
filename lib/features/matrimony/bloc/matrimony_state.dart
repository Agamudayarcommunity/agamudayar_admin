import 'package:equatable/equatable.dart';
import '../models/matrimony_profile_model.dart';

abstract class MatrimonyState extends Equatable {
  const MatrimonyState();

  @override
  List<Object> get props => [];
}

class MatrimonyInitial extends MatrimonyState {}

class MatrimonyLoading extends MatrimonyState {}

class MatrimonyLoaded extends MatrimonyState {
  final List<MatrimonyProfile> profiles;

  const MatrimonyLoaded({required this.profiles});

  @override
  List<Object> get props => [profiles];
}

class MatrimonyError extends MatrimonyState {
  final String message;

  const MatrimonyError({required this.message});

  @override
  List<Object> get props => [message];
}

class MatrimonyProfileStatusUpdated extends MatrimonyState {
  final String profileId;
  final String newStatus;

  const MatrimonyProfileStatusUpdated({
    required this.profileId,
    required this.newStatus,
  });

  @override
  List<Object> get props => [profileId, newStatus];
}