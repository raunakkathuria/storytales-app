import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';

/// A widget that displays an error message in a branded style.
///
/// This widget is used to display error messages in a consistent way
/// throughout the app, following the brand guidelines.
class ErrorMessage extends StatelessWidget {
  /// The error message to display.
  final String message;

  /// Whether to animate the widget when it appears.
  final bool animate;

  /// Creates a new ErrorMessage widget.
  ///
  /// [message] - The error message to display.
  /// [animate] - Whether to animate the widget when it appears. Defaults to true.
  const ErrorMessage({
    super.key,
    required this.message,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: StoryTalesTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: StoryTalesTheme.errorColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: StoryTalesTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: StoryTalesTheme.errorColor,
                fontFamily: StoryTalesTheme.fontFamilyBody,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );

    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: widget,
      );
    }

    return widget;
  }
}
