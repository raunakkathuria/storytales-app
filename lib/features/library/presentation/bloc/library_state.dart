import 'package:equatable/equatable.dart';
import 'package:storytales/features/library/domain/entities/story.dart';
import 'package:storytales/features/library/presentation/bloc/library_event.dart';

/// States for the LibraryBloc.
abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the LibraryBloc.
class LibraryInitial extends LibraryState {
  const LibraryInitial();
}

/// State when the library is loading.
class LibraryLoading extends LibraryState {
  const LibraryLoading();
}

/// State when the library has been loaded.
class LibraryLoaded extends LibraryState {
  final List<Story> stories;
  final LibraryTab activeTab;

  const LibraryLoaded({
    required this.stories,
    this.activeTab = LibraryTab.all,
  });

  @override
  List<Object?> get props => [stories, activeTab];

  /// Create a copy of this LibraryLoaded with the given fields replaced with the new values.
  LibraryLoaded copyWith({
    List<Story>? stories,
    LibraryTab? activeTab,
  }) {
    return LibraryLoaded(
      stories: stories ?? this.stories,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

/// State when there is an error loading the library.
class LibraryError extends LibraryState {
  final String message;

  const LibraryError({required this.message});

  @override
  List<Object?> get props => [message];
}


/// State when a story's favorite status is being toggled.
class FavoriteToggling extends LibraryState {
  final String storyId;

  const FavoriteToggling({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

/// State when a story's favorite status has been toggled.
class FavoriteToggled extends LibraryState {
  final String storyId;
  final bool isFavorite;

  const FavoriteToggled({
    required this.storyId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [storyId, isFavorite];
}

/// State when the library is empty.
class LibraryEmpty extends LibraryState {
  final LibraryTab activeTab;
  final String message;

  const LibraryEmpty({
    required this.activeTab,
    required this.message,
  });

  @override
  List<Object?> get props => [activeTab, message];
}

/// State when an API story is being fetched.
class ApiStoryFetching extends LibraryState {
  final String storyId;

  const ApiStoryFetching({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

/// State when an API story has been fetched successfully.
class ApiStoryFetched extends LibraryState {
  final String storyId;

  const ApiStoryFetched({required this.storyId});

  @override
  List<Object?> get props => [storyId];
}

/// State when there is an error fetching an API story.
class ApiStoryFetchError extends LibraryState {
  final String storyId;
  final String message;

  const ApiStoryFetchError({
    required this.storyId,
    required this.message,
  });

  @override
  List<Object?> get props => [storyId, message];
}
