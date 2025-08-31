import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/registration_form.dart';
import '../../domain/entities/user_profile.dart';
import 'verify_email_page.dart';
import 'login_page.dart';

/// Dedicated page for user registration.
class RegisterPage extends StatelessWidget {
  /// The current user profile.
  final UserProfile profile;

  /// Creates a register page.
  const RegisterPage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveText(
          text: 'Create Account',
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
          if (state is ProfileRegistrationPending) {
            // Capture the ProfileBloc reference before navigation
            final profileBloc = context.read<ProfileBloc>();
            
            // Navigate directly to verification page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (newContext) => BlocProvider.value(
                  value: profileBloc,
                  child: VerifyEmailPage(
                    registrationResponse: state.registrationResponse,
                    displayName: state.displayName,
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
                          Icons.person_add_outlined,
                          color: StoryTalesTheme.accentColor,
                          size: 32,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const ResponsiveText(
                        text: '🎭 Join the Story Kingdom',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyHeading,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: StoryTalesTheme.surfaceColor,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const ResponsiveText(
                        text: 'Create your account to save stories forever and access them from any device!',
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
                
                // Registration Form
                RegistrationForm(
                  profile: profile,
                  onRegister: (email, displayName) {
                    context.read<ProfileBloc>().add(
                      RegisterUser(email: email, displayName: displayName),
                    );
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                  isLoading: state is ProfileRegistering,
                ),
                
                const SizedBox(height: 24),
                
                // Already have account section
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
                    children: [
                      const ResponsiveText(
                        text: 'Already have an account?',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyBody,
                          fontSize: 14,
                          color: StoryTalesTheme.textLightColor,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      OutlinedButton(
                        onPressed: () {
                          final profileBloc = context.read<ProfileBloc>();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (newContext) => BlocProvider.value(
                                value: profileBloc,
                                child: const LoginPage(),
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: StoryTalesTheme.primaryColor,
                          side: const BorderSide(color: StoryTalesTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const ResponsiveText(
                          text: 'Sign In Instead',
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
              ],
            ),
          );
        },
      ),
    );
  }
}