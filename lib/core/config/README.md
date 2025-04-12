# Environment Configuration System

This directory contains the configuration system for the StoryTales app. It allows for different configurations based on the environment (development, staging, production).

## Files

- `app_config.dart`: The main configuration class that holds environment-specific settings.
- `environment.dart`: Contains environment constants and the current environment setting.

## Configuration Files

The actual configuration values are stored in JSON files in the `assets/config/` directory:

- `app_config.json`: Production configuration
- `app_config_dev.json`: Development configuration
- `app_config_staging.json`: Staging configuration

## How to Use

### Changing the Current Environment

To change the environment, modify the `currentEnvironment` constant in `environment.dart`:

```dart
/// The current environment.
static const String currentEnvironment = development; // Change to production, staging, or development
```

### Accessing Configuration Values

Inject the `AppConfig` instance where needed:

```dart
final AppConfig appConfig;

MyClass({
  required this.appConfig,
});

void myMethod() {
  // Use the API base URL from the configuration
  final apiUrl = '${appConfig.apiBaseUrl}/endpoint';

  // Check if mock data should be used
  if (appConfig.useMockData) {
    // Use mock data
  } else {
    // Use real data
  }
}
```

### Adding New Configuration Values

1. Add the new property to the `AppConfig` class in `app_config.dart`:

```dart
class AppConfig {
  final String apiBaseUrl;
  final int apiTimeoutSeconds;
  final bool useMockData;
  final String environment;
  final String newProperty; // Add your new property here

  const AppConfig({
    required this.apiBaseUrl,
    required this.apiTimeoutSeconds,
    required this.useMockData,
    required this.environment,
    required this.newProperty, // Add it to the constructor
  });

  // Update fromJson method
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      apiBaseUrl: json['apiBaseUrl'] as String,
      apiTimeoutSeconds: json['apiTimeoutSeconds'] as int,
      useMockData: json['useMockData'] as bool,
      environment: json['environment'] as String,
      newProperty: json['newProperty'] as String, // Add it to the fromJson method
    );
  }

  // Update copyWith method
  AppConfig copyWith({
    String? apiBaseUrl,
    int? apiTimeoutSeconds,
    bool? useMockData,
    String? environment,
    String? newProperty, // Add it to the copyWith method
  }) {
    return AppConfig(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      apiTimeoutSeconds: apiTimeoutSeconds ?? this.apiTimeoutSeconds,
      useMockData: useMockData ?? this.useMockData,
      environment: environment ?? this.environment,
      newProperty: newProperty ?? this.newProperty, // Add it to the copyWith method
    );
  }
}
```

2. Add the new property to each configuration file:

```json
{
  "apiBaseUrl": "https://api.storytales.app",
  "apiTimeoutSeconds": 120,
  "useMockData": false,
  "environment": "production",
  "newProperty": "value"
}
```

## Deployment

When deploying the app, make sure to:

1. Set the `currentEnvironment` in `environment.dart` to the appropriate value.
2. Update the configuration files with the correct values for each environment.
3. Include the configuration files in the assets section of `pubspec.yaml`.

## Best Practices

1. Never hardcode environment-specific values in the code. Always use the configuration system.
2. Keep sensitive information (like API keys) out of the configuration files. Use secure storage or environment variables for those.
3. Log the current environment and configuration at startup to help with debugging.
4. Add new configuration values to all environment files to avoid missing values in some environments.
