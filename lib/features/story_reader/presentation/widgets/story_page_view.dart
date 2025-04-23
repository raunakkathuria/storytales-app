import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:storytales/core/services/image/image_service.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_icon.dart';
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
  bool _isTextVisible = true; // Track whether text is visible

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

    return GestureDetector(
      // Toggle text visibility on tap in the center area
      onTap: () {
        setState(() {
          _isTextVisible = !_isTextVisible;
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          _buildBackgroundImage(page.imagePath),

          // Semi-transparent overlay for better text readability (only when text is visible)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.3, // Bottom 30% of screen
            child: AnimatedOpacity(
              opacity: _isTextVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _buildOverlay(),
            ),
          ),

          // Story text with animation
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _isTextVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _buildStoryText(page.content),
            ),
          ),

          // Navigation areas (left/right sides of the screen)
          _buildNavigationAreas(),

          // Text preview tab (only visible when text is hidden)
          Positioned(
            right: 0,
            // Position proportionally based on screen height
            bottom: MediaQuery.of(context).size.height * 0.15,
            child: AnimatedOpacity(
              opacity: _isTextVisible ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isTextVisible = true;
                  });
                },
                child: Container(
                  // Responsive width based on screen width (min 120px, max 20% of screen width)
                  width: math.max(120, MediaQuery.of(context).size.width * 0.2),
                  // Ensure minimum touch target size of 44px height
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(-2, 0),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ResponsiveIcon(
                        icon: Icons.menu_book,
                        color: Colors.white,
                        sizeCategory: IconSizeCategory.small,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: ResponsiveText(
                          text: _getTextPreview(page.content),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14, // Body Small as per guidelines
                            fontWeight: FontWeight.bold,
                            fontFamily: StoryTalesTheme.fontFamilyBody,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
      color: StoryTalesTheme.primaryColor.withValues(alpha: .3),
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
      color: StoryTalesTheme.primaryColor.withValues(alpha: .1),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildOverlay() {
    // Create a gradient container for better text readability
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.6),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }

  Widget _buildStoryText(String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16), // Extra padding at top for the handle
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: StoryTalesTheme.textBackgroundOpacity),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drawer handle indicator
          Container(
            width: 50, // Fixed width for the handle
            height: 4, // Height of the handle
            margin: const EdgeInsets.only(bottom: 12), // Space between handle and text
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .5), // Semi-transparent white
              borderRadius: BorderRadius.circular(2), // Rounded corners
            ),
          ),
          // Story text
          ResponsiveText(
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
        ],
      ),
    );
  }

  // This method now just returns an empty container since we're using swipe navigation only
  Widget _buildNavigationAreas() {
    // Return an empty, transparent container that doesn't interfere with other gestures
    return Container(
      color: Colors.transparent,
    );
  }

  // Extract the first few words from the text for the preview tab
  String _getTextPreview(String text) {
    // Split the text into words
    final words = text.split(' ');

    // Take the first 3 words (or fewer if the text is shorter)
    final previewWords = words.take(3).join(' ');

    // Add ellipsis if there are more words
    return words.length > 3 ? '$previewWords...' : previewWords;
  }
}
