import 'package:storytales/features/authentication/data/models/user_profile_model.dart';

/// Interface for authentication data sources.
///
/// This interface defines the contract that any authentication data source
/// implementation must fulfill. It provides methods for user authentication,
/// profile management, and session handling.
abstract class AuthDataSource {
  /// Gets the current user profile, if authenticated.
  ///
  /// Returns a [UserProfileModel] if the user is authenticated, or null if not.
  Future<UserProfileModel?> getCurrentUser();

  /// Checks if the user is currently authenticated.
  ///
  /// Returns true if the user is authenticated, false otherwise.
  Future<bool> isAuthenticated();

  /// Sends a sign-in link to the provided email address.
  ///
  /// [email] - The email address to send the sign-in link to.
  /// [continueUrl] - The URL to redirect to after authentication.
  ///
  /// Returns true if the email was sent successfully, false otherwise.
  Future<bool> sendSignInLinkToEmail(String email, String continueUrl);

  /// Signs in a user with an email link.
  ///
  /// [email] - The email address used for authentication.
  /// [emailLink] - The email link received for authentication.
  ///
  /// Returns the authenticated [UserProfileModel] if successful, or throws an exception.
  Future<UserProfileModel> signInWithEmailLink(String email, String emailLink);

  /// Sends a one-time password (OTP) to the provided email address.
  ///
  /// [email] - The email address to send the OTP to.
  ///
  /// Returns true if the OTP was sent successfully, false otherwise.
  Future<bool> sendOtpToEmail(String email);

  /// Verifies a one-time password (OTP) for the provided email address.
  ///
  /// [email] - The email address used for authentication.
  /// [otp] - The OTP code entered by the user.
  ///
  /// Returns the authenticated [UserProfileModel] if successful, or throws an exception.
  Future<UserProfileModel> verifyOtp(String email, String otp);

  /// Signs out the current user.
  ///
  /// Returns true if the sign-out was successful, false otherwise.
  Future<bool> signOut();

  /// Updates the current user's profile.
  ///
  /// [userProfile] - The updated user profile.
  ///
  /// Returns the updated [UserProfileModel] if successful, or throws an exception.
  Future<UserProfileModel> updateUserProfile(UserProfileModel userProfile);

  /// Checks if an incoming link is a sign-in link.
  ///
  /// [link] - The link to check.
  ///
  /// Returns true if the link is a sign-in link, false otherwise.
  Future<bool> isSignInLink(String link);

  /// Gets the email address stored for authentication.
  ///
  /// Returns the stored email address, or null if none is stored.
  Future<String?> getStoredEmail();

  /// Stores the email address for authentication.
  ///
  /// [email] - The email address to store.
  ///
  /// Returns true if the email was stored successfully, false otherwise.
  Future<bool> storeEmail(String email);

  /// Clears the stored email address.
  ///
  /// Returns true if the email was cleared successfully, false otherwise.
  Future<bool> clearStoredEmail();
}
