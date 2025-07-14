/// Repository interface for managing subscriptions.
abstract class SubscriptionRepository {
  /// Check if the user can create a new story.
  /// Returns true if the user has an active subscription or has not reached the free story limit.
  Future<bool> canCreateStory();

  /// Increment the number of stories the user has generated.
  Future<void> incrementGeneratedStoryCount();

  /// Check if the user has an active subscription.
  Future<bool> hasActiveSubscription();

  /// Set the user's subscription status.
  Future<void> setSubscriptionStatus(bool isActive);

  /// Get the number of stories the user has generated.
  Future<int> getGeneratedStoryCount();

  /// Get the number of free stories allowed.
  int getFreeStoryLimit();

  /// Get the number of free stories remaining.
  Future<int> getFreeStoriesRemaining();

  /// Get the user's subscription type.
  Future<String?> getSubscriptionType();

  /// Set the user's subscription type.
  Future<void> setSubscriptionType(String type);
}
