import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:storytales/core/services/api/user_api_client.dart';
import 'package:storytales/core/services/local_storage/database_service.dart';
import 'package:storytales/core/models/user_stories_response.dart';
import 'package:storytales/core/models/pagination_info.dart';
import 'package:storytales/features/library/data/repositories/story_repository_impl.dart';
import 'package:storytales/features/story_generation/data/datasources/story_api_client.dart';

import 'mixed_stories_integration_test.mocks.dart';

@GenerateMocks([DatabaseService, StoryApiClient, UserApiClient])
void main() {
  group('Mixed Stories Integration', () {
    late StoryRepositoryImpl repository;
    late MockDatabaseService mockDatabaseService;
    late MockStoryApiClient mockStoryApiClient;
    late MockUserApiClient mockUserApiClient;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockStoryApiClient = MockStoryApiClient();
      mockUserApiClient = MockUserApiClient();
      repository = StoryRepositoryImpl(
        databaseService: mockDatabaseService,
        storyApiClient: mockStoryApiClient,
        userApiClient: mockUserApiClient,
      );
    });

    test('should get mixed stories (user + pre-generated)', () async {
      // Arrange
      const userId = '123';
      const userStoriesPage = 1;
      const userStoriesLimit = 10;

      final mockUserStories = [
        UserStoryItem(
          id: 'user_story_1',
          title: 'My Adventure',
          summary: 'A user-generated story about adventure',
          coverImagePath: 'https://example.com/user1.jpg',
          createdAt: DateTime.now(),
          author: 'User',
          readingTime: '3 min',
          tags: ['adventure'],
        ),
      ];

      final mockUserStoriesResponse = UserStoriesResponse(
        stories: mockUserStories,
        pagination: const PaginationInfo(
          total: 1,
          currentPage: 1,
          totalPages: 1,
          hasNext: false,
          hasPrevious: false,
          limit: 10,
        ),
        subscriptionTier: 'free',
      );

      final mockPreGeneratedStories = [
        {
          'id': 'pre_story_1',
          'title': 'The Magic Forest',
          'summary': 'A pre-generated story',
          'cover_image_path': 'https://example.com/pre1.jpg',
          'created_at': DateTime.now().toIso8601String(),
          'author': 'StoryTales',
          'reading_time': '4 min',
          'tags': [],
          'is_pregenerated': 1,
          'is_favorite': 0,
        }
      ];

      // Mock user API call
      when(mockUserApiClient.getUserStories(
        userId: userId,
        page: userStoriesPage,
        limit: userStoriesLimit,
      )).thenAnswer((_) async => mockUserStoriesResponse);

      // Mock database calls for pre-generated stories
      when(mockDatabaseService.query('stories', orderBy: 'created_at DESC'))
          .thenAnswer((_) async => mockPreGeneratedStories);
      
      when(mockDatabaseService.query(
        'story_pages',
        where: 'story_id = ?',
        whereArgs: ['pre_story_1'],
        orderBy: 'page_number ASC',
      )).thenAnswer((_) async => [
        {
          'id': 'page_1',
          'story_id': 'pre_story_1',
          'page_number': 1,
          'content': 'Once upon a time...',
          'image_path': 'https://example.com/page1.jpg',
        }
      ]);

      when(mockDatabaseService.query(
        'story_tags',
        where: 'story_id = ?',
        whereArgs: ['pre_story_1'],
      )).thenAnswer((_) async => []);

      when(mockDatabaseService.query(
        'story_questions',
        where: 'story_id = ?',
        whereArgs: ['pre_story_1'],
        orderBy: 'question_order ASC',
      )).thenAnswer((_) async => []);

      // Act
      final result = await repository.getMixedStories(
        userId: userId,
        userStoriesPage: userStoriesPage,
        userStoriesLimit: userStoriesLimit,
      );

      // Assert
      expect(result.length, 2); // 1 user story + 1 pre-generated story
      
      // Check that user story comes first
      expect(result[0].title, 'My Adventure');
      expect(result[0].isPregenerated, false);
      
      // Check that pre-generated story comes second
      expect(result[1].title, 'The Magic Forest');
      expect(result[1].isPregenerated, true);

      // Verify API was called
      verify(mockUserApiClient.getUserStories(
        userId: userId,
        page: userStoriesPage,
        limit: userStoriesLimit,
      )).called(1);
    });

    test('should handle user stories API failure gracefully', () async {
      // Arrange
      const userId = '123';
      
      final mockPreGeneratedStories = [
        {
          'id': 'pre_story_1',
          'title': 'The Magic Forest',
          'summary': 'A pre-generated story',
          'cover_image_path': 'https://example.com/pre1.jpg',
          'created_at': DateTime.now().toIso8601String(),
          'author': 'StoryTales',
          'reading_time': '4 min',
          'tags': [],
          'is_pregenerated': 1,
          'is_favorite': 0,
        }
      ];

      // Mock user API to throw exception
      when(mockUserApiClient.getUserStories(
        userId: userId,
        page: anyNamed('page'),
        limit: anyNamed('limit'),
      )).thenThrow(Exception('API Error'));

      // Mock database calls for pre-generated stories fallback
      when(mockDatabaseService.query('stories', orderBy: 'created_at DESC'))
          .thenAnswer((_) async => mockPreGeneratedStories);
      
      when(mockDatabaseService.query(
        'story_pages',
        where: 'story_id = ?',
        whereArgs: ['pre_story_1'],
        orderBy: 'page_number ASC',
      )).thenAnswer((_) async => [
        {
          'id': 'page_1',
          'story_id': 'pre_story_1',
          'page_number': 1,
          'content': 'Once upon a time...',
          'image_path': 'https://example.com/page1.jpg',
        }
      ]);

      when(mockDatabaseService.query(
        'story_tags',
        where: 'story_id = ?',
        whereArgs: ['pre_story_1'],
      )).thenAnswer((_) async => []);

      when(mockDatabaseService.query(
        'story_questions',
        where: 'story_id = ?',
        whereArgs: ['pre_story_1'],
        orderBy: 'question_order ASC',
      )).thenAnswer((_) async => []);

      // Act
      final result = await repository.getMixedStories(
        userId: userId,
        userStoriesPage: 1,
        userStoriesLimit: 10,
      );

      // Assert
      expect(result.length, 1); // Only pre-generated stories
      expect(result[0].title, 'The Magic Forest');
      expect(result[0].isPregenerated, true);
    });
  });
}