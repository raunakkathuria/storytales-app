import 'package:storytales/features/library/domain/entities/story.dart';

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


  /// Load pre-generated stories from the assets and save them to the local database.
  Future<void> loadPreGeneratedStories();

  /// Fetch and load pre-generated stories from the API.
  Future<void> loadApiPreGeneratedStories();

  /// Fetch a single story by ID from the API and save it locally.
  Future<Story> fetchAndSaveApiStoryById(String storyId);

  /// Save an AI-generated story to the local database.
  Future<Story> saveAiGeneratedStory(Map<String, dynamic> aiResponse);
}
