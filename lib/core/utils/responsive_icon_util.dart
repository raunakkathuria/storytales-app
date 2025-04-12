import 'package:flutter/material.dart';
import 'package:storytales/core/utils/responsive_text_util.dart';

/// Utility class for responsive icon sizing.
///
/// Provides methods to calculate appropriate icon sizes based on screen dimensions.
/// Follows Flutter standards and best practices for responsive design.
class ResponsiveIconUtil {
  /// Base sizes for different icon categories
  static const double _baseSmallIconSize = 16.0;
  static const double _baseMediumIconSize = 24.0;
  static const double _baseLargeIconSize = 48.0;

  /// Returns a scaled size for small icons (e.g., inline indicators, small buttons)
  static double getSmallIconSize(BuildContext context) {
    return _getScaledIconSize(context, _baseSmallIconSize);
  }

  /// Returns a scaled size for medium icons (e.g., app bar icons, navigation)
  static double getMediumIconSize(BuildContext context) {
    return _getScaledIconSize(context, _baseMediumIconSize);
  }

  /// Returns a scaled size for large icons (e.g., featured icons, empty states)
  static double getLargeIconSize(BuildContext context) {
    return _getScaledIconSize(context, _baseLargeIconSize);
  }

  /// Returns a custom scaled icon size based on the provided base size
  static double getCustomIconSize(BuildContext context, double baseSize) {
    return _getScaledIconSize(context, baseSize);
  }

  /// Internal method to calculate the scaled icon size
  static double _getScaledIconSize(BuildContext context, double baseSize) {
    // Use the same scale factor as text for consistency
    final scaleFactor = ResponsiveTextUtil.getScaleFactor(context);
    return baseSize * scaleFactor;
  }
}
