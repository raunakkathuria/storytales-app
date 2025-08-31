import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/otp_verification_form.dart';
import '../../domain/entities/registration_request.dart';

/// Dedicated page for email verification with OTP.
class VerifyEmailPage extends StatelessWidget {
  /// The registration response containing email info.
  final RegistrationResponse registrationResponse;

  /// The display name being registered.
  final String displayName;

  /// Creates a verify email page.
  const VerifyEmailPage({
    super.key,
    required this.registrationResponse,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveText(
          text: 'Verify Email',
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
          if (state is ProfileRegistrationCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Registration completed successfully! Welcome to StoryTales!'),
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
                    color: StoryTalesTheme.accentColor,
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
                          Icons.email_outlined,
                          color: StoryTalesTheme.accentColor,
                          size: 32,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const ResponsiveText(
                        text: '📧 Check Your Email',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyHeading,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: StoryTalesTheme.surfaceColor,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      ResponsiveText(
                        text: 'We\'ve sent a verification code to\n${registrationResponse.email}',
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
                
                // OTP Verification Form
                OtpVerificationForm(
                  registrationResponse: registrationResponse,
                  displayName: displayName,
                  onVerify: (otpCode) {
                    context.read<ProfileBloc>().add(
                      VerifyRegistration(otpCode: otpCode),
                    );
                  },
                  onCancel: () {
                    // Go back to profile page (cancels the entire registration flow)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  onRequestNewCode: () {
                    context.read<ProfileBloc>().add(const RequestNewRegistrationOTP());
                  },
                  isLoading: state is ProfileVerifying,
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
                        text: '💡 Helpful Tips',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyHeading,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: StoryTalesTheme.textColor,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      const ResponsiveText(
                        text: '• Check your spam/junk folder if you don\'t see the email\n• The verification code expires in 10 minutes\n• You can request a new code if needed',
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