import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/approval_status.dart';
import '../repositories/matrimony_repository.dart';
import 'matrimony_event.dart';
import 'matrimony_state.dart';

class MatrimonyBloc extends Bloc<MatrimonyEvent, MatrimonyState> {
  final MatrimonyRepository matrimonyRepository;

  MatrimonyBloc({required this.matrimonyRepository}) : super(MatrimonyInitial()) {
    on<LoadMatrimonyProfiles>(_onLoadMatrimonyProfiles);
    on<UpdateMatrimonyProfileStatus>(_onUpdateMatrimonyProfileStatus);
    on<AddSampleMatrimonyProfiles>(_onAddSampleMatrimonyProfiles);
  }

  Future<void> _onLoadMatrimonyProfiles(
    LoadMatrimonyProfiles event,
    Emitter<MatrimonyState> emit,
  ) async {
    emit(MatrimonyLoading());
    try {
      final profiles = event.filterStatus != null
          ? await matrimonyRepository.getProfilesByStatus(event.filterStatus!)
          : await matrimonyRepository.getAllProfiles();
      emit(MatrimonyLoaded(profiles: profiles));
    } catch (e) {
      emit(MatrimonyError(message: e.toString()));
    }
  }

  Future<void> _onUpdateMatrimonyProfileStatus(
    UpdateMatrimonyProfileStatus event,
    Emitter<MatrimonyState> emit,
  ) async {
    try {
      await matrimonyRepository.updateProfileStatus(
        profileId: event.profileId,
        newStatus: event.newStatus,
        rejectionReason: event.rejectionReason,
      );

      emit(MatrimonyProfileStatusUpdated(
        profileId: event.profileId,
        newStatus: event.newStatus.name,
      ));

      // Reload the profiles after updating status
      add(const LoadMatrimonyProfiles());
    } catch (e) {
      emit(MatrimonyError(message: e.toString()));
    }
  }

  Future<void> _onAddSampleMatrimonyProfiles(
    AddSampleMatrimonyProfiles event,
    Emitter<MatrimonyState> emit,
  ) async {
    try {
      await matrimonyRepository.addSampleProfiles();
      add(const LoadMatrimonyProfiles());
    } catch (e) {
      emit(MatrimonyError(message: e.toString()));
    }
  }
}