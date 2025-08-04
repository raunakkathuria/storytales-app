import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/services/analytics/analytics_service.dart';
import 'package:storytales/features/library/domain/repositories/story_repository.dart';
import 'package:storytales/features/library/presentation/bloc/library_event.dart';
import 'package:storytales/features/library/presentation/bloc/library_state.dart';

/// BLoC for managing the library of stories.
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final StoryRepository _repository;
  final AnalyticsService _analyticsService;

  LibraryBloc({
    required StoryRepository repository,
    required AnalyticsService analyticsService,
  })  : _repository = repository,
        _analyticsService = analyticsService,
        super(const LibraryInitial()) {
    on<LoadAllStories>(_onLoadAllStories);
    on<LoadFavoriteStories>(_onLoadFavoriteStories);
    on<ToggleFavorite>(_onToggleFavorite);
    on<FilterByTab>(_onFilterByTab);
    on<LoadApiPreGeneratedStories>(_onLoadApiPreGeneratedStories);
    on<FetchApiStory>(_onFetchApiStory);
  }

  /// Handle the LoadAllStories event.
  Future<void> _onLoadAllStories(
    LoadAllStories event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoading());

    try {
      // Load pre-generated stories from assets if this is the first time
      await _repository.loadPreGeneratedStories();

      // Also try to load pre-generated stories from the API
      // This is done in the background and won't fail the entire operation
      try {
        await _repository.loadApiPreGeneratedStories();
      } catch (apiError) {
        // Log the API error but don't fail the entire operation
        await _analyticsService.logError(
          errorType: 'api_pregenerated_stories_background_load_error',
          errorMessage: apiError.toString(),
          errorDetails: 'Failed to load API stories in background during LoadAllStories',
        );
      }

      // Get all stories (including any newly loaded API stories)
      final stories = await _repository.getAllStories();

      if (stories.isEmpty) {
        emit(const LibraryEmpty(
          activeTab: LibraryTab.all,
          message: 'No stories found. Create your first story!',
        ));
      } else {
        emit(LibraryLoaded(
          stories: stories,
          activeTab: LibraryTab.all,
        ));
      }
    } catch (e) {
      emit(LibraryError(message: e.toString()));

      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'library_load_error',
        errorMessage: e.toString(),
      );
    }
  }

  /// Handle the LoadFavoriteStories event.
  Future<void> _onLoadFavoriteStories(
    LoadFavoriteStories event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoading());

    try {
      final stories = await _repository.getFavoriteStories();

      if (stories.isEmpty) {
        emit(const LibraryEmpty(
          activeTab: LibraryTab.favorites,
          message: 'No favorite stories yet. Mark stories as favorites to see them here!',
        ));
      } else {
        emit(LibraryLoaded(
          stories: stories,
          activeTab: LibraryTab.favorites,
        ));
      }
    } catch (e) {
      emit(LibraryError(message: e.toString()));

      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'favorites_load_error',
        errorMessage: e.toString(),
      );
    }
  }

  /// Handle the ToggleFavorite event.
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<LibraryState> emit,
  ) async {
    emit(FavoriteToggling(storyId: event.storyId));

    try {
      // Get the current story to check its favorite status
      final story = await _repository.getStoryById(event.storyId);
      final newFavoriteStatus = !story.isFavorite;

      // Toggle favorite status
      await _repository.toggleFavorite(event.storyId);

      // Log analytics event
      if (newFavoriteStatus) {
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

      emit(FavoriteToggled(
        storyId: event.storyId,
        isFavorite: newFavoriteStatus,
      ));

      // Reload the appropriate list based on the current tab
      if (state is LibraryLoaded) {
        final currentState = state as LibraryLoaded;
        if (currentState.activeTab == LibraryTab.all) {
          add(const LoadAllStories());
        } else {
          add(const LoadFavoriteStories());
        }
      } else {
        add(const LoadAllStories());
      }
    } catch (e) {
      emit(LibraryError(message: e.toString()));

      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'favorite_toggle_error',
        errorMessage: e.toString(),
      );
    }
  }


  /// Handle the FilterByTab event.
  void _onFilterByTab(
    FilterByTab event,
    Emitter<LibraryState> emit,
  ) {
    if (event.tab == LibraryTab.all) {
      add(const LoadAllStories());
    } else {
      add(const LoadFavoriteStories());
    }
  }

  /// Handle the LoadApiPreGeneratedStories event.
  Future<void> _onLoadApiPreGeneratedStories(
    LoadApiPreGeneratedStories event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      // Load pre-generated stories from the API
      await _repository.loadApiPreGeneratedStories();

      // Log analytics event for successful API story loading
      await _analyticsService.logEvent(
        eventName: 'api_pregenerated_stories_loaded',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // After loading API stories, refresh the current view
      // Check the current state to determine which tab to reload
      if (state is LibraryLoaded) {
        final currentState = state as LibraryLoaded;
        if (currentState.activeTab == LibraryTab.all) {
          add(const LoadAllStories());
        } else {
          add(const LoadFavoriteStories());
        }
      } else {
        // Default to loading all stories
        add(const LoadAllStories());
      }
    } catch (e) {
      // Don't emit an error state here, just log it
      // The user will still see their existing stories
      await _analyticsService.logError(
        errorType: 'api_pregenerated_stories_load_error',
        errorMessage: e.toString(),
        errorDetails: 'Failed to load pre-generated stories from API',
      );

      // Optionally, you could show a snackbar or toast message to inform the user
      // that new stories couldn't be loaded, but existing stories are still available
    }
  }

  /// Handle the FetchApiStory event.
  Future<void> _onFetchApiStory(
    FetchApiStory event,
    Emitter<LibraryState> emit,
  ) async {
    emit(ApiStoryFetching(storyId: event.storyId));

    try {
      // Fetch the full story from the API and save it locally
      await _repository.fetchAndSaveApiStoryById(event.storyId);

      // Log analytics event for successful API story fetch
      await _analyticsService.logEvent(
        eventName: 'api_story_fetched',
        parameters: {
          'story_id': event.storyId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      emit(ApiStoryFetched(storyId: event.storyId));
    } catch (e) {
      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'api_story_fetch_error',
        errorMessage: e.toString(),
        errorDetails: 'Failed to fetch API story with ID: ${event.storyId}',
      );

      emit(ApiStoryFetchError(
        storyId: event.storyId,
        message: e.toString(),
      ));
    }
  }
}
