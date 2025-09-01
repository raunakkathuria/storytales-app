import '../../domain/entities/user_profile.dart';

/// Data model for user profile that handles API serialization.
class UserProfileModel extends UserProfile {
  /// Creates a user profile model.
  const UserProfileModel({
    required super.userId,
    super.displayName,
    super.email,
    required super.emailVerified,
    required super.isAnonymous,
    required super.subscriptionTier,
    required super.storiesRemaining,
    required super.deviceId,
    super.sessionId,
    super.sessionCreatedAt,
    super.isAuthenticated,
  });

  /// Creates a user profile model from JSON.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: _parseIntRequired(json['id']),
      displayName: _parseStringSafely(json['display_name']),
      email: _parseStringSafely(json['email']),
      emailVerified: _parseBoolSafely(json['email_verified']) ?? false,
      isAnonymous: _parseBoolSafely(json['is_anonymous']) ?? true,
      subscriptionTier: _parseStringSafely(json['subscription_tier']) ?? 'free',
      storiesRemaining: _parseIntSafely(json['max_monthly_stories']) ?? 0,
      deviceId: _parseStringSafely(json['device_id']) ?? '',
      sessionId: _parseStringSafely(json['session_id']),
      sessionCreatedAt: _parseDateTimeSafely(json['session_created_at']),
      isAuthenticated: _parseBoolSafely(json['is_authenticated']),
    );
  }

  /// Safely parses a required integer from various input types.
  static int _parseIntRequired(dynamic value) {
    if (value == null) {
      throw Exception('🌟 Oh no! Our Story Wizard had trouble finding your profile. Let\'s try to set things up again!');
    }
    if (value is int) {
      return value;
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    throw Exception('🧙‍♂️ It looks like some of your account magic got mixed up. Don\'t worry, we can fix this!');
  }

  /// Safely parses an integer from various input types, allowing null.
  static int? _parseIntSafely(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// Safely parses a string from various input types.
  static String? _parseStringSafely(dynamic value) {
    if (value == null || value == 'null') {
      return null;
    }
    return value.toString();
  }

  /// Safely parses a boolean from various input types.
  static bool? _parseBoolSafely(dynamic value) {
    if (value == null || value == 'null') {
      return null;
    }
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  /// Safely parses a DateTime from various input types.
  static DateTime? _parseDateTimeSafely(dynamic value) {
    if (value == null || value == 'null') {
      return null;
    }
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Converts the user profile model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'email': email,
      'email_verified': emailVerified,
      'is_anonymous': isAnonymous,
      'subscription_tier': subscriptionTier,
      'stories_remaining': storiesRemaining,
      'device_id': deviceId,
      'session_id': sessionId,
      'session_created_at': sessionCreatedAt?.toIso8601String(),
      'is_authenticated': isAuthenticated,
    };
  }

  /// Creates a domain entity from this model.
  UserProfile toDomain() {
    return UserProfile(
      userId: userId,
      displayName: displayName,
      email: email,
      emailVerified: emailVerified,
      isAnonymous: isAnonymous,
      subscriptionTier: subscriptionTier,
      storiesRemaining: storiesRemaining,
      deviceId: deviceId,
      sessionId: sessionId,
      sessionCreatedAt: sessionCreatedAt,
      isAuthenticated: isAuthenticated,
    );
  }

  /// Creates a model from a domain entity.
  factory UserProfileModel.fromDomain(UserProfile profile) {
    return UserProfileModel(
      userId: profile.userId,
      displayName: profile.displayName,
      email: profile.email,
      emailVerified: profile.emailVerified,
      isAnonymous: profile.isAnonymous,
      subscriptionTier: profile.subscriptionTier,
      storiesRemaining: profile.storiesRemaining,
      deviceId: profile.deviceId,
      sessionId: profile.sessionId,
      sessionCreatedAt: profile.sessionCreatedAt,
      isAuthenticated: profile.isAuthenticated,
    );
  }
}