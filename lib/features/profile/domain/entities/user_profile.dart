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

  /// Number of stories used in current month.
  final int monthlyStoryCount;

  /// Maximum stories allowed per month for current tier.
  final int maxMonthlyStories;

  /// Device ID associated with this user.
  final String deviceId;

  /// Current session ID for authenticated users (null if signed out).
  final String? sessionId;

  /// When current session was created (null if signed out).
  final DateTime? sessionCreatedAt;

  /// Whether user has valid session data and is currently authenticated.
  final bool? isAuthenticated;

  /// Creates a user profile entity.
  const UserProfile({
    required this.userId,
    this.displayName,
    this.email,
    required this.emailVerified,
    required this.isAnonymous,
    required this.subscriptionTier,
    required this.storiesRemaining,
    this.monthlyStoryCount = 0,
    this.maxMonthlyStories = 0,
    required this.deviceId,
    this.sessionId,
    this.sessionCreatedAt,
    this.isAuthenticated,
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
    int? monthlyStoryCount,
    int? maxMonthlyStories,
    String? deviceId,
    String? sessionId,
    DateTime? sessionCreatedAt,
    bool? isAuthenticated,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      storiesRemaining: storiesRemaining ?? this.storiesRemaining,
      monthlyStoryCount: monthlyStoryCount ?? this.monthlyStoryCount,
      maxMonthlyStories: maxMonthlyStories ?? this.maxMonthlyStories,
      deviceId: deviceId ?? this.deviceId,
      sessionId: sessionId ?? this.sessionId,
      sessionCreatedAt: sessionCreatedAt ?? this.sessionCreatedAt,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  /// Returns true if the user has a registered account (handles both API patterns).
  /// 
  /// Current API: is_anonymous stays true until verification complete
  /// Future API: is_anonymous becomes false after registration
  bool get hasRegisteredAccount {
    // User has registered if they have email and display name, regardless of anonymous status
    final hasRegistrationData = email != null && displayName != null;
    
    // For future API compatibility: check if not anonymous AND has email
    final isVerifiedInFutureAPI = !isAnonymous && email != null;
    
    return hasRegistrationData || isVerifiedInFutureAPI;
  }

  /// Returns true if the user can register (truly anonymous with no registration started).
  bool get canRegister {
    // Can register if no email or display name has been set
    return email == null && displayName == null;
  }

  /// Returns true if the user needs to login (has account but needs to authenticate).
  bool get canLogin {
    // Can login if they have registration data but aren't fully verified
    return hasRegisteredAccount && !emailVerified;
  }

  /// Returns true if the user has registered but needs email verification.
  /// This method abstracts the API pattern differences and provides consistent behavior.
  bool get needsEmailVerification {
    // User needs verification if they have registered but email is not verified
    return hasRegisteredAccount && !emailVerified;
  }

  /// Returns true if the user is fully verified and authenticated.
  bool get isFullyVerified {
    return hasRegisteredAccount && emailVerified;
  }

  /// Returns true if the user is signed out (has no valid session).
  bool get isSignedOut {
    // Use new isAuthenticated field from API if available, fallback to sessionId check
    if (isAuthenticated != null) {
      return !isAuthenticated!;
    }
    // Fallback for compatibility until API is fully updated
    return sessionId == null;
  }

  @override
  List<Object?> get props => [
        userId,
        displayName,
        email,
        emailVerified,
        isAnonymous,
        subscriptionTier,
        storiesRemaining,
        monthlyStoryCount,
        maxMonthlyStories,
        deviceId,
        sessionId,
        sessionCreatedAt,
        isAuthenticated,
      ];
}