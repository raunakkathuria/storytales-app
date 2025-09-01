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
                
              ],
            ),
          );
        },
      ),
    );
  }
}