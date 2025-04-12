import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for subscription-related data.
class SubscriptionLocalDataSource {
  static const String _generatedStoryCountKey = 'generated_story_count';
  static const String _hasActiveSubscriptionKey = 'has_active_subscription';
  static const String _subscriptionTypeKey = 'subscription_type';

  final SharedPreferences _sharedPreferences;

  SubscriptionLocalDataSource({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  /// Get the number of stories the user has generated.
  Future<int> getGeneratedStoryCount() async {
    return _sharedPreferences.getInt(_generatedStoryCountKey) ?? 0;
  }

  /// Increment the number of stories the user has generated.
  Future<void> incrementGeneratedStoryCount() async {
    final currentCount = await getGeneratedStoryCount();
    await _sharedPreferences.setInt(_generatedStoryCountKey, currentCount + 1);
  }

  /// Reset the number of stories the user has generated.
  Future<void> resetGeneratedStoryCount() async {
    await _sharedPreferences.setInt(_generatedStoryCountKey, 0);
  }

  /// Check if the user has an active subscription.
  Future<bool> hasActiveSubscription() async {
    return _sharedPreferences.getBool(_hasActiveSubscriptionKey) ?? false;
  }

  /// Set the user's subscription status.
  Future<void> setSubscriptionStatus(bool isActive) async {
    await _sharedPreferences.setBool(_hasActiveSubscriptionKey, isActive);
  }

  /// Get the user's subscription type.
  Future<String?> getSubscriptionType() async {
    return _sharedPreferences.getString(_subscriptionTypeKey);
  }

  /// Set the user's subscription type.
  Future<void> setSubscriptionType(String type) async {
    await _sharedPreferences.setString(_subscriptionTypeKey, type);
  }
}
