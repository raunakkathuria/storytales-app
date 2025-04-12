import 'package:equatable/equatable.dart';

/// States for the SubscriptionBloc.
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the SubscriptionBloc.
class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

/// State when checking the subscription status.
class SubscriptionChecking extends SubscriptionState {
  const SubscriptionChecking();
}

/// State when the user has free stories available.
class FreeStoriesAvailable extends SubscriptionState {
  final int freeStoriesRemaining;
  final int totalFreeStories;

  const FreeStoriesAvailable({
    required this.freeStoriesRemaining,
    required this.totalFreeStories,
  });

  @override
  List<Object?> get props => [freeStoriesRemaining, totalFreeStories];
}

/// State when the user has reached the free story limit and needs to subscribe.
class SubscriptionRequired extends SubscriptionState {
  final int generatedStoryCount;
  final int freeStoryLimit;

  const SubscriptionRequired({
    required this.generatedStoryCount,
    required this.freeStoryLimit,
  });

  @override
  List<Object?> get props => [generatedStoryCount, freeStoryLimit];
}

/// State when the user has an active subscription.
class SubscriptionActive extends SubscriptionState {
  final String subscriptionType;

  const SubscriptionActive({this.subscriptionType = 'monthly'});

  @override
  List<Object?> get props => [subscriptionType];
}

/// State when a subscription purchase is in progress.
class SubscriptionPurchasing extends SubscriptionState {
  final String subscriptionType;

  const SubscriptionPurchasing({required this.subscriptionType});

  @override
  List<Object?> get props => [subscriptionType];
}

/// State when a subscription purchase has been completed.
class SubscriptionPurchased extends SubscriptionState {
  final String subscriptionType;
  final String subscriptionId;

  const SubscriptionPurchased({
    required this.subscriptionType,
    required this.subscriptionId,
  });

  @override
  List<Object?> get props => [subscriptionType, subscriptionId];
}

/// State when a subscription purchase has failed.
class SubscriptionPurchaseFailed extends SubscriptionState {
  final String error;

  const SubscriptionPurchaseFailed({required this.error});

  @override
  List<Object?> get props => [error];
}

/// State when a subscription restoration is in progress.
class SubscriptionRestoring extends SubscriptionState {
  const SubscriptionRestoring();
}

/// State when a subscription restoration has been completed.
class SubscriptionRestored extends SubscriptionState {
  final bool wasSuccessful;

  const SubscriptionRestored({required this.wasSuccessful});

  @override
  List<Object?> get props => [wasSuccessful];
}

/// State when a subscription restoration has failed.
class SubscriptionRestoreFailed extends SubscriptionState {
  final String error;

  const SubscriptionRestoreFailed({required this.error});

  @override
  List<Object?> get props => [error];
}

/// State when there is an error with the subscription.
class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}
