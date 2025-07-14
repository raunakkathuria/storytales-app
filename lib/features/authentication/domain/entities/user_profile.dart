import 'package:equatable/equatable.dart';

/// Entity class representing a user profile in the application.
///
/// This class contains all the user-specific data that is stored in Firestore
/// and used throughout the application.
class UserProfile extends Equatable {
  /// Unique identifier for the user (Firebase Auth UID)
  final String id;

  /// User's email address
  final String email;

  /// User's display name (optional)
  final String? displayName;

  /// URL to the user's profile photo (optional)
  final String? photoUrl;

  /// Timestamp when the account was created
  final DateTime createdAt;

  /// Timestamp of the user's last login
  final DateTime lastLoginAt;

  /// User's preferences (can be extended as needed)
  final Map<String, dynamic> preferences;

  /// Creates a new UserProfile instance.
  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.preferences = const {},
  });

  /// Creates a copy of this UserProfile with the given fields replaced with new values.
  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Creates an empty UserProfile instance.
  ///
  /// This is useful for representing an unauthenticated state.
  factory UserProfile.empty() {
    return UserProfile(
      id: '',
      email: '',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Whether this UserProfile represents an authenticated user.
  bool get isAuthenticated => id.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        createdAt,
        lastLoginAt,
        preferences,
      ];
}
