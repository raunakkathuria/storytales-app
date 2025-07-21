import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:storytales/core/services/image/image_service.dart';
import 'package:storytales/core/services/local_storage/database_service.dart';
import 'package:storytales/features/library/data/models/story_model.dart';
import 'package:storytales/features/library/domain/entities/story.dart';
import 'package:storytales/features/library/domain/repositories/story_repository.dart';

/// Implementation of the [StoryRepository] interface.
class StoryRepositoryImpl implements StoryRepository {
  final DatabaseService _databaseService;
  final Uuid _uuid = const Uuid();

  StoryRepositoryImpl({required DatabaseService databaseService})
      : _databaseService = databaseService;

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
      // Save story
      await txn.insert('stories', storyModel.toDbMap());

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
  Future<void> loadPreGeneratedStories() async {
    // Check if pre-generated stories are already loaded
    final existingStories = await _databaseService.query(
      'stories',
      where: 'is_pregenerated = ?',
      whereArgs: [1],
    );

    if (existingStories.isNotEmpty) {
      // Pre-generated stories already loaded
      return;
    }

    // Load pre-generated stories from JSON asset
    final jsonString = await rootBundle.loadString('assets/data/pre_generated_stories.json');
    final jsonData = json.decode(jsonString);
    final stories = (jsonData['stories'] as List)
        .map((storyJson) => StoryModel.fromPreGeneratedJson(storyJson))
        .toList();

    // Save pre-generated stories to database
    for (var story in stories) {
      await saveStory(story);
    }
  }

  @override
  Future<Story> saveAiGeneratedStory(Map<String, dynamic> aiResponse) async {
    // Create story model from AI response
    final storyModel = StoryModel.fromAiResponseJson(aiResponse);

    // Download and save images locally
    final updatedStoryModel = await _downloadAndSaveImages(storyModel);

    // Save story to database
    await saveStory(updatedStoryModel);

    return updatedStoryModel;
  }

  /// Downloads images from URLs and saves them locally.
  /// Returns an updated story model with local image paths.
  Future<StoryModel> _downloadAndSaveImages(StoryModel storyModel) async {
    final imageService = ImageService();

    // Process cover image
    String updatedCoverImagePath;
    final coverImageUrl = storyModel.coverImagePath;

    if (coverImageUrl.startsWith('http')) {
      // Download and cache the cover image
      final coverImageFileName = 'cover_${storyModel.id}.webp';
      updatedCoverImagePath = await imageService.downloadAndCacheImage(
        coverImageUrl,
        coverImageFileName
      );
    } else if (coverImageUrl.isEmpty) {
      // Empty URL, use fallback
      updatedCoverImagePath = ImageService.placeholderImagePath;
    } else {
      // Use the existing path
      updatedCoverImagePath = coverImageUrl;
    }

    // Process page images
    final updatedPages = <StoryPageModel>[];
    for (var i = 0; i < storyModel.pages.length; i++) {
      final page = storyModel.pages[i] as StoryPageModel;
      final pageImageUrl = page.imagePath;
      String updatedPageImagePath;

      if (pageImageUrl.startsWith('http')) {
        // Download and cache the page image
        final pageImageFileName = 'page_${storyModel.id}_$i.webp';
        updatedPageImagePath = await imageService.downloadAndCacheImage(
          pageImageUrl,
          pageImageFileName
        );
      } else if (pageImageUrl.isEmpty) {
        // Empty URL, use fallback
        updatedPageImagePath = ImageService.placeholderImagePath;
      } else {
        // Use the existing path
        updatedPageImagePath = pageImageUrl;
      }

      updatedPages.add(page.copyWith(imagePath: updatedPageImagePath));
    }

    return storyModel.copyWith(
      coverImagePath: updatedCoverImagePath,
      pages: updatedPages,
    );
  }
}
