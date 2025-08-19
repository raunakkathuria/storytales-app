import 'package:flutter_test/flutter_test.dart';
import 'package:storytales/features/library/data/models/story_model.dart';

void main() {
  group('Story Database Constraint Fix - Simple Tests', () {
    test('StoryModel.fromAiResponseJson should generate unique IDs for different calls', () {
      // Arrange - Create the same AI response data
      final aiResponse = {
        'metadata': {
          'created_at': '2024-01-01T00:00:00Z',
          'author': 'Test Author',
          'age_range': '3-5',
          'reading_time': '5 minutes',
          'original_prompt': 'A friendly dragon',
          'genre': 'Fantasy',
          'theme': 'Friendship',
          'tags': ['dragon', 'friendship'],
        },
        'data': {
          'title': 'The Friendly Dragon',
          'summary': 'A story about a friendly dragon',
          'cover_image_url': 'https://example.com/cover.jpg',
          'pages': [
            {
              'content': 'Once upon a time, there was a friendly dragon.',
              'image_url': 'https://example.com/page1.jpg',
            },
          ],
          'questions': ['What made the dragon friendly?'],
        },
      };

      // Act - Create multiple story models from the same response
      final story1 = StoryModel.fromAiResponseJson(aiResponse);
      final story2 = StoryModel.fromAiResponseJson(aiResponse);
      final story3 = StoryModel.fromAiResponseJson(aiResponse);

      // Assert - Each story should have a unique ID
      expect(story1.id, isNot(equals(story2.id)));
      expect(story1.id, isNot(equals(story3.id)));
      expect(story2.id, isNot(equals(story3.id)));

      // All IDs should start with 'ai_gen_' prefix
      expect(story1.id, startsWith('ai_gen_'));
      expect(story2.id, startsWith('ai_gen_'));
      expect(story3.id, startsWith('ai_gen_'));

      // All stories should have the same content but different IDs
      expect(story1.title, equals(story2.title));
      expect(story1.title, equals(story3.title));
      expect(story1.summary, equals(story2.summary));
      expect(story1.summary, equals(story3.summary));
    });

    test('Story model should have consistent structure for database operations', () {
      // Arrange
      final aiResponse = {
        'metadata': {
          'created_at': '2024-01-01T00:00:00Z',
          'author': 'Test Author',
          'age_range': '3-5',
          'reading_time': '5 minutes',
          'original_prompt': 'A friendly dragon',
          'genre': 'Fantasy',
          'theme': 'Friendship',
          'tags': ['dragon', 'friendship'],
        },
        'data': {
          'title': 'The Friendly Dragon',
          'summary': 'A story about a friendly dragon',
          'cover_image_url': 'https://example.com/cover.jpg',
          'pages': [
            {
              'content': 'Once upon a time, there was a friendly dragon.',
              'image_url': 'https://example.com/page1.jpg',
            },
          ],
          'questions': ['What made the dragon friendly?'],
        },
      };

      // Act
      final story = StoryModel.fromAiResponseJson(aiResponse);
      final dbMap = story.toDbMap();

      // Assert - Database map should contain all required fields
      expect(dbMap['id'], isNotNull);
      expect(dbMap['title'], equals('The Friendly Dragon'));
      expect(dbMap['summary'], equals('A story about a friendly dragon'));
      expect(dbMap['cover_image_path'], equals('https://example.com/cover.jpg'));
      expect(dbMap['created_at'], isNotNull);
      expect(dbMap['author'], equals('Test Author'));
      expect(dbMap['age_range'], equals('3-5'));
      expect(dbMap['reading_time'], equals('5 minutes'));
      expect(dbMap['original_prompt'], equals('A friendly dragon'));
      expect(dbMap['genre'], equals('Fantasy'));
      expect(dbMap['theme'], equals('Friendship'));
      expect(dbMap['is_pregenerated'], equals(0)); // false for AI generated
      expect(dbMap['is_favorite'], equals(0)); // false by default

      // Story should have pages
      expect(story.pages, isNotEmpty);
      expect(story.pages.first.content, equals('Once upon a time, there was a friendly dragon.'));
      expect(story.pages.first.imagePath, equals('https://example.com/page1.jpg'));

      // Story should have questions
      expect(story.questions, isNotEmpty);
      expect(story.questions.first, equals('What made the dragon friendly?'));

      // Story should have tags
      expect(story.tags, contains('dragon'));
      expect(story.tags, contains('friendship'));
    });
  });
}
