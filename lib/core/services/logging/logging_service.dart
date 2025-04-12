import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// A service for centralized logging throughout the app.
///
/// This service wraps the logging package to provide a consistent
/// interface for logging across the application. It configures the
/// logger differently based on whether the app is running in
/// debug or release mode.
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  static bool _initialized = false;

  /// Factory constructor to return the same instance every time
  factory LoggingService() => _instance;

  /// Private constructor for singleton pattern
  LoggingService._internal();

  /// Initialize the logging service
  void init() {
    if (_initialized) return;

    // Configure the logger
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        // In debug mode, use debugPrint for console output with more details
        debugPrint('${record.time}: ${record.level.name}: ${record.loggerName}: ${record.message}');
        if (record.error != null) {
          debugPrint('Error: ${record.error}');
        }
        if (record.stackTrace != null) {
          debugPrint('Stack trace: ${record.stackTrace}');
        }
      } else {
        // In release mode, use dart:developer log for warnings and errors
        // This is more appropriate for production and can be integrated with crash reporting tools
        if (record.level >= Level.WARNING) {
          developer.log(
            record.message,
            time: record.time,
            name: record.loggerName,
            level: record.level.value,
            error: record.error,
            stackTrace: record.stackTrace,
          );
        }
      }
    });

    _initialized = true;
  }

  /// Get a logger for a specific class or component
  Logger getLogger(String name) {
    if (!_initialized) {
      init();
    }
    return Logger(name);
  }

  /// Log a debug message
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    final logger = getLogger('App');
    logger.fine(message, error, stackTrace);
  }

  /// Log an info message
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    final logger = getLogger('App');
    logger.info(message, error, stackTrace);
  }

  /// Log a warning message
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    final logger = getLogger('App');
    logger.warning(message, error, stackTrace);
  }

  /// Log an error message
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    final logger = getLogger('App');
    logger.severe(message, error, stackTrace);
  }
}
