import 'package:equatable/equatable.dart';
import 'package:storytales/features/authentication/domain/repositories/auth_repository.dart';
import 'package:storytales/features/authentication/domain/usecases/usecase.dart';

/// Use case for sending a sign-in link to an email address.
///
/// This use case sends a sign-in link to the provided email address.
class SendSignInLinkToEmail implements UseCase<bool, SendSignInLinkParams> {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a new SendSignInLinkToEmail use case.
  ///
  /// [repository] - The authentication repository to use.
  SendSignInLinkToEmail(this.repository);

  @override
  Future<bool> call(SendSignInLinkParams params) async {
    final result = await repository.sendSignInLinkToEmail(
      params.email,
      params.continueUrl,
    );

    if (result) {
      // Store the email for later use during sign-in
      await repository.storeEmail(params.email);
    }

    return result;
  }
}

/// Parameters for the SendSignInLinkToEmail use case.
class SendSignInLinkParams extends Equatable {
  /// The email address to send the sign-in link to.
  final String email;

  /// The URL to redirect to after authentication.
  final String continueUrl;

  /// Creates a new SendSignInLinkParams instance.
  ///
  /// [email] - The email address to send the sign-in link to.
  /// [continueUrl] - The URL to redirect to after authentication.
  const SendSignInLinkParams({
    required this.email,
    required this.continueUrl,
  });

  @override
  List<Object?> get props => [email, continueUrl];
}
