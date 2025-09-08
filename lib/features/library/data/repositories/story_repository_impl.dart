import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'package:storytales/core/services/local_storage/database_service.dart';
import 'package:storytales/features/library/data/models/story_model.dart';
import 'package:storytales/features/library/domain/entities/story.dart';
import 'package:storytales/features/library/domain/repositories/story_repository.dart';
import 'package:storytales/features/story_generation/data/datasources/story_api_client.dart';
import 'package:storytales/core/services/api/user_api_client.dart';
import 'package:storytales/core/models/user_stories_response.dart';

/// Implementation of the [StoryRepository] interface.
class StoryRepositoryImpl implements StoryRepository {
  final DatabaseService _databaseService;
  final StoryApiClient _storyApiClient;
  final UserApiClient _userApiClient;
  final Uuid _uuid = const Uuid();

  StoryRepositoryImpl({
    required DatabaseService databaseService,
    required StoryApiClient storyApiClient,
    required UserApiClient userApiClient,
  }) : _databaseService = databaseService,
       _storyApiClient = storyApiClient,
       _userApiClient = userApiClient;

  @override
  Future<List<Story>> getAllStories() async {
    final storiesData = await _databaseService.query(
      'stories',
      orderBy: 'created_at DESC',
    );

    return Future.wait(storiesData.map((storyData) async {
      // Get pages for this story
      final pagesData = await _databaseService.query(
        'story_pages',
        where: 'story_id = ?',
        whereArgs: [storyData['id']],
        orderBy: 'page_number ASC',
      );
      final pages = pagesData
          .map((pageData) => StoryPageModel.fromDbMap(pageData))
          .toList();

      // Get tags for this story
      final tagsData = await _databaseService.query(
        'story_tags',
        where: 'story_id = ?',
        whereArgs: [storyData['id']],
      );
      final tags = tagsData.map((tagData) => tagData['tag'] as String).toList();

      // Get questions for this story
      final questionsData = await _databaseService.query(
        'story_questions',
        where: 'story_id = ?',
        whereArgs: [storyData['id']],
        orderBy: 'question_order ASC',
      );
      final questions = questionsData
          .map((questionData) => questionData['question_text'] as String)
          .toList();

      return StoryModel.fromDbMap(storyData, pages, tags, questions);
    }).toList());
  }

  @override
  Future<List<Story>> getFavoriteStories() async {
    final storiesData = await _databaseService.query(
      'stories',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );

    return Future.wait(storiesData.map((storyData) async {
      // Get pages for this story
      final pagesData = await _databaseService.query(
        'story_pages',
        where: 'story_id = ?',
        whereArgs: [storyData['id']],
        orderBy: 'page_number ASC',
      );
      final pages = pagesData
          .map((pageData) => StoryPageModel.fromDbMap(pageData))
          .toList();

      // Get tags for this story
      final tagsData = await _databaseService.query(
        'story_tags',
        where: 'story_id = ?',
        whereArgs: [storyData['id']],
      );
      final tags = tagsData.map((tagData) => tagData['tag'] as String).toList();

      // Get questions for this story
      final questionsData = await _databaseService.query(
        'story_questions',
        where: 'story_id = ?',
        whereArgs: [storyData['id']],
        orderBy: 'question_order ASC',
      );
      final questions = questionsData
          .map((questionData) => questionData['question_text'] as String)
          .toList();

      return StoryModel.fromDbMap(storyData, pages, tags, questions);
    }).toList());
  }

  @override
  Future<Story> getStoryById(String id) async {
    final storiesData = await _databaseService.query(
      'stories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (storiesData.isEmpty) {
      throw Exception('Story not found');
    }

    // Get pages for this story
    final pagesData = await _databaseService.query(
      'story_pages',
      where: 'story_id = ?',
      whereArgs: [id],
      orderBy: 'page_number ASC',
    );
    final pages =
        pagesData.map((pageData) => StoryPageModel.fromDbMap(pageData)).toList();

    // Get tags for this story
    final tagsData = await _databaseService.query(
      'story_tags',
      where: 'story_id = ?',
      whereArgs: [id],
    );
    final tags = tagsData.map((tagData) => tagData['tag'] as String).toList();

    // Get questions for this story
    final questionsData = await _databaseService.query(
      'story_questions',
      where: 'story_id = ?',
      whereArgs: [id],
      orderBy: 'question_order ASC',
    );
    final questions = questionsData
        .map((questionData) => questionData['question_text'] as String)
        .toList();

    return StoryModel.fromDbMap(storiesData.first, pages, tags, questions);
  }

  @override
  Future<void> saveStory(Story story) async {
    final storyModel = story as StoryModel;

    await _databaseService.transaction((txn) async {
      // Save story (upsert - insert or replace if exists)
      await txn.insert('stories', storyModel.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      // Delete existing related data to avoid duplicates
      await txn.delete('story_pages', where: 'story_id = ?', whereArgs: [storyModel.id]);
      await txn.delete('story_tags', where: 'story_id = ?', whereArgs: [storyModel.id]);
      await txn.delete('story_questions', where: 'story_id = ?', whereArgs: [storyModel.id]);

      // Save pages
      for (var page in storyModel.pages) {
        final pageModel = page as StoryPageModel;
        await txn.insert('story_pages', pageModel.toDbMap());
      }

      // Save tags
      for (var tag in storyModel.tags) {
        final tagModel = StoryTagModel(
          id: _uuid.v4(),
          storyId: storyModel.id,
          tag: tag,
        );
        await txn.insert('story_tags', tagModel.toDbMap());
      }

      // Save questions
      for (var i = 0; i < storyModel.questions.length; i++) {
        final questionModel = StoryQuestionModel(
          id: _uuid.v4(),
          storyId: storyModel.id,
          questionText: storyModel.questions[i],
          questionOrder: i,
        );
        await txn.insert('story_questions', questionModel.toDbMap());
      }
    });
  }

  @override
  Future<void> updateStory(Story story) async {
    final storyModel = story as StoryModel;

    await _databaseService.transaction((txn) async {
      // Update story
      await txn.update(
        'stories',
        storyModel.toDbMap(),
        where: 'id = ?',
        whereArgs: [storyModel.id],
      );

      // Delete existing pages, tags, and questions
      await txn.delete('story_pages', where: 'story_id = ?', whereArgs: [storyModel.id]);
      await txn.delete('story_tags', where: 'story_id = ?', whereArgs: [storyModel.id]);
      await txn.delete('story_questions', where: 'story_id = ?', whereArgs: [storyModel.id]);

      // Save pages
      for (var page in storyModel.pages) {
        final pageModel = page as StoryPageModel;
        await txn.insert('story_pages', pageModel.toDbMap());
      }

      // Save tags
      for (var tag in storyModel.tags) {
        final tagModel = StoryTagModel(
          id: _uuid.v4(),
          storyId: storyModel.id,
          tag: tag,
        );
        await txn.insert('story_tags', tagModel.toDbMap());
      }

      // Save questions
      for (var i = 0; i < storyModel.questions.length; i++) {
        final questionModel = StoryQuestionModel(
          id: _uuid.v4(),
          storyId: storyModel.id,
          questionText: storyModel.questions[i],
          questionOrder: i,
        );
        await txn.insert('story_questions', questionModel.toDbMap());
      }
    });
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final story = await getStoryById(id);
    final updatedStory = story.copyWith(isFavorite: !story.isFavorite);
    await updateStory(updatedStory);
  }

  @override
  Future<void> loadApiPreGeneratedStories() async {
    try {
      // Fetch pre-generated stories from the API
      final apiStories = await _storyApiClient.fetchPreGeneratedStories();

      // Convert API stories to StoryModel and save them
      for (var apiStoryJson in apiStories) {
        // Check if this specific story already exists (using UUID directly)
        final storyId = apiStoryJson['id'];
        final existingStory = await _databaseService.query(
          'stories',
          where: 'id = ?',
          whereArgs: [storyId],
        );

        // Only save if the story doesn't already exist
        if (existingStory.isEmpty) {
          final storyModel = StoryModel.fromApiPreGeneratedJson(apiStoryJson);
          await saveStory(storyModel);
        }
      }
    } catch (e) {
      // Re-throw the exception so the calling code can handle it appropriately
      // The StoryApiClient already provides user-friendly error messages
      rethrow;
    }
  }

  @override
  Future<Story> fetchAndSaveApiStoryById(String storyId) async {
    try {
      // Check if the story already exists locally (using UUID directly)
      try {
        final existingStory = await getStoryById(storyId);

        // Check if the existing story has full content or just summary
        if (existingStory.pages.length == 1 &&
            existingStory.pages.first.content.trim() == existingStory.summary.trim()) {
          // Continue to fetch from API to get full content
        } else {
          // If it has full content, return it
          return existingStory;
        }
      } catch (e) {
        // Story doesn't exist locally, continue to fetch from API
      }

      // Fetch the story from the API
      final apiStoryResponse = await _storyApiClient.fetchStoryById(storyId);

      // Convert API response to StoryModel
      final storyModel = StoryModel.fromSingleApiStoryJson(apiStoryResponse);

      // Save story to database (this will update the existing story if it exists)
      await updateStory(storyModel);

      return storyModel;
    } catch (e) {
      // Re-throw the exception so the calling code can handle it appropriately
      // The StoryApiClient already provides user-friendly error messages
      rethrow;
    }
  }

  @override
  Future<Story> saveAiGeneratedStory(Map<String, dynamic> aiResponse) async {
    // Create story model from AI response (uses API image URLs directly)
    final storyModel = StoryModel.fromAiResponseJson(aiResponse);

    // Save story to database
    await saveStory(storyModel);

    return storyModel;
  }

  @override
  Future<UserStoriesResponse> getUserStories({
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    // Directly call the UserApiClient to get user stories
    return await _userApiClient.getUserStories(
      userId: userId,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<Story>> getMixedStories({
    required String userId,
    int userStoriesPage = 1,
    int userStoriesLimit = 10,
  }) async {
    try {
      // Get user stories from API
      final userStoriesResponse = await _userApiClient.getUserStories(
        userId: userId,
        page: userStoriesPage,
        limit: userStoriesLimit,
      );
      
      // Convert UserStoryItem to Story entities
      final userStories = userStoriesResponse.stories.map((userStoryItem) {
        return Story(
          id: userStoryItem.id,
          title: userStoryItem.title,
          summary: userStoryItem.summary,
          pages: [
            // User stories from API typically have summary content only
            StoryPage(
              id: '${userStoryItem.id}_page_1',
              storyId: userStoryItem.id,
              pageNumber: 1,
              content: userStoryItem.summary,
              imagePath: userStoryItem.coverImagePath,
            ),
          ],
          questions: [], // User stories don't have questions in the API response
          coverImagePath: userStoryItem.coverImagePath,
          readingTime: userStoryItem.readingTime,
          createdAt: userStoryItem.createdAt,
          author: userStoryItem.author,
          ageRange: userStoryItem.ageRange,
          originalPrompt: userStoryItem.originalPrompt,
          genre: userStoryItem.genre,
          theme: userStoryItem.theme,
          tags: userStoryItem.tags,
          isPregenerated: false, // User stories are not pre-generated
          isFavorite: false, // Default to false, will be updated from database if needed
        );
      }).toList();

      // Get all pre-generated stories from local database
      final allLocalStories = await getAllStories();
      final preGeneratedStories = allLocalStories.where((story) => story.isPregenerated).toList();

      // Combine user stories first, then pre-generated stories
      return [...userStories, ...preGeneratedStories];
    } catch (e) {
      // If user stories API fails, just return pre-generated stories
      final allLocalStories = await getAllStories();
      return allLocalStories.where((story) => story.isPregenerated).toList();
    }
  }

}
