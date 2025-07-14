import 'package:equatable/equatable.dart';
import 'package:storytales/features/library/domain/entities/story.dart';

/// States for the StoryReaderBloc.
abstract class StoryReaderState extends Equatable {
  const StoryReaderState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the StoryReaderBloc.
class StoryReaderInitial extends StoryReaderState {
  const StoryReaderInitial();
}

/// State when a story is being loaded.
class StoryReaderLoading extends StoryReaderState {
  const StoryReaderLoading();
}

/// State when a story has been loaded and is ready for reading.
class StoryReaderLoaded extends StoryReaderState {
  final Story story;
  final int currentPageIndex;
  final bool isLastPage;
  final bool isFirstPage;
  final bool isQuestionsPage;

  const StoryReaderLoaded({
    required this.story,
    required this.currentPageIndex,
    required this.isLastPage,
    required this.isFirstPage,
    required this.isQuestionsPage,
  });

  @override
  List<Object?> get props => [
        story,
        currentPageIndex,
        isLastPage,
        isFirstPage,
        isQuestionsPage,
      ];

  /// Create a copy of this StoryReaderLoaded with the given fields replaced with the new values.
  StoryReaderLoaded copyWith({
    Story? story,
    int? currentPageIndex,
    bool? isLastPage,
    bool? isFirstPage,
    bool? isQuestionsPage,
  }) {
    return StoryReaderLoaded(
      story: story ?? this.story,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isLastPage: isLastPage ?? this.isLastPage,
      isFirstPage: isFirstPage ?? this.isFirstPage,
      isQuestionsPage: isQuestionsPage ?? this.isQuestionsPage,
    );
  }
}

/// State when there is an error loading or reading a story.
class StoryReaderError extends StoryReaderState {
  final String message;

  const StoryReaderError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when the story reader is being closed.
class StoryReaderClosing extends StoryReaderState {
  const StoryReaderClosing();
}

/// State when the story's favorite status is being toggled.
class StoryFavoriteToggling extends StoryReaderState {
  const StoryFavoriteToggling();
}

/// State when the story's favorite status has been toggled.
class StoryFavoriteToggled extends StoryReaderState {
  final bool isFavorite;

  const StoryFavoriteToggled({required this.isFavorite});

  @override
  List<Object?> get props => [isFavorite];
}
