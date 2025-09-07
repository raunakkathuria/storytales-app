import 'package:storytales/features/library/domain/entities/story.dart';
import 'package:storytales/core/models/user_stories_response.dart';

/// Repository interface for managing stories.
abstract class StoryRepository {
  /// Get all stories from the local database.
  Future<List<Story>> getAllStories();

  /// Get favorite stories from the local database.
  Future<List<Story>> getFavoriteStories();

  /// Get a story by its ID.
  Future<Story> getStoryById(String id);

  /// Save a story to the local database.
  Future<void> saveStory(Story story);

  /// Update a story in the local database.
  Future<void> updateStory(Story story);

  /// Toggle the favorite status of a story.
  Future<void> toggleFavorite(String id);

  /// Fetch and load pre-generated stories from the API.
  Future<void> loadApiPreGeneratedStories();

  /// Fetch a single story by ID from the API and save it locally.
  Future<Story> fetchAndSaveApiStoryById(String storyId);

  /// Save an AI-generated story to the local database.
  Future<Story> saveAiGeneratedStory(Map<String, dynamic> aiResponse);

  /// Get user-generated stories with pagination.
  Future<UserStoriesResponse> getUserStories({
    required int userId,
    int page = 1,
    int limit = 10,
  });

  /// Get mixed stories (user + pre-generated) for homepage display.
  Future<List<Story>> getMixedStories({
    required int userId,
    int userStoriesPage = 1,
    int userStoriesLimit = 10,
  });
}
