import '../entities/user_profile.dart';
import '../entities/registration_request.dart';

/// Repository interface for profile operations.
abstract class ProfileRepository {
  /// Gets the current user profile.
  Future<UserProfile> getCurrentUserProfile();

  /// Updates the user's display name.
  Future<UserProfile> updateDisplayName(String displayName);

  /// Registers a new user with email.
  Future<RegistrationResponse> registerUser({
    required String email,
    required String displayName,
  });

  /// Verifies user registration with OTP code.
  Future<UserProfile> verifyRegistration({
    required String otpCode,
  });

  /// Logs in an existing user with email.
  Future<RegistrationResponse> loginUser({
    required String email,
  });

  /// Verifies user login with OTP code.
  Future<UserProfile> verifyLogin({
    required String sessionId,
    required String otpCode,
  });

  /// Signs out the current user (return to anonymous state).
  Future<void> signOut();

  /// Refreshes user profile from server.
  Future<UserProfile> refreshUserProfile();
}