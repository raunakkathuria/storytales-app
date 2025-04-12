import 'package:storytales/features/library/domain/entities/story.dart';

/// Repository interface for generating stories.
abstract class StoryGenerationRepository {
  /// Check if the user can generate a story.
  /// Returns true if the user has an active subscription or has not reached the free story limit.
  Future<bool> canGenerateStory();

  /// Generate a story using the provided parameters.
  ///
  /// [prompt] is the user's prompt for the story.
  /// [ageRange] is the target age range for the story.
  /// [theme] is the theme of the story.
  /// [genre] is the genre of the story.
  ///
  /// Returns the generated story.
  ///
  /// Throws an exception if the user cannot generate a story or if there is an error during generation.
  Future<Story> generateStory({
    required String prompt,
    String? ageRange,
    String? theme,
    String? genre,
  });

  /// Get the number of free stories remaining.
  Future<int> getFreeStoriesRemaining();
}
