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


/// Event to filter stories by tab.
class FilterByTab extends LibraryEvent {
  final LibraryTab tab;

  const FilterByTab({required this.tab});

  @override
  List<Object?> get props => [tab];
}

/// Event to load pre-generated stories from the API.
class LoadApiPreGeneratedStories extends LibraryEvent {
  const LoadApiPreGeneratedStories();
}

/// Event to fetch a single API story by ID.
class FetchApiStory extends LibraryEvent {
  final String storyId;

  const FetchApiStory({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

/// Event to retry loading stories when there's a network issue.
class RetryLoadStories extends LibraryEvent {
  const RetryLoadStories();

  @override
  List<Object?> get props => [];
}

/// Enum for library tabs.
enum LibraryTab {
  all,
  favorites,
}
