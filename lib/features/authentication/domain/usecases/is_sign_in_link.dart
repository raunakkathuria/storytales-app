import 'package:equatable/equatable.dart';
import 'package:storytales/features/authentication/domain/repositories/auth_repository.dart';
import 'package:storytales/features/authentication/domain/usecases/usecase.dart';

/// Use case for checking if a link is a sign-in link.
///
/// This use case checks if an incoming link is a sign-in link.
class IsSignInLink implements UseCase<bool, IsSignInLinkParams> {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a new IsSignInLink use case.
  ///
  /// [repository] - The authentication repository to use.
  IsSignInLink(this.repository);

  @override
  Future<bool> call(IsSignInLinkParams params) async {
    return await repository.isSignInLink(params.link);
  }
}

/// Parameters for the IsSignInLink use case.
class IsSignInLinkParams extends Equatable {
  /// The link to check.
  final String link;

  /// Creates a new IsSignInLinkParams instance.
  ///
  /// [link] - The link to check.
  const IsSignInLinkParams({
    required this.link,
  });

  @override
  List<Object?> get props => [link];
}
