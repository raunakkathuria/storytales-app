import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import '../bloc/story_workshop_bloc.dart';
import '../bloc/story_workshop_state.dart';
import 'story_workshop_dialog.dart';

/// Compact animated indicator widget that shows when there are active story generations
/// Displays as an icon-based indicator on the left side of the app bar
class StoryWorkshopIndicator extends StatefulWidget {
  const StoryWorkshopIndicator({super.key});

  @override
  State<StoryWorkshopIndicator> createState() => _StoryWorkshopIndicatorState();
}

class _StoryWorkshopIndicatorState extends State<StoryWorkshopIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for active generation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for the magic wand icon
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryWorkshopBloc, StoryWorkshopState>(
      builder: (context, state) {
        if (state is! StoryWorkshopActive || !state.hasJobs) {
          // Stop animations when no jobs
          _pulseController.stop();
          _rotationController.stop();
          return const SizedBox.shrink();
        }

        final activeCount = state.activeJobs.length;
        final failedCount = state.failedJobs.length;
        final hasActiveJobs = activeCount > 0;

        // Start/stop animations based on job status
        if (hasActiveJobs) {
          _pulseController.repeat(reverse: true);
          _rotationController.repeat();
        } else {
          _pulseController.stop();
          _rotationController.stop();
        }

        return GestureDetector(
          onTap: () => StoryWorkshopDialog.show(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getIndicatorColor(state),
              shape: BoxShape.circle,
              border: Border.all(
                color: _getBorderColor(state),
                width: 2,
              ),
              boxShadow: hasActiveJobs ? [
                BoxShadow(
                  color: StoryTalesTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main icon with animations
                AnimatedBuilder(
                  animation: hasActiveJobs ? _pulseAnimation :
                             const AlwaysStoppedAnimation(1.0),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: AnimatedBuilder(
                        animation: hasActiveJobs ? _rotationAnimation :
                                   const AlwaysStoppedAnimation(0.0),
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value * 2 * 3.14159,
                            child: Icon(
                              _getMainIcon(state),
                              size: 20,
                              color: _getIconColor(state),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                // Badge for job count (only show if more than 1 job)
                if (activeCount + failedCount > 1)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getBadgeColor(state),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${activeCount + failedCount}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: StoryTalesTheme.fontFamilyBody,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getMainIcon(StoryWorkshopActive state) {
    if (state.hasOnlyFailedJobs) {
      return Icons.error_outline;
    }
    return Icons.auto_fix_high; // Magic wand icon for story generation
  }

  Color _getIndicatorColor(StoryWorkshopActive state) {
    if (state.hasOnlyFailedJobs) {
      return StoryTalesTheme.errorColor.withValues(alpha: 0.1);
    }
    return StoryTalesTheme.primaryColor.withValues(alpha: 0.1);
  }

  Color _getBorderColor(StoryWorkshopActive state) {
    if (state.hasOnlyFailedJobs) {
      return StoryTalesTheme.errorColor;
    }
    return StoryTalesTheme.primaryColor;
  }

  Color _getIconColor(StoryWorkshopActive state) {
    if (state.hasOnlyFailedJobs) {
      return StoryTalesTheme.errorColor;
    }
    return StoryTalesTheme.primaryColor;
  }

  Color _getBadgeColor(StoryWorkshopActive state) {
    if (state.hasOnlyFailedJobs) {
      return StoryTalesTheme.errorColor;
    }
    return StoryTalesTheme.accentColor;
  }
}
