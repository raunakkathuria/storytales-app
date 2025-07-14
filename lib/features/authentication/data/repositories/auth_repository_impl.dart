import 'package:storytales/features/authentication/data/datasources/auth_data_source.dart';
import 'package:storytales/features/authentication/data/models/user_profile_model.dart';
import 'package:storytales/features/authentication/domain/entities/user_profile.dart';
import 'package:storytales/features/authentication/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] that uses an [AuthDataSource].
class AuthRepositoryImpl implements AuthRepository {
  /// The authentication data source.
  final AuthDataSource dataSource;

  /// Creates a new AuthRepositoryImpl instance.
  ///
  /// [dataSource] - The authentication data source to use.
  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<UserProfile?> getCurrentUser() async {
    return await dataSource.getCurrentUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await dataSource.isAuthenticated();
  }

  @override
  Future<bool> sendSignInLinkToEmail(String email, String continueUrl) async {
    return await dataSource.sendSignInLinkToEmail(email, continueUrl);
  }

  @override
  Future<UserProfile> signInWithEmailLink(String email, String emailLink) async {
    return await dataSource.signInWithEmailLink(email, emailLink);
  }

  @override
  Future<bool> sendOtpToEmail(String email) async {
    return await dataSource.sendOtpToEmail(email);
  }

  @override
  Future<UserProfile> verifyOtp(String email, String otp) async {
    return await dataSource.verifyOtp(email, otp);
  }

  @override
  Future<bool> signOut() async {
    return await dataSource.signOut();
  }

  @override
  Future<UserProfile> updateUserProfile(UserProfile userProfile) async {
    // Convert the domain entity to a data model
    final userProfileModel = UserProfileModel(
      id: userProfile.id,
      email: userProfile.email,
      displayName: userProfile.displayName,
      photoUrl: userProfile.photoUrl,
      createdAt: userProfile.createdAt,
      lastLoginAt: userProfile.lastLoginAt,
      preferences: userProfile.preferences,
    );

    return await dataSource.updateUserProfile(userProfileModel);
  }

  @override
  Future<bool> isSignInLink(String link) async {
    return await dataSource.isSignInLink(link);
  }

  @override
  Future<String?> getStoredEmail() async {
    return await dataSource.getStoredEmail();
  }

  @override
  Future<bool> storeEmail(String email) async {
    return await dataSource.storeEmail(email);
  }

  @override
  Future<bool> clearStoredEmail() async {
    return await dataSource.clearStoredEmail();
  }
}
