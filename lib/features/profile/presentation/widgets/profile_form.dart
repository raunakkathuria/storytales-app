import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../../domain/entities/user_profile.dart';

/// Form widget for editing user profile information.
class ProfileForm extends StatefulWidget {
  /// The user profile to edit.
  final UserProfile profile;

  /// Callback when display name is updated.
  final Function(String displayName)? onDisplayNameUpdate;

  /// Whether the form is in loading state.
  final bool isLoading;

  /// Creates a profile form widget.
  const ProfileForm({
    super.key,
    required this.profile,
    this.onDisplayNameUpdate,
    this.isLoading = false,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _displayNameController.text = widget.profile.displayName ?? '';
  }

  @override
  void dispose() {
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
            // Section Title
            const ResponsiveText(
              text: 'Profile Information',
              style: TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyHeading,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: StoryTalesTheme.textColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
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
                      return 'Please enter a display name';
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
            
            const SizedBox(height: 24),
            
            // Update Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : _onUpdateDisplayName,
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
                        text: 'Update Name',
                        style: TextStyle(
                          fontFamily: StoryTalesTheme.fontFamilyBody,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Account Status Info
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ResponsiveText(
                    text: 'Account Status',
                    style: TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: StoryTalesTheme.textLightColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ResponsiveText(
                    text: widget.profile.hasRegisteredAccount
                        ? 'Your account is registered and secure!'
                        : 'This is an anonymous account. Register to secure your stories!',
                    style: const TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontSize: 14,
                      color: StoryTalesTheme.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onUpdateDisplayName() {
    if (_formKey.currentState!.validate()) {
      final displayName = _displayNameController.text.trim();
      if (displayName != widget.profile.displayName) {
        widget.onDisplayNameUpdate?.call(displayName);
      }
    }
  }
}