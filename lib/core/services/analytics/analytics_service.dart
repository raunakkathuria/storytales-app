import 'package:firebase_analytics/firebase_analytics.dart';

/// Service for tracking analytics events in the app.
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({required FirebaseAnalytics analytics})
      : _analytics = analytics;

  /// Log when a story is generated.
  Future<void> logStoryGenerated({
    required String storyId,
    required String storyTitle,
    String? ageRange,
    String? genre,
    String? theme,
  }) async {
    await _analytics.logEvent(
      name: 'story_generated',
      parameters: {
        'story_id': storyId,
        'title': storyTitle,
        if (ageRange != null) 'age_range': ageRange,
        if (genre != null) 'genre': genre,
        if (theme != null) 'theme': theme,
      },
    );
  }

  /// Log when a story is viewed.
  Future<void> logStoryViewed({
    required String storyId,
    required String storyTitle,
    bool? isPregenerated,
  }) async {
    await _analytics.logEvent(
      name: 'story_viewed',
      parameters: {
        'story_id': storyId,
        'title': storyTitle,
        if (isPregenerated != null) 'is_pregenerated': isPregenerated.toString(),
      },
    );
  }

  /// Log when a story is marked as favorite.
  Future<void> logStoryFavorited({
    required String storyId,
    required String storyTitle,
  }) async {
    await _analytics.logEvent(
      name: 'story_favorited',
      parameters: {
        'story_id': storyId,
        'title': storyTitle,
      },
    );
  }

  /// Log when a story is removed from favorites.
  Future<void> logStoryUnfavorited({
    required String storyId,
    required String storyTitle,
  }) async {
    await _analytics.logEvent(
      name: 'story_unfavorited',
      parameters: {
        'story_id': storyId,
        'title': storyTitle,
      },
    );
  }

  /// Log when a story is deleted.
  Future<void> logStoryDeleted({
    required String storyId,
    required String storyTitle,
  }) async {
    await _analytics.logEvent(
      name: 'story_deleted',
      parameters: {
        'story_id': storyId,
        'title': storyTitle,
      },
    );
  }

  /// Log when the subscription prompt is shown.
  Future<void> logSubscriptionPromptShown() async {
    await _analytics.logEvent(name: 'subscription_prompt_shown');
  }

  /// Log when a subscription is purchased.
  Future<void> logSubscriptionPurchased({
    required String subscriptionType,
    required String subscriptionId,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_purchased',
      parameters: {
        'subscription_type': subscriptionType,
        'subscription_id': subscriptionId,
      },
    );
  }

  /// Log when a subscription purchase is canceled.
  Future<void> logSubscriptionCanceled({
    required String subscriptionType,
    required String subscriptionId,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_canceled',
      parameters: {
        'subscription_type': subscriptionType,
        'subscription_id': subscriptionId,
      },
    );
  }

  /// Log when an error occurs.
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? errorDetails,
  }) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        if (errorDetails != null) 'error_details': errorDetails,
      },
    );
  }

  /// Log when a screen is viewed.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Log when the app is opened.
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  /// Log a custom event with parameters.
  Future<void> logEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
}
