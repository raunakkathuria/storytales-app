import 'package:equatable/equatable.dart';
import 'package:storytales/features/authentication/domain/repositories/auth_repository.dart';

/// Use case for sending a one-time password (OTP) to an email address.
class SendOtpToEmail {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a new SendOtpToEmail use case.
  ///
  /// [repository] - The authentication repository to use.
  SendOtpToEmail(this.repository);

  /// Executes the use case.
  ///
  /// [params] - The parameters for the use case.
  ///
  /// Returns true if the OTP was sent successfully, false otherwise.
  Future<bool> call(SendOtpParams params) async {
    return await repository.sendOtpToEmail(params.email);
  }
}

/// Parameters for the [SendOtpToEmail] use case.
class SendOtpParams extends Equatable {
  /// The email address to send the OTP to.
  final String email;

  /// Creates a new SendOtpParams instance.
  ///
  /// [email] - The email address to send the OTP to.
  const SendOtpParams({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}
