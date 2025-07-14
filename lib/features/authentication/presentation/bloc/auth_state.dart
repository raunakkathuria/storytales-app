import 'package:equatable/equatable.dart';
import 'package:storytales/features/authentication/domain/entities/user_profile.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
  /// Creates a new AuthState instance.
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial authentication state.
///
/// This is the state when the authentication status is unknown.
class AuthInitial extends AuthState {
  /// Creates a new AuthInitial state.
  const AuthInitial();
}

/// Loading authentication state.
///
/// This is the state when an authentication operation is in progress.
class AuthLoading extends AuthState {
  /// Creates a new AuthLoading state.
  const AuthLoading();
}

/// Authenticated state.
///
/// This is the state when the user is authenticated.
class Authenticated extends AuthState {
  /// The authenticated user's profile.
  final UserProfile userProfile;

  /// Creates a new Authenticated state.
  ///
  /// [userProfile] - The authenticated user's profile.
  const Authenticated({
    required this.userProfile,
  });

  @override
  List<Object?> get props => [userProfile];
}

/// Unauthenticated state.
///
/// This is the state when the user is not authenticated.
class Unauthenticated extends AuthState {
  /// Creates a new Unauthenticated state.
  const Unauthenticated();
}

/// Sign-in link sent state.
///
/// This is the state when a sign-in link has been sent to the user's email.
class SignInLinkSent extends AuthState {
  /// The email address the sign-in link was sent to.
  final String email;

  /// Creates a new SignInLinkSent state.
  ///
  /// [email] - The email address the sign-in link was sent to.
  const SignInLinkSent({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}

/// Authentication error state.
///
/// This is the state when an authentication operation has failed.
class AuthError extends AuthState {
  /// The error message.
  final String message;

  /// Creates a new AuthError state.
  ///
  /// [message] - The error message.
  const AuthError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// Profile update success state.
///
/// This is the state when a profile update operation has succeeded.
class ProfileUpdateSuccess extends AuthState {
  /// The updated user profile.
  final UserProfile userProfile;

  /// Creates a new ProfileUpdateSuccess state.
  ///
  /// [userProfile] - The updated user profile.
  const ProfileUpdateSuccess({
    required this.userProfile,
  });

  @override
  List<Object?> get props => [userProfile];
}

/// Sign-in link check result state.
///
/// This is the state when a sign-in link check operation has completed.
class SignInLinkCheckResult extends AuthState {
  /// Whether the link is a sign-in link.
  final bool isSignInLink;

  /// The link that was checked.
  final String link;

  /// Creates a new SignInLinkCheckResult state.
  ///
  /// [isSignInLink] - Whether the link is a sign-in link.
  /// [link] - The link that was checked.
  const SignInLinkCheckResult({
    required this.isSignInLink,
    required this.link,
  });

  @override
  List<Object?> get props => [isSignInLink, link];
}

/// Stored email result state.
///
/// This is the state when a stored email retrieval operation has completed.
class StoredEmailResult extends AuthState {
  /// The stored email address, or null if none is stored.
  final String? email;

  /// Creates a new StoredEmailResult state.
  ///
  /// [email] - The stored email address, or null if none is stored.
  const StoredEmailResult({
    this.email,
  });

  @override
  List<Object?> get props => [email];
}

/// OTP sent state.
///
/// This is the state when an OTP has been sent to the user's email.
class OtpSent extends AuthState {
  /// The email address the OTP was sent to.
  final String email;

  /// Creates a new OtpSent state.
  ///
  /// [email] - The email address the OTP was sent to.
  const OtpSent({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}

/// OTP verification failed state.
///
/// This is the state when OTP verification has failed.
class OtpVerificationFailed extends AuthState {
  /// The error message.
  final String message;

  /// Creates a new OtpVerificationFailed state.
  ///
  /// [message] - The error message.
  const OtpVerificationFailed({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
