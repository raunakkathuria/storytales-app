import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/login_form.dart';
import 'login_verify_page.dart';
import 'register_page.dart';
import '../../domain/entities/user_profile.dart';

/// Dedicated page for user login.
class LoginPage extends StatelessWidget {
  /// Creates a login page.
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveText(
          text: 'Sign In',
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
          if (state is ProfileLoginPending) {
            // Navigate directly to login verification page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (newContext) => BlocProvider.value(
                  value: context.read<ProfileBloc>(),
                  child: LoginVerifyPage(
                    email: state.email,
                    loginResponse: state.loginResponse,
                  ),
                ),
              ),
            );
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
                          Icons.login_outlined,
                          color: StoryTalesTheme.primaryColor,
                          size: 32,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const ResponsiveText(
                        text: '🌟 Welcome Back',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyHeading,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: StoryTalesTheme.surfaceColor,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const ResponsiveText(
                        text: 'Sign in to access your saved stories and continue your magical journey!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyBody,
                          fontSize: 14,
                          color: StoryTalesTheme.overlayLightColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login Form
                LoginForm(
                  onLogin: (email) {
                    context.read<ProfileBloc>().add(
                      LoginUser(email: email),
                    );
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                  isLoading: state is ProfileLoggingIn,
                ),
                
                const SizedBox(height: 24),
                
                // Need an account section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: StoryTalesTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: StoryTalesTheme.accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const ResponsiveText(
                        text: 'Need an account?',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyBody,
                          fontSize: 14,
                          color: StoryTalesTheme.textLightColor,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (newContext) => BlocProvider.value(
                                value: context.read<ProfileBloc>(),
                                child: RegisterPage(
                                  // We need to get the profile from somewhere - let's use a simple anonymous profile
                                  profile: const UserProfile(
                                    userId: 0,
                                    emailVerified: false,
                                    isAnonymous: true,
                                    subscriptionTier: 'free',
                                    storiesRemaining: 2,
                                    deviceId: '',
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: StoryTalesTheme.accentColor,
                          side: const BorderSide(color: StoryTalesTheme.accentColor),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const ResponsiveText(
                          text: 'Create Account',
                          style: TextStyle(
                            fontFamily: StoryTalesTheme.fontFamilyBody,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                        text: '🔐 Sign In Help',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyHeading,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: StoryTalesTheme.textColor,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      const ResponsiveText(
                        text: '• Enter the email address you used to create your account\n• We\'ll send you a verification code to sign in\n• No password needed - just your email!',
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