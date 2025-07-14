import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/features/authentication/domain/usecases/get_current_user.dart';
import 'package:storytales/features/authentication/domain/usecases/get_stored_email.dart';
import 'package:storytales/features/authentication/domain/usecases/is_authenticated.dart';
import 'package:storytales/features/authentication/domain/usecases/is_sign_in_link.dart';
import 'package:storytales/features/authentication/domain/usecases/send_otp_to_email.dart';
import 'package:storytales/features/authentication/domain/usecases/send_sign_in_link_to_email.dart';
import 'package:storytales/features/authentication/domain/usecases/sign_in_with_email_link.dart';
import 'package:storytales/features/authentication/domain/usecases/sign_out.dart';
import 'package:storytales/features/authentication/domain/usecases/update_user_profile.dart';
import 'package:storytales/features/authentication/domain/usecases/verify_otp.dart' as usecase;
import 'package:storytales/features/authentication/domain/usecases/usecase.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_event.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_state.dart';

/// BLoC for handling authentication-related events and states.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Use case for getting the current user.
  final GetCurrentUser _getCurrentUser;

  /// Use case for checking if the user is authenticated.
  final IsAuthenticated _isAuthenticated;

  /// Use case for sending a sign-in link to an email address.
  final SendSignInLinkToEmail _sendSignInLinkToEmail;

  /// Use case for signing in with an email link.
  final SignInWithEmailLink _signInWithEmailLink;

  /// Use case for signing out.
  final SignOut _signOut;

  /// Use case for updating the user profile.
  final UpdateUserProfile _updateUserProfile;

  /// Use case for checking if a link is a sign-in link.
  final IsSignInLink _isSignInLink;

  /// Use case for getting the stored email address.
  final GetStoredEmail _getStoredEmail;

  /// Use case for sending a one-time password (OTP) to an email address.
  final SendOtpToEmail _sendOtpToEmail;

  /// Use case for verifying a one-time password (OTP).
  final usecase.VerifyOtp _verifyOtp;

  /// Creates a new AuthBloc instance.
  ///
  /// [getCurrentUser] - The use case for getting the current user.
  /// [isAuthenticated] - The use case for checking if the user is authenticated.
  /// [sendSignInLinkToEmail] - The use case for sending a sign-in link to an email address.
  /// [signInWithEmailLink] - The use case for signing in with an email link.
  /// [signOut] - The use case for signing out.
  /// [updateUserProfile] - The use case for updating the user profile.
  /// [isSignInLink] - The use case for checking if a link is a sign-in link.
  /// [getStoredEmail] - The use case for getting the stored email address.
  /// [sendOtpToEmail] - The use case for sending a one-time password (OTP) to an email address.
  /// [verifyOtp] - The use case for verifying a one-time password (OTP).
  AuthBloc({
    required GetCurrentUser getCurrentUser,
    required IsAuthenticated isAuthenticated,
    required SendSignInLinkToEmail sendSignInLinkToEmail,
    required SignInWithEmailLink signInWithEmailLink,
    required SignOut signOut,
    required UpdateUserProfile updateUserProfile,
    required IsSignInLink isSignInLink,
    required GetStoredEmail getStoredEmail,
    required SendOtpToEmail sendOtpToEmail,
    required usecase.VerifyOtp verifyOtp,
  })  : _getCurrentUser = getCurrentUser,
        _isAuthenticated = isAuthenticated,
        _sendSignInLinkToEmail = sendSignInLinkToEmail,
        _signInWithEmailLink = signInWithEmailLink,
        _signOut = signOut,
        _updateUserProfile = updateUserProfile,
        _isSignInLink = isSignInLink,
        _getStoredEmail = getStoredEmail,
        _sendOtpToEmail = sendOtpToEmail,
        _verifyOtp = verifyOtp,
        super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SendSignInLink>(_onSendSignInLink);
    on<SignInWithLink>(_onSignInWithLink);
    on<SignOutUser>(_onSignOutUser);
    on<UpdateProfile>(_onUpdateProfile);
    on<CheckSignInLink>(_onCheckSignInLink);
    on<GetStoredEmailEvent>(_onGetStoredEmail);
    on<SendOtp>(_onSendOtp);
    on<VerifyOtp>(_onVerifyOtp);
  }

  /// Handles the [CheckAuthStatus] event.
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final isAuth = await _isAuthenticated(const NoParams());
      if (isAuth) {
        final user = await _getCurrentUser(const NoParams());
        if (user != null) {
          emit(Authenticated(userProfile: user));
        } else {
          emit(const Unauthenticated());
        }
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles the [SendSignInLink] event.
  Future<void> _onSendSignInLink(
    SendSignInLink event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final params = SendSignInLinkParams(
        email: event.email,
        continueUrl: event.continueUrl,
      );
      final result = await _sendSignInLinkToEmail(params);
      if (result) {
        emit(SignInLinkSent(email: event.email));
      } else {
        emit(const AuthError(message: 'Failed to send sign-in link'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles the [SignInWithLink] event.
  Future<void> _onSignInWithLink(
    SignInWithLink event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final params = SignInWithEmailLinkParams(
        email: event.email,
        emailLink: event.emailLink,
      );
      final user = await _signInWithEmailLink(params);
      emit(Authenticated(userProfile: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles the [SignOutUser] event.
  Future<void> _onSignOutUser(
    SignOutUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _signOut(const NoParams());
      if (result) {
        emit(const Unauthenticated());
      } else {
        emit(const AuthError(message: 'Failed to sign out'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles the [UpdateProfile] event.
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final params = UpdateUserProfileParams(
        userProfile: event.userProfile,
      );
      final updatedUser = await _updateUserProfile(params);
      // Only emit ProfileUpdateSuccess which contains the updated user profile
      // This will be handled by the ProfileSettingsPage to show a success message
      emit(ProfileUpdateSuccess(userProfile: updatedUser));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles the [CheckSignInLink] event.
  Future<void> _onCheckSignInLink(
    CheckSignInLink event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final params = IsSignInLinkParams(
        link: event.link,
      );
      final isSignInLink = await _isSignInLink(params);
      emit(SignInLinkCheckResult(
        isSignInLink: isSignInLink,
        link: event.link,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles the [GetStoredEmailEvent] event.
  Future<void> _onGetStoredEmail(
    GetStoredEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final email = await _getStoredEmail(const NoParams());
      emit(StoredEmailResult(email: email));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles the [SendOtp] event.
  Future<void> _onSendOtp(
    SendOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final params = SendOtpParams(
        email: event.email,
      );
      final result = await _sendOtpToEmail(params);
      if (result) {
        emit(OtpSent(email: event.email));
      } else {
        emit(const AuthError(message: 'Failed to send OTP'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles the [VerifyOtp] event.
  Future<void> _onVerifyOtp(
    VerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final params = usecase.VerifyOtpParams(
        email: event.email,
        otp: event.otp,
      );
      final user = await _verifyOtp(params);
      emit(Authenticated(userProfile: user));
    } catch (e) {
      emit(OtpVerificationFailed(message: e.toString()));
    }
  }
}
