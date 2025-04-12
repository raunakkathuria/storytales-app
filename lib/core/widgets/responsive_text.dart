import 'package:flutter/material.dart';
import 'package:storytales/core/utils/responsive_text_util.dart';

/// A text widget that automatically scales based on screen size.
///
/// This widget wraps the standard Flutter [Text] widget and applies
/// responsive scaling based on the device's screen size.
class ResponsiveText extends StatelessWidget {
  /// The text to display.
  final String text;

  /// The style to use for this text.
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The maximum number of lines for the text to span.
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// Creates a responsive text widget.
  ///
  /// The [text] parameter must not be null.
  const ResponsiveText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // Get the base style, either from the provided style or the default text theme
    final TextStyle effectiveStyle = style ?? Theme.of(context).textTheme.bodyMedium!;

    // Get the base font size from the style
    final double baseFontSize = effectiveStyle.fontSize ?? 16.0;

    // Calculate the scaled font size
    final double scaledFontSize = ResponsiveTextUtil.getScaledFontSize(
      context,
      baseFontSize,
    );

    // Create a new style with the scaled font size
    final TextStyle responsiveStyle = effectiveStyle.copyWith(
      fontSize: scaledFontSize,
    );

    // Return a standard Text widget with the responsive style
    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
