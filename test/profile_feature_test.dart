import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/features/profile/domain/entities/user_profile.dart';
import 'package:storytales/features/profile/domain/entities/registration_request.dart';
import 'package:storytales/features/profile/domain/repositories/profile_repository.dart';
import 'package:storytales/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:storytales/features/profile/presentation/bloc/profile_event.dart';
import 'package:storytales/features/profile/presentation/bloc/profile_state.dart';
import 'package:storytales/features/profile/data/models/user_profile_model.dart';
import 'package:storytales/features/profile/data/models/registration_models.dart';

import 'profile_feature_test.mocks.dart';

@GenerateMocks([
  ProfileRepository,
  LoggingService,
])
void main() {
  group('Profile Feature Tests', () {
    late MockProfileRepository mockProfileRepository;
    late MockLoggingService mockLoggingService;

    setUp(() {
      mockProfileRepository = MockProfileRepository();
      mockLoggingService = MockLoggingService();
    });

    group('Domain Layer Tests', () {
      group('UserProfile Entity', () {
        test('should create UserProfile with correct properties', () {
          // Arrange
          const userProfile = UserProfile(
            userId: 123,
            displayName: 'John Doe',
            email: 'john@example.com',
            emailVerified: true,
            isAnonymous: false,
            subscriptionTier: 'premium',
            storiesRemaining: 10,
            deviceId: 'device-123',
          );

          // Assert
          expect(userProfile.userId, equals(123));
          expect(userProfile.displayName, equals('John Doe'));
          expect(userProfile.email, equals('john@example.com'));
          expect(userProfile.emailVerified, isTrue);
          expect(userProfile.isAnonymous, isFalse);
          expect(userProfile.hasRegisteredAccount, isTrue);
          expect(userProfile.canRegister, isFalse);
        });

        test('should detect anonymous user correctly', () {
          // Arrange
          const anonymousProfile = UserProfile(
            userId: 456,
            displayName: null,
            email: null,
            emailVerified: false,
            isAnonymous: true,
            subscriptionTier: 'free',
            storiesRemaining: 2,
            deviceId: 'device-456',
          );

          // Assert
          expect(anonymousProfile.hasRegisteredAccount, isFalse);
          expect(anonymousProfile.canRegister, isTrue);
        });

        test('should create copy with updated fields', () {
          // Arrange
          const originalProfile = UserProfile(
            userId: 123,
            displayName: 'Original Name',
            email: null,
            emailVerified: false,
            isAnonymous: true,
            subscriptionTier: 'free',
            storiesRemaining: 2,
            deviceId: 'device-123',
          );

          // Act
          final updatedProfile = originalProfile.copyWith(
            displayName: 'Updated Name',
            email: 'new@example.com',
          );

          // Assert
          expect(updatedProfile.displayName, equals('Updated Name'));
          expect(updatedProfile.email, equals('new@example.com'));
          expect(updatedProfile.userId, equals(123)); // Unchanged
        });
      });

      group('Registration Request Entity', () {
        test('should create RegistrationRequest with correct properties', () {
          // Arrange
          const registrationRequest = RegistrationRequest(
            email: 'test@example.com',
            displayName: 'Test User',
          );

          // Assert
          expect(registrationRequest.email, equals('test@example.com'));
          expect(registrationRequest.displayName, equals('Test User'));
        });

        test('should create VerificationRequest with correct properties', () {
          // Arrange
          const verificationRequest = VerificationRequest(otpCode: '123456');

          // Assert
          expect(verificationRequest.otpCode, equals('123456'));
        });
      });
    });

    group('Data Layer Tests', () {
      group('UserProfileModel', () {
        test('should create from JSON correctly', () {
          // Arrange
          final json = {
            'id': 123,
            'display_name': 'John Doe',
            'email': 'john@example.com',
            'email_verified': true,
            'is_anonymous': false,
            'subscription_tier': 'premium',
            'max_monthly_stories': 10,
            'device_id': 'device-123',
          };

          // Act
          final model = UserProfileModel.fromJson(json);

          // Assert
          expect(model.userId, equals(123));
          expect(model.displayName, equals('John Doe'));
          expect(model.email, equals('john@example.com'));
          expect(model.emailVerified, isTrue);
          expect(model.isAnonymous, isFalse);
        });

        test('should handle null values in JSON', () {
          // Arrange
          final json = {
            'id': 123,
            'display_name': null,
            'email': null,
            'device_id': 'device-123',
          };

          // Act
          final model = UserProfileModel.fromJson(json);

          // Assert
          expect(model.userId, equals(123));
          expect(model.displayName, isNull);
          expect(model.email, isNull);
          expect(model.emailVerified, isFalse); // Default value
          expect(model.isAnonymous, isTrue); // Default value
          expect(model.subscriptionTier, equals('free')); // Default value
          expect(model.storiesRemaining, equals(0)); // Default value
        });

        test('should convert to JSON correctly', () {
          // Arrange
          const model = UserProfileModel(
            userId: 123,
            displayName: 'John Doe',
            email: 'john@example.com',
            emailVerified: true,
            isAnonymous: false,
            subscriptionTier: 'premium',
            storiesRemaining: 10,
            deviceId: 'device-123',
          );

          // Act
          final json = model.toJson();

          // Assert
          expect(json['user_id'], equals(123));
          expect(json['display_name'], equals('John Doe'));
          expect(json['email'], equals('john@example.com'));
          expect(json['email_verified'], isTrue);
          expect(json['is_anonymous'], isFalse);
        });

        test('should convert to domain entity correctly', () {
          // Arrange
          const model = UserProfileModel(
            userId: 123,
            displayName: 'John Doe',
            email: 'john@example.com',
            emailVerified: true,
            isAnonymous: false,
            subscriptionTier: 'premium',
            storiesRemaining: 10,
            deviceId: 'device-123',
          );

          // Act
          final domain = model.toDomain();

          // Assert
          expect(domain, isA<UserProfile>());
          expect(domain.userId, equals(123));
          expect(domain.displayName, equals('John Doe'));
        });
      });

      group('RegistrationResponseModel', () {
        test('should create from JSON correctly', () {
          // Arrange
          final json = {
            'otp_sent': true,
            'email': 'test@example.com',
            'verify_url': '/verify/123',
          };

          // Act
          final model = RegistrationResponseModel.fromJson(json);

          // Assert
          expect(model.otpSent, isTrue);
          expect(model.email, equals('test@example.com'));
          expect(model.verifyUrl, equals('/verify/123'));
        });

        test('should convert to JSON correctly', () {
          // Arrange
          const model = RegistrationResponseModel(
            otpSent: true,
            email: 'test@example.com',
            verifyUrl: '/verify/123',
          );

          // Act
          final json = model.toJson();

          // Assert
          expect(json['otp_sent'], isTrue);
          expect(json['email'], equals('test@example.com'));
          expect(json['verify_url'], equals('/verify/123'));
        });
      });
    });

    group('BLoC Tests', () {
      late ProfileBloc profileBloc;

      setUp(() {
        profileBloc = ProfileBloc(
          profileRepository: mockProfileRepository,
          loggingService: mockLoggingService,
        );
      });

      tearDown(() {
        profileBloc.close();
      });

      test('initial state should be ProfileInitial', () {
        // Assert
        expect(profileBloc.state, isA<ProfileInitial>());
      });

      group('LoadProfile', () {
        const mockProfile = UserProfile(
          userId: 123,
          displayName: 'Test User',
          email: 'test@example.com',
          emailVerified: true,
          isAnonymous: false,
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        blocTest<ProfileBloc, ProfileState>(
          'should emit [ProfileLoading, ProfileLoaded] when successful',
          build: () {
            when(mockProfileRepository.getCurrentUserProfile())
                .thenAnswer((_) async => mockProfile);
            return profileBloc;
          },
          act: (bloc) => bloc.add(const LoadProfile()),
          expect: () => [
            const ProfileLoading(),
            const ProfileLoaded(profile: mockProfile),
          ],
          verify: (_) {
            verify(mockProfileRepository.getCurrentUserProfile()).called(1);
          },
        );

        blocTest<ProfileBloc, ProfileState>(
          'should emit [ProfileLoading, ProfileError] when repository throws exception',
          build: () {
            when(mockProfileRepository.getCurrentUserProfile())
                .thenThrow(Exception('Failed to load profile'));
            return profileBloc;
          },
          act: (bloc) => bloc.add(const LoadProfile()),
          expect: () => [
            const ProfileLoading(),
            const ProfileError(message: '🌟 Oh no! Our Story Wizard had trouble loading your profile. Please try again!'),
          ],
        );
      });

      group('UpdateDisplayName', () {
        const initialProfile = UserProfile(
          userId: 123,
          displayName: 'Old Name',
          email: 'test@example.com',
          emailVerified: true,
          isAnonymous: false,
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        const updatedProfile = UserProfile(
          userId: 123,
          displayName: 'New Name',
          email: 'test@example.com',
          emailVerified: true,
          isAnonymous: false,
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        blocTest<ProfileBloc, ProfileState>(
          'should emit [ProfileUpdating, ProfileUpdated, ProfileLoaded] when successful',
          build: () {
            when(mockProfileRepository.updateDisplayName('New Name'))
                .thenAnswer((_) async => updatedProfile);
            return profileBloc;
          },
          seed: () => const ProfileLoaded(profile: initialProfile),
          act: (bloc) => bloc.add(const UpdateDisplayName(displayName: 'New Name')),
          expect: () => [
            const ProfileUpdating(profile: initialProfile),
            const ProfileUpdated(profile: updatedProfile),
          ],
          verify: (_) {
            verify(mockProfileRepository.updateDisplayName('New Name')).called(1);
          },
        );
      });

      group('RegisterUser', () {
        const currentProfile = UserProfile(
          userId: 123,
          displayName: 'Test User',
          email: null,
          emailVerified: false,
          isAnonymous: true,
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        const registrationResponse = RegistrationResponse(
          otpSent: true,
          email: 'test@example.com',
          verifyUrl: '/verify/123',
        );

        blocTest<ProfileBloc, ProfileState>(
          'should emit [ProfileRegistering, ProfileRegistrationPending] when successful',
          build: () {
            when(mockProfileRepository.registerUser(
              email: 'test@example.com',
              displayName: 'Test User',
            )).thenAnswer((_) async => registrationResponse);
            return profileBloc;
          },
          seed: () => const ProfileLoaded(profile: currentProfile),
          act: (bloc) => bloc.add(const RegisterUser(
            email: 'test@example.com',
            displayName: 'Test User',
          )),
          expect: () => [
            const ProfileRegistering(
              profile: currentProfile,
              email: 'test@example.com',
              displayName: 'Test User',
            ),
            const ProfileRegistrationPending(
              profile: currentProfile,
              registrationResponse: registrationResponse,
              displayName: 'Test User',
            ),
          ],
          verify: (_) {
            verify(mockProfileRepository.registerUser(
              email: 'test@example.com',
              displayName: 'Test User',
            )).called(1);
          },
        );
      });

      group('VerifyRegistration', () {
        const currentProfile = UserProfile(
          userId: 123,
          displayName: 'Test User',
          email: null,
          emailVerified: false,
          isAnonymous: true,
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        const registrationResponse = RegistrationResponse(
          otpSent: true,
          email: 'test@example.com',
          verifyUrl: '/verify/123',
        );

        const verifiedProfile = UserProfile(
          userId: 123,
          displayName: 'Test User',
          email: 'test@example.com',
          emailVerified: true,
          isAnonymous: false,
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        blocTest<ProfileBloc, ProfileState>(
          'should emit [ProfileVerifying, ProfileRegistrationCompleted] when successful',
          build: () {
            when(mockProfileRepository.verifyRegistration(otpCode: '123456'))
                .thenAnswer((_) async => verifiedProfile);
            return profileBloc;
          },
          seed: () => const ProfileRegistrationPending(
            profile: currentProfile,
            registrationResponse: registrationResponse,
            displayName: 'Test User',
          ),
          act: (bloc) => bloc.add(const VerifyRegistration(otpCode: '123456')),
          expect: () => [
            const ProfileVerifying(
              profile: currentProfile,
              registrationResponse: registrationResponse,
              displayName: 'Test User',
              otpCode: '123456',
            ),
            const ProfileRegistrationCompleted(profile: verifiedProfile),
          ],
          verify: (_) {
            verify(mockProfileRepository.verifyRegistration(otpCode: '123456')).called(1);
          },
        );
      });

      group('SignOut', () {
        blocTest<ProfileBloc, ProfileState>(
          'should emit ProfileInitial when successful',
          build: () {
            when(mockProfileRepository.signOut())
                .thenAnswer((_) async {});
            return profileBloc;
          },
          act: (bloc) => bloc.add(const SignOut()),
          expect: () => [
            const ProfileInitial(),
          ],
          verify: (_) {
            verify(mockProfileRepository.signOut()).called(1);
          },
        );
      });

      group('ClearError', () {
        const mockProfile = UserProfile(
          userId: 123,
          displayName: 'Test User',
          email: 'test@example.com',
          emailVerified: true,
          isAnonymous: false,
          subscriptionTier: 'free',
          storiesRemaining: 2,
          deviceId: 'device-123',
        );

        blocTest<ProfileBloc, ProfileState>(
          'should emit ProfileLoaded when profile exists',
          build: () => profileBloc,
          seed: () => const ProfileError(
            message: 'Test error',
            profile: mockProfile,
          ),
          act: (bloc) => bloc.add(const ClearError()),
          expect: () => [
            const ProfileLoaded(profile: mockProfile),
          ],
        );

        blocTest<ProfileBloc, ProfileState>(
          'should emit ProfileInitial when no profile exists',
          build: () => profileBloc,
          seed: () => const ProfileError(message: 'Test error'),
          act: (bloc) => bloc.add(const ClearError()),
          expect: () => [
            const ProfileInitial(),
          ],
        );
      });
    });
  });
}