import 'package:equatable/equatable.dart';
import 'package:storytales/features/authentication/domain/entities/user_profile.dart';
import 'package:storytales/features/authentication/domain/repositories/auth_repository.dart';

/// Use case for verifying a one-time password (OTP).
class VerifyOtp {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a new VerifyOtp use case.
  ///
  /// [repository] - The authentication repository to use.
  VerifyOtp(this.repository);

  /// Executes the use case.
  ///
  /// [params] - The parameters for the use case.
  ///
  /// Returns the authenticated [UserProfile] if successful, or throws an exception.
  Future<UserProfile> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(params.email, params.otp);
  }
}

/// Parameters for the [VerifyOtp] use case.
class VerifyOtpParams extends Equatable {
  /// The email address used for authentication.
  final String email;

  /// The OTP code entered by the user.
  final String otp;

  /// Creates a new VerifyOtpParams instance.
  ///
  /// [email] - The email address used for authentication.
  /// [otp] - The OTP code entered by the user.
  const VerifyOtpParams({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}
