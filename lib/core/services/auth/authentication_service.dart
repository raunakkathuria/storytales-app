import 'package:shared_preferences/shared_preferences.dart';
import 'package:storytales/core/services/device/device_service.dart';
import 'package:storytales/core/services/api/user_api_client.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/core/di/injection_container.dart';

/// Service for managing user authentication and session state.
class AuthenticationService {
  static const String _userIdKey = 'user_id';
  static const String _userProfileKey = 'user_profile';
  static const String _isAuthenticatedKey = 'is_authenticated';

  final DeviceService _deviceService;
  final UserApiClient _userApiClient;
  final LoggingService _loggingService;

  AuthenticationService({
    required DeviceService deviceService,
    required UserApiClient userApiClient,
  })  : _deviceService = deviceService,
        _userApiClient = userApiClient,
        _loggingService = sl<LoggingService>();

  /// Initializes the authentication system by creating or retrieving an anonymous user.
  ///
  /// This method should be called on app startup to ensure the user has a valid session.
  Future<Map<String, dynamic>> initializeAuthentication() async {
    _loggingService.info('Initializing authentication system...');

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we already have a stored user ID
      final storedUserId = prefs.getInt(_userIdKey);
      if (storedUserId != null) {
        _loggingService.info('Found existing user ID: $storedUserId');

        try {
          // Try to fetch the current user profile to verify the account still exists
          final userProfile = await _userApiClient.getUserProfile(userId: storedUserId);

          // Store the updated profile
          await _storeUserProfile(userProfile);

          _loggingService.info('Successfully retrieved existing user profile');
          return userProfile;
        } catch (e) {
          _loggingService.warning('Failed to retrieve existing user profile: $e');
          // If fetching fails, create a new user
          await _clearStoredUserData();
        }
      }

      // Create a new anonymous user
      _loggingService.info('Creating new anonymous user...');
      final deviceId = await _deviceService.getDeviceId();
      final userProfile = await _userApiClient.createUser(deviceId: deviceId);

      // Store the user data
      await _storeUserProfile(userProfile);

      _loggingService.info('Successfully created and stored new user profile');
      return userProfile;
    } catch (e) {
      _loggingService.error('Failed to initialize authentication: $e');
      rethrow;
    }
  }

  /// Gets the current user profile, refreshing it from the API if needed.
  Future<Map<String, dynamic>?> getCurrentUserProfile({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_userIdKey);

      if (userId == null) {
        _loggingService.warning('No user ID found, authentication not initialized');
        return null;
      }

      if (forceRefresh) {
        _loggingService.info('Force refreshing user profile from API');
        final userProfile = await _userApiClient.getUserProfile(userId: userId);
        await _storeUserProfile(userProfile);
        return userProfile;
      }

      // Try to get cached profile first
      final cachedProfile = prefs.getString(_userProfileKey);
      if (cachedProfile != null) {
        try {
          final Map<String, dynamic> profile = Map<String, dynamic>.from(
            await Future.value(cachedProfile).then((json) =>
              Map<String, dynamic>.from(Uri.splitQueryString(json))
            )
          );
          return profile;
        } catch (e) {
          _loggingService.warning('Failed to parse cached profile, fetching from API: $e');
        }
      }

      // Fetch from API if no valid cache
      final userProfile = await _userApiClient.getUserProfile(userId: userId);
      await _storeUserProfile(userProfile);
      return userProfile;
    } catch (e) {
      _loggingService.error('Failed to get current user profile: $e');
      return null;
    }
  }

  /// Updates the user's display name.
  Future<Map<String, dynamic>> updateDisplayName(String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);

    if (userId == null) {
      throw Exception('No user session found. Please restart the app.');
    }

    _loggingService.info('Updating display name for user $userId');

    final updatedProfile = await _userApiClient.updateUserProfile(
      userId: userId,
      displayName: displayName,
    );

    await _storeUserProfile(updatedProfile);
    return updatedProfile;
  }

  /// Starts the subscription process.
  Future<Map<String, dynamic>> startSubscription({
    required String email,
    required String displayName,
    required String plan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);

    if (userId == null) {
      throw Exception('No user session found. Please restart the app.');
    }

    _loggingService.info('Starting subscription for user $userId with plan: $plan');

    return await _userApiClient.startSubscription(
      userId: userId,
      email: email,
      displayName: displayName,
      plan: plan,
    );
  }

  /// Verifies the subscription OTP and activates the subscription.
  Future<Map<String, dynamic>> verifySubscription(String otpCode) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);

    if (userId == null) {
      throw Exception('No user session found. Please restart the app.');
    }

    _loggingService.info('Verifying subscription for user $userId');

    final updatedProfile = await _userApiClient.verifySubscription(
      userId: userId,
      otpCode: otpCode,
    );

    // Update stored profile with new subscription status
    await _storeUserProfile(updatedProfile);
    return updatedProfile;
  }

  /// Checks if the user is currently authenticated (has a valid session).
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey) != null;
  }

  /// Gets the current user ID if available.
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  /// Signs out the user by clearing all stored authentication data.
  Future<void> signOut() async {
    _loggingService.info('Signing out user and clearing authentication data');
    await _clearStoredUserData();
  }

  /// Resets the user session by clearing data and creating a new anonymous user.
  Future<Map<String, dynamic>> resetUserSession() async {
    _loggingService.info('Resetting user session...');

    // Clear existing data
    await _clearStoredUserData();

    // Clear device ID to force generation of new one
    await _deviceService.clearDeviceId();

    // Initialize new authentication
    return await initializeAuthentication();
  }

  /// Stores user profile data locally.
  Future<void> _storeUserProfile(Map<String, dynamic> userProfile) async {
    final prefs = await SharedPreferences.getInstance();

    // Store user ID
    final userId = userProfile['user_id'];
    if (userId is int) {
      await prefs.setInt(_userIdKey, userId);
    }

    // Store full profile as JSON string
    final profileJson = userProfile.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    await prefs.setString(_userProfileKey, profileJson);

    // Mark as authenticated
    await prefs.setBool(_isAuthenticatedKey, true);

    _loggingService.info('User profile stored successfully');
  }

  /// Clears all stored user authentication data.
  Future<void> _clearStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userProfileKey);
    await prefs.remove(_isAuthenticatedKey);
    _loggingService.info('Cleared all stored user data');
  }
}
