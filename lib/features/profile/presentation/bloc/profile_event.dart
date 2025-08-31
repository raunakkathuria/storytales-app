import 'package:equatable/equatable.dart';

/// Base class for profile events.
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the current user profile.
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

/// Event to refresh the user profile from server.
class RefreshProfile extends ProfileEvent {
  const RefreshProfile();
}

/// Event to update the user's display name.
class UpdateDisplayName extends ProfileEvent {
  /// The new display name.
  final String displayName;

  const UpdateDisplayName({
    required this.displayName,
  });

  @override
  List<Object> get props => [displayName];
}

/// Event to start user registration process.
class RegisterUser extends ProfileEvent {
  /// User's email address.
  final String email;

  /// User's display name.
  final String displayName;

  const RegisterUser({
    required this.email,
    required this.displayName,
  });

  @override
  List<Object> get props => [email, displayName];
}

/// Event to verify user registration with OTP.
class VerifyRegistration extends ProfileEvent {
  /// OTP code received via email.
  final String otpCode;

  const VerifyRegistration({
    required this.otpCode,
  });

  @override
  List<Object> get props => [otpCode];
}

/// Event to request a new registration OTP when the previous one expires.
class RequestNewRegistrationOTP extends ProfileEvent {
  const RequestNewRegistrationOTP();
}

/// Event to login an existing user.
class LoginUser extends ProfileEvent {
  /// User's email address.
  final String email;

  const LoginUser({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

/// Event to verify user login with OTP.
class VerifyLogin extends ProfileEvent {
  /// Session ID from login response.
  final String sessionId;
  
  /// OTP code received via email.
  final String otpCode;

  const VerifyLogin({
    required this.sessionId,
    required this.otpCode,
  });

  @override
  List<Object> get props => [sessionId, otpCode];
}

/// Event to sign out user (return to anonymous state).
class SignOut extends ProfileEvent {
  const SignOut();
}

/// Event to reset any error state.
class ClearError extends ProfileEvent {
  const ClearError();
}

/// Event to cancel registration process.
class CancelRegistration extends ProfileEvent {
  const CancelRegistration();
}