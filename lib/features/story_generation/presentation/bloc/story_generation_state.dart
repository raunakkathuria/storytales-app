import 'package:equatable/equatable.dart';
import 'package:storytales/features/library/domain/entities/story.dart';

/// States for the StoryGenerationBloc.
abstract class StoryGenerationState extends Equatable {
  const StoryGenerationState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the StoryGenerationBloc.
class StoryGenerationInitial extends StoryGenerationState {
  const StoryGenerationInitial();
}

/// State when checking if the user can generate a story.
class CheckingCanGenerateStory extends StoryGenerationState {
  const CheckingCanGenerateStory();
}

/// State when the user can generate a story.
class CanGenerateStory extends StoryGenerationState {
  final int freeStoriesRemaining;

  const CanGenerateStory({required this.freeStoriesRemaining});

  @override
  List<Object?> get props => [freeStoriesRemaining];
}

/// State when the user cannot generate a story due to subscription limits.
class CannotGenerateStory extends StoryGenerationState {
  final String message;

  const CannotGenerateStory({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when a story is being generated.
class StoryGenerationLoading extends StoryGenerationState {
  final double progress;

  const StoryGenerationLoading({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}

/// State when a story has been successfully generated.
class StoryGenerationSuccess extends StoryGenerationState {
  final Story story;

  const StoryGenerationSuccess({required this.story});

  @override
  List<Object?> get props => [story];
}

/// State when there is an error during story generation.
class StoryGenerationFailure extends StoryGenerationState {
  final String error;
  final bool isRetryable;

  const StoryGenerationFailure({
    required this.error,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [error, isRetryable];
}

/// State when the story generation has been canceled.
class StoryGenerationCanceled extends StoryGenerationState {
  const StoryGenerationCanceled();
}

/// State when displaying the number of free stories remaining.
class FreeStoriesRemainingState extends StoryGenerationState {
  final int freeStoriesRemaining;

  const FreeStoriesRemainingState({required this.freeStoriesRemaining});

  @override
  List<Object?> get props => [freeStoriesRemaining];
}

/// State when showing the countdown before starting background generation.
class StoryGenerationCountdown extends StoryGenerationState {
  final int secondsRemaining;

  const StoryGenerationCountdown({required this.secondsRemaining});

  @override
  List<Object?> get props => [secondsRemaining];
}

/// State when a story is being generated in the background.
class StoryGenerationInBackground extends StoryGenerationState {
  final String tempStoryId;
  final String prompt;
  final String? ageRange;
  final DateTime startTime;

  const StoryGenerationInBackground({
    required this.tempStoryId,
    required this.prompt,
    this.ageRange,
    required this.startTime,
  });

  @override
  List<Object?> get props => [tempStoryId, prompt, ageRange, startTime];
}

/// State when background generation completes successfully.
class BackgroundGenerationComplete extends StoryGenerationState {
  final Story story;

  const BackgroundGenerationComplete({required this.story});

  @override
  List<Object?> get props => [story];
}

/// State when background generation fails.
class BackgroundGenerationFailure extends StoryGenerationState {
  final String tempStoryId;
  final String error;

  const BackgroundGenerationFailure({
    required this.tempStoryId,
    required this.error,
  });

  @override
  List<Object?> get props => [tempStoryId, error];
}
