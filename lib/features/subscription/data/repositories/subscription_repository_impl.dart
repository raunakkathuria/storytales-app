import 'package:storytales/features/subscription/data/datasources/subscription_local_data_source.dart';
import 'package:storytales/features/subscription/domain/repositories/subscription_repository.dart';

/// Implementation of the [SubscriptionRepository] interface.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource _localDataSource;

  /// The number of free stories allowed in Phase 1.
  static const int _freeStoryLimit = 2;

  SubscriptionRepositoryImpl({required SubscriptionLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<bool> canCreateStory() async {
    // Check if the user has an active subscription
    final hasSubscription = await _localDataSource.hasActiveSubscription();
    if (hasSubscription) {
      return true;
    }

    // Check if the user has not reached the free story limit
    final generatedStoryCount = await _localDataSource.getGeneratedStoryCount();
    return generatedStoryCount < _freeStoryLimit;
  }

  @override
  Future<void> incrementGeneratedStoryCount() async {
    await _localDataSource.incrementGeneratedStoryCount();
  }

  @override
  Future<bool> hasActiveSubscription() async {
    return await _localDataSource.hasActiveSubscription();
  }

  @override
  Future<void> setSubscriptionStatus(bool isActive) async {
    await _localDataSource.setSubscriptionStatus(isActive);
  }

  @override
  Future<int> getGeneratedStoryCount() async {
    return await _localDataSource.getGeneratedStoryCount();
  }

  @override
  int getFreeStoryLimit() {
    return _freeStoryLimit;
  }

  @override
  Future<int> getFreeStoriesRemaining() async {
    final generatedStoryCount = await _localDataSource.getGeneratedStoryCount();
    final remaining = _freeStoryLimit - generatedStoryCount;
    return remaining > 0 ? remaining : 0;
  }

  @override
  Future<String?> getSubscriptionType() async {
    return await _localDataSource.getSubscriptionType();
  }

  @override
  Future<void> setSubscriptionType(String type) async {
    await _localDataSource.setSubscriptionType(type);
  }
}
