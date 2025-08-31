import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';

/// Widget for displaying incomplete registration state.
class IncompleteRegistrationSection extends StatelessWidget {
  final String email;
  final String displayName;
  final VoidCallback onCompleteVerification;
  final VoidCallback onStartOver;

  const IncompleteRegistrationSection({
    super.key,
    required this.email,
    required this.displayName,
    required this.onCompleteVerification,
    required this.onStartOver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StoryTalesTheme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: StoryTalesTheme.accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with warning icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: StoryTalesTheme.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pending_actions,
                  color: StoryTalesTheme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: ResponsiveText(
                  text: 'Complete Your Registration',
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
          
          // Explanation text
          ResponsiveText(
            text: 'You started registering as "$displayName" with $email but didn\'t complete the email verification. You can continue where you left off or start over.',
            style: const TextStyle(
              fontFamily: StoryTalesTheme.fontFamilyBody,
              fontSize: 14,
              color: StoryTalesTheme.textColor,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Column(
            children: [
              // Complete verification button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onCompleteVerification,
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: const ResponsiveText(
                    text: 'Complete Email Verification',
                    style: TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryTalesTheme.primaryColor,
                    foregroundColor: StoryTalesTheme.surfaceColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Start over button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onStartOver,
                  icon: const Icon(Icons.refresh_outlined, size: 18),
                  label: const ResponsiveText(
                    text: 'Start Over',
                    style: TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: StoryTalesTheme.textColor,
                    side: const BorderSide(color: StoryTalesTheme.textLightColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}