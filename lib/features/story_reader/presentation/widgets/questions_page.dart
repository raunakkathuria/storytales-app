import 'package:flutter/material.dart';
import 'package:storytales/core/services/image/image_service.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_icon.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import 'package:storytales/features/library/domain/entities/story.dart';

/// A widget that displays discussion questions and story information at the end of a story.
class QuestionsPage extends StatelessWidget {
  final Story story;
  final VoidCallback onBackPressed;
  final String? backgroundImagePath;

  const QuestionsPage({
    super.key,
    required this.story,
    required this.onBackPressed,
    this.backgroundImagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Use the provided background image or fall back to cover image
    final imagePath = backgroundImagePath ?? story.coverImagePath;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        ImageService().getImage(
          imagePath: imagePath,
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
        ),

        // Semi-transparent overlay for better text readability - matching story page overlay
        Container(
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
        ),

        // Content
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 120, 24, 80), // Increased top padding for header
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title - styled consistently with story page
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: StoryTalesTheme.textBackgroundOpacity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ResponsiveText(
                    text: 'Let\'s Talk About "${story.title}"',
                    style: const TextStyle(
                      color: StoryTalesTheme.surfaceColor,
                      fontSize: 24, // Slightly larger than story text
                      fontWeight: FontWeight.w600, // Semi-bold text
                      fontFamily: StoryTalesTheme.fontFamilyHeading,
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
              ),

              const SizedBox(height: 32),

              // Discussion questions
              _buildDiscussionQuestions(),

              const SizedBox(height: 32),

              // Story information
              _buildStoryInformation(),
            ],
          ),
        ),

        // Back button positioned at bottom right
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: onBackPressed,
            icon: const Icon(
              Icons.arrow_back,
              size: 22,
            ),
            label: Builder(
              builder: (context) => ResponsiveText(
                text: 'Back to Story',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: StoryTalesTheme.fontFamilyBody,
                ),
              ),
            ),
            backgroundColor: StoryTalesTheme.accentColor,
            foregroundColor: StoryTalesTheme.surfaceColor,
            elevation: 4,
          ),
        ),
      ],
    );
  }


  Widget _buildDiscussionQuestions() {
    if (story.questions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Match story page padding
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: StoryTalesTheme.textBackgroundOpacity),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText(
            text: 'Discussion Questions:',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800, // Extra bold for better visibility
              fontFamily: StoryTalesTheme.fontFamilyHeading,
              color: StoryTalesTheme.secondaryColor, // Using theme color for consistency
              letterSpacing: 0.2, // Slight letter spacing for better readability
            ),
          ),

          const SizedBox(height: 16),

          ...List.generate(story.questions.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4), // Add padding to align with text
                    child: ResponsiveIcon(
                      icon: Icons.lightbulb_outline,
                      color: StoryTalesTheme.accentColor, // Using theme color for consistency
                      sizeCategory: IconSizeCategory.medium,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ResponsiveText(
                    text: story.questions[index],
                    style: const TextStyle(
                      color: StoryTalesTheme.surfaceColor,
                      fontSize: 20, // Match story page text size
                      fontWeight: FontWeight.w600, // Semi-bold text
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      height: 1.5, // Match story page line height
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
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStoryInformation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Match story page padding
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: StoryTalesTheme.textBackgroundOpacity),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ResponsiveText(
            text: 'Story Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800, // Extra bold for better visibility
              fontFamily: StoryTalesTheme.fontFamilyHeading,
              color: StoryTalesTheme.secondaryColor, // Using theme color for consistency
              letterSpacing: 0.2, // Slight letter spacing for better readability
            ),
          ),

          Divider(
            color: StoryTalesTheme.surfaceColor.withValues(alpha: 0.3),
          ),

          // Age range
          if (story.ageRange != null) _buildInfoRow('Age Range:', story.ageRange!),

          // Genre
          if (story.genre != null) _buildInfoRow('Genre:', story.genre!),

          // Theme
          if (story.theme != null) _buildInfoRow('Theme:', story.theme!),

          // Reading time
          _buildInfoRow('Reading Time:', story.readingTime),

          // Created date
          _buildInfoRow('Created:', story.createdAt.toString().split(' ')[0]),

          // Characters (if we had this field in the Story entity)
          // if (story.characters.isNotEmpty)
          //   _buildInfoRow('Characters:', story.characters.join(', ')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // Increased from 4 to 6
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            text: label,
            style: const TextStyle(
              fontSize: 15, // Added explicit font size
              fontWeight: FontWeight.w700, // Bolder for better visibility
              fontFamily: StoryTalesTheme.fontFamilyBody,
              color: StoryTalesTheme.secondaryColor, // Using theme color for consistency
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: ResponsiveText(
              text: value,
              style: const TextStyle(
                color: StoryTalesTheme.surfaceColor,
                fontSize: 18, // Slightly smaller than main text
                fontWeight: FontWeight.w600, // Semi-bold text
                fontFamily: StoryTalesTheme.fontFamilyBody,
                height: 1.5,
                shadows: [
                  Shadow(
                    color: StoryTalesTheme.textColor,
                    offset: Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
