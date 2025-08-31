import '../../domain/entities/user_profile.dart';
import '../../domain/entities/registration_request.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';
import '../models/registration_models.dart';
import '../../../../core/services/api/user_api_client.dart';
import '../../../../core/services/auth/authentication_service.dart';
import '../../../../core/services/logging/logging_service.dart';
import '../../../../core/di/injection_container.dart';

/// Implementation of ProfileRepository using API calls.
class ProfileRepositoryImpl implements ProfileRepository {
  final UserApiClient _userApiClient;
  final AuthenticationService _authenticationService;
  final LoggingService _loggingService;

  /// Creates a profile repository implementation.
  ProfileRepositoryImpl({
    required UserApiClient userApiClient,
    required AuthenticationService authenticationService,
  })  : _userApiClient = userApiClient,
        _authenticationService = authenticationService,
        _loggingService = sl<LoggingService>();

  @override
  Future<UserProfile> getCurrentUserProfile() async {
    try {
      // Check if authentication is still being initialized
      if (_authenticationService.isInitializing) {
        throw Exception('🔄 The Story Wizard is still setting up your magical account. Please wait a moment...');
      }

      // Check if authentication has completed initialization
      final isInitComplete = await _authenticationService.isInitializationComplete();
      if (!isInitComplete) {
        // Try to initialize authentication first
        try {
          final freshProfile = await _authenticationService.initializeAuthentication();
          final userProfile = UserProfileModel.fromJson(freshProfile);
          return userProfile.toDomain();
        } catch (initError) {
          throw Exception('🌟 The Story Wizard is having trouble setting up your account. Please check your internet connection and try again!');
        }
      }

      // Get current user profile from authentication service
      final userProfileData = await _authenticationService.getCurrentUserProfile();
      if (userProfileData == null) {
        // If profile is null but initialization is complete, there's a timing issue
        // Wait a bit for SharedPreferences to sync and try again
        await Future.delayed(const Duration(milliseconds: 100));
        final retryProfileData = await _authenticationService.getCurrentUserProfile();
        if (retryProfileData == null) {
          throw Exception('⭐ The Story Wizard needs to refresh your account details. Please restart the app and we\'ll set everything up again!');
        }
        final userProfile = UserProfileModel.fromJson(retryProfileData);
        return userProfile.toDomain();
      }
      
      final userProfile = UserProfileModel.fromJson(userProfileData);
      return userProfile.toDomain();
    } catch (e) {
      // Don't clear data for initialization or network errors
      if (e.toString().contains('setting up your magical account') || 
          e.toString().contains('check your internet connection') ||
          e.toString().contains('initialization already in progress')) {
        rethrow;
      }

      // Only clear data if it's genuinely corrupted data parsing error
      if (e.toString().contains('Story Wizard had trouble finding your profile') || 
          e.toString().contains('account magic got mixed up')) {
        try {
          // Clear corrupted data and try fresh initialization
          await _authenticationService.clearUserData();
          final freshProfile = await _authenticationService.initializeAuthentication();
          final userProfile = UserProfileModel.fromJson(freshProfile);
          return userProfile.toDomain();
        } catch (recoveryError) {
          throw Exception('⭐ The Story Wizard needs to refresh your account details. Please restart the app and we\'ll set everything up again!');
        }
      }
      
      // Log the original error for debugging
      _loggingService.info('ProfileRepository DEBUG - Original error: $e');
      _loggingService.info('ProfileRepository DEBUG - Error type: ${e.runtimeType}');
      _loggingService.info('ProfileRepository DEBUG - Error string contains check: ${e.toString()}');
      
      throw Exception('🧙‍♂️ Our Story Wizard encountered a mysterious spell error while loading your profile. Let\'s try again!');
    }
  }

  @override
  Future<UserProfile> updateDisplayName(String displayName) async {
    try {
      // Get current user profile to get user ID
      final currentProfile = await getCurrentUserProfile();
      
      // Update display name via API
      final updatedProfileData = await _userApiClient.updateUserProfile(
        userId: currentProfile.userId,
        displayName: displayName,
      );
      
      // Update local storage through authentication service
      await _authenticationService.updateStoredUserProfile(updatedProfileData);
      
      final updatedProfile = UserProfileModel.fromJson(updatedProfileData);
      return updatedProfile.toDomain();
    } catch (e) {
      throw Exception('Failed to update display name: $e');
    }
  }

  @override
  Future<RegistrationResponse> registerUser({
    required String email,
    required String displayName,
  }) async {
    try {
      // Get current user profile to get user ID
      final currentProfile = await getCurrentUserProfile();
      
      // Register user via API
      final registrationData = await _userApiClient.registerUser(
        userId: currentProfile.userId,
        email: email,
        displayName: displayName,
      );
      
      final registrationResponse = RegistrationResponseModel.fromJson(registrationData);
      return registrationResponse.toDomain();
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  @override
  Future<UserProfile> verifyRegistration({
    required String otpCode,
  }) async {
    try {
      // Get current user profile to get user ID
      final currentProfile = await getCurrentUserProfile();
      
      // Verify registration via API
      final verifiedProfileData = await _userApiClient.verifyRegistration(
        userId: currentProfile.userId,
        otpCode: otpCode,
      );
      
      // Update local storage through authentication service
      await _authenticationService.updateStoredUserProfile(verifiedProfileData);
      
      final verifiedProfile = UserProfileModel.fromJson(verifiedProfileData);
      return verifiedProfile.toDomain();
    } catch (e) {
      throw Exception('Failed to verify registration: $e');
    }
  }

  @override
  Future<RegistrationResponse> loginUser({
    required String email,
  }) async {
    try {
      // Login user via API
      final loginData = await _userApiClient.loginUser(
        email: email,
      );
      
      final loginResponse = RegistrationResponseModel.fromJson(loginData);
      return loginResponse.toDomain();
    } catch (e) {
      throw Exception('🌟 Oh no! Our Story Wizard had trouble logging you in. Please check your email and try again!');
    }
  }

  @override
  Future<UserProfile> verifyLogin({
    required String sessionId,
    required String otpCode,
  }) async {
    try {
      // Verify login via API
      final loggedInProfileData = await _userApiClient.verifyLogin(
        sessionId: sessionId,
        otpCode: otpCode,
      );
      
      // Update local storage through authentication service
      await _authenticationService.updateStoredUserProfile(loggedInProfileData);
      
      final loggedInProfile = UserProfileModel.fromJson(loggedInProfileData);
      return loggedInProfile.toDomain();
    } catch (e) {
      throw Exception('🧙‍♂️ The Story Wizard couldn\'t verify your login code. Please check the code and try again!');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Clear local user data and return to anonymous state
      await _authenticationService.clearUserData();
      // Re-initialize as anonymous user
      await _authenticationService.initializeAuthentication();
    } catch (e) {
      throw Exception('🌟 Oh no! Our Story Wizard had trouble signing you out. Please try again!');
    }
  }

  @override
  Future<UserProfile> refreshUserProfile() async {
    try {
      // Force refresh user profile from server (not cached)
      final refreshedProfileData = await _authenticationService.getCurrentUserProfile(forceRefresh: true);
      if (refreshedProfileData == null) {
        throw Exception('Unable to refresh profile - no user data found');
      }
      final refreshedProfile = UserProfileModel.fromJson(refreshedProfileData);
      return refreshedProfile.toDomain();
    } catch (e) {
      throw Exception('Failed to refresh user profile: $e');
    }
  }
}