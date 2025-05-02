import 'package:storytales/features/authentication/domain/repositories/auth_repository.dart';
import 'package:storytales/features/authentication/domain/usecases/usecase.dart';

/// Use case for signing out the current user.
///
/// This use case signs out the current user.
class SignOut implements UseCase<bool, NoParams> {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a new SignOut use case.
  ///
  /// [repository] - The authentication repository to use.
  SignOut(this.repository);

  @override
  Future<bool> call(NoParams params) async {
    return await repository.signOut();
  }
}
