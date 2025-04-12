import 'package:flutter/material.dart';
import 'package:storytales/core/services/image/image_service.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import 'package:storytales/features/library/domain/entities/story.dart';

/// A widget that displays a single page of a story with text overlay on an image.
class StoryPageView extends StatefulWidget {
  final Story story;
  final int currentPageIndex;
  final VoidCallback onNextPage;
  final VoidCallback onPreviousPage;

  const StoryPageView({
    super.key,
    required this.story,
    required this.currentPageIndex,
    required this.onNextPage,
    required this.onPreviousPage,
  });

  @override
  State<StoryPageView> createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep this page in memory when not visible

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    // Ensure the page index is valid
    if (widget.currentPageIndex < 0 || widget.currentPageIndex >= widget.story.pages.length) {
      return const Center(
        child: ResponsiveText(
          text: 'Invalid page index',
          style: TextStyle(
            fontFamily: StoryTalesTheme.fontFamilyBody,
            fontSize: 16,
            color: StoryTalesTheme.errorColor,
          ),
        ),
      );
    }

    final page = widget.story.pages[widget.currentPageIndex];

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        _buildBackgroundImage(page.imagePath),

        // Semi-transparent overlay for better text readability
        _buildOverlay(),

        // Story text
        _buildStoryText(page.content),

        // Navigation areas (left/right sides of the screen)
        _buildNavigationAreas(),
      ],
    );
  }

  Widget _buildBackgroundImage(String imagePath) {
    // Check if the image path is valid
    if (imagePath.isEmpty) {
      return _buildFallbackImage();
    }

    return ImageService().getImage(
      imagePath: imagePath,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildLoadingIndicator(),
      errorWidget: (context, url, error) => _buildFallbackImage(),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: StoryTalesTheme.primaryColor.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: StoryTalesTheme.accentColor,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: StoryTalesTheme.primaryColor.withValues(alpha: 0.1),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.6),
          ],
          stops: const [0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildStoryText(String text) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: StoryTalesTheme.textBackgroundOpacity),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ResponsiveText(
          text: text,
          style: const TextStyle(
            color: StoryTalesTheme.surfaceColor,
            fontSize: 20,
            fontWeight: FontWeight.w600, // Semi-bold text
            fontFamily: StoryTalesTheme.fontFamilyBody,
            height: 1.5,
            shadows: [
              Shadow(
                color: StoryTalesTheme.textColor,
                offset: Offset(1, 1),
                blurRadius: 4,
              ),
              Shadow(
                color: StoryTalesTheme.textColor,
                offset: Offset(-1, -1),
                blurRadius: 4,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildNavigationAreas() {
    return Row(
      children: [
        // Left side - previous page
        Expanded(
          child: GestureDetector(
            onTap: widget.currentPageIndex > 0 ? widget.onPreviousPage : null,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent, // Keep transparent for hit testing
            ),
          ),
        ),

        // Right side - next page
        Expanded(
          child: GestureDetector(
            onTap: widget.onNextPage,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent, // Keep transparent for hit testing
            ),
          ),
        ),
      ],
    );
  }
}
