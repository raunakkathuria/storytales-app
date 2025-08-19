import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_button.dart';
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
        // Use a custom layout for actions to ensure responsiveness
        actions: !isLoading ? [_buildResponsiveActions(context)] : null,
      ),
    );
  }

  /// Builds responsive action buttons that adapt to different screen sizes.
  Widget _buildResponsiveActions(BuildContext context) {
    // Check if we should show the secondary button
    final hasSecondaryAction = secondaryActionText.isNotEmpty;

    // Get screen width to determine layout
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine if we should use vertical layout based on available dialog width
    // We need to estimate the dialog width since we don't have direct access to it
    final estimatedDialogWidth = screenWidth - 80; // Accounting for insetPadding
    final useVerticalLayout = estimatedDialogWidth < 280;

    // Create buttons using the ResponsiveButton component
    final cancelButton = hasSecondaryAction
        ? ResponsiveButton.primary(
            text: secondaryActionText,
            onPressed: onSecondaryAction ?? () => Navigator.pop(context),
            fontSize: 16.0, // Will be automatically scaled down on small screens
          )
        : null;

    final confirmButton = ResponsiveButton.accent(
      text: primaryActionText,
      onPressed: onPrimaryAction,
      fontSize: 16.0, // Will be automatically scaled down on small screens
    );

    // Return appropriate layout based on available width and button count
    if (!hasSecondaryAction) {
      // Single button - always center it
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [confirmButton],
      );
    }

    return useVerticalLayout
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              confirmButton,
              const SizedBox(height: 8),
              cancelButton!,
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              cancelButton!,
              const SizedBox(width: 8),
              confirmButton,
            ],
          );
  }
}
