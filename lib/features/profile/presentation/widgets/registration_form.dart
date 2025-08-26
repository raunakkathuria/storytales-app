import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../../domain/entities/user_profile.dart';

/// Form widget for user registration.
class RegistrationForm extends StatefulWidget {
  /// The current user profile.
  final UserProfile profile;

  /// Callback when registration is submitted.
  final Function(String email, String displayName)? onRegister;

  /// Callback when registration is cancelled.
  final VoidCallback? onCancel;

  /// Whether the form is in loading state.
  final bool isLoading;

  /// Creates a registration form widget.
  const RegistrationForm({
    super.key,
    required this.profile,
    this.onRegister,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _displayNameController.text = widget.profile.displayName ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
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
            // Header
            Row(
              children: [
                const Icon(
                  Icons.app_registration,
                  color: StoryTalesTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: ResponsiveText(
                    text: 'Register Your Account',
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
            
            const SizedBox(height: 8),
            
            const ResponsiveText(
              text: 'Secure your stories by creating an account. We\'ll send you a verification code!',
              style: TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyBody,
                fontSize: 14,
                color: StoryTalesTheme.textLightColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
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
            
            const SizedBox(height: 20),
            
            // Display Name Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ResponsiveText(
                  text: 'Display Name',
                  style: TextStyle(
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: StoryTalesTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _displayNameController,
                  enabled: !widget.isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: StoryTalesTheme.primaryColor,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your display name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters long';
                    }
                    if (value.trim().length > 30) {
                      return 'Name must be less than 30 characters';
                    }
                    return null;
                  },
                ),
              ],
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
                
                // Register Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: widget.isLoading ? null : _onRegister,
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
                            text: 'Register',
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

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final displayName = _displayNameController.text.trim();
      widget.onRegister?.call(email, displayName);
    }
  }
}