import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../../domain/entities/registration_request.dart';

/// Form widget for OTP verification during registration.
class OtpVerificationForm extends StatefulWidget {
  /// The registration response containing email info.
  final RegistrationResponse registrationResponse;

  /// The display name being registered.
  final String displayName;

  /// Callback when OTP is submitted.
  final Function(String otpCode)? onVerify;

  /// Callback when verification is cancelled.
  final VoidCallback? onCancel;

  /// Whether the form is in loading state.
  final bool isLoading;

  /// Creates an OTP verification form widget.
  const OtpVerificationForm({
    super.key,
    required this.registrationResponse,
    required this.displayName,
    this.onVerify,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<OtpVerificationForm> createState() => _OtpVerificationFormState();
}

class _OtpVerificationFormState extends State<OtpVerificationForm> {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Success Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: StoryTalesTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read,
                    color: StoryTalesTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: ResponsiveText(
                    text: 'Check Your Email!',
                    style: TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyHeading,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: StoryTalesTheme.textColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            ResponsiveText(
              text: 'We\'ve sent a verification code to ${widget.registrationResponse.email}. Please check your email and enter the code below.',
              style: const TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyBody,
                fontSize: 14,
                color: StoryTalesTheme.textLightColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
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
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                  ),
                  decoration: const InputDecoration(
                    hintText: '123456',
                    prefixIcon: Icon(
                      Icons.security,
                      color: StoryTalesTheme.primaryColor,
                    ),
                    counterText: '',
                  ),
                  maxLength: 6,
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
            
            const SizedBox(height: 24),
            
            // Info Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: StoryTalesTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: StoryTalesTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ResponsiveText(
                    text: '✨ Almost there!',
                    style: TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: StoryTalesTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ResponsiveText(
                    text: 'Once verified, you\'ll be registered as "${widget.displayName}" and your stories will be secure!',
                    style: const TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontSize: 12,
                      color: StoryTalesTheme.textColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.isLoading ? null : widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StoryTalesTheme.textLightColor,
                      side: const BorderSide(color: StoryTalesTheme.textLightColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const ResponsiveText(
                      text: 'Cancel',
                      style: TextStyle(
                        fontFamily: StoryTalesTheme.fontFamilyBody,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Verify Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: widget.isLoading ? null : _onVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StoryTalesTheme.successColor,
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
                            text: 'Verify',
                            style: TextStyle(
                              fontFamily: StoryTalesTheme.fontFamilyBody,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onVerify() {
    if (_formKey.currentState!.validate()) {
      final otpCode = _otpController.text.trim();
      widget.onVerify?.call(otpCode);
    }
  }
}