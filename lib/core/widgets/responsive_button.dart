import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_icon.dart';
import 'package:storytales/core/widgets/responsive_text.dart';

/// A responsive button that adapts to different screen sizes.
///
/// This widget provides a standardized way to create buttons that follow
/// the app's responsive design guidelines.
class ResponsiveButton extends StatelessWidget {
  /// The text to display on the button.
  final String text;

  /// The callback to execute when the button is pressed.
  final VoidCallback? onPressed;

  /// The background color of the button.
  final Color backgroundColor;

  /// The text color of the button.
  final Color textColor;

  /// Whether the button should take up the full width of its parent.
  final bool isFullWidth;

  /// An optional icon to display before the text.
  final IconData? icon;

  /// The size category for the icon (if provided).
  final IconSizeCategory iconSizeCategory;

  /// The font size for the button text.
  final double fontSize;

  /// The padding around the button content.
  final EdgeInsetsGeometry? padding;

  /// The minimum size of the button.
  final Size? minimumSize;

  /// Creates a responsive button with consistent styling.
  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = StoryTalesTheme.primaryColor,
    this.textColor = StoryTalesTheme.surfaceColor,
    this.isFullWidth = false,
    this.icon,
    this.iconSizeCategory = IconSizeCategory.small,
    this.fontSize = 16.0,
    this.padding,
    this.minimumSize,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width to determine sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360; // iPhone SE and similar

    // Calculate responsive dimensions
    final responsiveFontSize = isSmallScreen ? fontSize - 2 : fontSize;
    final responsivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16.0 : 24.0,
          vertical: isSmallScreen ? 8.0 : 12.0,
        );
    final responsiveMinimumSize = minimumSize ??
        Size(isSmallScreen ? 80 : 100, isSmallScreen ? 36 : 44);

    // Create button style with responsive dimensions
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
      padding: responsivePadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      minimumSize: responsiveMinimumSize,
    );

    // Create button content
    Widget buttonContent;
    if (icon != null) {
      // Button with icon and text
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResponsiveIcon(
            icon: icon!,
            color: textColor,
            sizeCategory: iconSizeCategory,
          ),
          const SizedBox(width: 8),
          ResponsiveText(
            text: text,
            style: TextStyle(
              fontFamily: StoryTalesTheme.fontFamilyBody,
              fontWeight: FontWeight.bold,
              fontSize: responsiveFontSize,
            ),
          ),
        ],
      );
    } else {
      // Button with text only
      buttonContent = ResponsiveText(
        text: text,
        style: TextStyle(
          fontFamily: StoryTalesTheme.fontFamilyBody,
          fontWeight: FontWeight.bold,
          fontSize: responsiveFontSize,
        ),
      );
    }

    // Create the button
    final button = ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: buttonContent,
    );

    // Return full width button if requested
    return isFullWidth
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }

  /// Creates a primary button with the app's primary color.
  factory ResponsiveButton.primary({
    required String text,
    required VoidCallback? onPressed,
    bool isFullWidth = false,
    IconData? icon,
    IconSizeCategory iconSizeCategory = IconSizeCategory.small,
    double fontSize = 16.0,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
  }) {
    return ResponsiveButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: StoryTalesTheme.primaryColor,
      textColor: StoryTalesTheme.surfaceColor,
      isFullWidth: isFullWidth,
      icon: icon,
      iconSizeCategory: iconSizeCategory,
      fontSize: fontSize,
      padding: padding,
      minimumSize: minimumSize,
    );
  }

  /// Creates an accent button with the app's accent color.
  factory ResponsiveButton.accent({
    required String text,
    required VoidCallback? onPressed,
    bool isFullWidth = false,
    IconData? icon,
    IconSizeCategory iconSizeCategory = IconSizeCategory.small,
    double fontSize = 16.0,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
  }) {
    return ResponsiveButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: StoryTalesTheme.accentColor,
      textColor: StoryTalesTheme.surfaceColor,
      isFullWidth: isFullWidth,
      icon: icon,
      iconSizeCategory: iconSizeCategory,
      fontSize: fontSize,
      padding: padding,
      minimumSize: minimumSize,
    );
  }

  /// Creates an outlined button with transparent background and colored border.
  factory ResponsiveButton.outlined({
    required String text,
    required VoidCallback? onPressed,
    Color borderColor = StoryTalesTheme.primaryColor,
    Color textColor = StoryTalesTheme.primaryColor,
    bool isFullWidth = false,
    IconData? icon,
    IconSizeCategory iconSizeCategory = IconSizeCategory.small,
    double fontSize = 16.0,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
  }) {
    return ResponsiveButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      textColor: textColor,
      isFullWidth: isFullWidth,
      icon: icon,
      iconSizeCategory: iconSizeCategory,
      fontSize: fontSize,
      padding: padding,
      minimumSize: minimumSize,
    );
  }
}
