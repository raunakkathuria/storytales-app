import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import 'package:storytales/core/widgets/responsive_icon.dart';
import '../../domain/entities/user_profile.dart';

/// Header widget displaying user profile information.
class ProfileHeader extends StatelessWidget {
  /// The user profile to display.
  final UserProfile profile;

  /// Callback when user taps on "Verify Email" badge.
  final VoidCallback? onVerifyEmail;

  /// Callback when user taps on edit icon.
  final VoidCallback? onEditProfile;

  /// Creates a profile header widget.
  const ProfileHeader({
    super.key,
    required this.profile,
    this.onVerifyEmail,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StoryTalesTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: StoryTalesTheme.surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: StoryTalesTheme.overlayDarkColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ResponsiveIcon(
              icon: profile.hasRegisteredAccount ? Icons.person : Icons.person_outline,
              sizeCategory: IconSizeCategory.large,
              color: StoryTalesTheme.primaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Display Name with Edit Icon for registered users
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: ResponsiveText(
                  text: profile.hasRegisteredAccount 
                      ? (profile.displayName ?? 'User')
                      : 'Anonymous User',
                  style: const TextStyle(
                    fontFamily: StoryTalesTheme.fontFamilyHeading,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: StoryTalesTheme.surfaceColor,
                  ),
                ),
              ),
              if (profile.hasRegisteredAccount) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onEditProfile,
                  child: ResponsiveIcon(
                    icon: Icons.edit,
                    sizeCategory: IconSizeCategory.small,
                    color: StoryTalesTheme.surfaceColor,
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Email for registered users only
          if (profile.hasRegisteredAccount && profile.email != null)
            ResponsiveText(
              text: profile.email!,
              style: const TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyBody,
                fontSize: 16,
                color: StoryTalesTheme.overlayLightColor,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Account Status Badge (tappable for email verification)
          GestureDetector(
            onTap: profile.needsEmailVerification && onVerifyEmail != null 
                ? onVerifyEmail 
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusBadgeColor(profile),
                borderRadius: BorderRadius.circular(20),
                // Add subtle shadow when tappable
                boxShadow: profile.needsEmailVerification && onVerifyEmail != null
                    ? [
                        BoxShadow(
                          color: StoryTalesTheme.overlayDarkColor.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ResponsiveIcon(
                    icon: _getStatusBadgeIcon(profile),
                    sizeCategory: IconSizeCategory.small,
                    color: StoryTalesTheme.surfaceColor,
                  ),
                  const SizedBox(width: 8),
                  ResponsiveText(
                    text: _getStatusBadgeText(profile),
                    style: const TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: StoryTalesTheme.surfaceColor,
                    ),
                  ),
                  // Add arrow icon for tappable verify email badge
                  if (profile.needsEmailVerification && onVerifyEmail != null) ...[
                    const SizedBox(width: 4),
                    ResponsiveIcon(
                      icon: Icons.arrow_forward_ios,
                      sizeCategory: IconSizeCategory.small,
                      color: StoryTalesTheme.surfaceColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gets the appropriate color for the status badge based on user's verification state.
  Color _getStatusBadgeColor(UserProfile profile) {
    if (profile.isFullyVerified) {
      return StoryTalesTheme.successColor; // Green for verified
    } else if (profile.needsEmailVerification) {
      return StoryTalesTheme.accentColor; // Orange for needs verification
    } else {
      return StoryTalesTheme.primaryColor; // Sky blue for anonymous
    }
  }

  /// Gets the appropriate icon for the status badge based on user's verification state.
  IconData _getStatusBadgeIcon(UserProfile profile) {
    if (profile.isFullyVerified) {
      return Icons.verified_user; // Verified icon for verified users
    } else if (profile.needsEmailVerification) {
      return Icons.email_outlined; // Email icon for needs verification
    } else {
      return Icons.info_outline; // Info icon for anonymous
    }
  }

  /// Gets the appropriate text for the status badge based on user's verification state.
  String _getStatusBadgeText(UserProfile profile) {
    if (profile.isFullyVerified) {
      return 'Verified Account';
    } else if (profile.needsEmailVerification) {
      return 'Verify Email';
    } else {
      return 'Anonymous Account';
    }
  }
}