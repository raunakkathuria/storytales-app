import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import 'package:storytales/core/widgets/responsive_icon.dart';
import '../../domain/entities/user_profile.dart';

/// Header widget displaying user profile information.
class ProfileHeader extends StatelessWidget {
  /// The user profile to display.
  final UserProfile profile;

  /// Creates a profile header widget.
  const ProfileHeader({
    super.key,
    required this.profile,
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
                ResponsiveIcon(
                  icon: Icons.edit,
                  sizeCategory: IconSizeCategory.small,
                  color: StoryTalesTheme.surfaceColor,
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
          
          // Account Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: profile.hasRegisteredAccount 
                  ? StoryTalesTheme.successColor
                  : StoryTalesTheme.accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ResponsiveIcon(
                  icon: profile.hasRegisteredAccount 
                      ? Icons.verified_user 
                      : Icons.info_outline,
                  sizeCategory: IconSizeCategory.small,
                  color: StoryTalesTheme.surfaceColor,
                ),
                const SizedBox(width: 8),
                ResponsiveText(
                  text: profile.hasRegisteredAccount 
                      ? 'Registered Account'
                      : 'Anonymous Account',
                  style: const TextStyle(
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: StoryTalesTheme.surfaceColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}