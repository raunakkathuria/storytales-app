import 'package:equatable/equatable.dart';

/// Events for the LibraryBloc.
abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all stories.
class LoadAllStories extends LibraryEvent {
  const LoadAllStories();
}

/// Event to load favorite stories.
class LoadFavoriteStories extends LibraryEvent {
  const LoadFavoriteStories();
}

/// Event to toggle the favorite status of a story.
class ToggleFavorite extends LibraryEvent {
  final String storyId;

  const ToggleFavorite({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

/// Event to delete a story.
class DeleteStory extends LibraryEvent {
  final String storyId;

  const DeleteStory({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

/// Event to filter stories by tab.
class FilterByTab extends LibraryEvent {
  final LibraryTab tab;

  const FilterByTab({required this.tab});

  @override
  List<Object?> get props => [tab];
}

/// Enum for library tabs.
enum LibraryTab {
  all,
  favorites,
}
