import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/advertisement_repository.dart';
import 'advertisement_event.dart';
import 'advertisement_state.dart';

class AdvertisementBloc extends Bloc<AdvertisementEvent, AdvertisementState> {
  final AdvertisementRepository _advertisementRepository;
  StreamSubscription? _advertisementSubscription;

  AdvertisementBloc({required AdvertisementRepository advertisementRepository})
      : _advertisementRepository = advertisementRepository,
        super(AdvertisementInitial()) {
    on<LoadAdvertisements>(_onLoadAdvertisements);
    on<UpdateAdvertisementStatus>(_onUpdateAdvertisementStatus);
    on<AddSampleAdvertisements>(_onAddSampleAdvertisements);
  }

  Future<void> _onLoadAdvertisements(LoadAdvertisements event, Emitter<AdvertisementState> emit) async {
    emit(AdvertisementLoading());
    try {
      await _advertisementSubscription?.cancel();
      
      final stream = event.filterStatus != null
          ? _advertisementRepository.getAdvertisementsByStatus(event.filterStatus!)
          : _advertisementRepository.getAllAdvertisements();
      
      _advertisementSubscription = stream.listen(
        (advertisements) => add(LoadAdvertisements(filterStatus: event.filterStatus)),
        onError: (error) => emit(AdvertisementError(error.toString())),
      );
      
      final advertisements = await stream.first;
      emit(AdvertisementLoaded(advertisements));
    } catch (e) {
      emit(AdvertisementError(e.toString()));
    }
  }

  Future<void> _onUpdateAdvertisementStatus(UpdateAdvertisementStatus event, Emitter<AdvertisementState> emit) async {
    try {
      await _advertisementRepository.updateAdvertisementStatus(
        event.advertisementId,
        event.newStatus,
        rejectionReason: event.rejectionReason,
      );
      emit(AdvertisementStatusUpdated());
      
      // Reload the advertisements list
      if (state is AdvertisementLoaded) {
        final loadedState = state as AdvertisementLoaded;
        final updatedAdvertisements = loadedState.advertisements.map((ad) {
          if (ad.id == event.advertisementId) {
            return ad.copyWith(
              status: event.newStatus,
              rejectionReason: event.rejectionReason,
              approvedDate: event.newStatus.name == 'approved' ? DateTime.now() : null,
            );
          }
          return ad;
        }).toList();
        emit(AdvertisementLoaded(updatedAdvertisements));
      }
    } catch (e) {
      emit(AdvertisementError(e.toString()));
    }
  }

  Future<void> _onAddSampleAdvertisements(AddSampleAdvertisements event, Emitter<AdvertisementState> emit) async {
    try {
      await _advertisementRepository.addSampleAdvertisements();
      add(const LoadAdvertisements());
    } catch (e) {
      emit(AdvertisementError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _advertisementSubscription?.cancel();
    return super.close();
  }
}