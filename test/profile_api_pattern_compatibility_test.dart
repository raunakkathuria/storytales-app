import 'package:flutter_test/flutter_test.dart';
import 'package:storytales/features/profile/domain/entities/user_profile.dart';

void main() {
  group('UserProfile API Pattern Compatibility Tests', () {
    group('Current API Pattern (is_anonymous stays true until verification)', () {
      test('truly anonymous user should allow registration', () {
        final profile = UserProfile(
          userId: 1,
          displayName: null,
          email: null,
          emailVerified: false,
          isAnonymous: true,
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        expect(profile.canRegister, isTrue);
        expect(profile.canLogin, isFalse);
        expect(profile.hasRegisteredAccount, isFalse);
        expect(profile.needsEmailVerification, isFalse);
        expect(profile.isFullyVerified, isFalse);
      });

      test('registered but unverified user (current API pattern)', () {
        // This matches your actual API response:
        // 'display_name': 'Raunak',
        // 'email': 'raunakkathuria@gmail.com',
        // 'is_anonymous': True,  <- stays true until verification
        // 'email_verified': False
        final profile = UserProfile(
          userId: 1015,
          displayName: 'Raunak',
          email: 'raunakkathuria@gmail.com',
          emailVerified: false,
          isAnonymous: true, // Still true in current API
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        expect(profile.canRegister, isFalse);         // Has email + name
        expect(profile.canLogin, isTrue);             // Has account but unverified
        expect(profile.hasRegisteredAccount, isTrue); // Has email + name
        expect(profile.needsEmailVerification, isTrue); // Has account but unverified
        expect(profile.isFullyVerified, isFalse);     // Not verified yet
      });

      test('fully verified user (current API pattern)', () {
        final profile = UserProfile(
          userId: 1015,
          displayName: 'Raunak',
          email: 'raunakkathuria@gmail.com',
          emailVerified: true,  // Now verified
          isAnonymous: false,   // Now false after verification
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        expect(profile.canRegister, isFalse);
        expect(profile.canLogin, isFalse);            // No need to login
        expect(profile.hasRegisteredAccount, isTrue);
        expect(profile.needsEmailVerification, isFalse); // Already verified
        expect(profile.isFullyVerified, isTrue);      // Fully verified
      });
    });

    group('Future API Pattern (is_anonymous becomes false after registration)', () {
      test('truly anonymous user should allow registration', () {
        final profile = UserProfile(
          userId: 1,
          displayName: null,
          email: null,
          emailVerified: false,
          isAnonymous: true,
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        expect(profile.canRegister, isTrue);
        expect(profile.canLogin, isFalse);
        expect(profile.hasRegisteredAccount, isFalse);
        expect(profile.needsEmailVerification, isFalse);
        expect(profile.isFullyVerified, isFalse);
      });

      test('registered but unverified user (future API pattern)', () {
        // Future improved API pattern:
        // 'display_name': 'Raunak',
        // 'email': 'raunakkathuria@gmail.com',
        // 'is_anonymous': False,  <- becomes false after registration
        // 'email_verified': False
        final profile = UserProfile(
          userId: 1015,
          displayName: 'Raunak',
          email: 'raunakkathuria@gmail.com',
          emailVerified: false,
          isAnonymous: false, // False after registration in future API
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        expect(profile.canRegister, isFalse);         // Has email + name
        expect(profile.canLogin, isTrue);             // Has account but unverified
        expect(profile.hasRegisteredAccount, isTrue); // Not anonymous + has email
        expect(profile.needsEmailVerification, isTrue); // Has account but unverified
        expect(profile.isFullyVerified, isFalse);     // Not verified yet
      });

      test('fully verified user (future API pattern)', () {
        final profile = UserProfile(
          userId: 1015,
          displayName: 'Raunak',
          email: 'raunakkathuria@gmail.com',
          emailVerified: true,  // Verified
          isAnonymous: false,   // False after registration
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        expect(profile.canRegister, isFalse);
        expect(profile.canLogin, isFalse);            // No need to login
        expect(profile.hasRegisteredAccount, isTrue);
        expect(profile.needsEmailVerification, isFalse); // Already verified
        expect(profile.isFullyVerified, isTrue);      // Fully verified
      });
    });

    group('Edge Cases', () {
      test('user with email but no display name', () {
        final profile = UserProfile(
          userId: 1,
          displayName: null, // Missing display name
          email: 'user@example.com',
          emailVerified: false,
          isAnonymous: true,
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        // Should not be considered registered without both email AND display name
        expect(profile.hasRegisteredAccount, isFalse);
        expect(profile.canRegister, isFalse); // Can't register because already has partial data
        expect(profile.canLogin, isFalse);    // Can't login because not fully registered
        expect(profile.needsEmailVerification, isFalse);
      });

      test('user with display name but no email', () {
        final profile = UserProfile(
          userId: 1,
          displayName: 'John',
          email: null, // Missing email
          emailVerified: false,
          isAnonymous: true,
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        // Should not be considered registered without both email AND display name
        expect(profile.hasRegisteredAccount, isFalse);
        expect(profile.canRegister, isFalse); // Can't register because already has partial data
        expect(profile.canLogin, isFalse);    // Can't login because not fully registered
        expect(profile.needsEmailVerification, isFalse);
      });
    });
  });
}