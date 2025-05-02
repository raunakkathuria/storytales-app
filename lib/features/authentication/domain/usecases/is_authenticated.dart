import 'package:storytales/features/authentication/domain/repositories/auth_repository.dart';
import 'package:storytales/features/authentication/domain/usecases/usecase.dart';

/// Use case for checking if the user is authenticated.
///
/// This use case checks if the user is currently authenticated.
class IsAuthenticated implements UseCase<bool, NoParams> {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a new IsAuthenticated use case.
  ///
  /// [repository] - The authentication repository to use.
  IsAuthenticated(this.repository);

  @override
  Future<bool> call(NoParams params) async {
    return await repository.isAuthenticated();
  }
}
