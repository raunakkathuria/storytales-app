import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_event.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_state.dart';
import 'package:storytales/features/authentication/presentation/widgets/error_message.dart';

/// A screen where users can enter the OTP code they received via email.
class OtpVerificationPage extends StatefulWidget {
  /// The email address the OTP was sent to.
  final String email;

  /// Creates a new OtpVerificationPage instance.
  ///
  /// [email] - The email address the OTP was sent to.
  const OtpVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      final otp = _otpController.text.trim();
      context.read<AuthBloc>().add(VerifyOtp(
            email: widget.email,
            otp: otp,
          ));
    }
  }

  String? _validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP code';
    }

    // Simple OTP validation (6 digits)
    if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Please enter a valid 6-digit OTP code';
    }

    return null;
  }

  void _resendOtp() {
    context.read<AuthBloc>().add(SendOtp(
          email: widget.email,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }

          setState(() {
            // Clear error message when loading or authenticated
            if (state is AuthLoading || state is Authenticated) {
              _errorMessage = null;
            }

            // Set error message for error states
            if (state is OtpVerificationFailed) {
              _errorMessage = state.message;
            } else if (state is AuthError) {
              _errorMessage = state.message;
            }
          });

          if (state is Authenticated) {
            // Navigate back to the profile page or main app
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // Pop twice to go back to the main app
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully signed in'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is OtpSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP code resent successfully'),
                backgroundColor: Colors.green,
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
                    'Enter the OTP code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We\'ve sent a 6-digit OTP code to ${widget.email}. '
                    'Please enter it below to verify your email address.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: 'OTP Code',
                      hintText: 'Enter the 6-digit OTP code',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: _validateOtp,
                    enabled: !_isLoading,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    ErrorMessage(message: _errorMessage!),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StoryTalesTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Verify OTP'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading ? null : _resendOtp,
                    child: const Text('Resend OTP'),
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
