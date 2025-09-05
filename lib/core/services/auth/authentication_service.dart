import 'package:shared_preferences/shared_preferences.dart';
import 'package:storytales/core/services/device/device_service.dart';
import 'package:storytales/core/services/api/user_api_client.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/core/models/user_stories_response.dart';
import 'package:storytales/core/di/injection_container.dart';

/// Service for managing user authentication and session state.
class AuthenticationService {
  static const String _userIdKey = 'user_id';
  static const String _userProfileKey = 'user_profile';
  static const String _isAuthenticatedKey = 'is_authenticated';
  static const String _initializationCompleteKey = 'initialization_complete';

  final DeviceService _deviceService;
  final UserApiClient _userApiClient;
  final LoggingService _loggingService;
  
  bool _isInitializing = false;

  AuthenticationService({
    required DeviceService deviceService,
    required UserApiClient userApiClient,
  })  : _deviceService = deviceService,
        _userApiClient = userApiClient,
        _loggingService = sl<LoggingService>();

  /// Checks if authentication initialization is complete.
  Future<bool> isInitializationComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_initializationCompleteKey) ?? false;
  }

  /// Checks if authentication is currently being initialized.
  bool get isInitializing => _isInitializing;

  /// Initializes the authentication system by creating or retrieving an anonymous user.
  ///
  /// This method should be called on app startup to ensure the user has a valid session.
  Future<Map<String, dynamic>> initializeAuthentication() async {
    if (_isInitializing) {
      throw Exception('Authentication initialization already in progress');
    }

    _isInitializing = true;
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

          // Mark initialization as complete
          await _markInitializationComplete();

          _loggingService.info('Successfully retrieved existing user profile');
          return userProfile;
        } catch (e) {
          _loggingService.warning('Failed to retrieve existing user profile: $e');
          // If fetching fails, clear stored data and continue with device-based lookup
          await _clearStoredUserData();
        }
      }

      // Try to get existing user by device ID first (for app reinstalls)
      final deviceId = await _deviceService.getDeviceId();
      
      try {
        _loggingService.info('Trying to retrieve existing user by device ID...');
        final userProfile = await _userApiClient.getUserByDevice(deviceId: deviceId);
        
        // Store the retrieved user data
        await _storeUserProfile(userProfile);
        
        // Mark initialization as complete
        await _markInitializationComplete();
        
        _loggingService.info('Successfully retrieved existing user by device ID');
        return userProfile;
      } catch (e) {
        // If user not found by device ID (404), create a new user
        if (e.toString().contains('404') || e.toString().contains('No magical story account found')) {
          _loggingService.info('No existing user found for device, creating new user...');
        } else {
          _loggingService.warning('Error retrieving user by device ID: $e');
        }
      }

      // Create a new anonymous user
      _loggingService.info('Creating new anonymous user...');
      
      try {
        final userProfile = await _userApiClient.createUser(deviceId: deviceId);
        
        // Store the user data
        await _storeUserProfile(userProfile);
        
        // Mark initialization as complete
        await _markInitializationComplete();
        
        _loggingService.info('Successfully created and stored new user profile');
        return userProfile;
      } catch (e) {
        // Handle 409 conflict - device ID already exists
        if (e.toString().contains('409') || e.toString().contains('already has a magical story account')) {
          _loggingService.info('Device ID already exists (409 conflict), attempting to retrieve existing user...');
          
          try {
            // Try to get the existing user by device ID
            final userProfile = await _userApiClient.getUserByDevice(deviceId: deviceId);
            await _storeUserProfile(userProfile);
            
            // Mark initialization as complete
            await _markInitializationComplete();
            
            _loggingService.info('Successfully retrieved existing user after 409 conflict');
            return userProfile;
          } catch (getUserError) {
            // This is the 409→404 loop - device exists but user not found (signed out user)
            if (getUserError.toString().contains('404') || getUserError.toString().contains('No magical story account found')) {
              _loggingService.info('Detected signed-out user scenario (409→404 pattern) - user exists but is signed out');
              
              // Instead of creating API calls, return a local anonymous profile for UI
              // This breaks the infinite loop and provides proper UX for signed-out users
              final fallbackProfile = {
                'id': 0, // Temporary ID for UI
                'user_id': 0,
                'email_verified': false,
                'is_anonymous': true,
                'subscription_tier': 'free',
                'stories_remaining': 2,
                'device_id': deviceId,
                'session_id': null,
                'session_created_at': null,
                'is_authenticated': false, // Clear indication that user is not authenticated
              };
              
              // Mark initialization as complete without storing profile
              // (since this is a temporary fallback for signed-out users)
              await _markInitializationComplete();
              
              _loggingService.info('Created fallback anonymous profile for signed-out user');
              return fallbackProfile;
            }
            
            // For other getUserByDevice errors, rethrow
            rethrow;
          }
        }
        
        // For other errors, rethrow
        rethrow;
      }
    } catch (e) {
      _loggingService.error('Failed to initialize authentication: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  /// Gets the current user profile, refreshing it from the API if needed.
  Future<Map<String, dynamic>?> getCurrentUserProfile({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_userIdKey);
      final isInitComplete = prefs.getBool(_initializationCompleteKey) ?? false;

      if (userId == null) {
        if (!isInitComplete && !_isInitializing) {
          _loggingService.info('User ID not found but initialization not complete, this may be expected during startup');
        } else {
          _loggingService.warning('No user ID found after initialization should be complete');
          _loggingService.debug('DEBUG AuthService - userId: $userId');
          _loggingService.debug('DEBUG AuthService - isInitComplete: $isInitComplete');
          _loggingService.debug('DEBUG AuthService - _isInitializing: $_isInitializing');
          _loggingService.debug('DEBUG AuthService - All keys in prefs: ${prefs.getKeys()}');
          _loggingService.debug('DEBUG AuthService - _userIdKey value: ${prefs.get(_userIdKey)}');
          _loggingService.debug('DEBUG AuthService - _userProfileKey value: ${prefs.get(_userProfileKey)}');
          _loggingService.debug('DEBUG AuthService - _initializationCompleteKey value: ${prefs.get(_initializationCompleteKey)}');
        }
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
          _loggingService.debug('DEBUG getCurrentUserProfile - Cached profile: $profile');
          _loggingService.debug('DEBUG getCurrentUserProfile - Cached email_verified: ${profile['email_verified']}');
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
    // Clear device ID to ensure user becomes truly anonymous
    await _deviceService.clearDeviceId();
    _loggingService.info('User signed out and device ID cleared - now truly anonymous');
  }

  /// Gets paginated user stories for the current user.
  Future<UserStoriesResponse> getUserStories({
    int page = 1,
    int limit = 20,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);

    if (userId == null) {
      throw Exception('No user session found. Please restart the app.');
    }

    _loggingService.info('Fetching user stories for user $userId, page: $page, limit: $limit');

    return await _userApiClient.getUserStories(
      userId: userId,
      page: page,
      limit: limit,
    );
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

    // Store user ID - API can return either 'id' or 'user_id'
    final userId = userProfile['id'] ?? userProfile['user_id'];
    _loggingService.debug('DEBUG _storeUserProfile - Raw userProfile: $userProfile');
    _loggingService.debug('DEBUG _storeUserProfile - email_verified field: ${userProfile['email_verified']}');
    _loggingService.debug('DEBUG _storeUserProfile - Extracted userId: $userId (type: ${userId.runtimeType})');
    
    if (userId is int) {
      await prefs.setInt(_userIdKey, userId);
      _loggingService.debug('DEBUG _storeUserProfile - Stored userId as int: $userId');
    } else {
      _loggingService.error('DEBUG _storeUserProfile - ERROR: userId is not int, cannot store! Raw data: $userProfile');
    }

    // Store full profile as JSON string
    final profileJson = userProfile.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    await prefs.setString(_userProfileKey, profileJson);
    
    // Fix substring logging to handle short strings
    final jsonPreview = profileJson.length > 100 
        ? '${profileJson.substring(0, 100)}...' 
        : profileJson;
    _loggingService.debug('DEBUG _storeUserProfile - Stored profile JSON: $jsonPreview');

    // Mark as authenticated
    await prefs.setBool(_isAuthenticatedKey, true);

    _loggingService.info('User profile stored successfully');
  }

  /// Marks authentication initialization as complete.
  Future<void> _markInitializationComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_initializationCompleteKey, true);
    _loggingService.info('Marked authentication initialization as complete');
  }

  /// Clears all stored user authentication data.
  Future<void> _clearStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userProfileKey);
    await prefs.remove(_isAuthenticatedKey);
    await prefs.remove(_initializationCompleteKey);
    _loggingService.info('Cleared all stored user data');
  }

  /// Updates the stored user profile data.
  ///
  /// This is a public method for updating user profile after API calls.
  Future<void> updateStoredUserProfile(Map<String, dynamic> userProfile) async {
    await _storeUserProfile(userProfile);
  }

  /// Clears all user authentication data.
  ///
  /// This is a public method for logging out users.
  Future<void> clearUserData() async {
    await _clearStoredUserData();
  }

}
