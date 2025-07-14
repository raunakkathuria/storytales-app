import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_event.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_state.dart';

/// Utility class for handling deep links for authentication.
class DeepLinkHandler {
  /// The authentication BLoC.
  final AuthBloc authBloc;

  /// App Links instance for handling deep links
  final AppLinks _appLinks = AppLinks();

  /// Creates a new DeepLinkHandler instance.
  ///
  /// [authBloc] - The authentication BLoC to use.
  DeepLinkHandler({required this.authBloc});

  /// Initializes the deep link handler.
  ///
  /// This method should be called when the app starts.
  Future<void> initialize() async {
    // Handle links that opened the app
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleLink(initialLink.toString());
    }

    // Handle links that are received when the app is already running
    _appLinks.uriLinkStream.listen(
      (uri) {
        _handleLink(uri.toString());
      },
      onError: (error) {
        debugPrint('Deep link error: $error');
      },
    );
  }

  /// Handles a deep link.
  ///
  /// [link] - The deep link to handle.
  Future<void> _handleLink(String link) async {
    // Check if the link is a sign-in link
    authBloc.add(CheckSignInLink(link: link));

    // Listen for the result of the check
    late final StreamSubscription<AuthState> subscription;
    subscription = authBloc.stream.listen((state) async {
      if (state is SignInLinkCheckResult) {
        if (state.isSignInLink) {
          // Get the stored email
          authBloc.add(const GetStoredEmailEvent());
        }
      } else if (state is StoredEmailResult) {
        final email = state.email;
        if (email != null) {
          // Sign in with the email link
          authBloc.add(SignInWithLink(
            email: email,
            emailLink: link,
          ));
        } else {
          // If no email is stored, we can't complete the sign-in process
          debugPrint('No email stored for sign-in link');
        }
        // Cancel the subscription after handling the link
        subscription.cancel();
      }
    });
  }
}
