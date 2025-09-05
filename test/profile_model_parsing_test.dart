import 'package:flutter_test/flutter_test.dart';
import 'package:storytales/features/profile/data/models/user_profile_model.dart';

void main() {
  group('UserProfileModel Type Parsing Tests', () {
    test('should parse profile data from URL-encoded strings (AuthenticationService format)', () {
      // This simulates the data format returned by AuthenticationService
      // after parsing from URL-encoded SharedPreferences storage
      final urlEncodedData = {
        'id': '123',           // String instead of int
        'display_name': 'John Doe',
        'email': 'john@example.com',
        'email_verified': 'true',   // String instead of bool
        'is_anonymous': 'false',    // String instead of bool
        'subscription_tier': 'premium',
        'max_monthly_stories': '10',  // String instead of int
        'device_id': 'device-abc123',
      };

      // Act
      final model = UserProfileModel.fromJson(urlEncodedData);

      // Assert
      expect(model.userId, equals(123));
      expect(model.displayName, equals('John Doe'));
      expect(model.email, equals('john@example.com'));
      expect(model.emailVerified, isTrue);
      expect(model.isAnonymous, isFalse);
      expect(model.subscriptionTier, equals('premium'));
      expect(model.storiesRemaining, equals(10));
      expect(model.deviceId, equals('device-abc123'));
    });

    test('should handle null values in URL-encoded format', () {
      // This simulates data with null/missing values
      final dataWithNulls = {
        'id': '456',
        'display_name': 'null',      // String "null" should become null
        'email': 'null',             // String "null" should become null
        'email_verified': 'null',    // String "null" should use default
        'is_anonymous': 'null',      // String "null" should use default
        // subscription_tier missing entirely
        'max_monthly_stories': 'null', // String "null" should use default
        'device_id': 'device-def456',
      };

      // Act
      final model = UserProfileModel.fromJson(dataWithNulls);

      // Assert
      expect(model.userId, equals(456));
      expect(model.displayName, isNull);
      expect(model.email, isNull);
      expect(model.emailVerified, isFalse); // Default value
      expect(model.isAnonymous, isTrue);    // Default value
      expect(model.subscriptionTier, equals('free')); // Default value
      expect(model.storiesRemaining, equals(0));      // Default value
      expect(model.deviceId, equals('device-def456'));
    });

    test('should handle mixed data types correctly', () {
      // This simulates mixed data types that might come from different sources
      final mixedData = {
        'id': 789,              // Already an int
        'display_name': 'Test User',
        'email': null,               // Actually null, not string "null"
        'email_verified': false,     // Already a bool
        'is_anonymous': 'true',      // String bool
        'subscription_tier': 'free',
        'max_monthly_stories': '5',    // String int
        'device_id': 'device-ghi789',
      };

      // Act
      final model = UserProfileModel.fromJson(mixedData);

      // Assert
      expect(model.userId, equals(789));
      expect(model.displayName, equals('Test User'));
      expect(model.email, isNull);
      expect(model.emailVerified, isFalse);
      expect(model.isAnonymous, isTrue);
      expect(model.subscriptionTier, equals('free'));
      expect(model.storiesRemaining, equals(5));
      expect(model.deviceId, equals('device-ghi789'));
    });

    test('should throw exception when required userId is missing', () {
      final dataWithoutUserId = {
        'display_name': 'Test User',
        'email': 'test@example.com',
        'email_verified': 'true',
        'is_anonymous': 'false',
        'subscription_tier': 'free',
        'max_monthly_stories': '2',
        'device_id': 'device-test',
        // id is missing
      };

      // Act & Assert
      expect(
        () => UserProfileModel.fromJson(dataWithoutUserId),
        throwsA(predicate((e) => e.toString().contains('Story Wizard had trouble finding your profile'))),
      );
    });

    test('should throw exception when userId cannot be parsed', () {
      final dataWithInvalidUserId = {
        'id': 'not-a-number',   // Invalid integer string
        'display_name': 'Test User',
        'email': 'test@example.com',
        'email_verified': 'true',
        'is_anonymous': 'false',
        'subscription_tier': 'free',
        'max_monthly_stories': '2',
        'device_id': 'device-test',
      };

      // Act & Assert
      expect(
        () => UserProfileModel.fromJson(dataWithInvalidUserId),
        throwsA(predicate((e) => e.toString().contains('account magic got mixed up'))),
      );
    });

    test('should handle boolean string variations correctly', () {
      final boolVariations = {
        'id': '123',
        'display_name': 'Test User',
        'email': 'test@example.com',
        'email_verified': 'True',    // Capital T
        'is_anonymous': 'FALSE',     // All caps
        'subscription_tier': 'free',
        'max_monthly_stories': '2',
        'device_id': 'device-test',
      };

      // Act
      final model = UserProfileModel.fromJson(boolVariations);

      // Assert
      expect(model.emailVerified, isTrue);
      expect(model.isAnonymous, isFalse);
    });
  });
}