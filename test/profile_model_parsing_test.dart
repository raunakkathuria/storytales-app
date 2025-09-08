import 'package:flutter_test/flutter_test.dart';
import 'package:storytales/features/profile/data/models/user_profile_model.dart';

void main() {
  group('UserProfileModel Type Parsing Tests', () {
    test('should parse profile data from new API format', () {
      // This simulates the data format returned by the new API
      final newApiData = {
        'user_id': '550e8400-e29b-41d4-a716-446655440000',  // UUID format
        'display_name': 'John Doe',
        'email': 'john@example.com',
        'email_verified': true,
        'is_anonymous': false,
        'subscription_tier': 'premium',
        'stories_remaining': 10,
        'total_story_count': 5,      // New lifetime field
        'max_total_stories': 10,     // New lifetime field
        'session_id': 'login_1693234567_a1b2c3d4',
        'session_created_at': '2025-09-07T10:30:00Z',
        'is_authenticated': true,
      };

      // Act
      final model = UserProfileModel.fromJson(newApiData);

      // Assert
      expect(model.userId, equals('550e8400-e29b-41d4-a716-446655440000'));
      expect(model.displayName, equals('John Doe'));
      expect(model.email, equals('john@example.com'));
      expect(model.emailVerified, isTrue);
      expect(model.isAnonymous, isFalse);
      expect(model.subscriptionTier, equals('premium'));
      expect(model.storiesRemaining, equals(10));
      expect(model.totalStoryCount, equals(5));
      expect(model.maxTotalStories, equals(10));
      expect(model.sessionId, equals('login_1693234567_a1b2c3d4'));
      expect(model.isAuthenticated, isTrue);
    });

    test('should handle null values in new API format', () {
      // This simulates data with null/missing values
      final dataWithNulls = {
        'user_id': '550e8400-e29b-41d4-a716-446655440001',
        'display_name': null,
        'email': null,
        'email_verified': null,
        'is_anonymous': null,
        // subscription_tier missing entirely
        'stories_remaining': null,
        'total_story_count': null,
        'max_total_stories': null,
        'session_id': null,
        'session_created_at': null,
        'is_authenticated': null,
      };

      // Act
      final model = UserProfileModel.fromJson(dataWithNulls);

      // Assert
      expect(model.userId, equals('550e8400-e29b-41d4-a716-446655440001'));
      expect(model.displayName, isNull);
      expect(model.email, isNull);
      expect(model.emailVerified, isFalse); // Default value
      expect(model.isAnonymous, isTrue);    // Default value
      expect(model.subscriptionTier, equals('free')); // Default value
      expect(model.storiesRemaining, equals(0));      // Default value
      expect(model.totalStoryCount, equals(0));       // Default value
      expect(model.maxTotalStories, equals(0));       // Default value
      expect(model.sessionId, isNull);
      expect(model.isAuthenticated, isNull);
    });

    test('should handle string values that need conversion', () {
      // This simulates data that might come as strings needing conversion
      final stringData = {
        'user_id': '550e8400-e29b-41d4-a716-446655440002',
        'display_name': 'Test User',
        'email': 'test@example.com',
        'email_verified': 'true',     // String bool
        'is_anonymous': 'false',      // String bool
        'subscription_tier': 'free',
        'stories_remaining': '3',     // String int
        'total_story_count': '1',     // String int
        'max_total_stories': '3',     // String int
        'session_id': 'session-test-123',
        'is_authenticated': 'true',   // String bool
      };

      // Act
      final model = UserProfileModel.fromJson(stringData);

      // Assert
      expect(model.userId, equals('550e8400-e29b-41d4-a716-446655440002'));
      expect(model.displayName, equals('Test User'));
      expect(model.email, equals('test@example.com'));
      expect(model.emailVerified, isTrue);
      expect(model.isAnonymous, isFalse);
      expect(model.subscriptionTier, equals('free'));
      expect(model.storiesRemaining, equals(3));
      expect(model.totalStoryCount, equals(1));
      expect(model.maxTotalStories, equals(3));
      expect(model.sessionId, equals('session-test-123'));
      expect(model.isAuthenticated, isTrue);
    });

    test('should throw exception when required user_id is missing', () {
      final dataWithoutUserId = {
        'display_name': 'Test User',
        'email': 'test@example.com',
        'email_verified': true,
        'is_anonymous': false,
        'subscription_tier': 'free',
        'stories_remaining': 2,
        'total_story_count': 0,
        'max_total_stories': 3,
        // user_id is missing
      };

      // Act & Assert
      expect(
        () => UserProfileModel.fromJson(dataWithoutUserId),
        throwsA(predicate((e) => e.toString().contains('Story Wizard had trouble finding your profile'))),
      );
    });

    test('should throw exception when user_id is empty string', () {
      final dataWithEmptyUserId = {
        'user_id': '',   // Empty string
        'display_name': 'Test User',
        'email': 'test@example.com',
        'email_verified': true,
        'is_anonymous': false,
        'subscription_tier': 'free',
        'stories_remaining': 2,
        'total_story_count': 0,
        'max_total_stories': 3,
      };

      // Act & Assert
      expect(
        () => UserProfileModel.fromJson(dataWithEmptyUserId),
        throwsA(predicate((e) => e.toString().contains('account magic got mixed up'))),
      );
    });

    test('should handle boolean string variations correctly', () {
      final boolVariations = {
        'user_id': '550e8400-e29b-41d4-a716-446655440003',
        'display_name': 'Test User',
        'email': 'test@example.com',
        'email_verified': 'True',    // Capital T
        'is_anonymous': 'FALSE',     // All caps
        'subscription_tier': 'free',
        'stories_remaining': 2,
        'total_story_count': 0,
        'max_total_stories': 3,
        'is_authenticated': 'TRUE',  // All caps
      };

      // Act
      final model = UserProfileModel.fromJson(boolVariations);

      // Assert
      expect(model.emailVerified, isTrue);
      expect(model.isAnonymous, isFalse);
      expect(model.isAuthenticated, isTrue);
    });

    test('should handle datetime parsing correctly', () {
      final dataWithDatetime = {
        'user_id': '550e8400-e29b-41d4-a716-446655440004',
        'display_name': 'Test User',
        'email': 'test@example.com',
        'email_verified': true,
        'is_anonymous': false,
        'subscription_tier': 'free',
        'stories_remaining': 2,
        'total_story_count': 0,
        'max_total_stories': 3,
        'session_created_at': '2025-09-07T15:30:00Z',
        'is_authenticated': true,
      };

      // Act
      final model = UserProfileModel.fromJson(dataWithDatetime);

      // Assert
      expect(model.sessionCreatedAt, isNotNull);
      expect(model.sessionCreatedAt!.year, equals(2025));
      expect(model.sessionCreatedAt!.month, equals(9));
      expect(model.sessionCreatedAt!.day, equals(7));
    });
  });
}