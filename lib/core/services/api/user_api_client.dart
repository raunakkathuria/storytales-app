import 'package:dio/dio.dart';
import 'package:storytales/core/config/app_config.dart';
import 'package:storytales/core/services/connectivity/connectivity_service.dart';
import 'package:storytales/core/services/device/device_service.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/core/models/user_stories_response.dart';
import 'package:storytales/core/di/injection_container.dart';

/// Client for interacting with user management API endpoints.
class UserApiClient {
  final Dio _dio;
  final ConnectivityService _connectivityService;
  final DeviceService _deviceService;
  final LoggingService _loggingService;
  final AppConfig _appConfig;

  UserApiClient({
    required Dio dio,
    required ConnectivityService connectivityService,
    required DeviceService deviceService,
    required AppConfig appConfig,
  })  : _dio = dio,
        _connectivityService = connectivityService,
        _deviceService = deviceService,
        _appConfig = appConfig,
        _loggingService = sl<LoggingService>();

  /// Gets the device ID for use in API headers.
  Future<String> _getDeviceIdHeader() async {
    return await _deviceService.getDeviceId();
  }

  /// Creates a new anonymous user.
  ///
  /// Returns the user profile with user_id (UUID), subscription_tier, and stories_remaining.
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
        data: {},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
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

  /// Gets user profile.
  Future<Map<String, dynamic>> getUserProfile({
    required String userId,
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
            'device-id': await _getDeviceIdHeader(),
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
    required String userId,
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
            'device-id': await _getDeviceIdHeader(),
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

  /// Process a native in-app purchase subscription.
  ///
  /// Verifies the platform receipt and activates the subscription.
  Future<Map<String, dynamic>> purchaseSubscription({
    required String userId,
    required String platform,
    required String productId,
    required String receiptData,
    required String transactionId,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t process your subscription right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Processing subscription purchase for user ID: $userId, platform: $platform, product: $productId');

    try {
      final response = await _dio.post(
        '/users/$userId/purchase-subscription',
        data: {
          'platform': platform,
          'product_id': productId,
          'receipt_data': receiptData,
          'transaction_id': transactionId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Purchase subscription API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final subscriptionResponse = response.data as Map<String, dynamic>;
        _loggingService.info('Subscription purchase processed successfully: ${subscriptionResponse['subscription_tier']}');
        return subscriptionResponse;
      } else {
        _loggingService.error('Purchase subscription API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to process subscription purchase: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error processing subscription purchase: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while processing your subscription. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to process your subscription! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t process your subscription right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 400) {
              errorMessage = '📱 There seems to be an issue with your purchase receipt. Please try again or contact support if the problem persists.';
            } else if (statusCode == 402) {
              errorMessage = '💳 There was a problem processing your subscription payment. Please check your payment method and try again.';
            } else if (statusCode == 404) {
              errorMessage = '👤 Your magical story account seems to have wandered off! Please restart the app to create a new account.';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s subscription magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while processing your subscription. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while processing your magical subscription. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Restore subscription from previous purchases.
  ///
  /// Used for app reinstalls or device transfers.
  Future<Map<String, dynamic>> restoreSubscription({
    required String userId,
    required String platform,
    String? receiptData,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t restore your subscription right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Restoring subscription for user ID: $userId, platform: $platform');

    try {
      final requestData = {
        'platform': platform,
      };
      
      // Add receipt data if provided (mainly for Android)
      if (receiptData != null) {
        requestData['receipt_data'] = receiptData;
      }

      final response = await _dio.post(
        '/users/$userId/restore-subscription',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Restore subscription API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final restoreResponse = response.data as Map<String, dynamic>;
        final subscriptionFound = restoreResponse['subscription_found'] ?? false;
        _loggingService.info('Subscription restore completed - Found: $subscriptionFound');
        return restoreResponse;
      } else {
        _loggingService.error('Restore subscription API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to restore subscription: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error restoring subscription: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while restoring your subscription. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to restore your subscription! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t restore your subscription right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = '👤 No previous subscription found for this account. You can purchase a new subscription to access unlimited stories!';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s subscription restore magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while restoring your subscription. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while restoring your magical subscription. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Get current subscription status and details.
  ///
  /// Returns subscription tier, expiry date, and entitlement information.
  Future<Map<String, dynamic>> getSubscriptionStatus({
    required String userId,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t check your subscription status right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Getting subscription status for user ID: $userId');

    try {
      final response = await _dio.get(
        '/users/$userId/subscription-status',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Subscription status API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final statusResponse = response.data as Map<String, dynamic>;
        final subscriptionTier = statusResponse['subscription_tier'] ?? 'free';
        _loggingService.info('Subscription status retrieved: $subscriptionTier');
        return statusResponse;
      } else {
        _loggingService.error('Subscription status API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to get subscription status: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error getting subscription status: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while checking your subscription. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to check your subscription! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t check your subscription right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = '👤 Your magical story account seems to have wandered off! Please restart the app to create a new account.';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s subscription status magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while checking your subscription. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while checking your magical subscription. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Gets user profile by device ID.
  ///
  /// Essential for app reinstalls where the user needs to retrieve their existing account.
  Future<Map<String, dynamic>> getUserByDevice({
    required String deviceId,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t reach your profile right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Fetching user profile for device ID: ${deviceId.substring(0, 8)}...');

    try {
      final response = await _dio.get(
        '/users/device/$deviceId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Get user by device API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userProfile = response.data as Map<String, dynamic>;
        _loggingService.info('User profile retrieved by device ID successfully');
        return userProfile;
      } else {
        _loggingService.error('Get user by device API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to fetch user profile by device ID: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error fetching user profile by device ID: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while finding your account. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to find your account! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t reach your profile right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = '👤 No magical story account found for this device. We\'ll create a new one for you!';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s account lookup magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while finding your account. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while finding your magical account. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Gets paginated list of user stories.
  ///
  /// Returns UserStoriesResponse with stories, pagination info, subscription tier, and stories remaining.
  Future<UserStoriesResponse> getUserStories({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t reach your story collection right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Fetching user stories for user ID: $userId, page: $page, limit: $limit');

    try {
      final response = await _dio.get(
        '/users/$userId/stories',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('User stories API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userStoriesResponse = UserStoriesResponse.fromJson(response.data as Map<String, dynamic>);
        _loggingService.info('User stories fetched successfully: ${userStoriesResponse.stories.length} stories on page $page');
        return userStoriesResponse;
      } else {
        _loggingService.error('User stories API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to fetch user stories: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error fetching user stories: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while fetching your stories. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to fetch your stories! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t reach your story collection right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = '👤 Your magical story account seems to have wandered off! Please restart the app to create a new account.';
            } else if (statusCode == 400) {
              errorMessage = '📖 There seems to be an issue with your story request. Please try again with different parameters!';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s story collection magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while fetching your stories. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while fetching your magical story collection. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Registers a user with email and display name.
  ///
  /// Sends an OTP to the user's email for verification.
  Future<Map<String, dynamic>> registerUser({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t register your account right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Registering user with email: ${email.substring(0, 3)}***');

    try {
      final response = await _dio.post(
        '/users/$userId/register',
        data: {
          'email': email,
          'display_name': displayName,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Register user API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final registrationResponse = response.data as Map<String, dynamic>;
        _loggingService.info('User registration initiated successfully');
        return registrationResponse;
      } else {
        _loggingService.error('Register user API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to register user: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error registering user: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while registering your account. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to register your account! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t register your account right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 400) {
              errorMessage = '📧 Hmm, there seems to be an issue with that email address. Please check it\'s spelled correctly and try again!';
            } else if (statusCode == 409) {
              errorMessage = '👤 That email address is already part of our magical story kingdom! Try logging in instead.';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s registration magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while registering your account. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while creating your magical account. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Verifies user registration with OTP code.
  ///
  /// Completes the registration process by verifying the OTP.
  Future<Map<String, dynamic>> verifyRegistration({
    required String userId,
    required String otpCode,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t verify your account right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Verifying registration for user ID: $userId');

    try {
      final response = await _dio.post(
        '/users/$userId/verify-registration',
        data: {'otp_code': otpCode},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Verify registration API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userProfile = response.data as Map<String, dynamic>;
        _loggingService.info('User registration verified successfully');
        return userProfile;
      } else {
        _loggingService.error('Verify registration API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to verify registration: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error verifying registration: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while verifying your account. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to verify your account! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t verify your account right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 400) {
              errorMessage = '🔢 That verification code doesn\'t look quite right. Please check the code in your email and try again!';
            } else if (statusCode == 404) {
              errorMessage = '⏰ That verification code has expired or isn\'t valid. Please request a new registration email!';
            } else if (statusCode == 500) {
              // Check if this is an OTP expiration issue based on error message
              final responseData = e.response?.data;
              if (responseData is Map && 
                  (responseData.toString().contains('expired') || 
                   responseData.toString().contains('invalid') ||
                   responseData.toString().contains('Token has expired'))) {
                errorMessage = '⏰ Your verification code has expired! Don\'t worry - tap "Request New Code" to get a fresh one sent to your email.';
              } else {
                errorMessage = '🏰 The Story Wizard\'s verification magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
              }
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while verifying your account. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while verifying your magical account. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Logs in an existing user with email.
  ///
  /// Sends an OTP to the user's email for verification.
  Future<Map<String, dynamic>> loginUser({
    required String email,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t log you in right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Logging in user with email: ${email.substring(0, 3)}***');

    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Login user API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final loginResponse = response.data as Map<String, dynamic>;
        _loggingService.info('User login initiated successfully');
        return loginResponse;
      } else {
        _loggingService.error('Login user API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to login user: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error logging in user: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while logging you in. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to log you in! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t log you in right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = '👤 No magical story account found with that email address. Please check your email or register a new account!';
            } else if (statusCode == 400) {
              errorMessage = '📧 That email address doesn\'t look quite right. Please check it\'s spelled correctly and try again!';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s login magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while logging you in. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while logging into your magical account. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Verifies user login with OTP code.
  ///
  /// Completes the login process by verifying the OTP.
  Future<Map<String, dynamic>> verifyLogin({
    required String sessionId,
    required String otpCode,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t verify your login right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Verifying login with OTP code');

    try {
      final response = await _dio.post(
        '/auth/verify-login',
        data: {
          'session_id': sessionId,
          'otp_code': otpCode,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Verify login API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userProfile = response.data as Map<String, dynamic>;
        _loggingService.info('User login verified successfully');
        return userProfile;
      } else {
        _loggingService.error('Verify login API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to verify login: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error verifying login: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while verifying your login. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to verify your login! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t verify your login right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 400) {
              errorMessage = '🔢 That login code doesn\'t look quite right. Please check the code in your email and try again!';
            } else if (statusCode == 404) {
              errorMessage = '⏰ That login code has expired or isn\'t valid. Please request a new login email!';
            } else if (statusCode == 500) {
              // Check if this is an OTP expiration issue based on error message
              final responseData = e.response?.data;
              if (responseData is Map && 
                  (responseData.toString().contains('expired') || 
                   responseData.toString().contains('invalid') ||
                   responseData.toString().contains('Token has expired'))) {
                errorMessage = '⏰ Your login code has expired! Please request a new login code to continue.';
              } else {
                errorMessage = '🏰 The Story Wizard\'s login verification magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
              }
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while verifying your login. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while verifying your magical login. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Signs out the user by invalidating their session on the server.
  ///
  /// This prevents automatic login on app reinstall or device recovery.
  Future<Map<String, dynamic>> signOut({
    required String userId,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t sign you out right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Signing out user: $userId');

    try {
      final response = await _dio.post(
        '/users/$userId/signout',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Sign out API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final signOutResponse = response.data as Map<String, dynamic>;
        _loggingService.info('User signed out successfully from server');
        return signOutResponse;
      } else {
        _loggingService.error('Sign out API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to sign out user: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error signing out user: $e');

      String errorMessage = '🌟 Oh no! Our Story Wizard had trouble signing you out. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to sign you out! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t sign you out right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = '👤 Your account seems to already be signed out! You can continue safely.';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s sign out magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while signing you out. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while signing out of your magical account. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Generate a user story using the background job API.
  ///
  /// This endpoint properly tracks the story generation against the user's lifetime limit
  /// and associates the story with the user's account.
  Future<Map<String, dynamic>> generateUserStory({
    required String userId,
    required String prompt,
    String? ageRange,
    String? theme,
    String? genre,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t reach the magical story realm right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Generating user story for user ID: $userId');
    _loggingService.info('Story prompt: $prompt');
    _loggingService.info('Age range: $ageRange');

    try {
      // Start the background job for user story generation
      final jobResponse = await _startUserStoryGenerationJob(
        userId: userId,
        prompt: prompt,
        ageRange: ageRange,
        theme: theme,
        genre: genre,
      );

      // Poll for completion and return the final story data
      return await _pollForJobCompletion(jobResponse['job_id'] as String);
    } catch (e) {
      _loggingService.error('Error in user story generation flow: $e');
      rethrow;
    }
  }

  /// Start a background user story generation job
  Future<Map<String, dynamic>> _startUserStoryGenerationJob({
    required String userId,
    required String prompt,
    String? ageRange,
    String? theme,
    String? genre,
  }) async {
    try {
      // Prepare request data following the API spec
      final requestData = {
        'description': prompt, // Note: API spec uses 'description' not 'prompt'
        'age_range': ageRange,
      };

      _loggingService.info('Making API request to: ${_appConfig.apiBaseUrl}/users/$userId/stories');
      _loggingService.info('Request data: $requestData');

      final response = await _dio.post(
        '/users/$userId/stories',
        data: requestData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('User story generation API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jobResponse = response.data as Map<String, dynamic>;
        _loggingService.info('User story generation job started successfully');
        return jobResponse;
      } else {
        _loggingService.error('User story generation API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to start user story generation: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error starting user story generation job: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while creating your story. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to weave your tale! The magical connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t reach the magical story realm right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 402) {
              errorMessage = '📖 You\'ve reached your story limit! Subscribe to create unlimited magical tales and continue your storytelling adventure!';
            } else if (statusCode == 404) {
              errorMessage = '👤 Your account seems to have wandered off! Please try refreshing the app and logging in again.';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s castle is having some magical difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode). Let\'s try casting the story spell again!';
            }
            break;
          case DioExceptionType.cancel:
            errorMessage = '📖 The story creation was cancelled. No worries - the Story Wizard is ready whenever you are!';
            break;
          default:
            errorMessage = '🌙 Something unexpected happened in the magical story realm. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Poll for job completion and return the final story data
  Future<Map<String, dynamic>> _pollForJobCompletion(String jobId) async {
    const maxAttempts = 60; // 10 minutes with 10-second intervals
    const pollInterval = Duration(seconds: 10);
    const maxConsecutiveErrors = 5; // Stop after 5 consecutive failures
    
    int consecutiveErrors = 0;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        _loggingService.info('Checking job status (attempt ${attempt + 1}/$maxAttempts)');

        final statusResponse = await _checkJobStatus(jobId);

        if (statusResponse['status'] == 'completed') {
          _loggingService.info('Job completed successfully');
          return await _getJobResult(jobId);
        } else if (statusResponse['status'] == 'failed') {
          consecutiveErrors++;
          final errorMsg = statusResponse['error'] ?? 'Unknown error occurred during story generation';
          _loggingService.error('Job failed: $errorMsg');
          _loggingService.warning('Consecutive failures: $consecutiveErrors of $maxConsecutiveErrors');
          
          if (consecutiveErrors >= maxConsecutiveErrors) {
            _loggingService.error('Story generation failed after $maxConsecutiveErrors consecutive failures, stopping polling');
            throw Exception('🧙‍♂️ Our Story Wizard encountered persistent issues creating your story. Please try again later or contact support if the problem continues.');
          }
          
          // Continue polling for temporary failures
          _loggingService.info('Treating as temporary failure, continuing to poll...');
          if (attempt < maxAttempts - 1) {
            await Future.delayed(pollInterval);
          }
        } else if (statusResponse['status'] == 'processing' || statusResponse['status'] == 'started') {
          consecutiveErrors = 0; // Reset counter on successful status check
          _loggingService.info('Job still processing: ${statusResponse['progress'] ?? "Working on your story..."}');
          if (attempt < maxAttempts - 1) {
            await Future.delayed(pollInterval);
          }
        }
      } catch (e) {
        consecutiveErrors++;
        _loggingService.warning('Polling error (consecutive: $consecutiveErrors of $maxConsecutiveErrors): $e');
        
        if (consecutiveErrors >= maxConsecutiveErrors) {
          _loggingService.error('Story generation failed after $maxConsecutiveErrors consecutive errors, stopping polling');
          throw Exception('🧙‍♂️ Our Story Wizard encountered persistent connection issues. Please check your internet connection and try again later.');
        }
        
        if (attempt == maxAttempts - 1) {
          _loggingService.error('Final polling attempt failed: $e');
          rethrow;
        }
        _loggingService.warning('Polling attempt ${attempt + 1} failed, retrying...');
        await Future.delayed(pollInterval);
      }
    }

    throw Exception('🧙‍♂️ Our Story Wizard is taking longer than expected to craft your magical tale. Please try again!');
  }


  /// Check the status of a background job
  Future<Map<String, dynamic>> _checkJobStatus(String jobId) async {
    try {
      final response = await _dio.get(
        '/stories/status/$jobId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to check job status: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error checking job status: $e');
      rethrow;
    }
  }

  /// Get the result of a completed background job
  Future<Map<String, dynamic>> _getJobResult(String jobId) async {
    try {
      final response = await _dio.get(
        '/stories/result/$jobId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get job result: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error getting job result: $e');
      rethrow;
    }
  }

  /// Add a story to user's favorites.
  ///
  /// Works with both user-generated and pre-generated stories.
  Future<Map<String, dynamic>> addFavorite({
    required String userId,
    required String storyId,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t update your favorites right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Adding story to favorites for user ID: $userId, story ID: $storyId');

    try {
      final response = await _dio.post(
        '/users/$userId/favorites/$storyId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Add favorite API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final favoriteResponse = response.data as Map<String, dynamic>;
        _loggingService.info('Story added to favorites successfully');
        return favoriteResponse;
      } else {
        _loggingService.error('Add favorite API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to add favorite: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error adding favorite: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while adding to favorites. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to save your favorite! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t update your favorites right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = '📖 That story seems to have wandered off! Please try refreshing the app and try again.';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s favorite magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while saving your favorite. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while saving your magical favorite. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Remove a story from user's favorites.
  ///
  /// Works with both user-generated and pre-generated stories.
  Future<Map<String, dynamic>> removeFavorite({
    required String userId,
    required String storyId,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t update your favorites right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Removing story from favorites for user ID: $userId, story ID: $storyId');

    try {
      final response = await _dio.delete(
        '/users/$userId/favorites/$storyId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Remove favorite API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final favoriteResponse = response.data as Map<String, dynamic>;
        _loggingService.info('Story removed from favorites successfully');
        return favoriteResponse;
      } else {
        _loggingService.error('Remove favorite API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to remove favorite: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error removing favorite: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while removing from favorites. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to update your favorite! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t update your favorites right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = '📖 That favorite seems to have already been removed! Your favorites list is up to date.';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s favorite magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while updating your favorite. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while updating your magical favorite. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }

  /// Get user's favorite stories with pagination.
  ///
  /// Returns paginated list of both user-generated and pre-generated favorite stories.
  Future<Map<String, dynamic>> getUserFavorites({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t reach your favorite stories right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    _loggingService.info('Fetching user favorites for user ID: $userId, page: $page, limit: $limit');

    try {
      final response = await _dio.get(
        '/users/$userId/favorites',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'x-api-key': _appConfig.apiKey,
            'device-id': await _getDeviceIdHeader(),
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('User favorites API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final favoritesResponse = response.data as Map<String, dynamic>;
        _loggingService.info('User favorites fetched successfully: ${favoritesResponse['favorites']?.length ?? 0} favorites on page $page');
        return favoritesResponse;
      } else {
        _loggingService.error('User favorites API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to fetch user favorites: ${response.statusCode}');
      }
    } catch (e) {
      _loggingService.error('Error fetching user favorites: $e');

      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while fetching your favorite stories. Please try again!';

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to fetch your favorite stories! The connection seems slow. Please check your internet and let\'s try again!';
            break;
          case DioExceptionType.connectionError:
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t reach your favorite stories right now. Please check your internet connection and we\'ll try to reconnect!';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorMessage = '👤 Your magical story account seems to have wandered off! Please restart the app to create a new account.';
            } else if (statusCode == 400) {
              errorMessage = '📖 There seems to be an issue with your favorites request. Please try again with different parameters!';
            } else if (statusCode == 500) {
              errorMessage = '🏰 The Story Wizard\'s favorite magic is having some difficulties right now. We\'re working to fix it - please try again in a little while!';
            } else {
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while fetching your favorite stories. Let\'s try again!';
            }
            break;
          default:
            errorMessage = '🌙 Something unexpected happened while fetching your magical favorite stories. Our Story Wizard is investigating - please try again!';
        }
      }

      throw Exception(errorMessage);
    }
  }
}
