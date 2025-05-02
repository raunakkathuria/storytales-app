import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_event.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_state.dart';
import 'package:storytales/features/authentication/presentation/pages/profile_page.dart';
import 'package:storytales/features/authentication/presentation/utils/deep_link_handler.dart';

/// A widget that wraps the app and handles authentication state.
///
/// This widget listens to the authentication state and shows the appropriate
/// screen based on the state.
class AuthWrapper extends StatefulWidget {
  /// The child widget to show when the user is authenticated.
  final Widget child;

  /// Creates a new AuthWrapper instance.
  ///
  /// [child] - The child widget to show when the user is authenticated.
  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late DeepLinkHandler _deepLinkHandler;

  @override
  void initState() {
    super.initState();
    // Initialize the deep link handler
    _deepLinkHandler = DeepLinkHandler(
      authBloc: context.read<AuthBloc>(),
    );
    _deepLinkHandler.initialize();

    // Check the authentication status when the widget is initialized
    context.read<AuthBloc>().add(const CheckAuthStatus());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          // Show a loading indicator while checking the authentication status
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          // Always show the main content, regardless of authentication status
          return widget.child;
        }
      },
    );
  }
}

/// A widget that shows the profile settings page or sign-in page when tapped.
///
/// This widget can be used in the app to navigate to the profile settings page
/// or sign-in page depending on the authentication state.
class ProfileButton extends StatelessWidget {
  /// Creates a new ProfileButton instance.
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.account_circle,
        color: StoryTalesTheme.accentColor, // Use accent color to match subscription button
        size: 28, // Keep the larger size for better visibility
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProfilePage(),
          ),
        );
      },
      tooltip: 'Profile',
    );
  }
}
