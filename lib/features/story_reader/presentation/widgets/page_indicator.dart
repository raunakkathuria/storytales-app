import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';

/// A widget that displays page indicators (dots) to show the current page position.
class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final double dotSize;
  final double spacing;
  final Color activeColor;
  final Color inactiveColor;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.dotSize = 8.0,
    this.spacing = 4.0,
    this.activeColor = StoryTalesTheme.secondaryColor,
    this.inactiveColor = StoryTalesTheme.textLightColor,
  });

  @override
  Widget build(BuildContext context) {
    // Maximum number of dots to display
    const int maxDotsToShow = 5;

    // If we have fewer pages than our maximum, show all dots
    if (totalPages <= maxDotsToShow) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalPages, (index) {
          final isActive = index + 1 == currentPage;
          return _buildDot(isActive);
        }),
      );
    }

    // For longer stories, show first dot, last dot, and 3 dots in between
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First dot
        _buildDot(currentPage == 1),

        // Three dots in the middle
        _buildDot(false, isMiddleDot: true),
        _buildDot(false, isMiddleDot: true),
        _buildDot(false, isMiddleDot: true),

        // Last dot
        _buildDot(currentPage == totalPages),
      ],
    );
  }

  Widget _buildDot(bool isActive, {bool isMiddleDot = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing / 2),
      width: isActive ? dotSize * 1.5 : dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: isActive
            ? activeColor
            : isMiddleDot
                ? inactiveColor.withValues(alpha: 0.7)
                : inactiveColor,
        borderRadius: BorderRadius.circular(dotSize / 2),
      ),
    );
  }
}
