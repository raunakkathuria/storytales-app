/// Service for enhancing user prompts with AI generation optimizations.
class PromptEnhancementService {
  /// Enhances a user prompt with image quality optimizations for story generation.
  ///
  /// This method adds specific instructions to ensure:
  /// - Crystal clear, sharp images
  /// - Pixar-style 3D rendering
  /// - Perfect character focus
  /// - No blur effects or depth-of-field
  /// - Bright, even lighting
  ///
  /// [originalPrompt] The user's original story prompt
  /// Returns the enhanced prompt with image quality instructions
  static String enhanceForImageGeneration(String originalPrompt) {
    return "$originalPrompt. "
        "Generate a high-detail, crystal clear, Pixar-style 3D render. "
        "All characters must be in perfect sharp focus with distinct facial features. "
        "Use bright, even lighting with no blur effects or depth-of-field. "
        "Ensure razor-sharp clarity throughout the entire scene.";
  }

  /// Future enhancement method for cover images (if different optimization needed)
  static String enhanceForCoverImage(String originalPrompt) {
    // For now, use the same enhancement, but this allows for future customization
    return enhanceForImageGeneration(originalPrompt);
  }

  /// Future enhancement method for page images (if different optimization needed)
  static String enhanceForPageImage(String originalPrompt) {
    // For now, use the same enhancement, but this allows for future customization
    return enhanceForImageGeneration(originalPrompt);
  }
}
