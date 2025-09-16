import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:storytales/core/config/app_config.dart';
import 'package:storytales/core/services/connectivity/connectivity_service.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/core/services/api/user_api_client.dart';
import 'package:storytales/core/services/device/device_service.dart';

import 'device_id_header_test.mocks.dart';

@GenerateMocks([
  Dio,
  ConnectivityService,
  AppConfig,
  DeviceService,
  LoggingService,
])
void main() {
  group('Device ID Header Tests', () {
    late MockDio mockDio;
    late MockConnectivityService mockConnectivityService;
    late MockAppConfig mockAppConfig;
    late MockDeviceService mockDeviceService;
    late MockLoggingService mockLoggingService;
    late UserApiClient userApiClient;

    setUp(() {
      // Reset GetIt instance
      GetIt.instance.reset();

      mockDio = MockDio();
      mockConnectivityService = MockConnectivityService();
      mockAppConfig = MockAppConfig();
      mockDeviceService = MockDeviceService();
      mockLoggingService = MockLoggingService();

      // Register mock logging service
      GetIt.instance.registerSingleton<LoggingService>(mockLoggingService);

      // Setup mock app config
      when(mockAppConfig.apiKey).thenReturn('test-api-key');
      when(mockAppConfig.apiTimeoutSeconds).thenReturn(30);

      // Setup mock device service
      when(mockDeviceService.getDeviceId()).thenAnswer((_) async => 'test-device-id-12345');

      // Setup connectivity
      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);

      userApiClient = UserApiClient(
        dio: mockDio,
        connectivityService: mockConnectivityService,
        deviceService: mockDeviceService,
        appConfig: mockAppConfig,
      );
    });

    tearDown(() {
      // Clean up GetIt instance
      GetIt.instance.reset();
    });

    test('createUser should include device-id header', () async {
      // Arrange
      final responseData = {
        'user_id': 123,
        'subscription_tier': 'free',
        'stories_remaining': 2,
      };

      final response = Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/users'),
      );

      when(mockDio.post(
        '/users',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act
      await userApiClient.createUser(deviceId: 'test-device-123');

      // Assert
      final captured = verify(mockDio.post(
        '/users',
        data: anyNamed('data'),
        options: captureAnyNamed('options'),
      )).captured;

      final options = captured.first as Options;
      expect(options.headers, isNotNull);
      expect(options.headers!['device-id'], equals('test-device-id-12345'));
      expect(options.headers!['x-api-key'], equals('test-api-key'));
      expect(options.headers!['Content-Type'], equals('application/json'));
    });

    test('getUserProfile should include device-id header', () async {
      // Arrange
      final responseData = {
        'user_id': 123,
        'subscription_tier': 'free',
        'stories_remaining': 2,
      };

      final response = Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/users/123'),
      );

      when(mockDio.get(
        '/users/123',
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act
      await userApiClient.getUserProfile(userId: '123');

      // Assert
      final captured = verify(mockDio.get(
        '/users/123',
        options: captureAnyNamed('options'),
      )).captured;

      final options = captured.first as Options;
      expect(options.headers, isNotNull);
      expect(options.headers!['device-id'], equals('test-device-id-12345'));
      expect(options.headers!['x-api-key'], equals('test-api-key'));
    });

    test('updateUserProfile should include device-id header', () async {
      // Arrange
      final responseData = {
        'user_id': 123,
        'display_name': 'Test User',
        'subscription_tier': 'free',
        'stories_remaining': 2,
      };

      final response = Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/users/123/profile'),
      );

      when(mockDio.put(
        '/users/123/profile',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act
      await userApiClient.updateUserProfile(
        userId: '123',
        displayName: 'Test User',
      );

      // Assert
      final captured = verify(mockDio.put(
        '/users/123/profile',
        data: anyNamed('data'),
        options: captureAnyNamed('options'),
      )).captured;

      final options = captured.first as Options;
      expect(options.headers, isNotNull);
      expect(options.headers!['device-id'], equals('test-device-id-12345'));
      expect(options.headers!['x-api-key'], equals('test-api-key'));
      expect(options.headers!['Content-Type'], equals('application/json'));
    });

    test('purchaseSubscription should include device-id header', () async {
      // Arrange
      final responseData = {
        'success': true,
        'subscription_tier': 'monthly',
        'expires_at': '2025-02-15T10:30:00Z',
        'platform': 'ios',
        'product_id': 'com.storytales.monthly',
        'unlimited_stories': true,
      };

      final response = Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/users/123/purchase-subscription'),
      );

      when(mockDio.post(
        '/users/123/purchase-subscription',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act
      await userApiClient.purchaseSubscription(
        userId: '123',
        platform: 'ios',
        productId: 'com.storytales.monthly',
        receiptData: 'base64_receipt_data',
        transactionId: 'transaction_123',
      );

      // Assert
      final captured = verify(mockDio.post(
        '/users/123/purchase-subscription',
        data: anyNamed('data'),
        options: captureAnyNamed('options'),
      )).captured;

      final options = captured.first as Options;
      expect(options.headers, isNotNull);
      expect(options.headers!['device-id'], equals('test-device-id-12345'));
      expect(options.headers!['x-api-key'], equals('test-api-key'));
      expect(options.headers!['Content-Type'], equals('application/json'));
    });

    test('restoreSubscription should include device-id header', () async {
      // Arrange
      final responseData = {
        'success': true,
        'subscription_found': true,
        'subscription_tier': 'monthly',
        'expires_at': '2025-02-15T10:30:00Z',
        'platform': 'ios',
        'product_id': 'com.storytales.monthly',
      };

      final response = Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/users/123/restore-subscription'),
      );

      when(mockDio.post(
        '/users/123/restore-subscription',
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act
      await userApiClient.restoreSubscription(
        userId: '123',
        platform: 'ios',
        receiptData: 'base64_receipt_data',
      );

      // Assert
      final captured = verify(mockDio.post(
        '/users/123/restore-subscription',
        data: anyNamed('data'),
        options: captureAnyNamed('options'),
      )).captured;

      final options = captured.first as Options;
      expect(options.headers, isNotNull);
      expect(options.headers!['device-id'], equals('test-device-id-12345'));
      expect(options.headers!['x-api-key'], equals('test-api-key'));
      expect(options.headers!['Content-Type'], equals('application/json'));
    });

    test('getSubscriptionStatus should include device-id header', () async {
      // Arrange
      final responseData = {
        'user_id': 'test-user-uuid-1',
        'subscription_tier': 'monthly',
        'is_active': true,
        'expires_at': '2025-02-15T10:30:00Z',
        'platform': 'ios',
        'product_id': 'com.storytales.monthly',
        'auto_renewing': true,
        'unlimited_stories': true,
      };

      final response = Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/users/123/subscription-status'),
      );

      when(mockDio.get(
        '/users/123/subscription-status',
        options: anyNamed('options'),
      )).thenAnswer((_) async => response);

      // Act
      await userApiClient.getSubscriptionStatus(userId: '123');

      // Assert
      final captured = verify(mockDio.get(
        '/users/123/subscription-status',
        options: captureAnyNamed('options'),
      )).captured;

      final options = captured.first as Options;
      expect(options.headers, isNotNull);
      expect(options.headers!['device-id'], equals('test-device-id-12345'));
      expect(options.headers!['x-api-key'], equals('test-api-key'));
    });

    test('getUserStories should include device-id header', () async {
      // Arrange
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
        'stories_remaining': 2,
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
      await userApiClient.getUserStories(userId: '123');

      // Assert
      final captured = verify(mockDio.get(
        '/users/123/stories',
        queryParameters: anyNamed('queryParameters'),
        options: captureAnyNamed('options'),
      )).captured;

      final options = captured.first as Options;
      expect(options.headers, isNotNull);
      expect(options.headers!['device-id'], equals('test-device-id-12345'));
      expect(options.headers!['x-api-key'], equals('test-api-key'));
    });

    test('device service should be called for each API request', () async {
      // Arrange
      final responseData = {'user_id': 123, 'subscription_tier': 'free'};
      final response = Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/users/123'),
      );

      when(mockDio.get(any, options: anyNamed('options')))
          .thenAnswer((_) async => response);

      // Act - Make multiple API calls
      await userApiClient.getUserProfile(userId: '123');
      await userApiClient.getUserProfile(userId: '123');

      // Assert - Device service should be called for each request
      verify(mockDeviceService.getDeviceId()).called(2);
    });
  });
}
