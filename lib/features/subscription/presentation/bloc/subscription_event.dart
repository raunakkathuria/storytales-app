import 'package:equatable/equatable.dart';

/// Events for the SubscriptionBloc.
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check the subscription status.
class CheckSubscription extends SubscriptionEvent {
  const CheckSubscription();
}

/// Event to increment the generated story count.
class IncrementStoryCount extends SubscriptionEvent {
  const IncrementStoryCount();
}

/// Event to purchase a subscription.
class PurchaseSubscription extends SubscriptionEvent {
  final String subscriptionType;
  final String subscriptionId;

  const PurchaseSubscription({
    required this.subscriptionType,
    required this.subscriptionId,
  });

  @override
  List<Object?> get props => [subscriptionType, subscriptionId];
}

/// Event to restore a subscription.
class RestoreSubscription extends SubscriptionEvent {
  const RestoreSubscription();
}

/// Event to get the number of free stories remaining.
class GetFreeStoriesRemaining extends SubscriptionEvent {
  const GetFreeStoriesRemaining();
}

/// Event to simulate a subscription purchase (for development).
class SimulatePurchase extends SubscriptionEvent {
  const SimulatePurchase();
}

/// Event to reset the subscription status (for development).
class ResetSubscription extends SubscriptionEvent {
  const ResetSubscription();
}

/// Event to refresh the free stories count.
/// This is used to ensure the subscription page shows the correct count
/// after library changes (like deleting a story).
class RefreshFreeStoriesCount extends SubscriptionEvent {
  const RefreshFreeStoriesCount();
}
