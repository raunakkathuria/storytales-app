import 'package:flutter_test/flutter_test.dart';
import 'package:storytales/core/services/prompt/prompt_enhancement_service.dart';

void main() {
  group('PromptEnhancementService', () {
    test('should enhance prompt for image generation correctly', () {
      // Arrange
      const originalPrompt = 'A brave knight on a quest';

      // Act
      final enhancedPrompt = PromptEnhancementService.enhanceForImageGeneration(originalPrompt);

      // Assert
      expect(enhancedPrompt, contains(originalPrompt));
      expect(enhancedPrompt, contains('crystal clear'));
      expect(enhancedPrompt, contains('Pixar-style 3D render'));
      expect(enhancedPrompt, contains('perfect sharp focus'));
      expect(enhancedPrompt, contains('distinct facial features'));
      expect(enhancedPrompt, contains('bright, even lighting'));
      expect(enhancedPrompt, contains('no blur effects or depth-of-field'));
      expect(enhancedPrompt, contains('razor-sharp clarity'));
    });

    test('should handle empty prompt gracefully', () {
      // Arrange
      const originalPrompt = '';

      // Act
      final enhancedPrompt = PromptEnhancementService.enhanceForImageGeneration(originalPrompt);

      // Assert
      expect(enhancedPrompt, isNotEmpty);
      expect(enhancedPrompt, startsWith('. '));
      expect(enhancedPrompt, contains('crystal clear'));
    });

    test('should handle single word prompt', () {
      // Arrange
      const originalPrompt = 'Dragon';

      // Act
      final enhancedPrompt = PromptEnhancementService.enhanceForImageGeneration(originalPrompt);

      // Assert
      expect(enhancedPrompt, startsWith('Dragon. '));
      expect(enhancedPrompt, contains('crystal clear'));
    });

    test('enhanceForCoverImage should use same enhancement as general method', () {
      // Arrange
      const originalPrompt = 'A magical forest';

      // Act
      final generalEnhancement = PromptEnhancementService.enhanceForImageGeneration(originalPrompt);
      final coverEnhancement = PromptEnhancementService.enhanceForCoverImage(originalPrompt);

      // Assert
      expect(coverEnhancement, equals(generalEnhancement));
    });

    test('enhanceForPageImage should use same enhancement as general method', () {
      // Arrange
      const originalPrompt = 'A magical forest';

      // Act
      final generalEnhancement = PromptEnhancementService.enhanceForImageGeneration(originalPrompt);
      final pageEnhancement = PromptEnhancementService.enhanceForPageImage(originalPrompt);

      // Assert
      expect(pageEnhancement, equals(generalEnhancement));
    });
  });
}
