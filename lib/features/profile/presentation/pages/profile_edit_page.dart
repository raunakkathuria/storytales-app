import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_form.dart';
import '../../domain/entities/user_profile.dart';

/// Page for editing user profile information.
class ProfileEditPage extends StatelessWidget {
  /// The user profile to edit.
  final UserProfile profile;

  /// Creates a profile edit page.
  const ProfileEditPage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveText(
          text: 'Edit Profile',
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
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✨ Profile updated successfully!'),
                backgroundColor: StoryTalesTheme.successColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
            
            // Go back after successful update
            Navigator.of(context).pop();
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
                // Profile Header (View Only)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: StoryTalesTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: StoryTalesTheme.surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: StoryTalesTheme.primaryColor,
                          size: 32,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      ResponsiveText(
                        text: profile.displayName ?? 'User',
                        style: const TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyHeading,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: StoryTalesTheme.surfaceColor,
                        ),
                      ),
                      
                      if (profile.email != null) ...[
                        const SizedBox(height: 4),
                        ResponsiveText(
                          text: profile.email!,
                          style: const TextStyle(
                            fontFamily: StoryTalesTheme.fontFamilyBody,
                            fontSize: 14,
                            color: StoryTalesTheme.overlayLightColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Edit Form
                ProfileForm(
                  profile: profile,
                  onDisplayNameUpdate: (displayName) {
                    context.read<ProfileBloc>().add(
                      UpdateDisplayName(displayName: displayName),
                    );
                  },
                  isLoading: state is ProfileUpdating,
                ),
                
                const SizedBox(height: 24),
                
                // Account Actions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: StoryTalesTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: StoryTalesTheme.overlayDarkColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ResponsiveText(
                        text: 'Account Actions',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyHeading,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: StoryTalesTheme.textColor,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Sign Out Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _showSignOutConfirmation(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: StoryTalesTheme.textLightColor,
                            side: const BorderSide(color: StoryTalesTheme.textLightColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
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
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close edit page
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