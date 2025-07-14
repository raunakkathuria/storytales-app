import 'package:storytales/core/services/analytics/analytics_service.dart';
import 'package:storytales/core/services/logging/logging_service.dart';

/// A mock implementation of AnalyticsService for development purposes.
class MockAnalyticsService implements AnalyticsService {
  final LoggingService _logger;
  final String _loggerName = 'MockAnalytics';

  /// Constructor that takes a LoggingService instance
  MockAnalyticsService({required LoggingService logger}) : _logger = logger;
  @override
  Future<void> logStoryGenerated({
    required String storyId,
    required String storyTitle,
    String? ageRange,
    String? genre,
    String? theme,
  }) async {
    _logger.info('$_loggerName: logStoryGenerated(storyId: $storyId, storyTitle: $storyTitle, ageRange: $ageRange, genre: $genre, theme: $theme)');
    return;
  }

  @override
  Future<void> logStoryViewed({
    required String storyId,
    required String storyTitle,
    bool? isPregenerated,
  }) async {
    _logger.info('$_loggerName: logStoryViewed(storyId: $storyId, storyTitle: $storyTitle, isPregenerated: $isPregenerated)');
    return;
  }

  @override
  Future<void> logStoryFavorited({
    required String storyId,
    required String storyTitle,
  }) async {
    _logger.info('$_loggerName: logStoryFavorited(storyId: $storyId, storyTitle: $storyTitle)');
    return;
  }

  @override
  Future<void> logStoryUnfavorited({
    required String storyId,
    required String storyTitle,
  }) async {
    _logger.info('$_loggerName: logStoryUnfavorited(storyId: $storyId, storyTitle: $storyTitle)');
    return;
  }

  @override
  Future<void> logStoryDeleted({
    required String storyId,
    required String storyTitle,
  }) async {
    _logger.info('$_loggerName: logStoryDeleted(storyId: $storyId, storyTitle: $storyTitle)');
    return;
  }

  @override
  Future<void> logSubscriptionPromptShown() async {
    _logger.info('$_loggerName: logSubscriptionPromptShown()');
    return;
  }

  @override
  Future<void> logSubscriptionPurchased({
    required String subscriptionType,
    required String subscriptionId,
  }) async {
    _logger.info('$_loggerName: logSubscriptionPurchased(subscriptionType: $subscriptionType, subscriptionId: $subscriptionId)');
    return;
  }

  @override
  Future<void> logSubscriptionCanceled({
    required String subscriptionType,
    required String subscriptionId,
  }) async {
    _logger.info('$_loggerName: logSubscriptionCanceled(subscriptionType: $subscriptionType, subscriptionId: $subscriptionId)');
    return;
  }

  @override
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? errorDetails,
  }) async {
    _logger.error('$_loggerName: logError(errorType: $errorType, errorMessage: $errorMessage, errorDetails: $errorDetails)');
    return;
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    _logger.info('$_loggerName: logScreenView(screenName: $screenName, screenClass: $screenClass)');
    return;
  }

  @override
  Future<void> logAppOpen() async {
    _logger.info('$_loggerName: logAppOpen()');
    return;
  }
}
