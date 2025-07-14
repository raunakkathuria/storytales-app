import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_state.dart';
import 'package:storytales/features/authentication/presentation/pages/email_entry_page.dart';
import 'package:storytales/features/authentication/presentation/pages/profile_settings_page.dart';

/// A page that shows either the profile settings or sign-in options
/// depending on the authentication state.
class ProfilePage extends StatelessWidget {
  /// Creates a new ProfilePage instance.
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          // Show loading indicator while checking auth state
          return Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is Authenticated || state is ProfileUpdateSuccess) {
          // Show profile settings for authenticated users or when profile is updated
          final userProfile = state is Authenticated
              ? state.userProfile
              : (state as ProfileUpdateSuccess).userProfile;

          return ProfileSettingsPage(
            userProfile: userProfile,
          );
        } else {
          // Show sign-in options for unauthenticated users
          return _buildUnauthenticatedView(context);
        }
      },
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.account_circle,
              size: 80,
              color: StoryTalesTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Sign in to access your profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign in to sync your stories across devices and access premium features.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EmailEntryPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: StoryTalesTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue Without Signing In'),
            ),
          ],
        ),
      ),
    );
  }
}
