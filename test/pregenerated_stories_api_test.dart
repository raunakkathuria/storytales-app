import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:storytales/core/services/local_storage/database_service.dart';
import 'package:storytales/features/library/data/repositories/story_repository_impl.dart';
import 'package:storytales/features/story_generation/data/datasources/story_api_client.dart';

import 'pregenerated_stories_api_test.mocks.dart';

@GenerateMocks([DatabaseService, StoryApiClient])
void main() {
  group('Pre-Generated Stories API Integration', () {
    late StoryRepositoryImpl repository;
    late MockDatabaseService mockDatabaseService;
    late MockStoryApiClient mockStoryApiClient;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockStoryApiClient = MockStoryApiClient();
      repository = StoryRepositoryImpl(
        databaseService: mockDatabaseService,
        storyApiClient: mockStoryApiClient,
      );
    });

    test('should load API pre-generated stories successfully', () async {
      // Arrange
      final mockApiStories = [
        {
          'id': 'story1',
          'title': 'The Magic Forest',
          'summary': 'A tale of wonder and discovery',
          'cover_image_url': 'https://example.com/cover1.jpg',
          'created_at': '2024-01-01T00:00:00Z',
          'age_range': '5-8',
          'reading_time': '3 minutes',
          'genre': 'Fantasy',
          'theme': 'Adventure'
        }
      ];

      when(mockStoryApiClient.fetchPreGeneratedStories())
          .thenAnswer((_) async => mockApiStories);

      // Mock database queries to simulate no existing stories
      when(mockDatabaseService.query(
        'stories',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      // Mock transaction
      when(mockDatabaseService.transaction(any))
          .thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as Function;
        final mockTxn = MockDatabaseService();
        when(mockTxn.insert(any, any)).thenAnswer((_) async => 1);
        await callback(mockTxn);
        return null;
      });

      // Act
      await repository.loadApiPreGeneratedStories();

      // Assert
      verify(mockStoryApiClient.fetchPreGeneratedStories()).called(1);
      verify(mockDatabaseService.query(
        'stories',
        where: 'id LIKE ?',
        whereArgs: ['api_pre_gen_%'],
      )).called(1);
      verify(mockDatabaseService.query(
        'stories',
        where: 'id = ?',
        whereArgs: ['api_pre_gen_story1'],
      )).called(1);
    });

    test('should not save duplicate API stories', () async {
      // Arrange
      final mockApiStories = [
        {
          'id': 'story1',
          'title': 'The Magic Forest',
          'summary': 'A tale of wonder and discovery',
          'cover_image_url': 'https://example.com/cover1.jpg',
          'created_at': '2024-01-01T00:00:00Z',
          'age_range': '5-8',
          'reading_time': '3 minutes',
          'genre': 'Fantasy',
          'theme': 'Adventure'
        }
      ];

      when(mockStoryApiClient.fetchPreGeneratedStories())
          .thenAnswer((_) async => mockApiStories);

      // Mock database to return existing story (simulate duplicate)
      when(mockDatabaseService.query(
        'stories',
        where: 'id LIKE ?',
        whereArgs: ['api_pre_gen_%'],
      )).thenAnswer((_) async => []);

      when(mockDatabaseService.query(
        'stories',
        where: 'id = ?',
        whereArgs: ['api_pre_gen_story1'],
      )).thenAnswer((_) async => [
        {'id': 'api_pre_gen_story1', 'title': 'Existing Story'}
      ]);

      // Act
      await repository.loadApiPreGeneratedStories();

      // Assert
      verify(mockStoryApiClient.fetchPreGeneratedStories()).called(1);
      // Should not call transaction since story already exists
      verifyNever(mockDatabaseService.transaction(any));
    });

    test('should handle API errors gracefully', () async {
      // Arrange
      when(mockStoryApiClient.fetchPreGeneratedStories())
          .thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        () => repository.loadApiPreGeneratedStories(),
        throwsException,
      );
    });
  });
}
