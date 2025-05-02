import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storytales/features/authentication/domain/entities/user_profile.dart';

/// Model class for UserProfile.
///
/// This class extends the UserProfile entity and adds methods for
/// converting to and from JSON and Firestore documents.
class UserProfileModel extends UserProfile {
  /// Creates a new UserProfileModel instance.
  const UserProfileModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    required super.createdAt,
    required super.lastLoginAt,
    super.preferences = const {},
  });

  /// Creates a UserProfileModel from a JSON map.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (json['lastLoginAt'] as Timestamp).toDate(),
      preferences: json['preferences'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Creates a UserProfileModel from a Firestore document.
  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }

    return UserProfileModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// Converts this UserProfileModel to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'preferences': preferences,
    };
  }

  /// Converts this UserProfileModel to a Firestore document.
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Remove the id field as it's stored as the document ID
    json.remove('id');
    return json;
  }

  /// Creates a copy of this UserProfileModel with the given fields replaced with new values.
  @override
  UserProfileModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }
}
