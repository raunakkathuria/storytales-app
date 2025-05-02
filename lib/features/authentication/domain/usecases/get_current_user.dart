import 'package:storytales/features/authentication/domain/entities/user_profile.dart';
import 'package:storytales/features/authentication/domain/repositories/auth_repository.dart';
import 'package:storytales/features/authentication/domain/usecases/usecase.dart';

/// Use case for getting the current user profile.
///
/// This use case retrieves the current user profile from the authentication repository.
class GetCurrentUser implements UseCase<UserProfile?, NoParams> {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a new GetCurrentUser use case.
  ///
  /// [repository] - The authentication repository to use.
  GetCurrentUser(this.repository);

  @override
  Future<UserProfile?> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
