import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:storytales/core/config/app_config.dart';
import 'package:storytales/core/models/job_response.dart';
import 'package:storytales/core/models/job_status_response.dart';
import 'package:storytales/core/services/analytics/analytics_service.dart';
import 'package:storytales/core/services/connectivity/connectivity_service.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/features/story_generation/data/datasources/story_api_client.dart';

import 'story_generation_job_system_test.mocks.dart';

@GenerateMocks([Dio, ConnectivityService, LoggingService, AnalyticsService])
void main() {
  group('StoryApiClient Background Job System', () {
    late StoryApiClient storyApiClient;
    late MockDio mockDio;
    late MockConnectivityService mockConnectivityService;
    late MockLoggingService mockLoggingService;
    late MockAnalyticsService mockAnalyticsService;
    late AppConfig appConfig;

    setUp(() {
      // Reset GetIt
      GetIt.instance.reset();

      // Create mocks
      mockDio = MockDio();
      mockConnectivityService = MockConnectivityService();
      mockLoggingService = MockLoggingService();
      mockAnalyticsService = MockAnalyticsService();

      // Register mocks in GetIt
      GetIt.instance.registerSingleton<LoggingService>(mockLoggingService);
      GetIt.instance.registerSingleton<AnalyticsService>(mockAnalyticsService);

      appConfig = const AppConfig(
        apiBaseUrl: 'https://test-api.com',
        apiTimeoutSeconds: 30,
        useMockData: false,
        environment: 'test',
        apiKey: 'test-api-key',
      );

      storyApiClient = StoryApiClient(
        dio: mockDio,
        connectivityService: mockConnectivityService,
        appConfig: appConfig,
      );
    });

    tearDown(() {
      GetIt.instance.reset();
    });

    test('should handle JobResponse correctly when starting story generation', () async {
      // Arrange
      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);

      final jobResponse = {
        'job_id': 'test-job-123',
        'status': 'started',
        'message': 'Story generation started in background thread',
        'check_status_url': '/story/status/test-job-123',
        'get_result_url': '/story/result/test-job-123',
        'estimated_time': '2-5 minutes',
      };

      final statusResponse = {
        'job_id': 'test-job-123',
        'status': 'completed',
        'started_at': '2025-01-15T10:30:00Z',
        'completed_at': '2025-01-15T10:32:00Z',
      };

      final storyResult = {
        'id': 'story-123',
        'metadata': {
          'author': 'Storytales Maker',
          'age_range': '6-8 years',
          'reading_time': '5 minutes',
          'created_at': '2025-01-15T10:32:00Z',
          'original_prompt': 'A friendly dragon',
          'tags': ['adventure', 'friendship'],
          'genre': 'Children\'s Fantasy',
          'theme': 'Friendship',
          'main_character': 'Dragon',
          'characters': ['Dragon', 'Child'],
          'setting': 'Magical forest',
          'mood': 'Cheerful',
          'visual_style': 'Colorful and whimsical',
          'character_profiles': [],
          'visual_style_guidelines': {
            'art_style': 'Pixar/Disney 3D animation style',
            'lighting': 'soft, warm lighting',
            'color_palette': ['green', 'blue', 'yellow'],
            'character_consistency_rules': 'Consistent character appearance',
          },
          'visual_scenes': [],
          'story_sections': [],
          'image_plan': [],
          'total_images': 2,
        },
        'data': {
          'title': 'The Friendly Dragon',
          'summary': 'A story about a friendly dragon who makes friends.',
          'cover_image_url': 'https://test-api.com/images/cover.png',
          'pages': [
            {
              'content': 'Once upon a time, there was a friendly dragon.',
              'section_number': 1,
              'image_url': 'https://test-api.com/images/page1.png',
            }
          ],
          'questions': ['What made the dragon friendly?'],
        },
      };

      // Mock the API calls in sequence
      when(mockDio.post(
        '${appConfig.apiBaseUrl}/story',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: jobResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/story'),
      ));

      when(mockDio.get(
        '${appConfig.apiBaseUrl}/story/status/test-job-123',
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: statusResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/story/status/test-job-123'),
      ));

      when(mockDio.get(
        '${appConfig.apiBaseUrl}/story/result/test-job-123',
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: storyResult,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/story/result/test-job-123'),
      ));

      // Act
      final result = await storyApiClient.generateStory(
        prompt: 'A friendly dragon',
        ageRange: '6-8 years',
      );

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['metadata']['title'], isNull); // metadata doesn't have title
      expect(result['data']['title'], equals('The Friendly Dragon'));
      expect(result['data']['summary'], equals('A story about a friendly dragon who makes friends.'));
      expect(result['data']['pages'], isA<List>());
      expect(result['data']['pages'].length, equals(1));

      // Verify the API calls were made in the correct sequence
      verify(mockDio.post(
        '${appConfig.apiBaseUrl}/story',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).called(1);

      verify(mockDio.get(
        '${appConfig.apiBaseUrl}/story/status/test-job-123',
        options: anyNamed('options'),
      )).called(1);

      verify(mockDio.get(
        '${appConfig.apiBaseUrl}/story/result/test-job-123',
        options: anyNamed('options'),
      )).called(1);
    });

    test('should handle job failure correctly', () async {
      // Arrange
      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);

      final jobResponse = {
        'job_id': 'test-job-456',
        'status': 'started',
        'message': 'Story generation started in background thread',
        'check_status_url': '/story/status/test-job-456',
        'get_result_url': '/story/result/test-job-456',
        'estimated_time': '2-5 minutes',
      };

      final failedStatusResponse = {
        'job_id': 'test-job-456',
        'status': 'failed',
        'started_at': '2025-01-15T10:30:00Z',
        'error': 'AI service temporarily unavailable',
      };

      // Mock the API calls
      when(mockDio.post(
        '${appConfig.apiBaseUrl}/story',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: jobResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/story'),
      ));

      when(mockDio.get(
        '${appConfig.apiBaseUrl}/story/status/test-job-456',
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: failedStatusResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/story/status/test-job-456'),
      ));

      // Act & Assert
      expect(
        () async => await storyApiClient.generateStory(
          prompt: 'A friendly dragon',
          ageRange: '6-8 years',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Our Story Wizard encountered a magical mishap: AI service temporarily unavailable'),
        )),
      );
    });

    test('should parse JobResponse correctly', () {
      // Arrange
      final json = {
        'job_id': 'test-job-789',
        'status': 'started',
        'message': 'Story generation started',
        'check_status_url': '/story/status/test-job-789',
        'get_result_url': '/story/result/test-job-789',
        'estimated_time': '3 minutes',
      };

      // Act
      final jobResponse = JobResponse.fromJson(json);

      // Assert
      expect(jobResponse.jobId, equals('test-job-789'));
      expect(jobResponse.status, equals('started'));
      expect(jobResponse.message, equals('Story generation started'));
      expect(jobResponse.checkStatusUrl, equals('/story/status/test-job-789'));
      expect(jobResponse.getResultUrl, equals('/story/result/test-job-789'));
      expect(jobResponse.estimatedTime, equals('3 minutes'));
    });

    test('should parse JobStatusResponse correctly', () {
      // Arrange
      final json = {
        'job_id': 'test-job-101',
        'status': 'completed',
        'progress': 'Story generation complete',
        'estimated_remaining': null,
        'started_at': '2025-01-15T10:30:00Z',
        'completed_at': '2025-01-15T10:33:00Z',
        'error': null,
      };

      // Act
      final statusResponse = JobStatusResponse.fromJson(json);

      // Assert
      expect(statusResponse.jobId, equals('test-job-101'));
      expect(statusResponse.status, equals('completed'));
      expect(statusResponse.progress, equals('Story generation complete'));
      expect(statusResponse.isCompleted, isTrue);
      expect(statusResponse.isFailed, isFalse);
      expect(statusResponse.isProcessing, isFalse);
      expect(statusResponse.startedAt, equals(DateTime.parse('2025-01-15T10:30:00Z')));
      expect(statusResponse.completedAt, equals(DateTime.parse('2025-01-15T10:33:00Z')));
      expect(statusResponse.error, isNull);
    });
  });
}
