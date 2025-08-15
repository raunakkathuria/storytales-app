import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:storytales/core/config/app_config.dart';
import 'package:storytales/core/di/injection_container.dart';
import 'package:storytales/core/models/job_response.dart';
import 'package:storytales/core/models/job_status_response.dart';
import 'package:storytales/core/services/analytics/analytics_service.dart';
import 'package:storytales/core/services/connectivity/connectivity_service.dart';
import 'package:storytales/core/services/image/image_service.dart';
import 'package:storytales/core/services/logging/logging_service.dart';

/// Client for interacting with the story generation API.
class StoryApiClient {
  final Dio _dio;
  final ConnectivityService _connectivityService;
  final LoggingService _loggingService;
  final AnalyticsService _analyticsService;
  final AppConfig _appConfig;

  StoryApiClient({
    required Dio dio,
    required ConnectivityService connectivityService,
    required AppConfig appConfig,
  })  : _dio = dio,
        _connectivityService = connectivityService,
        _appConfig = appConfig,
        _loggingService = sl<LoggingService>(),
        _analyticsService = sl<AnalyticsService>();

  /// Generate a story using the background job API.
  Future<Map<String, dynamic>> generateStory({
    required String prompt,
    String? ageRange,
    String? theme,
    String? genre,
  }) async {
    // Check connectivity only if we're not using mock data
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected && !_appConfig.useMockData) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t reach the magical story realm right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    // Log the current configuration for debugging
    _loggingService.info('Using API endpoint: ${_appConfig.apiBaseUrl}');
    _loggingService.info('Mock data enabled: ${_appConfig.useMockData}');
    _loggingService.info('API key configured: ${_appConfig.apiKey.isNotEmpty ? 'Yes (${_appConfig.apiKey.length} chars)' : 'No'}');

    try {
      // Start the background job
      final jobResponse = await _startStoryGenerationJob(
        prompt: prompt,
        ageRange: ageRange,
        theme: theme,
        genre: genre,
      );

      // Poll for completion
      final storyData = await _pollForJobCompletion(jobResponse.jobId);

      // Process the completed story response
      return _processApiResponse(storyData);
    } catch (e) {
      _loggingService.error('Error in story generation flow: $e');
      rethrow;
    }
  }

  /// Start a background story generation job
  Future<JobResponse> _startStoryGenerationJob({
    required String prompt,
    String? ageRange,
    String? theme,
    String? genre,
  }) async {
    try {
      // Convert ageRange to integer for the API
      int age = 8; // Default age
      if (ageRange != null) {
        // Remove " years" suffix if present
        final cleanRange = ageRange.replaceAll(' years', '');

        // Parse age range like "6-8" to get the average
        final parts = cleanRange.split('-');
        if (parts.length == 2) {
          final minAge = int.tryParse(parts[0]) ?? 8;
          // Handle special case for "13+" format
          final maxAge = parts[1] == "+" ?
              minAge + 2 : // For "13+", use 15 as max (13+2)
              int.tryParse(parts[1]) ?? 10;
          age = (minAge + maxAge) ~/ 2;
        } else {
          age = int.tryParse(cleanRange) ?? 8;
        }
      }

      // Extract character name from prompt or use default
      String characterName = "Character";
      // Simple logic to try to extract a name from the prompt
      final words = prompt.split(' ');
      if (words.length > 1) {
        // Naively assume the second word might be a name if the first is "a" or "an"
        if (words[0].toLowerCase() == 'a' || words[0].toLowerCase() == 'an') {
          characterName = words[1];
        }
      }

      // Prepare request data
      final requestData = {
        'age': age,
        'character_name': characterName,
        'description': prompt,
      };

      // Log request details for debugging
      _loggingService.info('Making API request to: ${_appConfig.apiBaseUrl}/story');
      _loggingService.info('Request data: ${json.encode(requestData)}');
      _loggingService.info('Headers: Content-Type: application/json, x-api-key: ${_appConfig.apiKey.substring(0, 8)}...');

      // Make the API call to start the background job
      final response = await _dio.post(
        '${_appConfig.apiBaseUrl}/story',
        data: requestData,
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

      _loggingService.info('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final apiResponse = response.data;
        _loggingService.info('Job started successfully');

        // Parse the JobResponse
        return JobResponse.fromJson(apiResponse as Map<String, dynamic>);
      } else {
        _loggingService.error('API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to start story generation: ${response.statusCode}');
      }
    } catch (e) {
      await _handleApiError(e, 'story_generation', {
        'prompt_length': prompt.length,
        'age_range': ageRange,
        'theme': theme,
        'genre': genre,
      });
      rethrow;
    }
  }

  /// Poll for job completion and return the final story data
  Future<Map<String, dynamic>> _pollForJobCompletion(String jobId) async {
    const maxAttempts = 60; // 5 minutes with 5-second intervals
    const pollInterval = Duration(seconds: 5);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        _loggingService.info('Checking job status (attempt ${attempt + 1}/$maxAttempts)');

        final statusResponse = await _checkJobStatus(jobId);

        if (statusResponse.isCompleted) {
          _loggingService.info('Job completed successfully');
          return await _getJobResult(jobId);
        } else if (statusResponse.isFailed) {
          final errorMsg = statusResponse.error ?? 'Unknown error occurred during story generation';
          _loggingService.error('Job failed: $errorMsg');
          throw Exception('🧙‍♂️ Our Story Wizard encountered a magical mishap: $errorMsg');
        } else if (statusResponse.isProcessing) {
          _loggingService.info('Job still processing: ${statusResponse.progress ?? "Working on your story..."}');
          if (attempt < maxAttempts - 1) {
            await Future.delayed(pollInterval);
          }
        }
      } catch (e) {
        if (attempt == maxAttempts - 1) {
          _loggingService.error('Final polling attempt failed: $e');
          rethrow;
        }
        _loggingService.warning('Polling attempt ${attempt + 1} failed, retrying: $e');
        await Future.delayed(pollInterval);
      }
    }

    throw Exception('🧙‍♂️ Our Story Wizard is taking longer than expected to craft your magical tale. Please try again!');
  }

  /// Check the status of a background job
  Future<JobStatusResponse> _checkJobStatus(String jobId) async {
    try {
      final response = await _dio.get(
        '${_appConfig.apiBaseUrl}/story/status/$jobId',
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
        return JobStatusResponse.fromJson(response.data as Map<String, dynamic>);
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
        '${_appConfig.apiBaseUrl}/story/result/$jobId',
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

  /// Handle API errors with consistent error messaging and analytics
  Future<void> _handleApiError(dynamic error, String operation, Map<String, dynamic> context) async {
    String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap. Please try again!';
    String errorType = 'unknown_error';
    String technicalDetails = error.toString();

    if (error is DioException) {
      _loggingService.error('DioException Details:');
      _loggingService.error('- Type: ${error.type}');
      _loggingService.error('- Message: ${error.message}');
      _loggingService.error('- Response Status: ${error.response?.statusCode}');
      _loggingService.error('- Response Data: ${error.response?.data}');
      _loggingService.error('- Response Headers: ${error.response?.headers}');

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorType = 'timeout_error';
          errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to weave your tale! The magical connection seems slow. Please check your internet and let\'s try again!';
          technicalDetails = 'Timeout: ${error.type.name} - ${error.message}';
          break;
        case DioExceptionType.connectionError:
          errorType = 'connection_error';
          errorMessage = '🌟 Oh no! Our Story Wizard can\'t reach the magical story realm right now. Please check your internet connection and we\'ll try to reconnect!';
          technicalDetails = 'Connection error: ${error.message}';
          break;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            errorType = 'auth_error';
            errorMessage = '🔮 The Story Wizard\'s magical key isn\'t working properly. We\'re checking with the wizard council to fix this!';
            technicalDetails = 'Authentication failed: HTTP $statusCode';
          } else if (statusCode == 429) {
            errorType = 'rate_limit_error';
            errorMessage = '✨ Wow! So many story requests! Our Story Wizard is a bit overwhelmed. Please wait a moment and try again!';
            technicalDetails = 'Rate limited: HTTP $statusCode';
          } else if (statusCode == 500) {
            errorType = 'server_error';
            errorMessage = '🏰 The Story Wizard\'s castle is having some magical difficulties right now. We\'re working to fix it - please try again in a little while!';
            technicalDetails = 'Server error: HTTP $statusCode - ${error.response?.data}';
          } else {
            errorType = 'api_error';
            errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode). Let\'s try casting the story spell again!';
            technicalDetails = 'API error: HTTP $statusCode - ${error.response?.data}';
          }
          break;
        case DioExceptionType.cancel:
          errorType = 'cancelled_error';
          errorMessage = '📖 The story creation was cancelled. No worries - the Story Wizard is ready whenever you are!';
          technicalDetails = 'Request cancelled by user';
          break;
        default:
          errorType = 'dio_error';
          errorMessage = '🌙 Something unexpected happened in the magical story realm. Our Story Wizard is investigating - please try again!';
          technicalDetails = 'DioException: ${error.type.name} - ${error.message}';
      }
    }

    // Log detailed analytics
    await _analyticsService.logError(
      errorType: '${operation}_$errorType',
      errorMessage: errorMessage,
      errorDetails: json.encode({
        'technical_error': technicalDetails,
        'api_endpoint': _appConfig.apiBaseUrl,
        'environment': _appConfig.environment,
        'timestamp': DateTime.now().toIso8601String(),
        ...context,
      }),
    );

    throw Exception(errorMessage);
  }

  /// Generate a sample story for development/testing purposes.
  /// This method explicitly returns mock data and should only be used
  /// when the user explicitly chooses to view a sample story.
  Future<Map<String, dynamic>> generateSampleStory({
    String? prompt,
    String? ageRange,
    String? theme,
    String? genre,
  }) async {
    _loggingService.info('Generating sample story for development/testing');

    // Load the sample response
    final jsonString = await rootBundle.loadString('assets/data/sample-ai-response.json');
    final sampleResponse = json.decode(jsonString);

    // Update the sample response with the provided parameters if available
    if (sampleResponse is Map<String, dynamic> &&
        sampleResponse.containsKey('metadata') &&
        sampleResponse.containsKey('data')) {
      final metadata = sampleResponse['metadata'] as Map<String, dynamic>;

      if (ageRange != null) {
        metadata['age_range'] = ageRange;
      }

      if (theme != null) {
        metadata['theme'] = theme;
      }

      if (genre != null) {
        metadata['genre'] = genre;
      }

      if (prompt != null) {
        metadata['original_prompt'] = prompt;
      }

      metadata['created_at'] = DateTime.now().toIso8601String();
    }

    // Process the mock response to transform image URLs
    return _processApiResponse(sampleResponse);
  }

  /// Process the API response to handle null image URLs and ensure correct format
  Map<String, dynamic> _processApiResponse(Map<String, dynamic> apiResponse) {
    // Extract the response data
    final metadata = apiResponse['metadata'] as Map<String, dynamic>;
    final data = apiResponse['data'] as Map<String, dynamic>;

    // Process cover image URL - transform mock URLs to use configured API base URL
    final coverImageUrl = _transformImageUrl(data['cover_image_url']);

    // Process pages and handle null image URLs
    final pages = (data['pages'] as List).map((page) {
      return {
        'content': page['content'],
        'image_url': _transformImageUrl(page['image_url']),
      };
    }).toList();

    // Create a processed response that matches the expected format
    return {
      'metadata': metadata,
      'data': {
        'title': data['title'],
        'summary': data['summary'],
        'cover_image_url': coverImageUrl,
        'pages': pages,
        'questions': data['questions'],
      },
    };
  }

  /// Fetch pre-generated stories from the API.
  Future<List<Map<String, dynamic>>> fetchPreGeneratedStories() async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t reach the magical story realm right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    // Log the current configuration for debugging
    _loggingService.info('Fetching pre-generated stories from: ${_appConfig.apiBaseUrl}/stories');

    try {
      // Make the API call to fetch pre-generated stories
      final response = await _dio.get(
        '/stories',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Pre-generated stories API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final apiResponse = response.data;
        _loggingService.info('Pre-generated stories API Response received successfully');

        // Extract the stories array from the response
        if (apiResponse is Map<String, dynamic> && apiResponse.containsKey('stories')) {
          final stories = apiResponse['stories'] as List;
          return stories.cast<Map<String, dynamic>>();
        } else {
          throw Exception('Invalid API response format: missing stories array');
        }
      } else {
        _loggingService.error('Pre-generated stories API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to fetch pre-generated stories: ${response.statusCode}');
      }
    } catch (e) {
      // Enhanced error logging
      if (e is DioException) {
        _loggingService.error('DioException Details for pre-generated stories:');
        _loggingService.error('- Type: ${e.type}');
        _loggingService.error('- Message: ${e.message}');
        _loggingService.error('- Response Status: ${e.response?.statusCode}');
        _loggingService.error('- Response Data: ${e.response?.data}');
        _loggingService.error('- Response Headers: ${e.response?.headers}');
      }
      _loggingService.error('Error fetching pre-generated stories: $e');

      // Provide user-friendly error messages
      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while fetching stories. Please try again!';
      String errorType = 'unknown_error';
      String technicalDetails = e.toString();

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorType = 'timeout_error';
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to gather the magical stories! The connection seems slow. Please check your internet and let\'s try again!';
            technicalDetails = 'Timeout: ${e.type.name} - ${e.message}';
            break;
          case DioExceptionType.connectionError:
            errorType = 'connection_error';
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t reach the magical story library right now. Please check your internet connection and we\'ll try to reconnect!';
            technicalDetails = 'Connection error: ${e.message}';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorType = 'not_found_error';
              errorMessage = '📚 The Story Wizard\'s library seems to be temporarily unavailable. We\'re working to restore access to all the magical stories!';
              technicalDetails = 'Stories endpoint not found: HTTP $statusCode';
            } else if (statusCode == 500) {
              errorType = 'server_error';
              errorMessage = '🏰 The Story Wizard\'s library is having some magical difficulties right now. We\'re working to fix it - please try again in a little while!';
              technicalDetails = 'Server error: HTTP $statusCode - ${e.response?.data}';
            } else {
              errorType = 'api_error';
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while accessing the story library. Let\'s try again!';
              technicalDetails = 'API error: HTTP $statusCode - ${e.response?.data}';
            }
            break;
          case DioExceptionType.cancel:
            errorType = 'cancelled_error';
            errorMessage = '📖 The story fetching was cancelled. No worries - the Story Wizard is ready whenever you are!';
            technicalDetails = 'Request cancelled by user';
            break;
          default:
            errorType = 'dio_error';
            errorMessage = '🌙 Something unexpected happened while accessing the magical story library. Our Story Wizard is investigating - please try again!';
            technicalDetails = 'DioException: ${e.type.name} - ${e.message}';
        }
      }

      // Log detailed analytics for pre-generated stories fetch failures
      await _analyticsService.logError(
        errorType: 'pregenerated_stories_fetch_$errorType',
        errorMessage: errorMessage, // User-friendly message
        errorDetails: json.encode({
          'technical_error': technicalDetails,
          'api_endpoint': '${_appConfig.apiBaseUrl}/stories',
          'environment': _appConfig.environment,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      throw Exception(errorMessage);
    }
  }

  /// Fetch a single story by ID from the API.
  Future<Map<String, dynamic>> fetchStoryById(String storyId) async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      throw Exception('🌟 Oh no! Our Story Wizard can\'t reach the magical story realm right now. Please check your internet connection and we\'ll try to reconnect!');
    }

    // Log the current configuration for debugging
    _loggingService.info('Fetching story by ID from: ${_appConfig.apiBaseUrl}/stories/$storyId');

    try {
      // Make the API call to fetch the specific story
      final response = await _dio.get(
        '/stories/$storyId',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      _loggingService.info('Story by ID API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final apiResponse = response.data;
        _loggingService.info('Story by ID API Response received successfully');

        // The response format is different from the list endpoint
        // It returns a single story object with nested story_data
        return apiResponse as Map<String, dynamic>;
      } else {
        _loggingService.error('Story by ID API Error - Status: ${response.statusCode}, Data: ${response.data}');
        throw Exception('Failed to fetch story: ${response.statusCode}');
      }
    } catch (e) {
      // Enhanced error logging
      if (e is DioException) {
        _loggingService.error('DioException Details for story by ID:');
        _loggingService.error('- Type: ${e.type}');
        _loggingService.error('- Message: ${e.message}');
        _loggingService.error('- Response Status: ${e.response?.statusCode}');
        _loggingService.error('- Response Data: ${e.response?.data}');
        _loggingService.error('- Response Headers: ${e.response?.headers}');
      }
      _loggingService.error('Error fetching story by ID: $e');

      // Provide user-friendly error messages
      String errorMessage = 'Oops! Our Story Wizard encountered a magical mishap while fetching the story. Please try again!';
      String errorType = 'unknown_error';
      String technicalDetails = e.toString();

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorType = 'timeout_error';
            errorMessage = '🧙‍♂️ Our Story Wizard is taking too long to retrieve this magical story! The connection seems slow. Please check your internet and let\'s try again!';
            technicalDetails = 'Timeout: ${e.type.name} - ${e.message}';
            break;
          case DioExceptionType.connectionError:
            errorType = 'connection_error';
            errorMessage = '🌟 Oh no! Our Story Wizard can\'t reach the magical story right now. Please check your internet connection and we\'ll try to reconnect!';
            technicalDetails = 'Connection error: ${e.message}';
            break;
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            if (statusCode == 404) {
              errorType = 'not_found_error';
              errorMessage = '📚 This magical story seems to have wandered off! It might have been moved or is temporarily unavailable. Please try selecting another story!';
              technicalDetails = 'Story not found: HTTP $statusCode';
            } else if (statusCode == 500) {
              errorType = 'server_error';
              errorMessage = '🏰 The Story Wizard\'s library is having some magical difficulties right now. We\'re working to fix it - please try again in a little while!';
              technicalDetails = 'Server error: HTTP $statusCode - ${e.response?.data}';
            } else {
              errorType = 'api_error';
              errorMessage = '🧙‍♂️ Our Story Wizard encountered a mysterious spell error (code $statusCode) while retrieving this story. Let\'s try again!';
              technicalDetails = 'API error: HTTP $statusCode - ${e.response?.data}';
            }
            break;
          case DioExceptionType.cancel:
            errorType = 'cancelled_error';
            errorMessage = '📖 The story fetching was cancelled. No worries - the Story Wizard is ready whenever you are!';
            technicalDetails = 'Request cancelled by user';
            break;
          default:
            errorType = 'dio_error';
            errorMessage = '🌙 Something unexpected happened while retrieving this magical story. Our Story Wizard is investigating - please try again!';
            technicalDetails = 'DioException: ${e.type.name} - ${e.message}';
        }
      }

      // Log detailed analytics for story fetch failures
      await _analyticsService.logError(
        errorType: 'story_fetch_by_id_$errorType',
        errorMessage: errorMessage, // User-friendly message
        errorDetails: json.encode({
          'technical_error': technicalDetails,
          'story_id': storyId,
          'api_endpoint': '${_appConfig.apiBaseUrl}/stories/$storyId',
          'environment': _appConfig.environment,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      throw Exception(errorMessage);
    }
  }

  /// Transform image URLs from mock data to use the configured API base URL
  String _transformImageUrl(String? originalUrl) {
    if (originalUrl == null) {
      return ImageService.placeholderImagePath;
    }

    // If the URL contains the mock domain, replace it with the configured API base URL
    if (originalUrl.contains('ai-service.example.com')) {
      return originalUrl.replaceAll('https://ai-service.example.com', _appConfig.apiBaseUrl);
    }

    // If it's already a valid URL or placeholder, return as is
    return originalUrl;
  }
}
