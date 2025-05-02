import 'package:equatable/equatable.dart';
import 'package:storytales/features/authentication/domain/entities/user_profile.dart';
import 'package:storytales/features/authentication/domain/repositories/auth_repository.dart';
import 'package:storytales/features/authentication/domain/usecases/usecase.dart';

/// Use case for updating the user profile.
///
/// This use case updates the current user's profile.
class UpdateUserProfile implements UseCase<UserProfile, UpdateUserProfileParams> {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a new UpdateUserProfile use case.
  ///
  /// [repository] - The authentication repository to use.
  UpdateUserProfile(this.repository);

  @override
  Future<UserProfile> call(UpdateUserProfileParams params) async {
    return await repository.updateUserProfile(params.userProfile);
  }
}

/// Parameters for the UpdateUserProfile use case.
class UpdateUserProfileParams extends Equatable {
  /// The updated user profile.
  final UserProfile userProfile;

  /// Creates a new UpdateUserProfileParams instance.
  ///
  /// [userProfile] - The updated user profile.
  const UpdateUserProfileParams({
    required this.userProfile,
  });

  @override
  List<Object?> get props => [userProfile];
}
