import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/services/logging/logging_service.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/entities/registration_request.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC for managing profile state and operations.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final LoggingService _loggingService;

  /// Creates a profile BLoC.
  ProfileBloc({
    required ProfileRepository profileRepository,
    required LoggingService loggingService,
  })  : _profileRepository = profileRepository,
        _loggingService = loggingService,
        super(const ProfileInitial()) {
    // Register event handlers
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onRefreshProfile);
    on<UpdateDisplayName>(_onUpdateDisplayName);
    on<RegisterUser>(_onRegisterUser);
    on<VerifyRegistration>(_onVerifyRegistration);
    on<RequestNewRegistrationOTP>(_onRequestNewRegistrationOTP);
    on<LoginUser>(_onLoginUser);
    on<VerifyLogin>(_onVerifyLogin);
    on<SignOut>(_onSignOut);
    on<ClearError>(_onClearError);
    on<CancelRegistration>(_onCancelRegistration);
  }

  /// Handles loading the user profile.
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());
      _loggingService.info('Loading user profile...');

      final profile = await _profileRepository.getCurrentUserProfile();
      
      emit(ProfileLoaded(profile: profile));
      _loggingService.info('User profile loaded successfully');
    } catch (e) {
      _loggingService.error('Failed to load user profile: $e');
      
      // Determine error type and provide appropriate handling
      String friendlyMessage = e.toString();
      
      // Check if this is an initialization error
      if (friendlyMessage.contains('setting up your magical account')) {
        // This is expected during initialization, show loading state instead of error
        emit(const ProfileLoading());
        
        // Wait a bit and retry
        await Future.delayed(const Duration(seconds: 2));
        try {
          final profile = await _profileRepository.getCurrentUserProfile();
          emit(ProfileLoaded(profile: profile));
          _loggingService.info('User profile loaded successfully after retry');
          return;
        } catch (retryError) {
          friendlyMessage = retryError.toString();
        }
      }
      
      // Ensure all errors shown to users are Story Wizard friendly
      if (!friendlyMessage.contains('🌟') && !friendlyMessage.contains('🧙‍♂️') && !friendlyMessage.contains('⭐') && !friendlyMessage.contains('🔄')) {
        friendlyMessage = '🌟 Oh no! Our Story Wizard had trouble loading your profile. Please try again!';
      }
      
      emit(ProfileError(message: friendlyMessage));
    }
  }

  /// Handles refreshing the user profile from server.
  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final currentProfile = _getCurrentProfile();
      if (currentProfile != null) {
        emit(ProfileLoading());
      }

      _loggingService.info('Refreshing user profile from server...');
      
      final profile = await _profileRepository.refreshUserProfile();
      
      emit(ProfileLoaded(profile: profile));
      _loggingService.info('User profile refreshed successfully');
    } catch (e) {
      _loggingService.error('Failed to refresh user profile: $e');
      final currentProfile = _getCurrentProfile();
      emit(ProfileError(
        message: e.toString(),
        profile: currentProfile,
      ));
    }
  }

  /// Handles updating the display name.
  Future<void> _onUpdateDisplayName(
    UpdateDisplayName event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final currentProfile = _getCurrentProfile();
      if (currentProfile == null) {
        emit(const ProfileError(message: 'No profile loaded'));
        return;
      }

      emit(ProfileUpdating(profile: currentProfile));
      _loggingService.info('Updating display name...');

      final updatedProfile = await _profileRepository.updateDisplayName(
        event.displayName,
      );

      emit(ProfileUpdated(profile: updatedProfile));
      _loggingService.info('Display name updated successfully');

      // Auto-transition back to loaded state
      await Future.delayed(const Duration(seconds: 1));
      emit(ProfileLoaded(profile: updatedProfile));
    } catch (e) {
      _loggingService.error('Failed to update display name: $e');
      final currentProfile = _getCurrentProfile();
      emit(ProfileError(
        message: e.toString(),
        profile: currentProfile,
      ));
    }
  }

  /// Handles user registration.
  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final currentProfile = _getCurrentProfile();
      if (currentProfile == null) {
        emit(const ProfileError(message: 'No profile loaded'));
        return;
      }

      emit(ProfileRegistering(
        profile: currentProfile,
        email: event.email,
        displayName: event.displayName,
      ));
      
      _loggingService.info('Starting user registration...');

      final registrationResponse = await _profileRepository.registerUser(
        email: event.email,
        displayName: event.displayName,
      );

      emit(ProfileRegistrationPending(
        profile: currentProfile,
        registrationResponse: registrationResponse,
        displayName: event.displayName,
      ));
      
      _loggingService.info('User registration initiated, OTP sent');
    } catch (e) {
      _loggingService.error('Failed to register user: $e');
      final currentProfile = _getCurrentProfile();
      emit(ProfileError(
        message: e.toString(),
        profile: currentProfile,
      ));
    }
  }

  /// Handles registration verification.
  Future<void> _onVerifyRegistration(
    VerifyRegistration event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! ProfileRegistrationPending) {
        emit(const ProfileError(message: 'No pending registration to verify'));
        return;
      }

      emit(ProfileVerifying(
        profile: currentState.profile,
        registrationResponse: currentState.registrationResponse,
        displayName: currentState.displayName,
        otpCode: event.otpCode,
      ));
      
      _loggingService.info('Verifying registration with OTP...');

      final verifiedProfile = await _profileRepository.verifyRegistration(
        otpCode: event.otpCode,
      );

      emit(ProfileRegistrationCompleted(profile: verifiedProfile));
      _loggingService.info('User registration completed successfully');

      // Auto-transition to loaded state
      await Future.delayed(const Duration(seconds: 2));
      emit(ProfileLoaded(profile: verifiedProfile));
    } catch (e) {
      _loggingService.error('Failed to verify registration: $e');
      
      // Go back to registration pending state on error
      final currentState = state;
      if (currentState is ProfileVerifying) {
        emit(ProfileRegistrationPending(
          profile: currentState.profile,
          registrationResponse: currentState.registrationResponse,
          displayName: currentState.displayName,
        ));
      }
      
      // Show error temporarily
      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileError(
        message: e.toString(),
        profile: _getCurrentProfile(),
      ));
    }
  }

  /// Handles requesting a new registration OTP.
  Future<void> _onRequestNewRegistrationOTP(
    RequestNewRegistrationOTP event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! ProfileRegistrationPending) {
        emit(const ProfileError(message: 'No pending registration to retry'));
        return;
      }

      // Extract the original registration details
      final email = currentState.registrationResponse.email;
      final displayName = currentState.displayName;

      if (email.isEmpty || displayName.isEmpty) {
        emit(const ProfileError(message: 'Unable to retry registration - missing information'));
        return;
      }

      emit(ProfileRegistering(
        profile: currentState.profile,
        email: email,
        displayName: displayName,
      ));
      _loggingService.info('Requesting new registration OTP for: ${email.substring(0, 3)}***');

      // Re-register to get a new OTP
      final registrationResponse = await _profileRepository.registerUser(
        email: email,
        displayName: displayName,
      );

      emit(ProfileRegistrationPending(
        profile: currentState.profile,
        registrationResponse: registrationResponse,
        displayName: displayName,
      ));
      
      _loggingService.info('New registration OTP requested successfully');
    } catch (e) {
      _loggingService.error('Failed to request new registration OTP: $e');
      
      // Return to previous pending state if possible
      final currentState = state;
      if (currentState is ProfileRegistering) {
        emit(ProfileRegistrationPending(
          profile: currentState.profile,
          registrationResponse: const RegistrationResponse(
            otpSent: false,
            email: '',
            verifyUrl: '',
            sessionId: '',
          ),
          displayName: currentState.displayName,
        ));
      }
      
      // Show error temporarily
      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileError(
        message: e.toString(),
        profile: _getCurrentProfile(),
      ));
    }
  }

  /// Handles user login.
  Future<void> _onLoginUser(
    LoginUser event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoggingIn(email: event.email));
      _loggingService.info('Starting user login...');

      final loginResponse = await _profileRepository.loginUser(
        email: event.email,
      );

      emit(ProfileLoginPending(
        email: event.email,
        loginResponse: loginResponse,
      ));
      
      _loggingService.info('User login initiated, OTP sent');
    } catch (e) {
      _loggingService.error('Failed to login user: $e');
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles login verification.
  Future<void> _onVerifyLogin(
    VerifyLogin event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! ProfileLoginPending) {
        emit(const ProfileError(message: 'No pending login to verify'));
        return;
      }

      emit(ProfileLoginVerifying(
        email: currentState.email,
        loginResponse: currentState.loginResponse,
        otpCode: event.otpCode,
      ));
      
      _loggingService.info('Verifying login with OTP...');

      final loggedInProfile = await _profileRepository.verifyLogin(
        sessionId: event.sessionId,
        otpCode: event.otpCode,
      );

      emit(ProfileLoginCompleted(profile: loggedInProfile));
      _loggingService.info('User login completed successfully');

      // Auto-transition to loaded state
      await Future.delayed(const Duration(seconds: 2));
      emit(ProfileLoaded(profile: loggedInProfile));
    } catch (e) {
      _loggingService.error('Failed to verify login: $e');
      
      // Go back to login pending state on error
      final currentState = state;
      if (currentState is ProfileLoginVerifying) {
        emit(ProfileLoginPending(
          email: currentState.email,
          loginResponse: currentState.loginResponse,
        ));
      }
      
      // Show error temporarily
      await Future.delayed(const Duration(milliseconds: 100));
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles user sign out.
  Future<void> _onSignOut(
    SignOut event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      _loggingService.info('Signing out user...');
      
      await _profileRepository.signOut();
      
      emit(const ProfileInitial());
      _loggingService.info('User signed out successfully');
    } catch (e) {
      _loggingService.error('Failed to sign out user: $e');
      emit(ProfileError(message: e.toString()));
    }
  }

  /// Handles clearing error state.
  void _onClearError(
    ClearError event,
    Emitter<ProfileState> emit,
  ) {
    final currentProfile = _getCurrentProfile();
    if (currentProfile != null) {
      emit(ProfileLoaded(profile: currentProfile));
    } else {
      emit(const ProfileInitial());
    }
  }

  /// Handles canceling registration process.
  void _onCancelRegistration(
    CancelRegistration event,
    Emitter<ProfileState> emit,
  ) {
    final currentProfile = _getCurrentProfile();
    if (currentProfile != null) {
      emit(ProfileLoaded(profile: currentProfile));
      _loggingService.info('Registration process cancelled');
    } else {
      emit(const ProfileInitial());
    }
  }

  /// Gets the current user profile from the state.
  UserProfile? _getCurrentProfile() {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      return currentState.profile;
    } else if (currentState is ProfileUpdating) {
      return currentState.profile;
    } else if (currentState is ProfileUpdated) {
      return currentState.profile;
    } else if (currentState is ProfileRegistering) {
      return currentState.profile;
    } else if (currentState is ProfileRegistrationPending) {
      return currentState.profile;
    } else if (currentState is ProfileVerifying) {
      return currentState.profile;
    } else if (currentState is ProfileRegistrationCompleted) {
      return currentState.profile;
    } else if (currentState is ProfileLoginCompleted) {
      return currentState.profile;
    } else if (currentState is ProfileError) {
      return currentState.profile;
    }
    return null;
  }
}