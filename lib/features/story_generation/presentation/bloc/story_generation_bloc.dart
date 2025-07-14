import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/features/story_generation/domain/repositories/story_generation_repository.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_event.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_state.dart';

/// BLoC for managing story generation.
class StoryGenerationBloc
    extends Bloc<StoryGenerationEvent, StoryGenerationState> {
  final StoryGenerationRepository _repository;
  Timer? _progressTimer;

  StoryGenerationBloc({required StoryGenerationRepository repository})
      : _repository = repository,
        super(const StoryGenerationInitial()) {
    on<CheckCanGenerateStory>(_onCheckCanGenerateStory);
    on<GenerateStory>(_onGenerateStory);
    on<CancelStoryGeneration>(_onCancelStoryGeneration);
    on<ResetStoryGeneration>(_onResetStoryGeneration);
    on<GetFreeStoriesRemaining>(_onGetFreeStoriesRemaining);
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
      emit(StoryGenerationLoading(progress: progress));
    });
  }

  /// Cancel the progress timer.
  void _cancelProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  @override
  Future<void> close() {
    _cancelProgressTimer();
    return super.close();
  }
}
