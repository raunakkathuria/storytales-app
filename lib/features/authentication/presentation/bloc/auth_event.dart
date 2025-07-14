import 'package:equatable/equatable.dart';
import 'package:storytales/features/authentication/domain/entities/user_profile.dart';

/// Base class for all authentication events.
abstract class AuthEvent extends Equatable {
  /// Creates a new AuthEvent instance.
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check the current authentication status.
class CheckAuthStatus extends AuthEvent {
  /// Creates a new CheckAuthStatus event.
  const CheckAuthStatus();
}

/// Event to send a sign-in link to an email address.
class SendSignInLink extends AuthEvent {
  /// The email address to send the sign-in link to.
  final String email;

  /// The URL to redirect to after authentication.
  final String continueUrl;

  /// Creates a new SendSignInLink event.
  ///
  /// [email] - The email address to send the sign-in link to.
  /// [continueUrl] - The URL to redirect to after authentication.
  const SendSignInLink({
    required this.email,
    required this.continueUrl,
  });

  @override
  List<Object?> get props => [email, continueUrl];
}

/// Event to sign in with an email link.
class SignInWithLink extends AuthEvent {
  /// The email address used for authentication.
  final String email;

  /// The email link received for authentication.
  final String emailLink;

  /// Creates a new SignInWithLink event.
  ///
  /// [email] - The email address used for authentication.
  /// [emailLink] - The email link received for authentication.
  const SignInWithLink({
    required this.email,
    required this.emailLink,
  });

  @override
  List<Object?> get props => [email, emailLink];
}

/// Event to sign out the current user.
class SignOutUser extends AuthEvent {
  /// Creates a new SignOutUser event.
  const SignOutUser();
}

/// Event to update the user profile.
class UpdateProfile extends AuthEvent {
  /// The updated user profile.
  final UserProfile userProfile;

  /// Creates a new UpdateProfile event.
  ///
  /// [userProfile] - The updated user profile.
  const UpdateProfile({
    required this.userProfile,
  });

  @override
  List<Object?> get props => [userProfile];
}

/// Event to check if a link is a sign-in link.
class CheckSignInLink extends AuthEvent {
  /// The link to check.
  final String link;

  /// Creates a new CheckSignInLink event.
  ///
  /// [link] - The link to check.
  const CheckSignInLink({
    required this.link,
  });

  @override
  List<Object?> get props => [link];
}

/// Event to get the stored email address.
class GetStoredEmailEvent extends AuthEvent {
  /// Creates a new GetStoredEmailEvent event.
  const GetStoredEmailEvent();
}

/// Event to send a one-time password (OTP) to an email address.
class SendOtp extends AuthEvent {
  /// The email address to send the OTP to.
  final String email;

  /// Creates a new SendOtp event.
  ///
  /// [email] - The email address to send the OTP to.
  const SendOtp({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}

/// Event to verify a one-time password (OTP).
class VerifyOtp extends AuthEvent {
  /// The email address used for authentication.
  final String email;

  /// The OTP code entered by the user.
  final String otp;

  /// Creates a new VerifyOtp event.
  ///
  /// [email] - The email address used for authentication.
  /// [otp] - The OTP code entered by the user.
  const VerifyOtp({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}
