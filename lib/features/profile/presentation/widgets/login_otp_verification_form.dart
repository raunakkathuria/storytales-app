import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../../domain/entities/registration_request.dart';

/// Form widget for verifying login OTP.
class LoginOtpVerificationForm extends StatefulWidget {
  /// The login email.
  final String email;

  /// The login response containing verification details.
  final RegistrationResponse loginResponse;

  /// Callback when OTP verification is requested.
  final Function(String otpCode)? onVerify;

  /// Callback when form is cancelled.
  final VoidCallback? onCancel;

  /// Whether the form is in loading state.
  final bool isLoading;

  /// Creates a login OTP verification form widget.
  const LoginOtpVerificationForm({
    super.key,
    required this.email,
    required this.loginResponse,
    this.onVerify,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<LoginOtpVerificationForm> createState() => _LoginOtpVerificationFormState();
}

class _LoginOtpVerificationFormState extends State<LoginOtpVerificationForm> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StoryTalesTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: StoryTalesTheme.overlayDarkColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email Display
            ResponsiveText(
              text: 'Please check your email for the verification code',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyBody,
                fontSize: 16,
                color: StoryTalesTheme.textLightColor,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // OTP Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ResponsiveText(
                  text: 'Verification Code',
                  style: TextStyle(
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: StoryTalesTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _otpController,
                  enabled: !widget.isLoading,
                  keyboardType: TextInputType.number,
                  autocorrect: false,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter 6-digit code',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: StoryTalesTheme.primaryColor,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the verification code';
                    }
                    if (value.trim().length != 6) {
                      return 'Verification code must be 6 digits';
                    }
                    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
                      return 'Verification code must contain only numbers';
                    }
                    return null;
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : _onVerifyPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: StoryTalesTheme.accentColor,
                  foregroundColor: StoryTalesTheme.surfaceColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            StoryTalesTheme.surfaceColor,
                          ),
                        ),
                      )
                    : const ResponsiveText(
                        text: 'Verify & Sign In',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyBody,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Back Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.isLoading ? null : widget.onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: StoryTalesTheme.textLightColor,
                  side: const BorderSide(color: StoryTalesTheme.textLightColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const ResponsiveText(
                  text: 'Back to Login',
                  style: TextStyle(
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Concise help text
            const ResponsiveText(
              text: 'Code expires in 10 minutes • Check your spam folder',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyBody,
                fontSize: 13,
                color: StoryTalesTheme.textLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onVerifyPressed() {
    if (_formKey.currentState!.validate()) {
      final otpCode = _otpController.text.trim();
      widget.onVerify?.call(otpCode);
    }
  }
}