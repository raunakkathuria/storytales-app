import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import 'package:storytales/core/widgets/responsive_icon.dart';
import 'package:storytales/features/profile/domain/entities/user_profile.dart';
import 'package:storytales/features/profile/presentation/widgets/profile_header.dart';

void main() {
  group('ProfileHeader Widget Tests', () {
    testWidgets('should display "Anonymous User" for anonymous profile', (tester) async {
      // Arrange
      const anonymousProfile = UserProfile(
        userId: 123,
        displayName: null,
        email: null,
        emailVerified: false,
        isAnonymous: true,
        subscriptionTier: 'free',
        storiesRemaining: 2,
        deviceId: 'device-123',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: anonymousProfile),
          ),
        ),
      );

      // Assert
      expect(find.text('Anonymous User'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.text('Anonymous Account'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should display user name with edit icon for registered profile', (tester) async {
      // Arrange
      const registeredProfile = UserProfile(
        userId: 456,
        displayName: 'John Doe',
        email: 'john@example.com',
        emailVerified: true,
        isAnonymous: false,
        subscriptionTier: 'premium',
        storiesRemaining: 10,
        deviceId: 'device-456',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: registeredProfile),
          ),
        ),
      );

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('Registered Account'), findsOneWidget);
      expect(find.byIcon(Icons.verified_user), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should handle registered user with null display name', (tester) async {
      // Arrange
      const registeredProfile = UserProfile(
        userId: 789,
        displayName: null,
        email: 'user@example.com',
        emailVerified: true,
        isAnonymous: false,
        subscriptionTier: 'free',
        storiesRemaining: 2,
        deviceId: 'device-789',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: registeredProfile),
          ),
        ),
      );

      // Assert
      expect(find.text('User'), findsOneWidget); // Falls back to 'User'
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('Registered Account'), findsOneWidget);
    });

    testWidgets('should not display email for anonymous user', (tester) async {
      // Arrange
      const anonymousProfile = UserProfile(
        userId: 123,
        displayName: 'Anonymous User',
        email: null,
        emailVerified: false,
        isAnonymous: true,
        subscriptionTier: 'free',
        storiesRemaining: 2,
        deviceId: 'device-123',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: anonymousProfile),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('@'), findsNothing);
    });

    testWidgets('should use correct icon colors based on profile state', (tester) async {
      // Arrange
      const registeredProfile = UserProfile(
        userId: 123,
        displayName: 'Test User',
        email: 'test@example.com',
        emailVerified: true,
        isAnonymous: false,
        subscriptionTier: 'free',
        storiesRemaining: 2,
        deviceId: 'device-123',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: registeredProfile),
          ),
        ),
      );

      // Assert - Check that proper icons are used
      final personIcon = tester.widget<ResponsiveIcon>(
        find.byWidgetPredicate((widget) => 
          widget is ResponsiveIcon && widget.icon == Icons.person
        ),
      );
      expect(personIcon.color, equals(StoryTalesTheme.primaryColor));

      final verifiedIcon = tester.widget<ResponsiveIcon>(
        find.byWidgetPredicate((widget) => 
          widget is ResponsiveIcon && widget.icon == Icons.verified_user
        ),
      );
      expect(verifiedIcon.color, equals(StoryTalesTheme.surfaceColor));
    });

    testWidgets('should display proper badge colors for different account types', (tester) async {
      // Test anonymous user badge
      const anonymousProfile = UserProfile(
        userId: 123,
        displayName: null,
        email: null,
        emailVerified: false,
        isAnonymous: true,
        subscriptionTier: 'free',
        storiesRemaining: 2,
        deviceId: 'device-123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(profile: anonymousProfile),
          ),
        ),
      );

      // Find the badge container for anonymous user
      final badgeContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(ProfileHeader),
          matching: find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == StoryTalesTheme.accentColor
          ),
        ),
      );
      expect(badgeContainer, isNotNull);
    });
  });
}