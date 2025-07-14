import 'package:equatable/equatable.dart';
import 'package:storytales/features/authentication/domain/entities/user_profile.dart';
import 'package:storytales/features/authentication/domain/repositories/auth_repository.dart';
import 'package:storytales/features/authentication/domain/usecases/usecase.dart';

/// Use case for signing in with an email link.
///
/// This use case signs in a user with an email link.
class SignInWithEmailLink implements UseCase<UserProfile, SignInWithEmailLinkParams> {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a new SignInWithEmailLink use case.
  ///
  /// [repository] - The authentication repository to use.
  SignInWithEmailLink(this.repository);

  @override
  Future<UserProfile> call(SignInWithEmailLinkParams params) async {
    final userProfile = await repository.signInWithEmailLink(
      params.email,
      params.emailLink,
    );

    // Clear the stored email after successful sign-in
    await repository.clearStoredEmail();

    return userProfile;
  }
}

/// Parameters for the SignInWithEmailLink use case.
class SignInWithEmailLinkParams extends Equatable {
  /// The email address used for authentication.
  final String email;

  /// The email link received for authentication.
  final String emailLink;

  /// Creates a new SignInWithEmailLinkParams instance.
  ///
  /// [email] - The email address used for authentication.
  /// [emailLink] - The email link received for authentication.
  const SignInWithEmailLinkParams({
    required this.email,
    required this.emailLink,
  });

  @override
  List<Object?> get props => [email, emailLink];
}
