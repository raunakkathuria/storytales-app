import 'dart:convert';
import 'package:flutter/services.dart';

/// Configuration class for the application.
///
/// This class holds environment-specific configuration values such as API endpoints,
/// feature flags, and other settings that may vary between environments.
class AppConfig {
  /// The base URL for the API.
  final String apiBaseUrl;

  /// The timeout duration for API requests in seconds.
  final int apiTimeoutSeconds;

  /// Whether to use mock data for development.
  final bool useMockData;

  /// The environment name (e.g., development, staging, production).
  final String environment;

  /// Creates a new instance of [AppConfig].
  const AppConfig({
    required this.apiBaseUrl,
    required this.apiTimeoutSeconds,
    required this.useMockData,
    required this.environment,
  });

  /// Creates a new instance of [AppConfig] from a JSON map.
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      apiBaseUrl: json['apiBaseUrl'] as String,
      apiTimeoutSeconds: json['apiTimeoutSeconds'] as int,
      useMockData: json['useMockData'] as bool,
      environment: json['environment'] as String,
    );
  }

  /// Loads the configuration from an asset file.
  ///
  /// The [environment] parameter specifies which environment configuration to load:
  /// - 'production': Uses the default configuration (assets/config/app_config.json)
  /// - 'development': Uses the development configuration (assets/config/app_config_dev.json)
  /// - 'staging': Uses the staging configuration (assets/config/app_config_staging.json)
  ///
  /// If not provided, it defaults to 'production'.
  static Future<AppConfig> load({String environment = 'production'}) async {
    String configPath;

    switch (environment) {
      case 'development':
        configPath = 'assets/config/app_config_dev.json';
        break;
      case 'staging':
        configPath = 'assets/config/app_config_staging.json';
        break;
      case 'production':
      default:
        configPath = 'assets/config/app_config.json';
        break;
    }
    try {
      final jsonString = await rootBundle.loadString(configPath);
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return AppConfig.fromJson(jsonMap);
    } catch (e) {
      // Fallback to default configuration if loading fails
      return const AppConfig(
        apiBaseUrl: 'http://0.0.0.0:8000',
        apiTimeoutSeconds: 120,
        useMockData: true,
        environment: 'development',
      );
    }
  }

  /// Returns a copy of this configuration with the specified fields replaced.
  AppConfig copyWith({
    String? apiBaseUrl,
    int? apiTimeoutSeconds,
    bool? useMockData,
    String? environment,
  }) {
    return AppConfig(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      apiTimeoutSeconds: apiTimeoutSeconds ?? this.apiTimeoutSeconds,
      useMockData: useMockData ?? this.useMockData,
      environment: environment ?? this.environment,
    );
  }

  /// Returns a string representation of this configuration.
  @override
  String toString() {
    return 'AppConfig(apiBaseUrl: $apiBaseUrl, apiTimeoutSeconds: $apiTimeoutSeconds, '
        'useMockData: $useMockData, environment: $environment)';
  }
}
