import 'package:equatable/equatable.dart';

/// Events for the StoryGenerationBloc.
abstract class StoryGenerationEvent extends Equatable {
  const StoryGenerationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check if the user can generate a story.
class CheckCanGenerateStory extends StoryGenerationEvent {
  const CheckCanGenerateStory();
}

/// Event to generate a story.
class GenerateStory extends StoryGenerationEvent {
  final String prompt;
  final String? ageRange;
  final String? theme;
  final String? genre;

  const GenerateStory({
    required this.prompt,
    this.ageRange,
    this.theme,
    this.genre,
  });

  @override
  List<Object?> get props => [prompt, ageRange, theme, genre];
}

/// Event to cancel story generation.
class CancelStoryGeneration extends StoryGenerationEvent {
  const CancelStoryGeneration();
}

/// Event to reset the story generation state.
class ResetStoryGeneration extends StoryGenerationEvent {
  const ResetStoryGeneration();
}

/// Event to get the number of free stories remaining.
class GetFreeStoriesRemaining extends StoryGenerationEvent {
  const GetFreeStoriesRemaining();
}

/// Event to start the countdown before background generation.
class StartGenerationCountdown extends StoryGenerationEvent {
  final String prompt;
  final String? ageRange;
  final String? theme;
  final String? genre;

  const StartGenerationCountdown({
    required this.prompt,
    this.ageRange,
    this.theme,
    this.genre,
  });

  @override
  List<Object?> get props => [prompt, ageRange, theme, genre];
}

/// Event to start background story generation.
class StartBackgroundGeneration extends StoryGenerationEvent {
  final String prompt;
  final String? ageRange;
  final String? theme;
  final String? genre;

  const StartBackgroundGeneration({
    required this.prompt,
    this.ageRange,
    this.theme,
    this.genre,
  });

  @override
  List<Object?> get props => [prompt, ageRange, theme, genre];
}

/// Event when background generation completes.
class BackgroundGenerationCompleted extends StoryGenerationEvent {
  final String tempStoryId;

  const BackgroundGenerationCompleted({required this.tempStoryId});

  @override
  List<Object?> get props => [tempStoryId];
}

/// Event when background generation completes successfully with a story.
class BackgroundGenerationCompletedWithStory extends StoryGenerationEvent {
  final String tempStoryId;
  final dynamic story; // Using dynamic to avoid import issues

  const BackgroundGenerationCompletedWithStory({
    required this.tempStoryId,
    required this.story,
  });

  @override
  List<Object?> get props => [tempStoryId, story];
}

/// Event when background generation fails.
class BackgroundGenerationFailed extends StoryGenerationEvent {
  final String tempStoryId;
  final String error;

  const BackgroundGenerationFailed({
    required this.tempStoryId,
    required this.error,
  });

  @override
  List<Object?> get props => [tempStoryId, error];
}

/// Event to clear a failed story generation from the UI.
class ClearFailedStoryGeneration extends StoryGenerationEvent {
  final String tempStoryId;

  const ClearFailedStoryGeneration({required this.tempStoryId});

  @override
  List<Object?> get props => [tempStoryId];
}
