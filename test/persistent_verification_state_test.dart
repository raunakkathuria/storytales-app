import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:storytales/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:storytales/features/profile/presentation/bloc/profile_event.dart';
import 'package:storytales/features/profile/presentation/bloc/profile_state.dart';
import 'package:storytales/features/profile/domain/entities/user_profile.dart';
import 'package:storytales/features/profile/domain/entities/registration_request.dart';
import 'package:storytales/core/services/auth/authentication_service.dart';

import 'profile_feature_test.mocks.dart';

// Create a mock for AuthenticationService
class MockAuthenticationService extends Mock implements AuthenticationService {}

void main() {
  group('Persistent Verification State Tests', () {
    late ProfileBloc profileBloc;
    late MockProfileRepository mockRepository;
    late MockLoggingService mockLoggingService;
    late MockAuthenticationService mockAuthService;

    setUp(() {
      mockRepository = MockProfileRepository();
      mockLoggingService = MockLoggingService();
      mockAuthService = MockAuthenticationService();
      profileBloc = ProfileBloc(
        profileRepository: mockRepository,
        loggingService: mockLoggingService,
      );
    });

    tearDown(() {
      profileBloc.close();
    });

    const testProfile = UserProfile(
      userId: 123,
      displayName: 'Test User',
      email: 'test@example.com',
      emailVerified: false,
      subscriptionTier: 'free',
      storiesRemaining: 2,
      isAnonymous: true,
      deviceId: 'test-device-123',
    );

    const testRegistrationResponse = RegistrationResponse(
      otpSent: true,
      email: 'test@example.com',
      verifyUrl: 'https://example.com/verify',
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit ProfileRegistrationIncomplete when loading profile with pending registration',
      build: () {
        when(mockRepository.getCurrentUserProfile())
            .thenAnswer((_) async => testProfile);
        
        return profileBloc;
      },
      act: (bloc) => bloc.add(const LoadProfile()),
      expect: () => [
        const ProfileLoading(),
        const ProfileRegistrationIncomplete(
          profile: testProfile,
          email: 'test@example.com',
          displayName: 'Test User',
          registrationResponse: testRegistrationResponse,
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'should resume registration verification from incomplete state',
      build: () => profileBloc,
      seed: () => const ProfileRegistrationIncomplete(
        profile: testProfile,
        email: 'test@example.com',
        displayName: 'Test User',
        registrationResponse: testRegistrationResponse,
      ),
      act: (bloc) => bloc.add(const ResumeRegistrationVerification()),
      expect: () => [
        const ProfileRegistrationPending(
          profile: testProfile,
          registrationResponse: testRegistrationResponse,
          displayName: 'Test User',
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit error when trying to resume from non-incomplete state',
      build: () => profileBloc,
      seed: () => const ProfileLoaded(profile: testProfile),
      act: (bloc) => bloc.add(const ResumeRegistrationVerification()),
      expect: () => [
        const ProfileError(
          message: 'No incomplete registration to resume',
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'should store pending registration data when registering user',
      build: () {
        when(mockRepository.getCurrentUserProfile())
            .thenAnswer((_) async => testProfile);
        when(mockRepository.registerUser(
          email: 'test@example.com',
          displayName: 'Test User',
        )).thenAnswer((_) async => testRegistrationResponse);
        
        return profileBloc;
      },
      seed: () => const ProfileLoaded(profile: testProfile),
      act: (bloc) => bloc.add(const RegisterUser(
        email: 'test@example.com',
        displayName: 'Test User',
      )),
      expect: () => [
        const ProfileRegistering(
          profile: testProfile,
          email: 'test@example.com',
          displayName: 'Test User',
        ),
        const ProfileRegistrationPending(
          profile: testProfile,
          registrationResponse: testRegistrationResponse,
          displayName: 'Test User',
        ),
      ],
      verify: (_) {
        verify(mockRepository.registerUser(
          email: 'test@example.com',
          displayName: 'Test User',
        )).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'should clear pending registration on successful verification',
      build: () {
        const verifiedProfile = UserProfile(
          userId: 123,
          displayName: 'Test User',
          email: 'test@example.com',
          emailVerified: true,
          subscriptionTier: 'free',
          storiesRemaining: 2,
          isAnonymous: false,
          deviceId: 'test-device-123',
        );
        
        when(mockRepository.verifyRegistration(otpCode: '123456'))
            .thenAnswer((_) async => verifiedProfile);
        
        return profileBloc;
      },
      seed: () => const ProfileRegistrationPending(
        profile: testProfile,
        registrationResponse: testRegistrationResponse,
        displayName: 'Test User',
      ),
      act: (bloc) => bloc.add(const VerifyRegistration(otpCode: '123456')),
      expect: () => [
        const ProfileVerifying(
          profile: testProfile,
          registrationResponse: testRegistrationResponse,
          displayName: 'Test User',
          otpCode: '123456',
        ),
        const ProfileRegistrationCompleted(
          profile: UserProfile(
            userId: 123,
            displayName: 'Test User',
            email: 'test@example.com',
            emailVerified: true,
            subscriptionTier: 'free',
            storiesRemaining: 2,
            isAnonymous: false,
            deviceId: 'test-device-123',
          ),
        ),
        const ProfileLoaded(
          profile: UserProfile(
            userId: 123,
            displayName: 'Test User',
            email: 'test@example.com',
            emailVerified: true,
            subscriptionTier: 'free',
            storiesRemaining: 2,
            isAnonymous: false,
            deviceId: 'test-device-123',
          ),
        ),
      ],
      wait: const Duration(seconds: 3), // Wait for auto-transition
    );
  });
}