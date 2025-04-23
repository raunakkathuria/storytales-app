import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:storytales/core/config/app_config.dart';
import 'package:storytales/core/di/injection_container.dart';
import 'package:storytales/core/services/connectivity/connectivity_service.dart';
import 'package:storytales/core/services/image/image_service.dart';
import 'package:storytales/core/services/logging/logging_service.dart';

/// Client for interacting with the story generation API.
class StoryApiClient {
  final Dio _dio;
  final ConnectivityService _connectivityService;
  final LoggingService _loggingService;
  final AppConfig _appConfig;

  StoryApiClient({
    required Dio dio,
    required ConnectivityService connectivityService,
    required AppConfig appConfig,
  })  : _dio = dio,
        _connectivityService = connectivityService,
        _appConfig = appConfig,
        _loggingService = sl<LoggingService>();

  /// Generate a story using the local API.
  Future<Map<String, dynamic>> generateStory({
    required String prompt,
    String? ageRange,
    String? theme,
    String? genre,
  }) async {
    // Check connectivity only if we're not using mock data
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected && !_appConfig.useMockData) {
      throw Exception('No internet connection');
    }

    // Log the current configuration for debugging
    _loggingService.info('Using API endpoint: ${_appConfig.apiBaseUrl}');
    _loggingService.info('Mock data enabled: ${_appConfig.useMockData}');

    try {
      // Convert ageRange to integer for the API
      int age = 8; // Default age
      if (ageRange != null) {
        // Parse age range like "7-9" to get the average
        final parts = ageRange.split('-');
        if (parts.length == 2) {
          final minAge = int.tryParse(parts[0]) ?? 8;
          final maxAge = int.tryParse(parts[1]) ?? 10;
          age = (minAge + maxAge) ~/ 2;
        } else {
          age = int.tryParse(ageRange) ?? 8;
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

      // Make the API call to the configured endpoint
      final response = await _dio.post(
        '${_appConfig.apiBaseUrl}/story',
        data: {
          'age': age,
          'character_name': characterName,
          'description': prompt,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
          receiveTimeout: Duration(seconds: _appConfig.apiTimeoutSeconds),
        ),
      );

      if (response.statusCode == 200) {
        final apiResponse = response.data;

        // Process the response to handle null image URLs
        return _processApiResponse(apiResponse);
      } else {
        throw Exception('Failed to generate story: ${response.statusCode}');
      }
    } catch (e) {
      // Error handling with fallback for development
      _loggingService.error('Error calling API: $e');

      // Check if we should use mock data based on configuration
      if (!_appConfig.useMockData) {
        // In production, we don't want to use mock data, so rethrow the error
        throw Exception('Failed to generate story: $e');
      }

      // Fall back to sample response during development
      final jsonString = await rootBundle.loadString('assets/data/sample-ai-response.json');
      final sampleResponse = json.decode(jsonString);

      // Update the sample response with the provided parameters
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

        metadata['original_prompt'] = prompt;
        metadata['created_at'] = DateTime.now().toIso8601String();
      }

      return sampleResponse;
    }
  }

  /// Process the API response to handle null image URLs and ensure correct format
  Map<String, dynamic> _processApiResponse(Map<String, dynamic> apiResponse) {
    // Extract the response data
    final metadata = apiResponse['metadata'] as Map<String, dynamic>;
    final data = apiResponse['data'] as Map<String, dynamic>;

    // Process cover image URL - use placeholder if null
    final coverImageUrl = data['cover_image_url'] ?? ImageService.placeholderImagePath;

    // Process pages and handle null image URLs
    final pages = (data['pages'] as List).map((page) {
      return {
        'content': page['content'],
        'image_url': page['image_url'] ?? ImageService.placeholderImagePath,
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
}
