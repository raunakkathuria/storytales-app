import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/registration_request.dart';

/// Base class for profile states.
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state when profile is not loaded.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// State when profile is being loaded.
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// State when profile is successfully loaded.
class ProfileLoaded extends ProfileState {
  /// The loaded user profile.
  final UserProfile profile;

  const ProfileLoaded({
    required this.profile,
  });

  @override
  List<Object> get props => [profile];
}

/// State when updating display name.
class ProfileUpdating extends ProfileState {
  /// The current user profile.
  final UserProfile profile;

  const ProfileUpdating({
    required this.profile,
  });

  @override
  List<Object> get props => [profile];
}

/// State when display name update is successful.
class ProfileUpdated extends ProfileState {
  /// The updated user profile.
  final UserProfile profile;

  const ProfileUpdated({
    required this.profile,
  });

  @override
  List<Object> get props => [profile];
}

/// State when user registration is in progress.
class ProfileRegistering extends ProfileState {
  /// The current user profile.
  final UserProfile profile;

  /// The registration email.
  final String email;

  /// The display name being registered.
  final String displayName;

  const ProfileRegistering({
    required this.profile,
    required this.email,
    required this.displayName,
  });

  @override
  List<Object> get props => [profile, email, displayName];
}

/// State when registration OTP has been sent.
class ProfileRegistrationPending extends ProfileState {
  /// The current user profile.
  final UserProfile profile;

  /// The registration response.
  final RegistrationResponse registrationResponse;

  /// The display name being registered.
  final String displayName;

  const ProfileRegistrationPending({
    required this.profile,
    required this.registrationResponse,
    required this.displayName,
  });

  @override
  List<Object> get props => [profile, registrationResponse, displayName];
}

/// State when verifying registration OTP.
class ProfileVerifying extends ProfileState {
  /// The current user profile.
  final UserProfile profile;

  /// The registration response.
  final RegistrationResponse registrationResponse;

  /// The display name being registered.
  final String displayName;

  /// The OTP code being verified.
  final String otpCode;

  const ProfileVerifying({
    required this.profile,
    required this.registrationResponse,
    required this.displayName,
    required this.otpCode,
  });

  @override
  List<Object> get props => [profile, registrationResponse, displayName, otpCode];
}

/// State when registration is successfully completed.
class ProfileRegistrationCompleted extends ProfileState {
  /// The updated user profile after registration.
  final UserProfile profile;

  const ProfileRegistrationCompleted({
    required this.profile,
  });

  @override
  List<Object> get props => [profile];
}

/// State when user has incomplete registration (email registered but not verified).
class ProfileRegistrationIncomplete extends ProfileState {
  /// The current user profile.
  final UserProfile profile;

  /// The email address that needs verification.
  final String email;

  /// The display name being registered.
  final String displayName;

  /// The stored registration response.
  final RegistrationResponse registrationResponse;

  const ProfileRegistrationIncomplete({
    required this.profile,
    required this.email,
    required this.displayName,
    required this.registrationResponse,
  });

  @override
  List<Object> get props => [profile, email, displayName, registrationResponse];
}

/// State when user login is in progress.
class ProfileLoggingIn extends ProfileState {
  /// The login email.
  final String email;

  const ProfileLoggingIn({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

/// State when login OTP has been sent.
class ProfileLoginPending extends ProfileState {
  /// The login email.
  final String email;

  /// The login response (similar to registration response).
  final RegistrationResponse loginResponse;

  const ProfileLoginPending({
    required this.email,
    required this.loginResponse,
  });

  @override
  List<Object> get props => [email, loginResponse];
}

/// State when verifying login OTP.
class ProfileLoginVerifying extends ProfileState {
  /// The login email.
  final String email;

  /// The login response.
  final RegistrationResponse loginResponse;

  /// The OTP code being verified.
  final String otpCode;

  const ProfileLoginVerifying({
    required this.email,
    required this.loginResponse,
    required this.otpCode,
  });

  @override
  List<Object> get props => [email, loginResponse, otpCode];
}

/// State when login is successfully completed.
class ProfileLoginCompleted extends ProfileState {
  /// The user profile after login.
  final UserProfile profile;

  const ProfileLoginCompleted({
    required this.profile,
  });

  @override
  List<Object> get props => [profile];
}

/// State when an error occurs.
class ProfileError extends ProfileState {
  /// The error message.
  final String message;

  /// The current user profile (if available).
  final UserProfile? profile;

  const ProfileError({
    required this.message,
    this.profile,
  });

  @override
  List<Object?> get props => [message, profile];
}