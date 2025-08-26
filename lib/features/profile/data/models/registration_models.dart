import '../../domain/entities/registration_request.dart';

/// Data model for registration response that handles API serialization.
class RegistrationResponseModel extends RegistrationResponse {
  /// Creates a registration response model.
  const RegistrationResponseModel({
    required super.otpSent,
    required super.email,
    required super.verifyUrl,
  });

  /// Creates a registration response model from JSON.
  factory RegistrationResponseModel.fromJson(Map<String, dynamic> json) {
    return RegistrationResponseModel(
      otpSent: json['otp_sent'] as bool,
      email: json['email'] as String,
      verifyUrl: json['verify_url'] as String,
    );
  }

  /// Converts the registration response model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'otp_sent': otpSent,
      'email': email,
      'verify_url': verifyUrl,
    };
  }

  /// Creates a domain entity from this model.
  RegistrationResponse toDomain() {
    return RegistrationResponse(
      otpSent: otpSent,
      email: email,
      verifyUrl: verifyUrl,
    );
  }
}

/// Data model for registration request JSON payload.
class RegistrationRequestModel {
  /// User's email address.
  final String email;

  /// User's display name.
  final String displayName;

  /// Creates a registration request model.
  const RegistrationRequestModel({
    required this.email,
    required this.displayName,
  });

  /// Creates a registration request model from domain entity.
  factory RegistrationRequestModel.fromDomain(RegistrationRequest request) {
    return RegistrationRequestModel(
      email: request.email,
      displayName: request.displayName,
    );
  }

  /// Converts the registration request model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'display_name': displayName,
    };
  }
}

/// Data model for verification request JSON payload.
class VerificationRequestModel {
  /// OTP code received via email.
  final String otpCode;

  /// Creates a verification request model.
  const VerificationRequestModel({
    required this.otpCode,
  });

  /// Creates a verification request model from domain entity.
  factory VerificationRequestModel.fromDomain(VerificationRequest request) {
    return VerificationRequestModel(
      otpCode: request.otpCode,
    );
  }

  /// Converts the verification request model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'otp_code': otpCode,
    };
  }
}