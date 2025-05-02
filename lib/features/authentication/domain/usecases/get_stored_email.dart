import 'package:storytales/features/authentication/domain/repositories/auth_repository.dart';
import 'package:storytales/features/authentication/domain/usecases/usecase.dart';

/// Use case for getting the stored email address.
///
/// This use case retrieves the email address stored for authentication.
class GetStoredEmail implements UseCase<String?, NoParams> {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a new GetStoredEmail use case.
  ///
  /// [repository] - The authentication repository to use.
  GetStoredEmail(this.repository);

  @override
  Future<String?> call(NoParams params) async {
    return await repository.getStoredEmail();
  }
}
