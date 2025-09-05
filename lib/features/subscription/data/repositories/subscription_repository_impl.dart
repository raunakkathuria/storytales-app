import 'package:storytales/features/subscription/data/datasources/subscription_local_data_source.dart';
import 'package:storytales/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:storytales/features/profile/domain/repositories/profile_repository.dart';

/// Implementation of the [SubscriptionRepository] interface.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource _localDataSource;
  final ProfileRepository _profileRepository;

  /// The number of free stories allowed in Phase 1 (fallback value).
  static const int _freeStoryLimit = 2;

  SubscriptionRepositoryImpl({
    required SubscriptionLocalDataSource localDataSource,
    required ProfileRepository profileRepository,
  })  : _localDataSource = localDataSource,
        _profileRepository = profileRepository;

  @override
  Future<bool> canCreateStory() async {
    try {
      // Get current user profile from API
      final profile = await _profileRepository.getCurrentUserProfile();
      
      // For subscribed users (non-free tier), they can always create stories
      if (profile.subscriptionTier != 'free') {
        return true;
      }
      
      // For free tier users, check stories remaining using computed property
      return profile.actualStoriesRemaining > 0;
    } catch (e) {
      // Fallback to local data if API fails
      final hasSubscription = await _localDataSource.hasActiveSubscription();
      if (hasSubscription) {
        return true;
      }

      // Check if the user has not reached the free story limit
      final generatedStoryCount = await _localDataSource.getGeneratedStoryCount();
      return generatedStoryCount < _freeStoryLimit;
    }
  }

  @override
  Future<void> incrementGeneratedStoryCount() async {
    await _localDataSource.incrementGeneratedStoryCount();
  }

  @override
  Future<bool> hasActiveSubscription() async {
    try {
      // Get current user profile from API
      final profile = await _profileRepository.getCurrentUserProfile();
      
      // Consider non-free tiers as active subscriptions
      return profile.subscriptionTier != 'free';
    } catch (e) {
      // Fallback to local data if API fails
      return await _localDataSource.hasActiveSubscription();
    }
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
    try {
      // Get current user profile from API
      final profile = await _profileRepository.getCurrentUserProfile();
      
      // Use the computed property for accurate business logic
      return profile.actualStoriesRemaining;
    } catch (e) {
      // Fallback to local calculation if API fails
      final generatedStoryCount = await _localDataSource.getGeneratedStoryCount();
      final remaining = _freeStoryLimit - generatedStoryCount;
      return remaining > 0 ? remaining : 0;
    }
  }

  @override
  Future<String?> getSubscriptionType() async {
    try {
      // Get current user profile from API
      final profile = await _profileRepository.getCurrentUserProfile();
      return profile.subscriptionTier;
    } catch (e) {
      // Fallback to local data if API fails
      return await _localDataSource.getSubscriptionType();
    }
  }

  @override
  Future<void> setSubscriptionType(String type) async {
    await _localDataSource.setSubscriptionType(type);
  }
}
