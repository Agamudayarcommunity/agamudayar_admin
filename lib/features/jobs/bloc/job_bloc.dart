import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/job_repository.dart';
import 'job_event.dart';
import 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final JobRepository _jobRepository;
  StreamSubscription? _jobSubscription;

  JobBloc({required JobRepository jobRepository})
      : _jobRepository = jobRepository,
        super(JobInitial()) {
    on<LoadJobs>(_onLoadJobs);
    on<UpdateJobStatus>(_onUpdateJobStatus);
    on<AddSampleJobs>(_onAddSampleJobs);
  }

  Future<void> _onLoadJobs(LoadJobs event, Emitter<JobState> emit) async {
    emit(JobLoading());
    try {
      await _jobSubscription?.cancel();
      
      final stream = event.filterStatus != null
          ? _jobRepository.getJobsByStatus(event.filterStatus!)
          : _jobRepository.getAllJobs();
      
      _jobSubscription = stream.listen(
        (jobs) => add(LoadJobs(filterStatus: event.filterStatus)),
        onError: (error) => emit(JobError(error.toString())),
      );
      
      final jobs = await stream.first;
      emit(JobLoaded(jobs));
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  Future<void> _onUpdateJobStatus(UpdateJobStatus event, Emitter<JobState> emit) async {
    try {
      await _jobRepository.updateJobStatus(
        event.jobId,
        event.newStatus,
        rejectionReason: event.rejectionReason,
      );
      emit(JobStatusUpdated());
      
      // Reload the jobs list
      if (state is JobLoaded) {
        final loadedState = state as JobLoaded;
        final updatedJobs = loadedState.jobs.map((job) {
          if (job.id == event.jobId) {
            return job.copyWith(
              status: event.newStatus,
              rejectionReason: event.rejectionReason,
              approvedDate: event.newStatus.name == 'approved' ? DateTime.now() : null,
            );
          }
          return job;
        }).toList();
        emit(JobLoaded(updatedJobs));
      }
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  Future<void> _onAddSampleJobs(AddSampleJobs event, Emitter<JobState> emit) async {
    try {
      await _jobRepository.addSampleJobs();
      add(const LoadJobs());
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _jobSubscription?.cancel();
    return super.close();
  }
}