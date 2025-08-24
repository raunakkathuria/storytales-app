import 'package:flutter/material.dart';
import 'package:storytales/core/services/image/image_service.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import 'package:storytales/features/library/domain/entities/story.dart';

/// A card widget that displays a story in the library.
class StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const StoryCard({
    super.key,
    required this.story,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            _buildBackgroundImage(),

            // Gradient overlay for better text readability
            _buildGradientOverlay(),

            // Action buttons (favorite, delete)
            _buildActionButtons(),

            // Story info (title, reading time)
            _buildStoryInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return ImageService().getImage(
      imageUrl: story.coverImagePath,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: StoryTalesTheme.primaryColor.withValues(alpha: 0.1),
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: StoryTalesTheme.primaryColor.withValues(alpha: 0.3),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: StoryTalesTheme.accentColor,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: .7), // Darker overlay for better text contrast
          ],
          stops: const [0.5, 1.0], // Start gradient earlier for smoother transition
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      top: 8,
      right: 8,
      child: _buildIconButton(
        icon: story.isFavorite ? Icons.favorite : Icons.favorite_border,
        color: story.isFavorite ? StoryTalesTheme.errorColor : StoryTalesTheme.surfaceColor,
        onTap: onFavoriteToggle,
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent, // Keep transparent for material effect
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildStoryInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            ResponsiveText(
              text: story.title,
              style: const TextStyle(
                color: StoryTalesTheme.surfaceColor,
                fontSize: 18, // Increased from 16 to 18
                fontWeight: FontWeight.w800, // Extra bold for better visibility, consistent with tabs
                fontFamily: StoryTalesTheme.fontFamilyHeading,
                letterSpacing: 0.2, // Slight letter spacing for better readability
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Reading time
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.white, // Changed from overlayLightColor to pure white for better visibility
                  size: 14,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                ResponsiveText(
                  text: story.readingTime,
                  style: const TextStyle(
                    color: Colors.white, // Changed from overlayLightColor to pure white for better visibility
                    fontSize: 13, // Slightly increased from 12 to 13
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
