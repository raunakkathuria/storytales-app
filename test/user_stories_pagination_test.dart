import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storytales/core/config/app_config.dart';
import 'package:storytales/core/services/connectivity/connectivity_service.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/core/services/api/user_api_client.dart';
import 'package:storytales/core/services/auth/authentication_service.dart';
import 'package:storytales/core/services/device/device_service.dart';
import 'package:storytales/core/models/pagination_info.dart';
import 'package:storytales/core/models/user_stories_response.dart';

import 'user_stories_pagination_test.mocks.dart';

@GenerateMocks([
  Dio,
  ConnectivityService,
  AppConfig,
  DeviceService,
  UserApiClient,
  LoggingService,
])
void main() {
  group('User Stories Pagination Tests', () {
    late MockDio mockDio;
    late MockConnectivityService mockConnectivityService;
    late MockAppConfig mockAppConfig;
    late MockDeviceService mockDeviceService;
    late MockUserApiClient mockUserApiClient;
    late MockLoggingService mockLoggingService;
    late UserApiClient userApiClient;
    late AuthenticationService authService;

    setUp(() {
      // Reset GetIt instance
      GetIt.instance.reset();

      mockDio = MockDio();
      mockConnectivityService = MockConnectivityService();
      mockAppConfig = MockAppConfig();
      mockDeviceService = MockDeviceService();
      mockUserApiClient = MockUserApiClient();
      mockLoggingService = MockLoggingService();

      // Register mock logging service
      GetIt.instance.registerSingleton<LoggingService>(mockLoggingService);

      // Setup mock app config
      when(mockAppConfig.apiKey).thenReturn('test-api-key');
      when(mockAppConfig.apiTimeoutSeconds).thenReturn(30);

      userApiClient = UserApiClient(
        dio: mockDio,
        connectivityService: mockConnectivityService,
        appConfig: mockAppConfig,
      );

      authService = AuthenticationService(
        deviceService: mockDeviceService,
        userApiClient: mockUserApiClient,
      );
    });

    tearDown(() {
      // Clean up GetIt instance
      GetIt.instance.reset();
    });

    group('PaginationInfo Model', () {
      test('should create PaginationInfo from JSON correctly', () {
        // Arrange
        final json = {
          'total': 50,
          'current_page': 2,
          'total_pages': 5,
          'has_next': true,
          'has_previous': true,
          'limit': 10,
        };

        // Act
        final paginationInfo = PaginationInfo.fromJson(json);

        // Assert
        expect(paginationInfo.total, 50);
        expect(paginationInfo.currentPage, 2);
        expect(paginationInfo.totalPages, 5);
        expect(paginationInfo.hasNext, true);
        expect(paginationInfo.hasPrevious, true);
        expect(paginationInfo.limit, 10);
      });

      test('should convert PaginationInfo to JSON correctly', () {
        // Arrange
        const paginationInfo = PaginationInfo(
          total: 25,
          currentPage: 1,
          totalPages: 3,
          hasNext: true,
          hasPrevious: false,
          limit: 10,
        );

        // Act
        final json = paginationInfo.toJson();

        // Assert
        expect(json['total'], 25);
        expect(json['current_page'], 1);
        expect(json['total_pages'], 3);
        expect(json['has_next'], true);
        expect(json['has_previous'], false);
        expect(json['limit'], 10);
      });
    });

    group('UserStoriesResponse Model', () {
      test('should create UserStoriesResponse from JSON correctly', () {
        // Arrange
        final json = {
          'stories': [
            {
              'id': 'story-1',
              'title': 'Test Story 1',
              'summary': 'A test story summary',
              'cover_image_path': '/images/story1.jpg',
              'created_at': '2024-01-01T10:00:00Z',
              'author': 'Test Author',
              'age_range': '5-8',
              'reading_time': '5 minutes',
              'original_prompt': 'Test prompt',
              'genre': 'Adventure',
              'theme': 'Friendship',
              'tags': ['adventure', 'friendship'],
            }
          ],
          'pagination': {
            'total': 1,
            'current_page': 1,
            'total_pages': 1,
            'has_next': false,
            'has_previous': false,
            'limit': 20,
          },
          'subscription_tier': 'free',
          'stories_remaining': 2,
        };

        // Act
        final response = UserStoriesResponse.fromJson(json);

        // Assert
        expect(response.stories.length, 1);
        expect(response.stories.first.id, 'story-1');
        expect(response.stories.first.title, 'Test Story 1');
        expect(response.pagination.total, 1);
        expect(response.subscriptionTier, 'free');
        expect(response.storiesRemaining, 2);
      });
    });

    group('UserApiClient getUserStories', () {
      test('should fetch user stories with pagination successfully', () async {
        // Arrange
        when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);

        final responseData = {
          'stories': [
            {
              'id': 'story-1',
              'title': 'Test Story 1',
              'summary': 'A test story summary',
              'cover_image_path': '/images/story1.jpg',
              'created_at': '2024-01-01T10:00:00Z',
              'author': 'Test Author',
              'age_range': '5-8',
              'reading_time': '5 minutes',
              'original_prompt': 'Test prompt',
              'genre': 'Adventure',
              'theme': 'Friendship',
              'tags': ['adventure', 'friendship'],
            }
          ],
          'pagination': {
            'total': 15,
            'current_page': 2,
            'total_pages': 3,
            'has_next': true,
            'has_previous': true,
            'limit': 5,
          },
          'subscription_tier': 'premium',
          'stories_remaining': 8,
        };

        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/users/123/stories'),
        );

        when(mockDio.get(
          '/users/123/stories',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => response);

        // Act
        final result = await userApiClient.getUserStories(
          userId: 123,
          page: 2,
          limit: 5,
        );

        // Assert
        expect(result.stories.length, 1);
        expect(result.stories.first.title, 'Test Story 1');
        expect(result.pagination.currentPage, 2);
        expect(result.pagination.total, 15);
        expect(result.pagination.hasNext, true);
        expect(result.pagination.hasNext, true);
        expect(result.subscriptionTier, 'premium');
        expect(result.storiesRemaining, 8);

        // Verify the API call was made with correct parameters
        verify(mockDio.get(
          '/users/123/stories',
          queryParameters: {
            'page': 2,
            'limit': 5,
          },
          options: anyNamed('options'),
        )).called(1);
      });

      test('should use default pagination parameters when not provided', () async {
        // Arrange
        when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);

        final responseData = {
          'stories': [],
          'pagination': {
            'total': 0,
            'current_page': 1,
            'total_pages': 0,
            'has_next': false,
            'has_previous': false,
            'limit': 20,
          },
          'subscription_tier': 'free',
          'stories_remaining': 3,
        };

        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/users/123/stories'),
        );

        when(mockDio.get(
          '/users/123/stories',
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => response);

        // Act
        await userApiClient.getUserStories(userId: 123);

        // Assert
        verify(mockDio.get(
          '/users/123/stories',
          queryParameters: {
            'page': 1,
            'limit': 20,
          },
          options: anyNamed('options'),
        )).called(1);
      });

      test('should throw exception when no internet connection', () async {
        // Arrange
        when(mockConnectivityService.isConnected()).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => userApiClient.getUserStories(userId: 123),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Story Wizard can\'t reach your story collection'),
          )),
        );
      });
    });

    group('AuthenticationService getUserStories', () {
      test('should fetch user stories through authentication service', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'user_id': 123});

        final expectedResponse = UserStoriesResponse(
          stories: [],
          pagination: const PaginationInfo(
            total: 0,
            currentPage: 1,
            totalPages: 0,
            hasNext: false,
            hasPrevious: false,
            limit: 20,
          ),
          subscriptionTier: 'free',
          storiesRemaining: 3,
        );

        when(mockUserApiClient.getUserStories(
          userId: anyNamed('userId'),
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => expectedResponse);

        // Act
        final result = await authService.getUserStories(page: 1, limit: 10);

        // Assert
        expect(result.stories.length, 0);
        expect(result.pagination.currentPage, 1);
        expect(result.subscriptionTier, 'free');
        expect(result.storiesRemaining, 3);

        // Verify the API was called with correct user ID
        verify(mockUserApiClient.getUserStories(
          userId: 123,
          page: 1,
          limit: 10,
        )).called(1);
      });
    });
  });
}
