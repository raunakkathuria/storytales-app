import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';

/// A widget that displays the storybook logo with simple animations.
class AnimatedLogo extends StatefulWidget {
  final double size;

  const AnimatedLogo({
    super.key,
    this.size = 180,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated sparkles
        _buildSparkles(),

        // Animated logo
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: _buildLogo(),
              ),
            );
          },
        ),
      ],
    );
  }

  // Build a custom logo that doesn't rely on external assets
  Widget _buildLogo() {
    try {
      // Try to load the transparent logo image first
      return Image.asset(
        'assets/images/logo/storybook-logo-transparent.png',
        width: widget.size,
        height: widget.size,
        errorBuilder: (context, error, stackTrace) {
          // If transparent logo fails, try the regular logo
          return Image.asset(
            'assets/images/logo/storybook-logo.png',
            width: widget.size,
            height: widget.size,
            errorBuilder: (context, error, stackTrace) {
              // If both logos fail to load, use the custom drawn logo
              return _buildCustomLogo();
            },
          );
        },
      );
    } catch (e) {
      // Fallback to custom logo if any exception occurs
      return _buildCustomLogo();
    }
  }

  // Custom drawn logo that doesn't rely on external assets
  Widget _buildCustomLogo() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: StoryTalesTheme.primaryColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: StoryTalesTheme.primaryColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: StoryTalesTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Book shape
            Container(
              width: widget.size * 0.7,
              height: widget.size * 0.7,
              decoration: BoxDecoration(
                color: StoryTalesTheme.surfaceColor,
                borderRadius: BorderRadius.circular(widget.size * 0.05),
                border: Border.all(
                  color: StoryTalesTheme.primaryColor,
                  width: 2,
                ),
              ),
            ),

            // Book spine
            Positioned(
              left: widget.size * 0.35 - 1,
              top: widget.size * 0.15,
              bottom: widget.size * 0.15,
              child: Container(
                width: 2,
                color: StoryTalesTheme.primaryColor,
              ),
            ),

            // Text
            Positioned(
              bottom: widget.size * 0.25,
              child: Text(
                'STORY',
                style: TextStyle(
                  color: StoryTalesTheme.primaryColor,
                  fontSize: widget.size * 0.12,
                  fontWeight: FontWeight.bold,
                  fontFamily: StoryTalesTheme.fontFamilyHeading,
                ),
              ),
            ),

            // Text
            Positioned(
              top: widget.size * 0.25,
              child: Text(
                'TALES',
                style: TextStyle(
                  color: StoryTalesTheme.accentColor,
                  fontSize: widget.size * 0.12,
                  fontWeight: FontWeight.bold,
                  fontFamily: StoryTalesTheme.fontFamilyHeading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSparkles() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size * 1.5,
          height: widget.size * 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(8, (index) {
              // Calculate position for each sparkle
              final angle = index * (3.14159 * 2 / 8);
              final radius = widget.size * 0.6;
              final x = cos(angle) * radius;
              final y = sin(angle) * radius;

              // Alternate animation phase for each sparkle
              final delay = index / 8;
              final animationValue = (_controller.value + delay) % 1.0;

              // Scale and opacity based on animation
              final scale = 0.3 + (animationValue * 0.7);
              final opacity = 0.3 + (sin(animationValue * 3.14159) * 0.7);

              return Positioned(
                left: widget.size * 0.75 + x - 5,
                top: widget.size * 0.75 + y - 5,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.yellow[300],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withValues(alpha: 0.5),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// Helper function to avoid importing dart:math
double cos(double x) => _cos(x);
double sin(double x) => _sin(x);

// Simple implementation of cos and sin
double _cos(double x) {
  // Normalize x to [0, 2π]
  x = x % (2 * 3.14159);
  if (x < 0) x += 2 * 3.14159;

  // Use polynomial approximation
  if (x > 3.14159) return -_cos(x - 3.14159);
  if (x > 3.14159 / 2) return -_cos(3.14159 - x);

  // Taylor series approximation for [0, π/2]
  double result = 1.0;
  double term = 1.0;
  double x2 = x * x;

  for (int i = 1; i <= 5; i++) {
    term *= -x2 / (2 * i * (2 * i - 1));
    result += term;
  }

  return result;
}

double _sin(double x) {
  return _cos(x - 3.14159 / 2);
}
