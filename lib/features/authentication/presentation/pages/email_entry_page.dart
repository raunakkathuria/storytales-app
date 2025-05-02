import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_event.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_state.dart';
import 'package:storytales/features/authentication/presentation/pages/otp_verification_page.dart';
import 'package:storytales/features/authentication/presentation/widgets/error_message.dart';

/// A screen where users can enter their email address to receive a sign-in link.
class EmailEntryPage extends StatefulWidget {
  /// Creates a new EmailEntryPage instance.
  const EmailEntryPage({super.key});

  @override
  State<EmailEntryPage> createState() => _EmailEntryPageState();
}

class _EmailEntryPageState extends State<EmailEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      context.read<AuthBloc>().add(SendOtp(
            email: email,
          ));
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }

    // Simple email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        // Add a back button to allow users to return to the app without signing in
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          setState(() {
            if (state is AuthLoading) {
              _isLoading = true;
              _errorMessage = null;
            } else {
              _isLoading = false;
            }

            if (state is AuthError) {
              _errorMessage = state.message;
            }
          });

          if (state is OtpSent) {
            // Navigate to OTP verification page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OtpVerificationPage(
                  email: state.email,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Enter your email address to sign in',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'We\'ll send you a one-time password (OTP) to your email address. '
                    'No permanent password required!',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter your email address',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    enabled: !_isLoading,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    ErrorMessage(message: _errorMessage!),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StoryTalesTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Send OTP Code'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
