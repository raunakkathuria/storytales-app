import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/login_otp_verification_form.dart';
import '../../domain/entities/registration_request.dart';

/// Dedicated page for login verification with OTP.
class LoginVerifyPage extends StatelessWidget {
  /// The login email.
  final String email;

  /// The login response containing verification details.
  final RegistrationResponse loginResponse;

  /// Creates a login verify page.
  const LoginVerifyPage({
    super.key,
    required this.email,
    required this.loginResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveText(
          text: 'Verify Sign In',
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
          if (state is ProfileLoginCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🌟 Welcome back! You\'re now signed in to your account!'),
                backgroundColor: StoryTalesTheme.successColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
            
            // Navigate back to profile page
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: StoryTalesTheme.errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: StoryTalesTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: StoryTalesTheme.surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          color: StoryTalesTheme.primaryColor,
                          size: 32,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const ResponsiveText(
                        text: '🔐 Verify Your Identity',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyHeading,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: StoryTalesTheme.surfaceColor,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      ResponsiveText(
                        text: 'We\'ve sent a verification code to\n$email',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyBody,
                          fontSize: 14,
                          color: StoryTalesTheme.overlayLightColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login OTP Verification Form
                LoginOtpVerificationForm(
                  email: email,
                  loginResponse: loginResponse,
                  onVerify: (otpCode) {
                    context.read<ProfileBloc>().add(
                      VerifyLogin(
                        sessionId: loginResponse.sessionId ?? '',
                        otpCode: otpCode,
                      ),
                    );
                  },
                  onCancel: () {
                    // Go back to profile page (cancels the entire login flow)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  isLoading: state is ProfileLoginVerifying,
                ),
                
                const SizedBox(height: 24),
                
                // Help Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: StoryTalesTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: StoryTalesTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ResponsiveText(
                        text: '💡 Verification Tips',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyHeading,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: StoryTalesTheme.textColor,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      const ResponsiveText(
                        text: '• Check your spam/junk folder if you don\'t see the email\n• The verification code expires in 10 minutes\n• Make sure you\'re using the email address from your account',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyBody,
                          fontSize: 14,
                          color: StoryTalesTheme.textLightColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}