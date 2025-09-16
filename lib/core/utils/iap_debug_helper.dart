import 'package:get_it/get_it.dart';
import 'package:storytales/core/config/app_config.dart';
import 'package:storytales/core/services/logging/logging_service.dart';

/// Debug helper for in-app purchase development and testing.
class IAPDebugHelper {
  static final _loggingService = GetIt.instance<LoggingService>();

  /// Log IAP debug information if debug logging is enabled.
  static void logDebug(String message, {Map<String, dynamic>? data}) {
    final appConfig = GetIt.instance<AppConfig>();
    
    if (appConfig.iapDebugLogging) {
      final dataString = data != null ? ' | Data: $data' : '';
      _loggingService.info('IAP_DEBUG: $message$dataString');
    }
  }

  /// Log IAP transaction details for debugging.
  static void logTransaction({
    required String platform,
    required String productId,
    required String transactionId,
    String? receiptData,
  }) {
    logDebug('IAP Transaction', data: {
      'platform': platform,
      'productId': productId,
      'transactionId': transactionId,
      'hasReceiptData': receiptData != null,
      'receiptLength': receiptData?.length ?? 0,
    });
  }

  /// Log subscription status check for debugging.
  static void logSubscriptionCheck({
    required String userId,
    required String subscriptionTier,
    required bool isActive,
    required bool unlimitedStories,
  }) {
    logDebug('Subscription Status Check', data: {
      'userId': userId,
      'subscriptionTier': subscriptionTier,
      'isActive': isActive,
      'unlimitedStories': unlimitedStories,
    });
  }

  /// Log purchase result for debugging.
  static void logPurchaseResult({
    required bool success,
    String? error,
    String? subscriptionTier,
    String? transactionId,
  }) {
    logDebug('Purchase Result', data: {
      'success': success,
      'error': error,
      'subscriptionTier': subscriptionTier,
      'transactionId': transactionId,
    });
  }

  /// Log restore subscription result for debugging.
  static void logRestoreResult({
    required bool subscriptionFound,
    String? subscriptionTier,
    String? error,
  }) {
    logDebug('Restore Result', data: {
      'subscriptionFound': subscriptionFound,
      'subscriptionTier': subscriptionTier,
      'error': error,
    });
  }

  /// Get current IAP configuration summary.
  static Map<String, dynamic> getConfigSummary() {
    final appConfig = GetIt.instance<AppConfig>();
    
    return {
      'iapUseSandbox': appConfig.iapUseSandbox,
      'iapDebugLogging': appConfig.iapDebugLogging,
      'iapProductIds': appConfig.iapProductIds,
      'environment': appConfig.environment,
    };
  }

  /// Print configuration summary to console (for development only).
  static void printConfigSummary() {
    final config = getConfigSummary();
    logDebug('IAP Configuration Summary', data: config);
  }
}