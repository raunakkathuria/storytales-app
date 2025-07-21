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
  }

  /// Handle the LoadAllStories event.
  Future<void> _onLoadAllStories(
    LoadAllStories event,
    Emitter<LibraryState> emit,
  ) async {
    emit(const LibraryLoading());

    try {
      // Load pre-generated stories if this is the first time
      await _repository.loadPreGeneratedStories();

      // Get all stories
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
}
