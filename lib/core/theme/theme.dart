import 'package:flutter/material.dart';
import 'package:storytales/core/utils/responsive_text_util.dart';

/// Theme class for the StoryTales app.
class StoryTalesTheme {
  // Font families
  static const String fontFamilyHeading = 'Quicksand';
  static const String fontFamilyBody = 'Nunito';

  // "Storybook Sky" color palette
  static const Color primaryColor = Color(0xFF7DCDEE); // Sky Blue
  static const Color secondaryColor = Color(0xFFA18CD1); // Lavender Purple
  static const Color accentColor = Color(0xFFFF9A76); // Sunset Orange
  static const Color backgroundColor = Color(0xFFF8F9FA); // Cloud White
  static const Color errorColor = Color(0xFFE76161); // Coral red

  // Semantic colors for consistent usage
  static const Color successColor = Color(0xFF4CAF50); // Success green
  static const Color textColor = Color(0xFF333333); // Primary text color (dark for light backgrounds)
  static const Color textLightColor = Color(0xFF757575); // Secondary text color (medium gray)
  static const Color surfaceColor = Color(0xFFFFFFFF); // Card/surface background (white)

  // Overlay colors with predefined opacity
  static const Color overlayDarkColor = Color(0x99000000); // Black with 60% opacity
  static const Color overlayLightColor = Color(0xB3FFFFFF); // White with 70% opacity
  static const double textBackgroundOpacity = 0.8; // Text background opacity (80%)

  // Text styles
  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 18,
    color: textColor,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    color: textColor,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    color: textColor,
  );

  /// Creates responsive text styles based on screen size.
  static TextTheme _getResponsiveTextStyles(BuildContext context) {
    return TextTheme(
      displayLarge: headingLarge.copyWith(
        fontSize: ResponsiveTextUtil.getScaledFontSize(context, headingLarge.fontSize!),
      ),
      displayMedium: headingMedium.copyWith(
        fontSize: ResponsiveTextUtil.getScaledFontSize(context, headingMedium.fontSize!),
      ),
      displaySmall: headingSmall.copyWith(
        fontSize: ResponsiveTextUtil.getScaledFontSize(context, headingSmall.fontSize!),
      ),
      bodyLarge: bodyLarge.copyWith(
        fontSize: ResponsiveTextUtil.getScaledFontSize(context, bodyLarge.fontSize!),
      ),
      bodyMedium: bodyMedium.copyWith(
        fontSize: ResponsiveTextUtil.getScaledFontSize(context, bodyMedium.fontSize!),
      ),
      bodySmall: bodySmall.copyWith(
        fontSize: ResponsiveTextUtil.getScaledFontSize(context, bodySmall.fontSize!),
      ),
    );
  }

  /// Build the theme data for the app.
  ///
  /// This method now takes a BuildContext to enable responsive sizing.
  static ThemeData buildThemeData(BuildContext context) {
    // Calculate responsive text styles
    final textStyles = _getResponsiveTextStyles(context);

    return ThemeData(
      // Colors
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,

      // Typography
      fontFamily: fontFamilyBody,
      textTheme: textStyles,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: surfaceColor,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fontFamilyHeading,
          fontSize: ResponsiveTextUtil.getScaledFontSize(context, 20),
          fontWeight: FontWeight.bold,
          color: surfaceColor, // Changed from accentColor to white for better contrast
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: surfaceColor,
          textStyle: TextStyle(
            fontFamily: fontFamilyBody,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveTextUtil.getScaledFontSize(context, 16),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: const BorderSide(color: accentColor),
          textStyle: TextStyle(
            fontFamily: fontFamilyBody,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveTextUtil.getScaledFontSize(context, 16),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: TextStyle(
            fontFamily: fontFamilyBody,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveTextUtil.getScaledFontSize(context, 16),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textLightColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textLightColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(
          fontFamily: fontFamilyBody,
          color: textLightColor,
          fontSize: ResponsiveTextUtil.getScaledFontSize(context, 16),
        ),
        hintStyle: TextStyle(
          fontFamily: fontFamilyBody,
          color: textLightColor,
          fontSize: ResponsiveTextUtil.getScaledFontSize(context, 16),
        ),
        errorStyle: TextStyle(
          fontFamily: fontFamilyBody,
          color: errorColor,
          fontSize: ResponsiveTextUtil.getScaledFontSize(context, 14),
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceColor,
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: surfaceColor, // Changed from primaryColor to white for better contrast
        unselectedLabelColor: overlayLightColor, // Changed from textLightColor to overlayLightColor for better visibility
        indicatorColor: accentColor,
        labelStyle: TextStyle(
          fontFamily: fontFamilyBody,
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveTextUtil.getScaledFontSize(context, 16), // Increased font size for better visibility
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamilyBody,
          fontSize: ResponsiveTextUtil.getScaledFontSize(context, 16), // Matching font size for consistency
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: surfaceColor,
        extendedTextStyle: TextStyle(
          fontFamily: fontFamilyBody,
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveTextUtil.getScaledFontSize(context, 16),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: accentColor,
        unselectedItemColor: textLightColor,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamilyBody,
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveTextUtil.getScaledFontSize(context, 14),
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamilyBody,
          fontSize: ResponsiveTextUtil.getScaledFontSize(context, 14),
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
