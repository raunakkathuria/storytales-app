import 'package:equatable/equatable.dart';

/// Represents a user registration request.
class RegistrationRequest extends Equatable {
  /// User's email address.
  final String email;

  /// User's display name.
  final String displayName;

  /// Creates a registration request.
  const RegistrationRequest({
    required this.email,
    required this.displayName,
  });

  @override
  List<Object> get props => [email, displayName];
}

/// Represents a registration verification request.
class VerificationRequest extends Equatable {
  /// OTP code received via email.
  final String otpCode;

  /// Creates a verification request.
  const VerificationRequest({
    required this.otpCode,
  });

  @override
  List<Object> get props => [otpCode];
}

/// Represents the result of a registration request.
class RegistrationResponse extends Equatable {
  /// Whether OTP was sent successfully.
  final bool otpSent;

  /// User's email address.
  final String email;

  /// URL for verification (informational).
  final String verifyUrl;

  /// Session ID for login verification (only present for login responses).
  final String? sessionId;

  /// Creates a registration response.
  const RegistrationResponse({
    required this.otpSent,
    required this.email,
    required this.verifyUrl,
    this.sessionId,
  });

  @override
  List<Object?> get props => [otpSent, email, verifyUrl, sessionId];
}