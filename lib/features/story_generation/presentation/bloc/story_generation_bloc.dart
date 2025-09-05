import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/features/story_generation/domain/repositories/story_generation_repository.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_event.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_state.dart';
import 'package:storytales/features/profile/domain/repositories/profile_repository.dart';
import 'package:storytales/features/library/presentation/bloc/library_bloc.dart';
import 'package:storytales/features/library/presentation/bloc/library_event.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/core/di/injection_container.dart' as sl;

/// BLoC for managing story generation.
class StoryGenerationBloc
    extends Bloc<StoryGenerationEvent, StoryGenerationState> {
  final StoryGenerationRepository _repository;
  final ProfileRepository _profileRepository;
  final LoggingService _loggingService;
  Timer? _progressTimer;
  Timer? _countdownTimer;
  final Map<String, Timer> _backgroundGenerationTimers = {};

  StoryGenerationBloc({
    required StoryGenerationRepository repository,
    required ProfileRepository profileRepository,
    required LoggingService loggingService,
  })  : _repository = repository,
        _profileRepository = profileRepository,
        _loggingService = loggingService,
        super(const StoryGenerationInitial()) {
    on<CheckCanGenerateStory>(_onCheckCanGenerateStory);
    on<GenerateStory>(_onGenerateStory);
    on<ResetStoryGeneration>(_onResetStoryGeneration);
    on<GetFreeStoriesRemaining>(_onGetFreeStoriesRemaining);
    on<StartGenerationCountdown>(_onStartGenerationCountdown);
    on<StartBackgroundGeneration>(_onStartBackgroundGeneration);
    on<BackgroundGenerationCompleted>(_onBackgroundGenerationCompleted);
    on<BackgroundGenerationCompletedWithStory>(_onBackgroundGenerationCompletedWithStory);
    on<BackgroundGenerationFailed>(_onBackgroundGenerationFailed);
    on<ClearFailedStoryGeneration>(_onClearFailedStoryGeneration);
  }

  /// Handle the CheckCanGenerateStory event.
  Future<void> _onCheckCanGenerateStory(
    CheckCanGenerateStory event,
    Emitter<StoryGenerationState> emit,
  ) async {
    emit(const CheckingCanGenerateStory());

    try {
      final canGenerate = await _repository.canGenerateStory();
      final freeStoriesRemaining = await _repository.getFreeStoriesRemaining();

      if (canGenerate) {
        emit(CanGenerateStory(freeStoriesRemaining: freeStoriesRemaining));
      } else {
        emit(const CannotGenerateStory(
            message:
                'You have reached the free story limit. Please subscribe to generate more stories.'));
      }
    } catch (e) {
      emit(StoryGenerationFailure(error: e.toString()));
    }
  }

  /// Handle the GenerateStory event.
  Future<void> _onGenerateStory(
    GenerateStory event,
    Emitter<StoryGenerationState> emit,
  ) async {
    emit(const StoryGenerationLoading());

    // Start a timer to simulate progress updates
    _startProgressTimer(emit);

    try {
      final story = await _repository.generateStory(
        prompt: event.prompt,
        ageRange: event.ageRange,
        theme: event.theme,
        genre: event.genre,
      );

      _cancelProgressTimer();
      emit(StoryGenerationSuccess(story: story));
    } catch (e) {
      _cancelProgressTimer();
      final errorMessage = e.toString();
      final isSubscriptionError = errorMessage.contains('free story limit');

      if (isSubscriptionError) {
        await _handleSubscriptionError(emit, errorMessage);
      } else {
        emit(StoryGenerationFailure(
          error: errorMessage,
          isRetryable: true,
        ));
      }
    }
  }


  /// Handle the ResetStoryGeneration event.
  void _onResetStoryGeneration(
    ResetStoryGeneration event,
    Emitter<StoryGenerationState> emit,
  ) {
    emit(const StoryGenerationInitial());
  }

  /// Handle the GetFreeStoriesRemaining event.
  Future<void> _onGetFreeStoriesRemaining(
    GetFreeStoriesRemaining event,
    Emitter<StoryGenerationState> emit,
  ) async {
    try {
      final freeStoriesRemaining = await _repository.getFreeStoriesRemaining();
      emit(FreeStoriesRemainingState(freeStoriesRemaining: freeStoriesRemaining));
    } catch (e) {
      emit(StoryGenerationFailure(error: e.toString()));
    }
  }

  /// Start a timer to simulate progress updates during story generation.
  void _startProgressTimer(Emitter<StoryGenerationState> emit) {
    _cancelProgressTimer();

    double progress = 0.0;
    const totalDuration = Duration(seconds: 120);
    const interval = Duration(milliseconds: 100);
    final steps = totalDuration.inMilliseconds ~/ interval.inMilliseconds;
    final increment = 1.0 / steps;

    _progressTimer = Timer.periodic(interval, (timer) {
      progress += increment;
      if (progress >= 1.0) {
        progress = 0.99; // Cap at 99% until actual completion
        timer.cancel();
      }
      // Check if the emitter is still active before emitting
      if (!emit.isDone) {
        emit(StoryGenerationLoading(progress: progress));
      } else {
        timer.cancel();
      }
    });
  }

  /// Handle the StartGenerationCountdown event.
  Future<void> _onStartGenerationCountdown(
    StartGenerationCountdown event,
    Emitter<StoryGenerationState> emit,
  ) async {
    _cancelCountdownTimer();

    // Start background generation immediately (parallel with countdown)
    if (!emit.isDone) {
      add(StartBackgroundGeneration(
        prompt: event.prompt,
        ageRange: event.ageRange,
        theme: event.theme,
        genre: event.genre,
      ));
    }

    // Show countdown for magical UX while API call runs in background
    for (int i = 3; i >= 0; i--) {
      if (!emit.isDone) {
        emit(StoryGenerationCountdown(secondsRemaining: i));
        if (i > 0) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
  }


  /// Handle the StartBackgroundGeneration event.
  Future<void> _onStartBackgroundGeneration(
    StartBackgroundGeneration event,
    Emitter<StoryGenerationState> emit,
  ) async {
    // Generate a temporary story ID
    final tempStoryId = 'temp_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
    final startTime = DateTime.now();

    // Emit background generation state
    emit(StoryGenerationInBackground(
      tempStoryId: tempStoryId,
      prompt: event.prompt,
      ageRange: event.ageRange,
      startTime: startTime,
    ));

    // Emit loading card state for the library to display
    emit(ShowLoadingCard(
      tempStoryId: tempStoryId,
      prompt: event.prompt,
      ageRange: event.ageRange,
      startTime: startTime,
    ));

    // Start background generation
    _startBackgroundGeneration(tempStoryId, event, emit);
  }

  /// Handle the BackgroundGenerationCompleted event.
  void _onBackgroundGenerationCompleted(
    BackgroundGenerationCompleted event,
    Emitter<StoryGenerationState> emit,
  ) {
    // Clean up the background timer
    _backgroundGenerationTimers[event.tempStoryId]?.cancel();
    _backgroundGenerationTimers.remove(event.tempStoryId);
  }

  /// Handle the BackgroundGenerationCompletedWithStory event.
  void _onBackgroundGenerationCompletedWithStory(
    BackgroundGenerationCompletedWithStory event,
    Emitter<StoryGenerationState> emit,
  ) {
    // Remove the loading card first
    emit(RemoveLoadingCard(tempStoryId: event.tempStoryId));

    // Then emit the completion state
    emit(BackgroundGenerationComplete(story: event.story));
  }

  /// Handle the BackgroundGenerationFailed event.
  void _onBackgroundGenerationFailed(
    BackgroundGenerationFailed event,
    Emitter<StoryGenerationState> emit,
  ) {
    emit(BackgroundGenerationFailure(
      tempStoryId: event.tempStoryId,
      error: event.error,
    ));
  }

  /// Handle the ClearFailedStoryGeneration event.
  void _onClearFailedStoryGeneration(
    ClearFailedStoryGeneration event,
    Emitter<StoryGenerationState> emit,
  ) {
    // Emit RemoveLoadingCard to explicitly remove the failed card
    emit(RemoveLoadingCard(tempStoryId: event.tempStoryId));
  }

  /// Start background story generation.
  void _startBackgroundGeneration(
    String tempStoryId,
    StartBackgroundGeneration backgroundEvent,
    Emitter<StoryGenerationState> emit,
  ) {
    // Use a timer to run the background generation independently
    final timer = Timer(const Duration(milliseconds: 100), () {
      _performBackgroundGeneration(tempStoryId, backgroundEvent, emit);
    });

    _backgroundGenerationTimers[tempStoryId] = timer;
  }

  /// Perform the actual background story generation.
  Future<void> _performBackgroundGeneration(
    String tempStoryId,
    StartBackgroundGeneration generationEvent,
    Emitter<StoryGenerationState> emit,
  ) async {
    try {
      // Generate and save the story - this is a complete operation
      // that includes both API call and database save
      final story = await _repository.generateStory(
        prompt: generationEvent.prompt,
        ageRange: generationEvent.ageRange,
        theme: generationEvent.theme,
        genre: generationEvent.genre,
      );

      // At this point, the story is fully saved to the database
      // Now we can safely emit completion states directly for synchronous execution

      // Clean up the background timer first
      _backgroundGenerationTimers[tempStoryId]?.cancel();
      _backgroundGenerationTimers.remove(tempStoryId);

      // Check if emitter is still active before emitting
      if (!emit.isDone) {
        // Remove the loading card first
        emit(RemoveLoadingCard(tempStoryId: tempStoryId));

        // Then emit the completion state with the story
        // This will trigger the library refresh, and the story will be available
        emit(BackgroundGenerationComplete(story: story));

        // Trigger library refresh directly (same pattern as StoryWorkshopBloc)
        Timer.run(() {
          try {
            final libraryBloc = sl.sl<LibraryBloc>();
            libraryBloc.add(const LoadAllStories());
            _loggingService.info('Library refresh triggered after background story generation completion');
          } catch (e) {
            _loggingService.warning('Failed to trigger library refresh after story generation: $e');
          }
        });
      }
    } catch (e) {
      // Handle failure case
      // Clean up the background timer
      _backgroundGenerationTimers[tempStoryId]?.cancel();
      _backgroundGenerationTimers.remove(tempStoryId);

      // Check if emitter is still active before emitting
      if (!emit.isDone) {
        final errorMessage = e.toString();
        final isSubscriptionError = errorMessage.contains('free story limit');
        
        if (isSubscriptionError) {
          // For background generation subscription errors, we still emit the background failure
          // but the UI should handle this appropriately
          await _handleBackgroundSubscriptionError(emit, tempStoryId, errorMessage);
        } else {
          emit(BackgroundGenerationFailure(
            tempStoryId: tempStoryId,
            error: errorMessage,
          ));
        }
      }
    }
  }

  /// Cancel the countdown timer.
  void _cancelCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  /// Cancel the progress timer.
  void _cancelProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  /// Cancel all background generation timers.
  void _cancelAllBackgroundTimers() {
    for (final timer in _backgroundGenerationTimers.values) {
      timer.cancel();
    }
    _backgroundGenerationTimers.clear();
  }

  /// Handle subscription errors by checking user tier and emitting appropriate state.
  Future<void> _handleSubscriptionError(Emitter<StoryGenerationState> emit, String errorMessage) async {
    try {
      // Get current user profile to check subscription tier
      final profile = await _profileRepository.getCurrentUserProfile();
      
      if (profile.subscriptionTier == 'free') {
        // Free tier user hitting limit - show subscription prompt
        emit(StoryGenerationSubscriptionRequired(
          subscriptionTier: profile.subscriptionTier,
          storiesUsed: profile.monthlyStoryCount,
          monthlyLimit: profile.maxMonthlyStories,
          message: 'You\'ve reached your free story limit! Subscribe for unlimited stories.',
        ));
      } else {
        // Subscribed user getting subscription error - this is a technical issue
        emit(StoryGenerationFailure(
          error: 'Subscription verification failed. Please try again.',
          isRetryable: true,
        ));
      }
    } catch (e) {
      // If we can't get profile data, fallback to generic subscription error
      emit(StoryGenerationFailure(
        error: errorMessage,
        isRetryable: false,
      ));
    }
  }

  /// Handle subscription errors in background generation.
  Future<void> _handleBackgroundSubscriptionError(
    Emitter<StoryGenerationState> emit,
    String tempStoryId,
    String errorMessage,
  ) async {
    try {
      // Get current user profile to check subscription tier
      final profile = await _profileRepository.getCurrentUserProfile();
      
      if (profile.subscriptionTier == 'free') {
        // Free tier user hitting limit - emit background failure but with subscription context
        emit(BackgroundGenerationFailure(
          tempStoryId: tempStoryId,
          error: 'Subscription required: ${profile.monthlyStoryCount}/${profile.maxMonthlyStories} stories used',
        ));
      } else {
        // Subscribed user getting subscription error - technical issue
        emit(BackgroundGenerationFailure(
          tempStoryId: tempStoryId,
          error: 'Subscription verification failed',
        ));
      }
    } catch (e) {
      // Fallback to generic error
      emit(BackgroundGenerationFailure(
        tempStoryId: tempStoryId,
        error: errorMessage,
      ));
    }
  }

  @override
  Future<void> close() {
    _cancelProgressTimer();
    _cancelCountdownTimer();
    _cancelAllBackgroundTimers();
    return super.close();
  }
}
