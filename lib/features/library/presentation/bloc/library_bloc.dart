import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/services/analytics/analytics_service.dart';
import 'package:storytales/core/services/auth/authentication_service.dart';
import 'package:storytales/features/library/domain/entities/story.dart';
import 'package:storytales/features/library/domain/repositories/story_repository.dart';
import 'package:storytales/features/library/presentation/bloc/library_event.dart';
import 'package:storytales/features/library/presentation/bloc/library_state.dart';

/// BLoC for managing the library of stories.
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final StoryRepository _repository;
  final AnalyticsService _analyticsService;
  final AuthenticationService _authService;

  LibraryBloc({
    required StoryRepository repository,
    required AnalyticsService analyticsService,
    required AuthenticationService authService,
  })  : _repository = repository,
        _analyticsService = analyticsService,
        _authService = authService,
        super(const LibraryInitial()) {
    on<LoadAllStories>(_onLoadAllStories);
    on<LoadFavoriteStories>(_onLoadFavoriteStories);
    on<ToggleFavorite>(_onToggleFavorite);
    on<FilterByTab>(_onFilterByTab);
    on<LoadApiPreGeneratedStories>(_onLoadApiPreGeneratedStories);
    on<FetchApiStory>(_onFetchApiStory);
    on<RetryLoadStories>(_onRetryLoadStories);
    on<LoadMoreUserStories>(_onLoadMoreUserStories);
  }

  /// Handle the LoadAllStories event.
  Future<void> _onLoadAllStories(
    LoadAllStories event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoading());

    try {
      // Get current user ID from authentication service
      final userProfileData = await _authService.getCurrentUserProfile();
      
      late List<Story> stories;
      
      if (userProfileData != null) {
        final userId = userProfileData['id'] as String;
        // User is authenticated - get mixed stories (user + pre-generated)
        try {
          // First ensure pre-generated stories are loaded from API
          try {
            await _repository.loadApiPreGeneratedStories();
          } catch (pregenError) {
            // Log but continue - we can still show user stories even if pre-generated fail
            await _analyticsService.logError(
              errorType: 'pregenerated_stories_load_error',
              errorMessage: pregenError.toString(),
              errorDetails: 'Failed to load pre-generated stories, will show user stories only',
            );
          }
          
          stories = await _repository.getMixedStories(
            userId: userId,
            userStoriesPage: 1,
            userStoriesLimit: 10,
          );
        } catch (e) {
          // If mixed stories fail, fall back to pre-generated only
          await _analyticsService.logError(
            errorType: 'mixed_stories_load_error',
            errorMessage: e.toString(),
            errorDetails: 'Failed to load mixed stories, falling back to pre-generated only',
          );
          
          // Load pre-generated stories only
          await _repository.loadApiPreGeneratedStories();
          final allStories = await _repository.getAllStories();
          stories = allStories.where((story) => story.isPregenerated).toList();
        }
      } else {
        // User not authenticated - show only pre-generated stories
        try {
          await _repository.loadApiPreGeneratedStories();
          final allStories = await _repository.getAllStories();
          stories = allStories.where((story) => story.isPregenerated).toList();
        } catch (apiError) {
          // If no existing stories and API failed, check if it's a network error
          if (_isNetworkError(apiError)) {
            emit(const LibraryEmpty(
              activeTab: LibraryTab.all,
              message: 'Please connect to the internet to load stories',
              showRetryButton: true,
            ));
          } else {
            emit(const LibraryEmpty(
              activeTab: LibraryTab.all,
              message: 'Unable to load stories. Please check your connection and try again.',
              showRetryButton: true,
            ));
          }

          await _analyticsService.logError(
            errorType: 'api_pregenerated_stories_load_error',
            errorMessage: apiError.toString(),
            errorDetails: 'Failed to load API stories during initial LoadAllStories',
          );
          return;
        }
      }

      if (stories.isEmpty) {
        emit(LibraryEmpty(
          activeTab: LibraryTab.all,
          message: userProfileData != null 
            ? 'Create your first story to get started! Tap the + button to begin your storytelling journey.'
            : 'Please connect to the internet to load stories',
          showRetryButton: userProfileData == null, // Only show retry for connectivity issues
        ));
      } else {
        // Check if user has more stories by looking at the response
        bool hasMoreUserStories = true;
        if (userProfileData != null) {
          final userId = userProfileData['id'] as String;
          try {
            final userStoriesResponse = await _repository.getUserStories(
              userId: userId,
              page: 1,
              limit: 10,
            );
            hasMoreUserStories = userStoriesResponse.pagination.hasNext;
          } catch (e) {
            hasMoreUserStories = false;
          }
        }
        
        emit(LibraryLoaded(
          stories: stories,
          activeTab: LibraryTab.all,
          currentUserStoriesPage: 1,
          hasMoreUserStories: hasMoreUserStories,
          isLoadingMore: false,
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

  /// Handle the RetryLoadStories event.
  Future<void> _onRetryLoadStories(
    RetryLoadStories event,
    Emitter<LibraryState> emit,
  ) async {
    // Simply trigger LoadAllStories again
    add(const LoadAllStories());
  }

  /// Handle the LoadMoreUserStories event for pagination.
  Future<void> _onLoadMoreUserStories(
    LoadMoreUserStories event,
    Emitter<LibraryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LibraryLoaded) return;
    
    // Check if already loading or no more stories
    if (currentState.isLoadingMore || !currentState.hasMoreUserStories) return;

    // Get current user ID
    final userProfileData = await _authService.getCurrentUserProfile();
    if (userProfileData == null) return;
    
    final userId = userProfileData['user_id'] as String;

    // Set loading state
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentUserStoriesPage + 1;
      
      // Get next page of user stories
      final userStoriesResponse = await _repository.getUserStories(
        userId: userId,
        page: nextPage,
        limit: 10,
      );

      // Convert to Story entities
      final newUserStories = userStoriesResponse.stories.map((userStoryItem) {
        return Story(
          id: userStoryItem.id,
          title: userStoryItem.title,
          summary: userStoryItem.summary,
          pages: [
            StoryPage(
              id: '${userStoryItem.id}_page_1',
              storyId: userStoryItem.id,
              pageNumber: 1,
              content: userStoryItem.summary,
              imagePath: userStoryItem.coverImagePath,
            ),
          ],
          questions: [],
          coverImagePath: userStoryItem.coverImagePath,
          readingTime: userStoryItem.readingTime,
          createdAt: userStoryItem.createdAt,
          author: userStoryItem.author,
          ageRange: userStoryItem.ageRange,
          originalPrompt: userStoryItem.originalPrompt,
          genre: userStoryItem.genre,
          theme: userStoryItem.theme,
          tags: userStoryItem.tags,
          isPregenerated: false,
          isFavorite: false,
        );
      }).toList();

      // Separate current user stories from pre-generated stories
      final currentUserStories = currentState.stories.where((story) => !story.isPregenerated).toList();
      final preGeneratedStories = currentState.stories.where((story) => story.isPregenerated).toList();

      // Combine all user stories (existing + new) and pre-generated stories
      final allStories = [...currentUserStories, ...newUserStories, ...preGeneratedStories];

      emit(currentState.copyWith(
        stories: allStories,
        currentUserStoriesPage: nextPage,
        hasMoreUserStories: userStoriesResponse.pagination.hasNext,
        isLoadingMore: false,
      ));

    } catch (e) {
      // Error loading more stories
      emit(currentState.copyWith(isLoadingMore: false));
      
      await _analyticsService.logError(
        errorType: 'load_more_user_stories_error',
        errorMessage: e.toString(),
        errorDetails: 'Failed to load more user stories on page ${currentState.currentUserStoriesPage + 1}',
      );
    }
  }

  /// Check if an error is a network-related error.
  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('unreachable') ||
           errorString.contains('no internet') ||
           errorString.contains('socketexception');
  }
}
