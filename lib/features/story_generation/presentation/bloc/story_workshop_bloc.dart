import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/di/injection_container.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/features/story_generation/domain/repositories/story_generation_repository.dart';
import 'package:storytales/features/library/domain/repositories/story_repository.dart';
import 'package:storytales/features/library/presentation/bloc/library_bloc.dart';
import 'package:storytales/features/library/presentation/bloc/library_event.dart';
import 'story_workshop_event.dart';
import 'story_workshop_state.dart';

/// BLoC for managing multiple story generations in the Story Workshop modal
class StoryWorkshopBloc extends Bloc<StoryWorkshopEvent, StoryWorkshopState> {
  final StoryGenerationRepository _storyRepository;
  final StoryRepository _libraryRepository;
  final LoggingService _loggingService;

  // Track active timers for polling jobs
  final Map<String, Timer> _pollingTimers = {};

  // Track progress timers for each job
  final Map<String, Timer> _progressTimers = {};

  StoryWorkshopBloc({
    required StoryGenerationRepository storyRepository,
    required StoryRepository libraryRepository,
  })  : _storyRepository = storyRepository,
        _libraryRepository = libraryRepository,
        _loggingService = sl<LoggingService>(),
        super(const StoryWorkshopInitial()) {
    on<StartStoryGeneration>(_onStartStoryGeneration);
    on<UpdateJobProgress>(_onUpdateJobProgress);
    on<CompleteJob>(_onCompleteJob);
    on<FailJob>(_onFailJob);
    on<RetryJob>(_onRetryJob);
    on<DismissFailedJob>(_onDismissFailedJob);
    on<ClearCompletedJobs>(_onClearCompletedJobs);
    on<InitializeWorkshop>(_onInitializeWorkshop);
  }

  @override
  Future<void> close() {
    // Cancel all polling timers
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();

    // Cancel all progress timers
    for (final timer in _progressTimers.values) {
      timer.cancel();
    }
    _progressTimers.clear();

    return super.close();
  }

  Future<void> _onStartStoryGeneration(
    StartStoryGeneration event,
    Emitter<StoryWorkshopState> emit,
  ) async {
    try {
      _loggingService.info('Starting new story generation: ${event.prompt}');

      // Check if user can generate story
      final canGenerate = await _storyRepository.canGenerateStory();
      if (!canGenerate) {
        _loggingService.warning('User cannot generate story - subscription limit reached');
        return;
      }

      // Generate unique IDs
      final tempStoryId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final jobId = 'job_${DateTime.now().millisecondsSinceEpoch}';

      // Create new job
      final newJob = StoryGenerationJob(
        jobId: jobId,
        tempStoryId: tempStoryId,
        prompt: event.prompt,
        ageRange: event.ageRange,
        theme: event.theme,
        genre: event.genre,
        startTime: DateTime.now(),
        status: StoryJobStatus.generating,
        progress: 0.0,
      );

      // Update state with new job
      final currentState = state;
      Map<String, StoryGenerationJob> activeJobs = {};
      Map<String, StoryGenerationJob> failedJobs = {};

      if (currentState is StoryWorkshopActive) {
        activeJobs = Map.from(currentState.activeJobs);
        failedJobs = Map.from(currentState.failedJobs);
      }

      activeJobs[jobId] = newJob;

      emit(StoryWorkshopActive(
        activeJobs: activeJobs,
        failedJobs: failedJobs,
      ));

      // Start background generation
      _startBackgroundGeneration(newJob);

    } catch (e) {
      _loggingService.error('Error starting story generation: $e');
    }
  }

  Future<void> _startBackgroundGeneration(StoryGenerationJob job) async {
    try {
      _loggingService.info('Starting background generation for job: ${job.jobId}');

      // Start progress timer for visual feedback
      _startProgressTimer(job.jobId);

      // Use the API client's built-in job polling system
      await _storyRepository.generateStory(
        prompt: job.prompt,
        ageRange: job.ageRange,
        theme: job.theme,
        genre: job.genre,
      );

      // Cancel progress timer
      _cancelProgressTimer(job.jobId);

      // Mark job as completed and auto-remove
      add(CompleteJob(jobId: job.jobId));

      // Trigger library refresh directly
      Timer.run(() {
        try {
          final libraryBloc = sl<LibraryBloc>();
          libraryBloc.add(const LoadAllStories());
          _loggingService.info('Library refresh triggered for job: ${job.jobId}');
        } catch (e) {
          _loggingService.warning('Failed to trigger library refresh: $e');
        }
      });

      _loggingService.info('Story generation completed for job: ${job.jobId}');

    } catch (e) {
      _loggingService.error('Story generation failed for job ${job.jobId}: $e');

      // Cancel progress timer
      _cancelProgressTimer(job.jobId);

      // Mark job as failed
      add(FailJob(
        jobId: job.jobId,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateJobProgress(
    UpdateJobProgress event,
    Emitter<StoryWorkshopState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StoryWorkshopActive) return;

    final activeJobs = Map<String, StoryGenerationJob>.from(currentState.activeJobs);
    final job = activeJobs[event.jobId];

    if (job != null) {
      activeJobs[event.jobId] = job.copyWith(progress: event.progress);

      emit(StoryWorkshopActive(
        activeJobs: activeJobs,
        failedJobs: currentState.failedJobs,
      ));
    }
  }

  Future<void> _onCompleteJob(
    CompleteJob event,
    Emitter<StoryWorkshopState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StoryWorkshopActive) return;

    final activeJobs = Map<String, StoryGenerationJob>.from(currentState.activeJobs);
    final failedJobs = Map<String, StoryGenerationJob>.from(currentState.failedJobs);

    // Remove completed job immediately (simple cleanup)
    activeJobs.remove(event.jobId);

    // Cancel polling timer if exists
    _pollingTimers[event.jobId]?.cancel();
    _pollingTimers.remove(event.jobId);

    // Cancel progress timer if exists
    _cancelProgressTimer(event.jobId);

    // Emit new state or initial if no jobs remain
    if (activeJobs.isEmpty && failedJobs.isEmpty) {
      emit(const StoryWorkshopInitial());
    } else {
      emit(StoryWorkshopActive(
        activeJobs: activeJobs,
        failedJobs: failedJobs,
      ));
    }
  }

  Future<void> _onFailJob(
    FailJob event,
    Emitter<StoryWorkshopState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StoryWorkshopActive) return;

    final activeJobs = Map<String, StoryGenerationJob>.from(currentState.activeJobs);
    final failedJobs = Map<String, StoryGenerationJob>.from(currentState.failedJobs);

    // Move job from active to failed
    final job = activeJobs.remove(event.jobId);
    if (job != null) {
      failedJobs[event.jobId] = job.copyWith(
        status: StoryJobStatus.failed,
        error: event.error,
      );
    }

    // Cancel polling timer if exists
    _pollingTimers[event.jobId]?.cancel();
    _pollingTimers.remove(event.jobId);

    // Cancel progress timer if exists
    _cancelProgressTimer(event.jobId);

    emit(StoryWorkshopActive(
      activeJobs: activeJobs,
      failedJobs: failedJobs,
    ));
  }

  Future<void> _onRetryJob(
    RetryJob event,
    Emitter<StoryWorkshopState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StoryWorkshopActive) return;

    final activeJobs = Map<String, StoryGenerationJob>.from(currentState.activeJobs);
    final failedJobs = Map<String, StoryGenerationJob>.from(currentState.failedJobs);

    // Move job from failed back to active
    final job = failedJobs.remove(event.jobId);
    if (job != null) {
      final retryJob = job.copyWith(
        status: StoryJobStatus.generating,
        progress: 0.0,
        error: null,
        startTime: DateTime.now(), // Reset start time
      );

      activeJobs[event.jobId] = retryJob;

      emit(StoryWorkshopActive(
        activeJobs: activeJobs,
        failedJobs: failedJobs,
      ));

      // Restart background generation
      _startBackgroundGeneration(retryJob);
    }
  }

  Future<void> _onDismissFailedJob(
    DismissFailedJob event,
    Emitter<StoryWorkshopState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StoryWorkshopActive) return;

    final activeJobs = Map<String, StoryGenerationJob>.from(currentState.activeJobs);
    final failedJobs = Map<String, StoryGenerationJob>.from(currentState.failedJobs);

    // Remove failed job
    failedJobs.remove(event.jobId);

    // Emit new state or initial if no jobs remain
    if (activeJobs.isEmpty && failedJobs.isEmpty) {
      emit(const StoryWorkshopInitial());
    } else {
      emit(StoryWorkshopActive(
        activeJobs: activeJobs,
        failedJobs: failedJobs,
      ));
    }
  }

  Future<void> _onClearCompletedJobs(
    ClearCompletedJobs event,
    Emitter<StoryWorkshopState> emit,
  ) async {
    // This event is for immediate cleanup of completed jobs
    // Since we already do immediate cleanup in _onCompleteJob,
    // this is mainly for manual cleanup if needed
    final currentState = state;
    if (currentState is! StoryWorkshopActive) return;

    // Keep only active and failed jobs, remove any completed ones
    emit(StoryWorkshopActive(
      activeJobs: currentState.activeJobs,
      failedJobs: currentState.failedJobs,
    ));
  }

  Future<void> _onInitializeWorkshop(
    InitializeWorkshop event,
    Emitter<StoryWorkshopState> emit,
  ) async {
    // Initialize workshop with existing jobs (e.g., on app restart)
    if (event.activeJobs.isEmpty && event.failedJobs.isEmpty) {
      emit(const StoryWorkshopInitial());
    } else {
      emit(StoryWorkshopActive(
        activeJobs: event.activeJobs,
        failedJobs: event.failedJobs,
      ));

      // Resume background generation for active jobs
      for (final job in event.activeJobs.values) {
        if (job.status == StoryJobStatus.generating) {
          _startBackgroundGeneration(job);
        }
      }
    }
  }

  /// Start a progress timer for a specific job to simulate progress updates.
  void _startProgressTimer(String jobId) {
    _cancelProgressTimer(jobId);

    double progress = 0.0;
    const totalDuration = Duration(seconds: 90); // 90 seconds to match API completion time
    const interval = Duration(milliseconds: 100);
    final steps = totalDuration.inMilliseconds ~/ interval.inMilliseconds;
    final increment = 1.0 / steps;

    _progressTimers[jobId] = Timer.periodic(interval, (timer) {
      progress += increment;
      if (progress >= 1.0) {
        progress = 0.99; // Cap at 99% until actual completion
        timer.cancel();
        _progressTimers.remove(jobId);
      }

      // Emit progress update if BLoC is still active
      if (!isClosed) {
        add(UpdateJobProgress(jobId: jobId, progress: progress));
      } else {
        timer.cancel();
        _progressTimers.remove(jobId);
      }
    });
  }

  /// Cancel the progress timer for a specific job.
  void _cancelProgressTimer(String jobId) {
    _progressTimers[jobId]?.cancel();
    _progressTimers.remove(jobId);
  }
}
