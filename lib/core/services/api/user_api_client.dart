import 'package:dio/dio.dart';
import 'package:storytales/core/config/app_config.dart';
import 'package:storytales/core/services/connectivity/connectivity_service.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/core/di/injection_container.dart';

/// Client for interacting with user management API endpoints.
class UserApiClient {
  final Dio _dio;
  final ConnectivityService _connectivityService;
  final LoggingService _loggingService;
  final AppConfig _appConfig;

  UserApiClient({
    required Dio dio,
    required ConnectivityService connectivityService,
    required AppConfig appConfig,
  })  : _dio = dio,
        _connectivityService = connectivityService,
        _appConfig = appConfig,
        _loggingService = sl<LoggingService>();

  /// Creates a new anonymous user with device tracking.
  ///
  /// Returns the user profile with user_id, subscription_tier, and stories_remaining.
  Future<Map<String, dynamic>> createUser({
    required String deviceId,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t reach the magical user realm right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Creating user with device ID: ${deviceId.substring(0, 8)}...');

    try {
      final response = await _dio.post(
        '/users',
        data: {
          'device_id': deviceId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('User creation API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userProfile = response.data as Map<String, dynamic>;
        _loggingService.info('User created successfully with ID: ${userProfile['user_id']}');
        return userProfile;
      } else {
        _loggingService.error('User creation API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error creating user: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while setting up your account. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to set up your account! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t reach the magical user realm right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 409) {
              errorMessage = '🎭 This device already has a magical story account! Let\'s continue with your existing account.';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s account creation spell is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while creating your account. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while setting up your magical story account. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Gets user profile with automatic monthly reset check.
  Future<Map<String, dynamic>> getUserProfile({
    required int userId,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t reach your profile right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Fetching user profile for user ID: $userId');

    try {
      final response = await _dio.get(
        '/users/$userId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('User profile API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userProfile = response.data as Map<String, dynamic>;
        _loggingService.info('User profile fetched successfully');
        return userProfile;
      } else {
        _loggingService.error('User profile API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error fetching user profile: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while fetching your profile. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to fetch your profile! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t reach your profile right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = '👤 Your magical story account seems to have wandered off! Please restart the app to create a new account.';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s profile magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while fetching your profile. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while fetching your magical profile. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Updates user profile information (display name only).
  Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    required String displayName,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t update your profile right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Updating user profile for user ID: $userId');

    try {
      final response = await _dio.put(
        '/users/$userId/profile',
        data: {
          'display_name': displayName,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('User profile update API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userProfile = response.data as Map<String, dynamic>;
        _loggingService.info('User profile updated successfully');
        return userProfile;
      } else {
        _loggingService.error('User profile update API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to update user profile: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error updating user profile: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while updating your profile. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to update your profile! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t update your profile right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = '👤 Your magical story account seems to have wandered off! Please restart the app to create a new account.';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s profile update magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while updating your profile. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while updating your magical profile. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Starts subscription process by sending OTP to email.
  Future<Map<String, dynamic>> startSubscription({
    required int userId,
    required String email,
    required String displayName,
    required String plan,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t start your subscription right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Starting subscription for user ID: $userId, plan: $plan');

    try {
      final response = await _dio.post(
        '/users/$userId/subscription',
        data: {
          'email': email,
          'display_name': displayName,
          'plan': plan,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Start subscription API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final subscriptionResponse = response.data as Map<String, dynamic>;
        _loggingService.info('Subscription started successfully, OTP sent to: $email');
        return subscriptionResponse;
      } else {
        _loggingService.error('Start subscription API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to start subscription: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error starting subscription: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while starting your subscription. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to start your subscription! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t start your subscription right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = '👤 Your magical story account seems to have wandered off! Please restart the app to create a new account.';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s subscription magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while starting your subscription. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while starting your magical subscription. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Verifies OTP and activates subscription.
  Future<Map<String, dynamic>> verifySubscription({
    required int userId,
    required String otpCode,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t verify your subscription right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Verifying subscription for user ID: $userId');

    try {
      final response = await _dio.post(
        '/users/$userId/verify-subscription',
        data: {
          'otp_code': otpCode,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Verify subscription API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final subscriptionResponse = response.data as Map<String, dynamic>;
        _loggingService.info('Subscription verified and activated successfully');
        return subscriptionResponse;
      } else {
        _loggingService.error('Verify subscription API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to verify subscription: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error verifying subscription: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while verifying your subscription. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to verify your subscription! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t verify your subscription right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 400) {
              errorMessage = '🔢 The magic code you entered doesn\'t seem to be correct. Please check your email and try again!';
            } else if (statusCode == 404) {
              errorMessage = '👤 Your magical story account seems to have wandered off! Please restart the app to create a new account.';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s subscription verification magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while verifying your subscription. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while verifying your magical subscription. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }
}
