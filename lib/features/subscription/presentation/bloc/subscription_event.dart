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

/// Event to purchase a subscription using native in-app purchase.
class PurchaseSubscription extends SubscriptionEvent {
  final String platform; // 'ios' or 'android'
  final String productId; // 'com.storytales.monthly' or 'com.storytales.annual'
  final String receiptData; // Base64 receipt from platform
  final String transactionId; // Platform transaction ID

  const PurchaseSubscription({
    required this.platform,
    required this.productId, 
    required this.receiptData,
    required this.transactionId,
  });

  @override
  List<Object?> get props => [platform, productId, receiptData, transactionId];
}

/// Event to restore a subscription from previous purchases.
class RestoreSubscription extends SubscriptionEvent {
  final String platform; // 'ios' or 'android'
  final String? receiptData; // Optional receipt data (mainly for Android)

  const RestoreSubscription({
    required this.platform,
    this.receiptData,
  });

  @override
  List<Object?> get props => [platform, receiptData];
}

/// Event to get the number of free stories remaining.
class GetFreeStoriesRemaining extends SubscriptionEvent {
  const GetFreeStoriesRemaining();
}


/// Event to refresh the free stories count.
/// This is used to ensure the subscription page shows the correct count
/// after library changes (like deleting a story).
class RefreshFreeStoriesCount extends SubscriptionEvent {
  const RefreshFreeStoriesCount();
}
