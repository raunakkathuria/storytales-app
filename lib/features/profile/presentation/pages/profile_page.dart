import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_form.dart';
import '../widgets/registration_form.dart';
import '../widgets/otp_verification_form.dart';
import '../widgets/login_form.dart';
import '../widgets/login_otp_verification_form.dart';

/// Page for managing user profile and registration.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showRegistrationForm = false;
  bool _showLoginForm = false;

  @override
  void initState() {
    super.initState();
    // Load profile when page is initialized
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveText(
          text: 'Profile',
          style: TextStyle(
            color: StoryTalesTheme.textColor,
            fontFamily: StoryTalesTheme.fontFamilyHeading,
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 40,
        backgroundColor: StoryTalesTheme.surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: StoryTalesTheme.textColor,
        ),
      ),
      backgroundColor: StoryTalesTheme.backgroundColor,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          // Handle success and error states
          if (state is ProfileRegistrationCompleted) {
            _showSuccessSnackBar('🎉 Registration completed successfully! Welcome to StoryTales!');
            setState(() {
              _showRegistrationForm = false;
            });
          } else if (state is ProfileLoginCompleted) {
            _showSuccessSnackBar('🌟 Welcome back! You\'re now signed in to your account!');
            setState(() {
              _showLoginForm = false;
            });
          } else if (state is ProfileUpdated) {
            _showSuccessSnackBar('✨ Profile updated successfully!');
          } else if (state is ProfileError) {
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && state is! ProfileUpdating && state is! ProfileRegistering && state is! ProfileVerifying && state is! ProfileLoggingIn && state is! ProfileLoginVerifying) {
            return const _LoadingView();
          }

          if (state is ProfileError && state.profile == null) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<ProfileBloc>().add(const LoadProfile()),
              showRestartOption: state.message.contains('Please restart the app'),
            );
          }

          // Handle login states that don't have profiles
          if (state is ProfileLoginPending) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: LoginOtpVerificationForm(
                email: state.email,
                loginResponse: state.loginResponse,
                onVerify: (otpCode) {
                  context.read<ProfileBloc>().add(
                    VerifyLogin(
                      sessionId: state.loginResponse.sessionId ?? '',
                      otpCode: otpCode,
                    ),
                  );
                },
                onCancel: () {
                  setState(() {
                    _showLoginForm = false;
                  });
                },
                isLoading: state is ProfileLoginVerifying,
              ),
            );
          }

          // All other states should have a profile
          final profile = (state is ProfileLoaded) ? state.profile
              : (state is ProfileUpdating) ? state.profile
              : (state is ProfileUpdated) ? state.profile
              : (state is ProfileRegistering) ? state.profile
              : (state is ProfileRegistrationPending) ? state.profile
              : (state is ProfileVerifying) ? state.profile
              : (state is ProfileRegistrationCompleted) ? state.profile
              : (state is ProfileLoginCompleted) ? state.profile
              : (state is ProfileError) ? state.profile
              : null;

          if (profile == null) {
            return _ErrorView(
              message: 'Unable to load profile',
              onRetry: () => context.read<ProfileBloc>().add(const LoadProfile()),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(const RefreshProfile());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  ProfileHeader(
                    profile: profile,
                    onVerifyEmail: profile.needsEmailVerification 
                        ? () {
                            context.read<ProfileBloc>().add(const StartEmailVerification());
                          }
                        : null,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Main Content based on state
                  if (state is ProfileRegistrationPending)
                    OtpVerificationForm(
                      registrationResponse: state.registrationResponse,
                      displayName: state.displayName,
                      onVerify: (otpCode) {
                        context.read<ProfileBloc>().add(
                          VerifyRegistration(otpCode: otpCode),
                        );
                      },
                      onCancel: () {
                        context.read<ProfileBloc>().add(const CancelRegistration());
                      },
                      onRequestNewCode: () {
                        context.read<ProfileBloc>().add(const RequestNewRegistrationOTP());
                      },
                      isLoading: state is ProfileVerifying,
                    )
                  else if (_showLoginForm)
                    LoginForm(
                      onLogin: (email) {
                        context.read<ProfileBloc>().add(
                          LoginUser(email: email),
                        );
                      },
                      onCancel: () {
                        setState(() {
                          _showLoginForm = false;
                        });
                      },
                      isLoading: state is ProfileLoggingIn,
                    )
                  else if (_showRegistrationForm)
                    RegistrationForm(
                      profile: profile,
                      onRegister: (email, displayName) {
                        context.read<ProfileBloc>().add(
                          RegisterUser(email: email, displayName: displayName),
                        );
                      },
                      onCancel: () {
                        setState(() {
                          _showRegistrationForm = false;
                        });
                      },
                      isLoading: state is ProfileRegistering,
                    )
                  else ...[
                    // Profile Form - only show for registered users
                    if (profile.hasRegisteredAccount)
                      ProfileForm(
                        profile: profile,
                        onDisplayNameUpdate: (displayName) {
                          context.read<ProfileBloc>().add(
                            UpdateDisplayName(displayName: displayName),
                          );
                        },
                        isLoading: state is ProfileUpdating,
                      ),
                    
                    if (profile.hasRegisteredAccount)
                      const SizedBox(height: 24),
                    
                    // Anonymous User Actions - Show prominent registration and login options
                    if (profile.canRegister) ...[
                      _AnonymousUserSection(
                        onRegisterTapped: () {
                          setState(() {
                            _showRegistrationForm = true;
                          });
                        },
                        onLoginTapped: () {
                          setState(() {
                            _showLoginForm = true;
                          });
                        },
                      ),
                    ] else ...[
                      // Registered User Actions - Show sign out option
                      _RegisteredUserSection(
                        profile: profile,
                        onSignOutTapped: () => _showSignOutConfirmation(),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: StoryTalesTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: StoryTalesTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const ResponsiveText(
          text: '👋 Sign Out?',
          style: TextStyle(
            fontFamily: StoryTalesTheme.fontFamilyHeading,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const ResponsiveText(
          text: 'You\'ll be signed out and returned to an anonymous account. You can sign back in anytime with your email!',
          style: TextStyle(
            fontFamily: StoryTalesTheme.fontFamilyBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const ResponsiveText(
              text: 'Cancel',
              style: TextStyle(fontFamily: StoryTalesTheme.fontFamilyBody),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProfileBloc>().add(const SignOut());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StoryTalesTheme.primaryColor,
            ),
            child: const ResponsiveText(
              text: 'Sign Out',
              style: TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyBody,
                color: StoryTalesTheme.surfaceColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading view widget.
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              StoryTalesTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          ResponsiveText(
            text: 'Loading your profile...',
            style: TextStyle(
              fontFamily: StoryTalesTheme.fontFamilyBody,
              color: StoryTalesTheme.textLightColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error view widget.
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showRestartOption;

  const _ErrorView({
    required this.message,
    this.onRetry,
    this.showRestartOption = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: StoryTalesTheme.errorColor,
            ),
            const SizedBox(height: 16),
            ResponsiveText(
              text: message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyBody,
                fontSize: 16,
                color: StoryTalesTheme.textColor,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: StoryTalesTheme.primaryColor,
                ),
                child: const ResponsiveText(
                  text: 'Try Again',
                  style: TextStyle(
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                    color: StoryTalesTheme.surfaceColor,
                  ),
                ),
              ),
              
              if (showRestartOption) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    // Note: In a real app, you might want to provide a way to restart
                    // For now, we'll just show a message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please close and restart the app to fix this issue.'),
                        backgroundColor: StoryTalesTheme.errorColor,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: StoryTalesTheme.errorColor,
                    side: const BorderSide(color: StoryTalesTheme.errorColor),
                  ),
                  child: const ResponsiveText(
                    text: 'Restart Required',
                    style: TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Anonymous user section widget - shows both register and login options.
class _AnonymousUserSection extends StatelessWidget {
  final VoidCallback? onRegisterTapped;
  final VoidCallback? onLoginTapped;

  const _AnonymousUserSection({
    this.onRegisterTapped,
    this.onLoginTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StoryTalesTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: StoryTalesTheme.overlayDarkColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const ResponsiveText(
            text: '🎭 Secure Your Story Kingdom',
            style: TextStyle(
              fontFamily: StoryTalesTheme.fontFamilyHeading,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: StoryTalesTheme.textColor,
            ),
          ),
          const SizedBox(height: 12),
          const ResponsiveText(
            text: 'Save your stories forever and access them from any device!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: StoryTalesTheme.fontFamilyBody,
              fontSize: 14,
              color: StoryTalesTheme.textLightColor,
            ),
          ),
          const SizedBox(height: 24),
          
          // Register Button (Primary)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRegisterTapped,
              style: ElevatedButton.styleFrom(
                backgroundColor: StoryTalesTheme.accentColor,
                foregroundColor: StoryTalesTheme.surfaceColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_outlined, size: 20),
                  SizedBox(width: 8),
                  ResponsiveText(
                    text: 'Create Account',
                    style: TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Login Button (Secondary)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onLoginTapped,
              style: OutlinedButton.styleFrom(
                foregroundColor: StoryTalesTheme.primaryColor,
                side: const BorderSide(color: StoryTalesTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login_outlined, size: 18),
                  SizedBox(width: 8),
                  ResponsiveText(
                    text: 'Sign In to Existing Account',
                    style: TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Registered user section widget - shows sign out option.
class _RegisteredUserSection extends StatelessWidget {
  final dynamic profile;
  final VoidCallback? onSignOutTapped;

  const _RegisteredUserSection({
    required this.profile,
    this.onSignOutTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StoryTalesTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: StoryTalesTheme.overlayDarkColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const ResponsiveText(
            text: '✨ Account Secure',
            style: TextStyle(
              fontFamily: StoryTalesTheme.fontFamilyHeading,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: StoryTalesTheme.textColor,
            ),
          ),
          const SizedBox(height: 12),
          const ResponsiveText(
            text: 'Your stories are safely stored in your magical account!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: StoryTalesTheme.fontFamilyBody,
              fontSize: 14,
              color: StoryTalesTheme.textLightColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSignOutTapped,
              style: OutlinedButton.styleFrom(
                foregroundColor: StoryTalesTheme.textLightColor,
                side: const BorderSide(color: StoryTalesTheme.textLightColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_outlined, size: 18),
                  SizedBox(width: 8),
                  ResponsiveText(
                    text: 'Sign Out',
                    style: TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}