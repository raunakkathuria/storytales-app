import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';

/// Form widget for user login with email input.
class LoginForm extends StatefulWidget {
  /// Callback when login is requested.
  final Function(String email)? onLogin;

  /// Callback when form is cancelled.
  final VoidCallback? onCancel;

  /// Whether the form is in loading state.
  final bool isLoading;

  /// Creates a login form widget.
  const LoginForm({
    super.key,
    this.onLogin,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
            // Title
            const ResponsiveText(
              text: '🌟 Welcome Back!',
              style: TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyHeading,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: StoryTalesTheme.textColor,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Subtitle
            const ResponsiveText(
              text: 'Sign in to your magical story account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyBody,
                fontSize: 16,
                color: StoryTalesTheme.textLightColor,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Email Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ResponsiveText(
                  text: 'Email Address',
                  style: TextStyle(
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: StoryTalesTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  enabled: !widget.isLoading,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: StoryTalesTheme.primaryColor,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : _onLoginPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: StoryTalesTheme.primaryColor,
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
                        text: 'Send Login Code',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyBody,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Cancel Button
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
                  text: 'Back',
                  style: TextStyle(
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: StoryTalesTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: StoryTalesTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: const ResponsiveText(
                text: '✉️ We\'ll send a verification code to your email address. Check your inbox and enter the code to access your story kingdom!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: StoryTalesTheme.fontFamilyBody,
                  fontSize: 14,
                  color: StoryTalesTheme.textLightColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      widget.onLogin?.call(email);
    }
  }
}