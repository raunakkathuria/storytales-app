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
import 'package:storytales/core/services/device/device_service.dart';

import 'user_authentication_enhancement_test.mocks.dart';

@GenerateMocks([
  Dio,
  ConnectivityService,
  AppConfig,
  DeviceService,
  LoggingService,
  UserApiClient,
  SharedPreferences,
])
void main() {
  group('User Authentication Enhancement Tests', () {
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

    group('UserApiClient.getUserByDevice Tests', () {
      test('should successfully get user by device ID', () async {
        // Arrange
        const deviceId = 'test-device-123';
        final responseData = {
          'user_id': 456,
          'device_id': deviceId,
          'subscription_tier': 'free',
          'stories_remaining': 2,
          'is_anonymous': true,
        };

        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/users/device/$deviceId'),
        );

        when(mockDio.get(
          '/users/device/$deviceId',
          options: anyNamed('options'),
        )).thenAnswer((_) async => response);

        // Act
        final result = await userApiClient.getUserByDevice(deviceId: deviceId);

        // Assert
        expect(result, equals(responseData));
        verify(mockDio.get(
          '/users/device/$deviceId',
          options: anyNamed('options'),
        )).called(1);
      });

      test('should include proper headers in getUserByDevice request', () async {
        // Arrange
        const deviceId = 'test-device-123';
        final responseData = {
          'user_id': 456,
          'device_id': deviceId,
          'subscription_tier': 'free',
        };

        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/users/device/$deviceId'),
        );

        when(mockDio.get(
          '/users/device/$deviceId',
          options: anyNamed('options'),
        )).thenAnswer((_) async => response);

        // Act
        await userApiClient.getUserByDevice(deviceId: deviceId);

        // Assert
        final captured = verify(mockDio.get(
          '/users/device/$deviceId',
          options: captureAnyNamed('options'),
        )).captured;

        final options = captured.first as Options;
        expect(options.headers, isNotNull);
        expect(options.headers!['device-id'], equals('test-device-id-12345'));
        expect(options.headers!['x-api-key'], equals('test-api-key'));
        expect(options.headers!['Accept'], equals('application/json'));
      });

      test('should handle 404 error when device ID not found', () async {
        // Arrange
        const deviceId = 'non-existent-device';

        when(mockDio.get(
          '/users/device/$deviceId',
          options: anyNamed('options'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/users/device/$deviceId'),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: '/users/device/$deviceId'),
          ),
          type: DioExceptionType.badResponse,
        ));

        // Act & Assert
        expect(
          () => userApiClient.getUserByDevice(deviceId: deviceId),
          throwsA(predicate((e) => e.toString().contains('No magical story account found'))),
        );
      });

      test('should handle connectivity issues', () async {
        // Arrange
        when(mockConnectivityService.isConnected()).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => userApiClient.getUserByDevice(deviceId: 'test-device'),
          throwsA(predicate((e) => e.toString().contains('check your internet connection'))),
        );
      });
    });

    group('AuthenticationService Logic Tests', () {
      test('getUserByDevice should be called with correct device ID', () async {
        // This is a simple test to verify the new method was added correctly
        const deviceId = 'test-device-logic-123';
        final responseData = {
          'user_id': 456,
          'device_id': deviceId,
          'subscription_tier': 'free',
          'stories_remaining': 2,
        };

        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/users/device/$deviceId'),
        );

        when(mockDio.get(
          '/users/device/$deviceId',
          options: anyNamed('options'),
        )).thenAnswer((_) async => response);

        // Act
        final result = await userApiClient.getUserByDevice(deviceId: deviceId);

        // Assert
        expect(result['user_id'], equals(456));
        expect(result['device_id'], equals(deviceId));
        verify(mockDio.get('/users/device/$deviceId', options: anyNamed('options'))).called(1);
      });

      test('getUserByDevice should throw exception for non-existent device', () async {
        // Arrange
        const deviceId = 'non-existent-device-456';

        when(mockDio.get(
          '/users/device/$deviceId',
          options: anyNamed('options'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/users/device/$deviceId'),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: '/users/device/$deviceId'),
          ),
          type: DioExceptionType.badResponse,
        ));

        // Act & Assert
        expect(
          () => userApiClient.getUserByDevice(deviceId: deviceId),
          throwsA(predicate((e) => e.toString().contains('No magical story account found'))),
        );
      });

      test('getUserByDevice should handle 500 server errors', () async {
        // Arrange
        const deviceId = 'server-error-device';

        when(mockDio.get(
          '/users/device/$deviceId',
          options: anyNamed('options'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/users/device/$deviceId'),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/users/device/$deviceId'),
          ),
          type: DioExceptionType.badResponse,
        ));

        // Act & Assert
        expect(
          () => userApiClient.getUserByDevice(deviceId: deviceId),
          throwsA(predicate((e) => e.toString().contains('account lookup magic is having some difficulties'))),
        );
      });
    });
  });
}