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
