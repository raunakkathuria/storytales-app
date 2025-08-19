import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../bloc/story_workshop_bloc.dart';
import '../bloc/story_workshop_state.dart';
import 'story_workshop_dialog.dart';

/// Indicator widget that shows when there are active story generations
/// Displays in the top bar and opens the workshop modal when tapped
class StoryWorkshopIndicator extends StatelessWidget {
  const StoryWorkshopIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryWorkshopBloc, StoryWorkshopState>(
      builder: (context, state) {
        if (state is! StoryWorkshopActive || !state.hasJobs) {
          return const SizedBox.shrink();
        }

        final activeCount = state.activeJobs.length;
        final failedCount = state.failedJobs.length;

        return GestureDetector(
          onTap: () => StoryWorkshopDialog.show(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getIndicatorColor(state),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getBorderColor(state),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIndicatorIcon(state),
                const SizedBox(width: 6),
                ResponsiveText(
                  text: _getIndicatorText(activeCount, failedCount),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(state),
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicatorIcon(StoryWorkshopActive state) {
    if (state.hasOnlyFailedJobs) {
      return const Icon(
        Icons.error,
        size: 16,
        color: StoryTalesTheme.errorColor,
      );
    }

    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(StoryTalesTheme.primaryColor),
      ),
    );
  }

  Color _getIndicatorColor(StoryWorkshopActive state) {
    if (state.hasOnlyFailedJobs) {
      return StoryTalesTheme.errorColor.withValues(alpha: 0.1);
    }
    return StoryTalesTheme.primaryColor.withValues(alpha: 0.1);
  }

  Color _getBorderColor(StoryWorkshopActive state) {
    if (state.hasOnlyFailedJobs) {
      return StoryTalesTheme.errorColor.withValues(alpha: 0.3);
    }
    return StoryTalesTheme.primaryColor.withValues(alpha: 0.3);
  }

  Color _getTextColor(StoryWorkshopActive state) {
    if (state.hasOnlyFailedJobs) {
      return StoryTalesTheme.errorColor;
    }
    return StoryTalesTheme.primaryColor;
  }

  String _getIndicatorText(int activeCount, int failedCount) {
    if (activeCount > 0 && failedCount > 0) {
      return '$activeCount generating, $failedCount failed';
    } else if (activeCount > 0) {
      return activeCount == 1 ? '1 story generating' : '$activeCount stories generating';
    } else if (failedCount > 0) {
      return failedCount == 1 ? '1 story failed' : '$failedCount stories failed';
    }
    return '';
  }
}
