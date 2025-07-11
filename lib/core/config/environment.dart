/// Environment configuration for the application.
///
/// This file contains constants for different environments and a utility
/// to determine the current environment.
class Environment {
  /// Production environment.
  static const String production = 'production';

  /// Staging environment.
  static const String staging = 'staging';

  /// Development environment.
  static const String development = 'development';

  /// The current environment.
  ///
  /// This should be set to the appropriate environment before building the app.
  /// For example, in a CI/CD pipeline, this would be set to 'production' for
  /// production builds.
  static const String currentEnvironment = production;

  /// Returns true if the current environment is production.
  static bool get isProduction => currentEnvironment == production;

  /// Returns true if the current environment is staging.
  static bool get isStaging => currentEnvironment == staging;

  /// Returns true if the current environment is development.
  static bool get isDevelopment => currentEnvironment == development;
}
