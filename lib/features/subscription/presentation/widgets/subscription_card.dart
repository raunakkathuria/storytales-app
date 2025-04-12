import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_icon.dart';
import 'package:storytales/core/widgets/responsive_text.dart';

/// A card widget that displays a subscription option.
class SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isRecommended;
  final bool isCurrentPlan;
  final VoidCallback? onSubscribe;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.isRecommended,
    this.isCurrentPlan = false,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isRecommended
            ? const BorderSide(
                color: StoryTalesTheme.accentColor,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          // Current Plan badge
          if (isCurrentPlan)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: StoryTalesTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: const ResponsiveText(
                  text: 'Current Plan',
                  style: TextStyle(
                    color: StoryTalesTheme.surfaceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                  ),
                ),
              ),
            ),

          // Recommended badge
          if (isRecommended)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: StoryTalesTheme.accentColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: const ResponsiveText(
                  text: 'Best Value',
                  style: TextStyle(
                    color: StoryTalesTheme.surfaceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                  ),
                ),
              ),
            ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                ResponsiveText(
                  text: title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: StoryTalesTheme.fontFamilyHeading,
                    color: StoryTalesTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    ResponsiveText(
                      text: price,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: StoryTalesTheme.fontFamilyHeading,
                        color: StoryTalesTheme.secondaryColor,
                      ),
                    ),

                    const SizedBox(width: 4),

                    ResponsiveText(
                      text: period,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: StoryTalesTheme.fontFamilyBody,
                        color: StoryTalesTheme.textLightColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Features
                ...features.map((feature) => _buildFeatureItem(feature)),

                const SizedBox(height: 24),

                // Subscribe button
                ElevatedButton(
                  onPressed: onSubscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRecommended
                        ? StoryTalesTheme.accentColor
                        : StoryTalesTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: ResponsiveText(
                    text: isCurrentPlan
                        ? 'Current Plan'
                        : (isRecommended ? 'Subscribe (Best Value)' : 'Subscribe'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveIcon(
            icon: Icons.check_circle,
            color: StoryTalesTheme.secondaryColor,
            sizeCategory: IconSizeCategory.small,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: ResponsiveText(
              text: feature,
              style: const TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyBody,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
