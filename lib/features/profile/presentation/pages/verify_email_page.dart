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
                // Clean Header Section - matching login/register design
                const Center(
                  child: ResponsiveText(
                    text: '📧 Check Your Email',
                    style: TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyHeading,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: StoryTalesTheme.textColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Center(
                  child: ResponsiveText(
                    text: 'Enter the verification code sent to ${registrationResponse.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontSize: 16,
                      color: StoryTalesTheme.textLightColor,
                    ),
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
              ],
            ),
          );
        },
      ),
    );
  }
}