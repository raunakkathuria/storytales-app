import 'package:flutter/material.dart';

/// Utility class for responsive text sizing.
///
/// Provides methods to calculate appropriate text sizes based on screen dimensions.
/// Follows Flutter standards and best practices for responsive design.
class ResponsiveTextUtil {
  /// Base width used for scaling calculations (iPhone 13 width).
  static const double _baseWidth = 390.0;

  /// Minimum scale factor to prevent text from becoming too small.
  static const double _minScaleFactor = 1.0;

  /// Maximum scale factor to prevent text from becoming too large.
  static const double _maxScaleFactor = 1.5;

  /// Returns true if the device is likely a tablet based on screen width.
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Calculates a scale factor based on the device's screen width.
  ///
  /// The scale factor is calculated as the ratio of the current screen width
  /// to the base width, clamped between minimum and maximum values.
  static double getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / _baseWidth;

    // Apply additional scaling for tablets
    if (isTablet(context)) {
      scaleFactor *= 1.2;
    }

    // Ensure scale factor is within bounds
    return scaleFactor.clamp(_minScaleFactor, _maxScaleFactor);
  }

  /// Returns a scaled font size based on the base font size and device screen.
  ///
  /// This method respects the user's device text scaling preferences by
  /// incorporating the system's textScaler.
  static double getScaledFontSize(BuildContext context, double fontSize) {
    // Get the system text scaler (respects user's accessibility settings)
    final textScaler = MediaQuery.of(context).textScaler;

    // Apply our custom scaling on top of the system scaling
    return fontSize * textScaler.scale(1.0) * getScaleFactor(context);
  }
}
