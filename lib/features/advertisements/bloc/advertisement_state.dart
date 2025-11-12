import 'package:equatable/equatable.dart';
import '../models/advertisement_model.dart';

abstract class AdvertisementState extends Equatable {
  const AdvertisementState();

  @override
  List<Object?> get props => [];
}

class AdvertisementInitial extends AdvertisementState {}

class AdvertisementLoading extends AdvertisementState {}

class AdvertisementLoaded extends AdvertisementState {
  final List<AdvertisementModel> advertisements;

  const AdvertisementLoaded(this.advertisements);

  @override
  List<Object?> get props => [advertisements];
}

class AdvertisementError extends AdvertisementState {
  final String message;

  const AdvertisementError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdvertisementStatusUpdated extends AdvertisementState {}