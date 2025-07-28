import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/features/story_generation/domain/repositories/story_generation_repository.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_event.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_state.dart';

/// BLoC for managing story generation.
class StoryGenerationBloc
    extends Bloc<StoryGenerationEvent, StoryGenerationState> {
  final StoryGenerationRepository _repository;
  Timer? _progressTimer;
  Timer? _countdownTimer;
  final Map<String, Timer> _backgroundGenerationTimers = {};

  StoryGenerationBloc({required StoryGenerationRepository repository})
      : _repository = repository,
        super(const StoryGenerationInitial()) {
    on<CheckCanGenerateStory>(_onCheckCanGenerateStory);
    on<GenerateStory>(_onGenerateStory);
    on<CancelStoryGeneration>(_onCancelStoryGeneration);
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

      emit(StoryGenerationFailure(
        error: errorMessage,
        isRetryable: !isSubscriptionError,
      ));
    }
  }

  /// Handle the CancelStoryGeneration event.
  void _onCancelStoryGeneration(
    CancelStoryGeneration event,
    Emitter<StoryGenerationState> emit,
  ) {
    _cancelProgressTimer();
    emit(const StoryGenerationCanceled());
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
    const totalDuration = Duration(seconds: 10);
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

    // Emit countdown states (reduced from 5 to 3 seconds)
    for (int i = 3; i >= 0; i--) {
      if (!emit.isDone) {
        emit(StoryGenerationCountdown(secondsRemaining: i));
        if (i > 0) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }

    // Start background generation after countdown
    if (!emit.isDone) {
      add(StartBackgroundGeneration(
        prompt: event.prompt,
        ageRange: event.ageRange,
        theme: event.theme,
        genre: event.genre,
      ));
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
      _performBackgroundGeneration(tempStoryId, backgroundEvent);
    });

    _backgroundGenerationTimers[tempStoryId] = timer;
  }

  /// Perform the actual background story generation.
  Future<void> _performBackgroundGeneration(
    String tempStoryId,
    StartBackgroundGeneration generationEvent,
  ) async {
    try {
      final enhancedPrompt = "${generationEvent.prompt}. "
        "Generate a high-detail, sharp focus, Pixar style 3D render. "
        "Ensure all characters are clearly defined with distinct features and cinematic lighting.";

      final story = await _repository.generateStory(
        prompt: enhancedPrompt,
        ageRange: generationEvent.ageRange,
        theme: generationEvent.theme,
        genre: generationEvent.genre,
      );

      // Use add() to trigger events through the normal flow
      add(BackgroundGenerationCompleted(tempStoryId: tempStoryId));

      // Schedule the completion state to be emitted
      Timer.run(() {
        if (!isClosed) {
          add(BackgroundGenerationCompletedWithStory(
            tempStoryId: tempStoryId,
            story: story,
          ));
        }
      });

      // Clean up
      _backgroundGenerationTimers.remove(tempStoryId);
    } catch (e) {
      // Schedule the failure state to be emitted
      Timer.run(() {
        if (!isClosed) {
          add(BackgroundGenerationFailed(
            tempStoryId: tempStoryId,
            error: e.toString(),
          ));
        }
      });

      // Clean up
      _backgroundGenerationTimers.remove(tempStoryId);
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

  @override
  Future<void> close() {
    _cancelProgressTimer();
    _cancelCountdownTimer();
    _cancelAllBackgroundTimers();
    return super.close();
  }
}
