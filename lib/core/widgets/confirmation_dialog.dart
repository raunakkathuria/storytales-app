import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';

/// A utility class for creating consistent confirmation dialogs across the app.
class ConfirmationDialog {
  /// Shows a confirmation dialog with consistent styling.
  ///
  /// [context] The build context.
  /// [title] The title of the dialog.
  /// [content] The content text of the dialog.
  /// [confirmText] The text for the confirm button (e.g., "Delete", "Cancel Subscription").
  /// [cancelText] The text for the cancel button (e.g., "Cancel", "Keep Subscription").
  /// [onConfirm] The callback to execute when the confirm button is pressed.
  /// [isDestructive] Whether the action is destructive (defaults to true).
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
    bool isDestructive = true,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StoryTalesTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: StoryTalesTheme.accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        title: ResponsiveText(
          text: title,
          style: const TextStyle(
            fontFamily: StoryTalesTheme.fontFamilyHeading,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: StoryTalesTheme.accentColor,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        content: ResponsiveText(
          text: content,
          style: const TextStyle(
            fontFamily: StoryTalesTheme.fontFamilyBody,
            fontSize: 16,
            color: StoryTalesTheme.textColor,
          ),
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        actions: [
          // Cancel button (highlighted)
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: StoryTalesTheme.primaryColor,
              foregroundColor: StoryTalesTheme.surfaceColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: ResponsiveText(
              text: cancelText,
              style: const TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyBody,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // Confirm button (destructive action)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true); // First dismiss the dialog
              onConfirm(); // Then execute the callback
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? StoryTalesTheme.errorColor
                  : StoryTalesTheme.accentColor,
              foregroundColor: StoryTalesTheme.surfaceColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: ResponsiveText(
              text: confirmText,
              style: const TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyBody,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
