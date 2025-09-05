import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:storytales/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:storytales/features/profile/presentation/bloc/profile_event.dart';
import 'package:storytales/features/profile/presentation/bloc/profile_state.dart';
import 'package:storytales/features/profile/domain/entities/user_profile.dart';
import 'package:storytales/features/profile/domain/entities/registration_request.dart';

import 'profile_feature_test.mocks.dart';

void main() {
  group('OTP Retry Functionality Tests', () {
    late ProfileBloc profileBloc;
    late MockProfileRepository mockRepository;
    late MockLoggingService mockLoggingService;

    setUp(() {
      mockRepository = MockProfileRepository();
      mockLoggingService = MockLoggingService();
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
      isAnonymous: false,
      deviceId: 'test-device-123',
    );

    const testRegistrationResponse = RegistrationResponse(
      otpSent: true,
      email: 'test@example.com',
      verifyUrl: 'https://example.com/verify',
    );

    blocTest<ProfileBloc, ProfileState>(
      'should handle RequestNewRegistrationOTP when in ProfileRegistrationPending state',
      build: () {
        when(mockRepository.registerUser(
          email: 'test@example.com',
          displayName: 'Test User',
        )).thenAnswer((_) async => testRegistrationResponse);
        
        return profileBloc;
      },
      seed: () => const ProfileRegistrationPending(
        profile: testProfile,
        registrationResponse: testRegistrationResponse,
        displayName: 'Test User',
      ),
      act: (bloc) => bloc.add(const RequestNewRegistrationOTP()),
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
      'should emit error when RequestNewRegistrationOTP fails',
      build: () {
        when(mockRepository.registerUser(
          email: 'test@example.com',
          displayName: 'Test User',
        )).thenThrow(Exception('Registration failed'));
        
        return profileBloc;
      },
      seed: () => const ProfileRegistrationPending(
        profile: testProfile,
        registrationResponse: testRegistrationResponse,
        displayName: 'Test User',
      ),
      act: (bloc) => bloc.add(const RequestNewRegistrationOTP()),
      wait: const Duration(milliseconds: 200), // Wait for async delay
      expect: () => [
        const ProfileRegistering(
          profile: testProfile,
          email: 'test@example.com',
          displayName: 'Test User',
        ),
        const ProfileRegistrationPending(
          profile: testProfile,
          registrationResponse: RegistrationResponse(
            otpSent: false,
            email: '',
            verifyUrl: '',
            sessionId: '',
          ),
          displayName: 'Test User',
        ),
        const ProfileError(
          message: 'Exception: Registration failed',
          profile: testProfile,
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit error when not in ProfileRegistrationPending state',
      build: () => profileBloc,
      seed: () => const ProfileLoaded(profile: testProfile),
      act: (bloc) => bloc.add(const RequestNewRegistrationOTP()),
      expect: () => [
        const ProfileError(
          message: 'No pending registration to retry',
        ),
      ],
    );
  });
}