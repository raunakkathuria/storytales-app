import 'package:equatable/equatable.dart';

/// Represents a user profile in the domain layer.
class UserProfile extends Equatable {
  /// Unique identifier for the user.
  final int userId;

  /// User's display name.
  final String? displayName;

  /// User's email address (null if not registered).
  final String? email;

  /// Whether the user's email has been verified.
  final bool emailVerified;

  /// Whether this is an anonymous user.
  final bool isAnonymous;

  /// User's subscription tier.
  final String subscriptionTier;

  /// Number of free stories remaining.
  final int storiesRemaining;

  /// Device ID associated with this user.
  final String deviceId;

  /// Creates a user profile entity.
  const UserProfile({
    required this.userId,
    this.displayName,
    this.email,
    required this.emailVerified,
    required this.isAnonymous,
    required this.subscriptionTier,
    required this.storiesRemaining,
    required this.deviceId,
  });

  /// Creates a copy of this user profile with updated fields.
  UserProfile copyWith({
    int? userId,
    String? displayName,
    String? email,
    bool? emailVerified,
    bool? isAnonymous,
    String? subscriptionTier,
    int? storiesRemaining,
    String? deviceId,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      storiesRemaining: storiesRemaining ?? this.storiesRemaining,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  /// Returns true if the user has a registered account.
  bool get hasRegisteredAccount => !isAnonymous && email != null;

  /// Returns true if the user can register (is anonymous).
  bool get canRegister => isAnonymous;

  /// Returns true if the user needs to login (anonymous but potentially has existing account).
  bool get canLogin => isAnonymous;

  @override
  List<Object?> get props => [
        userId,
        displayName,
        email,
        emailVerified,
        isAnonymous,
        subscriptionTier,
        storiesRemaining,
        deviceId,
      ];
}