import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/features/authentication/data/datasources/auth_data_source.dart';
import 'package:storytales/features/authentication/data/models/user_profile_model.dart';
import 'dart:math';

/// Implementation of [AuthDataSource] using Firebase Authentication and Firestore.
class FirebaseAuthDataSource implements AuthDataSource {
  /// Firebase Authentication instance.
  final FirebaseAuth _firebaseAuth;

  /// Firestore instance.
  final FirebaseFirestore _firestore;

  /// Shared Preferences instance for storing email.
  final SharedPreferences _sharedPreferences;

  /// Logging service for logging events.
  final LoggingService _loggingService = LoggingService();

  /// Key for storing email in SharedPreferences.
  static const String _emailKey = 'auth_email';

  /// Collection name for user profiles in Firestore.
  static const String _usersCollection = 'users';

  /// Creates a new FirebaseAuthDataSource instance.
  ///
  /// [firebaseAuth] - The Firebase Authentication instance to use.
  /// [firestore] - The Firestore instance to use.
  /// [sharedPreferences] - The SharedPreferences instance to use.
  FirebaseAuthDataSource({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required SharedPreferences sharedPreferences,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _sharedPreferences = sharedPreferences;

  @override
  Future<UserProfileModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return UserProfileModel.fromFirestore(userDoc);
      } else {
        // If the user exists in Firebase Auth but not in Firestore,
        // create a new user profile
        final newUserProfile = UserProfileModel(
          id: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
          lastLoginAt: user.metadata.lastSignInTime ?? DateTime.now(),
        );

        await _firestore
            .collection(_usersCollection)
            .doc(user.uid)
            .set(newUserProfile.toFirestore());

        return newUserProfile;
      }
    } catch (e) {
      // If there's an error, return a basic user profile based on Firebase Auth data
      return UserProfileModel(
        id: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: user.metadata.lastSignInTime ?? DateTime.now(),
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<bool> sendSignInLinkToEmail(String email, String continueUrl) async {
    try {
      await _firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: continueUrl,
          handleCodeInApp: true,
          androidPackageName: 'com.example.storytales',
          androidInstallApp: true,
          androidMinimumVersion: '12',
          iOSBundleId: 'com.example.storytales',
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserProfileModel> signInWithEmailLink(
      String email, String emailLink) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to sign in: User is null');
      }

      // Check if the user profile exists in Firestore
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();

      UserProfileModel userProfile;

      if (userDoc.exists) {
        // Update the last login time
        userProfile = UserProfileModel.fromFirestore(userDoc).copyWith(
          lastLoginAt: DateTime.now(),
        );
      } else {
        // Create a new user profile
        userProfile = UserProfileModel(
          id: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
          lastLoginAt: user.metadata.lastSignInTime ?? DateTime.now(),
        );
      }

      // Save or update the user profile in Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(userProfile.toFirestore());

      return userProfile;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile(
      UserProfileModel userProfile) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userProfile.id)
          .update(userProfile.toFirestore());

      // Update display name in Firebase Auth if it has changed
      final user = _firebaseAuth.currentUser;
      if (user != null && user.displayName != userProfile.displayName) {
        await user.updateDisplayName(userProfile.displayName);
      }

      return userProfile;
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<bool> isSignInLink(String link) async {
    return _firebaseAuth.isSignInWithEmailLink(link);
  }

  @override
  Future<String?> getStoredEmail() async {
    return _sharedPreferences.getString(_emailKey);
  }

  @override
  Future<bool> storeEmail(String email) async {
    return await _sharedPreferences.setString(_emailKey, email);
  }

  @override
  Future<bool> clearStoredEmail() async {
    return await _sharedPreferences.remove(_emailKey);
  }

  /// Key for storing OTP in SharedPreferences.
  static const String _otpKey = 'auth_otp';

  /// Key for storing OTP expiration time in SharedPreferences.
  static const String _otpExpirationKey = 'auth_otp_expiration';

  @override
  Future<bool> sendOtpToEmail(String email) async {
    try {
      // Generate a random 6-digit OTP
      final random = Random();
      final otp = (100000 + random.nextInt(900000)).toString();

      // Store the OTP and email in SharedPreferences
      await storeEmail(email);
      await _sharedPreferences.setString(_otpKey, otp);

      // Set OTP expiration time (10 minutes from now)
      final expirationTime = DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch;
      await _sharedPreferences.setInt(_otpExpirationKey, expirationTime);

      // In a real app, we would send the OTP via email here
      // For the emulator, we'll log it for testing purposes
      _loggingService.info('OTP for $email: $otp');

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserProfileModel> verifyOtp(String email, String otp) async {
    try {
      // Get the stored OTP and expiration time
      final storedOtp = _sharedPreferences.getString(_otpKey);
      final expirationTime = _sharedPreferences.getInt(_otpExpirationKey) ?? 0;

      // Check if OTP is valid and not expired
      if (storedOtp == null || storedOtp != otp) {
        throw Exception('Invalid OTP');
      }

      if (DateTime.now().millisecondsSinceEpoch > expirationTime) {
        throw Exception('OTP has expired');
      }

      // Clear the OTP after successful verification
      await _sharedPreferences.remove(_otpKey);
      await _sharedPreferences.remove(_otpExpirationKey);

      // Sign in or create user with email
      UserCredential userCredential;
      try {
        // Try to sign in with email
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: 'OTP-BASED-AUTH-NO-PASSWORD', // Dummy password, not actually used
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // If user doesn't exist, create a new account
          userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: 'OTP-BASED-AUTH-NO-PASSWORD', // Dummy password, not actually used
          );
        } else {
          throw Exception('Authentication failed: ${e.message}');
        }
      }

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to sign in: User is null');
      }

      // Check if the user profile exists in Firestore
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();

      UserProfileModel userProfile;

      if (userDoc.exists) {
        // Update the last login time
        userProfile = UserProfileModel.fromFirestore(userDoc).copyWith(
          lastLoginAt: DateTime.now(),
        );
      } else {
        // Create a new user profile
        userProfile = UserProfileModel(
          id: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
          lastLoginAt: user.metadata.lastSignInTime ?? DateTime.now(),
        );
      }

      // Save or update the user profile in Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(userProfile.toFirestore());

      return userProfile;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }
}
