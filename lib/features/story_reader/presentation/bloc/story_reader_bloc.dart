import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/services/analytics/analytics_service.dart';
import 'package:storytales/features/library/domain/repositories/story_repository.dart';
import 'package:storytales/features/story_reader/presentation/bloc/story_reader_event.dart';
import 'package:storytales/features/story_reader/presentation/bloc/story_reader_state.dart';

/// BLoC for managing the story reader.
class StoryReaderBloc extends Bloc<StoryReaderEvent, StoryReaderState> {
  final StoryRepository _repository;
  final AnalyticsService _analyticsService;

  StoryReaderBloc({
    required StoryRepository repository,
    required AnalyticsService analyticsService,
  })  : _repository = repository,
        _analyticsService = analyticsService,
        super(const StoryReaderInitial()) {
    on<LoadStory>(_onLoadStory);
    on<NextPage>(_onNextPage);
    on<PreviousPage>(_onPreviousPage);
    on<GoToPage>(_onGoToPage);
    on<ToggleStoryFavorite>(_onToggleStoryFavorite);
    on<CloseReader>(_onCloseReader);
  }

  /// Handle the LoadStory event.
  Future<void> _onLoadStory(
    LoadStory event,
    Emitter<StoryReaderState> emit,
  ) async {
    emit(const StoryReaderLoading());

    try {
      final story = await _repository.getStoryById(event.storyId);

      // Log analytics event for story viewed
      await _analyticsService.logStoryViewed(
        storyId: story.id,
        storyTitle: story.title,
        isPregenerated: story.isPregenerated,
      );

      // Initialize with the first page
      emit(StoryReaderLoaded(
        story: story,
        currentPageIndex: 0,
        isFirstPage: true,
        isLastPage: story.pages.length == 1,
        isQuestionsPage: false,
      ));
    } catch (e) {
      emit(StoryReaderError(message: e.toString()));

      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'story_reader_load_error',
        errorMessage: e.toString(),
      );
    }
  }

  /// Handle the NextPage event.
  void _onNextPage(
    NextPage event,
    Emitter<StoryReaderState> emit,
  ) {
    if (state is StoryReaderLoaded) {
      final currentState = state as StoryReaderLoaded;
      final story = currentState.story;
      final nextPageIndex = currentState.currentPageIndex + 1;

      // Check if we're moving to the questions page
      final isQuestionsPage = nextPageIndex >= story.pages.length;

      // Check if we're on the last page (questions page)
      final isLastPage = isQuestionsPage;

      emit(currentState.copyWith(
        currentPageIndex: nextPageIndex,
        isFirstPage: false,
        isLastPage: isLastPage,
        isQuestionsPage: isQuestionsPage,
      ));
    }
  }

  /// Handle the PreviousPage event.
  void _onPreviousPage(
    PreviousPage event,
    Emitter<StoryReaderState> emit,
  ) {
    if (state is StoryReaderLoaded) {
      final currentState = state as StoryReaderLoaded;

      // If we're on the questions page, go back to the last story page
      if (currentState.isQuestionsPage) {
        final lastPageIndex = currentState.story.pages.length - 1;
        emit(currentState.copyWith(
          currentPageIndex: lastPageIndex,
          isFirstPage: lastPageIndex == 0,
          isLastPage: false,
          isQuestionsPage: false,
        ));
        return;
      }

      // Otherwise, go to the previous page
      final previousPageIndex = currentState.currentPageIndex - 1;
      if (previousPageIndex >= 0) {
        emit(currentState.copyWith(
          currentPageIndex: previousPageIndex,
          isFirstPage: previousPageIndex == 0,
          isLastPage: false,
          isQuestionsPage: false,
        ));
      }
    }
  }

  /// Handle the GoToPage event.
  void _onGoToPage(
    GoToPage event,
    Emitter<StoryReaderState> emit,
  ) {
    if (state is StoryReaderLoaded) {
      final currentState = state as StoryReaderLoaded;
      final story = currentState.story;

      // Ensure the page index is valid
      if (event.pageIndex < 0 || event.pageIndex > story.pages.length) {
        return;
      }

      // Check if we're going to the questions page
      final isQuestionsPage = event.pageIndex == story.pages.length;

      emit(currentState.copyWith(
        currentPageIndex: event.pageIndex,
        isFirstPage: event.pageIndex == 0,
        isLastPage: isQuestionsPage,
        isQuestionsPage: isQuestionsPage,
      ));
    }
  }

  /// Handle the ToggleStoryFavorite event.
  Future<void> _onToggleStoryFavorite(
    ToggleStoryFavorite event,
    Emitter<StoryReaderState> emit,
  ) async {
    if (state is StoryReaderLoaded) {
      final currentState = state as StoryReaderLoaded;
      final story = currentState.story;

      emit(const StoryFavoriteToggling());

      try {
        // Toggle favorite status
        await _repository.toggleFavorite(story.id);

        // Get the updated story
        final updatedStory = await _repository.getStoryById(story.id);

        // Log analytics event
        if (updatedStory.isFavorite) {
          await _analyticsService.logStoryFavorited(
            storyId: story.id,
            storyTitle: story.title,
          );
        } else {
          await _analyticsService.logStoryUnfavorited(
            storyId: story.id,
            storyTitle: story.title,
          );
        }

        emit(StoryFavoriteToggled(isFavorite: updatedStory.isFavorite));

        // Restore the reader state with the updated story
        emit(currentState.copyWith(story: updatedStory));
      } catch (e) {
        emit(StoryReaderError(message: e.toString()));

        // Log analytics event for error
        await _analyticsService.logError(
          errorType: 'story_favorite_toggle_error',
          errorMessage: e.toString(),
        );

        // Restore the reader state
        emit(currentState);
      }
    }
  }

  /// Handle the CloseReader event.
  void _onCloseReader(
    CloseReader event,
    Emitter<StoryReaderState> emit,
  ) {
    emit(const StoryReaderClosing());
  }
}
