import 'package:flutter/material.dart';
import 'package:storytales/core/utils/responsive_icon_util.dart';

/// A widget that displays an icon with responsive sizing.
///
/// This widget wraps the standard Flutter [Icon] widget and applies
/// responsive scaling based on the device's screen size.
class ResponsiveIcon extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The color to use for the icon.
  final Color? color;

  /// The semantic label for the icon.
  final String? semanticLabel;

  /// The text direction to use for the icon.
  final TextDirection? textDirection;

  /// The shadows for the icon.
  final List<Shadow>? shadows;

  /// The size category of the icon.
  final IconSizeCategory sizeCategory;

  /// Custom base size for the icon. Only used when sizeCategory is [IconSizeCategory.custom].
  final double? customBaseSize;

  /// Creates a responsive icon widget.
  ///
  /// The [icon] parameter must not be null.
  const ResponsiveIcon({
    super.key,
    required this.icon,
    this.color,
    this.semanticLabel,
    this.textDirection,
    this.shadows,
    this.sizeCategory = IconSizeCategory.medium,
    this.customBaseSize,
  }) : assert(
          sizeCategory != IconSizeCategory.custom || customBaseSize != null,
          'customBaseSize must be provided when sizeCategory is custom',
        );

  @override
  Widget build(BuildContext context) {
    // Calculate the responsive size based on the size category
    final double size = _getResponsiveSize(context);

    // Return a standard Icon widget with the responsive size
    return Icon(
      icon,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
      shadows: shadows,
    );
  }

  /// Get the responsive size based on the size category
  double _getResponsiveSize(BuildContext context) {
    switch (sizeCategory) {
      case IconSizeCategory.small:
        return ResponsiveIconUtil.getSmallIconSize(context);
      case IconSizeCategory.medium:
        return ResponsiveIconUtil.getMediumIconSize(context);
      case IconSizeCategory.large:
        return ResponsiveIconUtil.getLargeIconSize(context);
      case IconSizeCategory.custom:
        return ResponsiveIconUtil.getCustomIconSize(context, customBaseSize!);
    }
  }
}

/// Enum representing different icon size categories.
enum IconSizeCategory {
  /// Small icons (e.g., inline indicators, small buttons)
  small,

  /// Medium icons (e.g., app bar icons, navigation)
  medium,

  /// Large icons (e.g., featured icons, empty states)
  large,

  /// Custom size icons
  custom,
}
