import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';

/// A utility class for creating consistent form dialogs across the app.
///
/// This class provides a standardized way to display form dialogs with
/// consistent styling, following the same design language as ConfirmationDialog.
class DialogForm extends StatelessWidget {
  /// The title of the dialog.
  final String title;

  /// The form content to display in the dialog.
  final Widget content;

  /// The text for the primary action button.
  final String primaryActionText;

  /// The callback to execute when the primary action button is pressed.
  final VoidCallback onPrimaryAction;

  /// The text for the secondary action button (usually "Cancel").
  final String secondaryActionText;

  /// The callback to execute when the secondary action button is pressed.
  final VoidCallback? onSecondaryAction;

  /// Whether the dialog is in a loading state.
  final bool isLoading;

  /// Optional loading indicator widget to show when [isLoading] is true.
  final Widget? loadingIndicator;

  /// Creates a dialog form with consistent styling.
  const DialogForm({
    super.key,
    required this.title,
    required this.content,
    required this.primaryActionText,
    required this.onPrimaryAction,
    this.secondaryActionText = 'Cancel',
    this.onSecondaryAction,
    this.isLoading = false,
    this.loadingIndicator,
  });

  /// Shows a dialog form with consistent styling.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    required String primaryActionText,
    required VoidCallback onPrimaryAction,
    String secondaryActionText = 'Cancel',
    VoidCallback? onSecondaryAction,
    bool isLoading = false,
    Widget? loadingIndicator,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: !isLoading, // Prevent dismissing when loading
      builder: (context) => DialogForm(
        title: title,
        content: content,
        primaryActionText: primaryActionText,
        onPrimaryAction: onPrimaryAction,
        secondaryActionText: secondaryActionText,
        onSecondaryAction: onSecondaryAction ?? () => Navigator.pop(context),
        isLoading: isLoading,
        loadingIndicator: loadingIndicator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent back button from closing dialog when loading
      canPop: !isLoading,
      child: AlertDialog(
        backgroundColor: StoryTalesTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: StoryTalesTheme.accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        // Standard content padding
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        // Control the dialog width with insetPadding
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        title: title.isEmpty
            ? null // Don't show title widget if title is empty
            : ResponsiveText(
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
        content: isLoading && loadingIndicator != null
            ? loadingIndicator
            : SingleChildScrollView(
                child: content,
              ),
        // More bottom padding for actions
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        // Use ButtonBar for standard Flutter button layout
        actions: !isLoading
            ? [
                ElevatedButton(
                  onPressed: onSecondaryAction ?? () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryTalesTheme.primaryColor,
                    foregroundColor: StoryTalesTheme.surfaceColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: ResponsiveText(
                    text: secondaryActionText,
                    style: const TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Increased font size
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: onPrimaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryTalesTheme.accentColor,
                    foregroundColor: StoryTalesTheme.surfaceColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: ResponsiveText(
                    text: primaryActionText,
                    style: const TextStyle(
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Increased font size
                    ),
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}
