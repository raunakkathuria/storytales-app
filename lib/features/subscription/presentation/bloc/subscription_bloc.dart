import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/services/analytics/analytics_service.dart';
import 'package:storytales/core/services/auth/authentication_service.dart';
import 'package:storytales/core/utils/iap_debug_helper.dart';
import 'package:storytales/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_state.dart';

/// BLoC for managing subscriptions.
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;
  final AnalyticsService _analyticsService;
  final AuthenticationService _authService;

  SubscriptionBloc({
    required SubscriptionRepository repository,
    required AnalyticsService analyticsService,
    required AuthenticationService authenticationService,
  })  : _repository = repository,
        _analyticsService = analyticsService,
        _authService = authenticationService,
        super(const SubscriptionInitial()) {
    on<CheckSubscription>(_onCheckSubscription);
    on<IncrementStoryCount>(_onIncrementStoryCount);
    on<PurchaseSubscription>(_onPurchaseSubscription);
    on<RestoreSubscription>(_onRestoreSubscription);
    on<GetFreeStoriesRemaining>(_onGetFreeStoriesRemaining);
    on<RefreshFreeStoriesCount>(_onRefreshFreeStoriesCount);
  }

  /// Handle the CheckSubscription event.
  Future<void> _onCheckSubscription(
    CheckSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionChecking());

    try {
      // Get subscription status from API via authentication service
      final subscriptionStatus = await _authService.getSubscriptionStatus();
      
      final subscriptionTier = subscriptionStatus['subscription_tier'] ?? 'free';
      final isActive = subscriptionStatus['is_active'] ?? false;
      final unlimitedStories = subscriptionStatus['unlimited_stories'] ?? false;

      // Debug logging for subscription check
      IAPDebugHelper.logSubscriptionCheck(
        userId: subscriptionStatus['user_id']?.toString() ?? 'unknown',
        subscriptionTier: subscriptionTier,
        isActive: isActive,
        unlimitedStories: unlimitedStories,
      );

      if (isActive && unlimitedStories) {
        // User has active subscription with unlimited stories
        emit(SubscriptionActive(subscriptionType: subscriptionTier));
      } else {
        // User is on free tier - check story limits using API data
        final freeStoriesRemaining = await _repository.getFreeStoriesRemaining();
        final freeStoryLimit = await _repository.getFreeStoryLimit();
        final generatedStoryCount = await _repository.getGeneratedStoryCount();

        if (freeStoriesRemaining <= 0) {
          // User has no free stories remaining, subscription is required
          emit(SubscriptionRequired(
            generatedStoryCount: generatedStoryCount,
            freeStoryLimit: freeStoryLimit,
          ));

          // Log analytics event for subscription prompt
          await _analyticsService.logSubscriptionPromptShown();
        } else {
          // User still has free stories remaining
          emit(FreeStoriesAvailable(
            freeStoriesRemaining: freeStoriesRemaining,
            totalFreeStories: freeStoryLimit,
          ));
        }
      }
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));

      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'subscription_check_error',
        errorMessage: e.toString(),
      );
    }
  }

  /// Handle the IncrementStoryCount event.
  Future<void> _onIncrementStoryCount(
    IncrementStoryCount event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      await _repository.incrementGeneratedStoryCount();
      add(const CheckSubscription());
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));

      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'increment_story_count_error',
        errorMessage: e.toString(),
      );
    }
  }

  /// Handle the PurchaseSubscription event.
  Future<void> _onPurchaseSubscription(
    PurchaseSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    // Determine subscription type from product ID
    final subscriptionType = event.productId.contains('monthly') ? 'monthly' : 'annual';
    emit(SubscriptionPurchasing(subscriptionType: subscriptionType));

    try {
      // Debug logging for purchase attempt
      IAPDebugHelper.logTransaction(
        platform: event.platform,
        productId: event.productId,
        transactionId: event.transactionId,
        receiptData: event.receiptData,
      );

      // Call authentication service to process the native IAP purchase
      final response = await _authService.purchaseSubscription(
        platform: event.platform,
        productId: event.productId,
        receiptData: event.receiptData,
        transactionId: event.transactionId,
      );

      // Check if purchase was successful
      if (response['success'] == true) {
        final subscriptionTier = response['subscription_tier'] ?? subscriptionType;
        
        // Debug logging for successful purchase
        IAPDebugHelper.logPurchaseResult(
          success: true,
          subscriptionTier: subscriptionTier,
          transactionId: event.transactionId,
        );

        // Log analytics event for subscription purchased
        await _analyticsService.logSubscriptionPurchased(
          subscriptionType: subscriptionTier,
          subscriptionId: event.transactionId,
        );

        emit(SubscriptionPurchased(
          subscriptionType: subscriptionTier,
          subscriptionId: event.transactionId,
        ));

        // Update the subscription status
        add(const CheckSubscription());
      } else {
        // Handle API failure response
        final errorMessage = response['message'] ?? 'Purchase verification failed';
        
        // Debug logging for failed purchase
        IAPDebugHelper.logPurchaseResult(
          success: false,
          error: errorMessage,
        );

        emit(SubscriptionPurchaseFailed(error: errorMessage));
        
        await _analyticsService.logError(
          errorType: 'subscription_purchase_verification_failed',
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      // Debug logging for purchase exception
      IAPDebugHelper.logPurchaseResult(
        success: false,
        error: e.toString(),
      );

      emit(SubscriptionPurchaseFailed(error: e.toString()));

      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'subscription_purchase_error',
        errorMessage: e.toString(),
      );
    }
  }

  /// Handle the RestoreSubscription event.
  Future<void> _onRestoreSubscription(
    RestoreSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionRestoring());

    try {
      // Call authentication service to restore subscription from platform
      final response = await _authService.restoreSubscription(
        platform: event.platform,
        receiptData: event.receiptData,
      );

      final subscriptionFound = response['subscription_found'] ?? false;
      
      if (subscriptionFound) {
        // Log successful restoration as a subscription event
        final subscriptionTier = response['subscription_tier'];
        
        // Debug logging for successful restore
        IAPDebugHelper.logRestoreResult(
          subscriptionFound: true,
          subscriptionTier: subscriptionTier,
        );

        await _analyticsService.logSubscriptionPurchased(
          subscriptionType: subscriptionTier,
          subscriptionId: 'restored_subscription',
        );
      } else {
        // Debug logging for no subscription found
        IAPDebugHelper.logRestoreResult(
          subscriptionFound: false,
        );
      }

      emit(SubscriptionRestored(wasSuccessful: subscriptionFound));

      // Update the subscription status regardless of result
      add(const CheckSubscription());
    } catch (e) {
      // Debug logging for restore exception
      IAPDebugHelper.logRestoreResult(
        subscriptionFound: false,
        error: e.toString(),
      );

      emit(SubscriptionRestoreFailed(error: e.toString()));

      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'subscription_restore_error',
        errorMessage: e.toString(),
      );
    }
  }

  /// Handle the GetFreeStoriesRemaining event.
  Future<void> _onGetFreeStoriesRemaining(
    GetFreeStoriesRemaining event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final freeStoriesRemaining = await _repository.getFreeStoriesRemaining();
      final freeStoryLimit = await _repository.getFreeStoryLimit();
      final generatedStoryCount = await _repository.getGeneratedStoryCount();

      if (freeStoriesRemaining <= 0) {
        // User has no free stories remaining, subscription is required
        emit(SubscriptionRequired(
          generatedStoryCount: generatedStoryCount,
          freeStoryLimit: freeStoryLimit,
        ));

        // Log analytics event for subscription prompt
        await _analyticsService.logSubscriptionPromptShown();
      } else {
        // User still has free stories remaining
        emit(FreeStoriesAvailable(
          freeStoriesRemaining: freeStoriesRemaining,
          totalFreeStories: freeStoryLimit,
        ));
      }
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));

      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'get_free_stories_remaining_error',
        errorMessage: e.toString(),
      );
    }
  }


  /// Handle the RefreshFreeStoriesCount event.
  /// This is used to ensure the subscription page shows the correct count
  /// after library changes (like deleting a story).
  Future<void> _onRefreshFreeStoriesCount(
    RefreshFreeStoriesCount event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      // Check if the user has an active subscription
      final hasActiveSubscription = await _repository.hasActiveSubscription();

      if (hasActiveSubscription) {
        // If the user has an active subscription, no need to refresh the count
        return;
      }

      // Get the latest counts
      final freeStoriesRemaining = await _repository.getFreeStoriesRemaining();
      final freeStoryLimit = await _repository.getFreeStoryLimit();
      final generatedStoryCount = await _repository.getGeneratedStoryCount();

      if (freeStoriesRemaining <= 0) {
        // User has no free stories remaining, subscription is required
        emit(SubscriptionRequired(
          generatedStoryCount: generatedStoryCount,
          freeStoryLimit: freeStoryLimit,
        ));
      } else {
        // User still has free stories remaining
        emit(FreeStoriesAvailable(
          freeStoriesRemaining: freeStoriesRemaining,
          totalFreeStories: freeStoryLimit,
        ));
      }
    } catch (e) {
      // Just log the error, don't emit an error state to avoid disrupting the UI
      await _analyticsService.logError(
        errorType: 'refresh_free_stories_count_error',
        errorMessage: e.toString(),
      );
    }
  }
}
