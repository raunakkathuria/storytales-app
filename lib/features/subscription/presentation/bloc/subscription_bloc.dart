import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/services/analytics/analytics_service.dart';
import 'package:storytales/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_state.dart';

/// BLoC for managing subscriptions.
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;
  final AnalyticsService _analyticsService;

  SubscriptionBloc({
    required SubscriptionRepository repository,
    required AnalyticsService analyticsService,
  })  : _repository = repository,
        _analyticsService = analyticsService,
        super(const SubscriptionInitial()) {
    on<CheckSubscription>(_onCheckSubscription);
    on<IncrementStoryCount>(_onIncrementStoryCount);
    on<PurchaseSubscription>(_onPurchaseSubscription);
    on<RestoreSubscription>(_onRestoreSubscription);
    on<GetFreeStoriesRemaining>(_onGetFreeStoriesRemaining);
    on<SimulatePurchase>(_onSimulatePurchase);
    on<ResetSubscription>(_onResetSubscription);
    on<RefreshFreeStoriesCount>(_onRefreshFreeStoriesCount);
  }

  /// Handle the CheckSubscription event.
  Future<void> _onCheckSubscription(
    CheckSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionChecking());

    try {
      final hasActiveSubscription = await _repository.hasActiveSubscription();

      if (hasActiveSubscription) {
        // Get the subscription type
        final subscriptionType = await _repository.getSubscriptionType();
        emit(SubscriptionActive(subscriptionType: subscriptionType ?? 'monthly'));
      } else {
        final freeStoriesRemaining = await _repository.getFreeStoriesRemaining();
        final freeStoryLimit = _repository.getFreeStoryLimit();
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
    emit(SubscriptionPurchasing(subscriptionType: event.subscriptionType));

    try {
      // In a real implementation, this would call the in-app purchase API
      // For Phase 1, we'll just set the subscription status to active
      await _repository.setSubscriptionStatus(true);

      // Store the subscription type
      await _repository.setSubscriptionType(event.subscriptionType);

      // Log analytics event for subscription purchased
      await _analyticsService.logSubscriptionPurchased(
        subscriptionType: event.subscriptionType,
        subscriptionId: event.subscriptionId,
      );

      emit(SubscriptionPurchased(
        subscriptionType: event.subscriptionType,
        subscriptionId: event.subscriptionId,
      ));

      // Update the subscription status
      add(const CheckSubscription());
    } catch (e) {
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
      // In a real implementation, this would call the in-app purchase API
      // For Phase 1, we'll just check if the user has an active subscription
      final hasActiveSubscription = await _repository.hasActiveSubscription();

      emit(SubscriptionRestored(wasSuccessful: hasActiveSubscription));

      // Update the subscription status
      add(const CheckSubscription());
    } catch (e) {
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
      final freeStoryLimit = _repository.getFreeStoryLimit();
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

  /// Handle the SimulatePurchase event (for development).
  Future<void> _onSimulatePurchase(
    SimulatePurchase event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionPurchasing(subscriptionType: 'monthly'));

    try {
      // Simulate a delay
      await Future.delayed(const Duration(seconds: 1));

      // Set the subscription status to active
      await _repository.setSubscriptionStatus(true);

      // Store the subscription type
      await _repository.setSubscriptionType('monthly');

      // Log analytics event for subscription purchased
      await _analyticsService.logSubscriptionPurchased(
        subscriptionType: 'monthly',
        subscriptionId: 'simulated_purchase',
      );

      emit(const SubscriptionPurchased(
        subscriptionType: 'monthly',
        subscriptionId: 'simulated_purchase',
      ));

      // Update the subscription status
      add(const CheckSubscription());
    } catch (e) {
      emit(SubscriptionPurchaseFailed(error: e.toString()));

      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'simulate_purchase_error',
        errorMessage: e.toString(),
      );
    }
  }

  /// Handle the ResetSubscription event (for development).
  Future<void> _onResetSubscription(
    ResetSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      // Set the subscription status to inactive
      await _repository.setSubscriptionStatus(false);

      // Update the subscription status
      add(const CheckSubscription());
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));

      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'reset_subscription_error',
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
      final freeStoryLimit = _repository.getFreeStoryLimit();
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
