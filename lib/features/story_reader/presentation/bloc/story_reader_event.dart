import 'package:equatable/equatable.dart';

/// Events for the StoryReaderBloc.
abstract class StoryReaderEvent extends Equatable {
  const StoryReaderEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load a story for reading.
class LoadStory extends StoryReaderEvent {
  final String storyId;

  const LoadStory({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

/// Event to navigate to the next page.
class NextPage extends StoryReaderEvent {
  const NextPage();
}

/// Event to navigate to the previous page.
class PreviousPage extends StoryReaderEvent {
  const PreviousPage();
}

/// Event to navigate to a specific page.
class GoToPage extends StoryReaderEvent {
  final int pageIndex;

  const GoToPage({required this.pageIndex});

  @override
  List<Object?> get props => [pageIndex];
}

/// Event to toggle the favorite status of the story.
class ToggleStoryFavorite extends StoryReaderEvent {
  const ToggleStoryFavorite();
}

/// Event to close the story reader.
class CloseReader extends StoryReaderEvent {
  const CloseReader();
}
