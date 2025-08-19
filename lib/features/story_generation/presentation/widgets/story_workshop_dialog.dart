import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/animated_logo.dart';
import 'package:storytales/core/widgets/dialog_form.dart';
import 'package:storytales/core/widgets/responsive_button.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../bloc/story_workshop_bloc.dart';
import '../bloc/story_workshop_event.dart';
import '../bloc/story_workshop_state.dart';

/// Simple dialog for showing story generation progress
class StoryWorkshopDialog extends StatelessWidget {
  const StoryWorkshopDialog({super.key});

  /// Show the Story Workshop dialog
  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // Don't allow dismissing during generation
      builder: (context) => const StoryWorkshopDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryWorkshopBloc, StoryWorkshopState>(
      builder: (context, state) {
        // Auto-close dialog if no jobs remain
        if (state is StoryWorkshopInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
          return const SizedBox.shrink();
        }

        if (state is StoryWorkshopActive) {
          return _buildDialog(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDialog(BuildContext context, StoryWorkshopActive state) {
    final allJobs = <StoryGenerationJob>[
      ...state.activeJobs.values,
      ...state.failedJobs.values,
    ];

    return DialogForm(
      title: '', // Empty title since we show it in the header
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with logo and title
          _buildHeader(),
          const SizedBox(height: 20),

          // Jobs list - compact and focused
          ...allJobs.map((job) => _buildJobItem(context, job)),
        ],
      ),
      primaryActionText: 'Close',
      onPrimaryAction: () => Navigator.pop(context),
      secondaryActionText: '', // No secondary action needed
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AnimatedLogo(size: 60),
        const SizedBox(height: 12),
        const ResponsiveText(
          text: 'Story Workshop',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: StoryTalesTheme.fontFamilyHeading,
            color: StoryTalesTheme.accentColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildJobItem(BuildContext context, StoryGenerationJob job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(job.status),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(job.status),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Job title and status
          Row(
            children: [
              _buildStatusIcon(job.status),
              const SizedBox(width: 8),
              Expanded(
                child: ResponsiveText(
                  text: job.displayTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: StoryTalesTheme.fontFamilyHeading,
                    color: StoryTalesTheme.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ResponsiveText(
                text: job.estimatedTime,
                style: const TextStyle(
                  fontSize: 12,
                  color: StoryTalesTheme.textLightColor,
                  fontFamily: StoryTalesTheme.fontFamilyBody,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Status message
          ResponsiveText(
            text: _getStatusMessage(job),
            style: TextStyle(
              fontSize: 14,
              color: _getStatusColor(job.status),
              fontFamily: StoryTalesTheme.fontFamilyBody,
            ),
          ),

          // Progress bar for generating stories
          if (job.status == StoryJobStatus.generating) ...[
            const SizedBox(height: 12),
            _buildProgressBar(job),
          ],

          // Error message for failed stories
          if (job.error != null) ...[
            const SizedBox(height: 8),
            ResponsiveText(
              text: _getUserFriendlyErrorMessage(job.error),
              style: const TextStyle(
                fontSize: 12,
                color: StoryTalesTheme.errorColor,
                fontFamily: StoryTalesTheme.fontFamilyBody,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Action buttons for failed stories
          if (job.status == StoryJobStatus.failed) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ResponsiveButton.outlined(
                  text: 'Dismiss',
                  onPressed: () {
                    context.read<StoryWorkshopBloc>().add(DismissFailedJob(jobId: job.jobId));
                  },
                  icon: Icons.close,
                  borderColor: StoryTalesTheme.textLightColor,
                  textColor: StoryTalesTheme.textLightColor,
                  fontSize: 14,
                ),
                const SizedBox(width: 8),
                ResponsiveButton.primary(
                  text: 'Retry',
                  onPressed: () {
                    context.read<StoryWorkshopBloc>().add(RetryJob(jobId: job.jobId));
                  },
                  icon: Icons.refresh,
                  fontSize: 14,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(StoryGenerationJob job) {
    final progress = job.progress ?? 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ResponsiveText(
              text: 'Progress',
              style: TextStyle(
                fontSize: 12,
                color: StoryTalesTheme.textLightColor,
                fontFamily: StoryTalesTheme.fontFamilyBody,
              ),
            ),
            ResponsiveText(
              text: '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                color: StoryTalesTheme.primaryColor,
                fontFamily: StoryTalesTheme.fontFamilyBody,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: StoryTalesTheme.backgroundColor,
          valueColor: const AlwaysStoppedAnimation<Color>(StoryTalesTheme.primaryColor),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildStatusIcon(StoryJobStatus status) {
    switch (status) {
      case StoryJobStatus.generating:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(StoryTalesTheme.primaryColor),
          ),
        );
      case StoryJobStatus.completed:
        return const Icon(
          Icons.check_circle,
          color: StoryTalesTheme.successColor,
          size: 16,
        );
      case StoryJobStatus.failed:
        return const Icon(
          Icons.error,
          color: StoryTalesTheme.errorColor,
          size: 16,
        );
    }
  }

  Color _getCardColor(StoryJobStatus status) {
    switch (status) {
      case StoryJobStatus.generating:
        return StoryTalesTheme.primaryColor.withValues(alpha: 0.05);
      case StoryJobStatus.completed:
        return StoryTalesTheme.successColor.withValues(alpha: 0.05);
      case StoryJobStatus.failed:
        return StoryTalesTheme.errorColor.withValues(alpha: 0.05);
    }
  }

  Color _getBorderColor(StoryJobStatus status) {
    switch (status) {
      case StoryJobStatus.generating:
        return StoryTalesTheme.primaryColor.withValues(alpha: 0.2);
      case StoryJobStatus.completed:
        return StoryTalesTheme.successColor.withValues(alpha: 0.2);
      case StoryJobStatus.failed:
        return StoryTalesTheme.errorColor.withValues(alpha: 0.2);
    }
  }

  Color _getStatusColor(StoryJobStatus status) {
    switch (status) {
      case StoryJobStatus.generating:
        return StoryTalesTheme.primaryColor;
      case StoryJobStatus.completed:
        return StoryTalesTheme.successColor;
      case StoryJobStatus.failed:
        return StoryTalesTheme.errorColor;
    }
  }

  String _getStatusMessage(StoryGenerationJob job) {
    switch (job.status) {
      case StoryJobStatus.generating:
        return 'Creating your magical story...';
      case StoryJobStatus.completed:
        return 'Story completed and added to library!';
      case StoryJobStatus.failed:
        return 'Story generation failed';
    }
  }

  /// Converts technical error messages to user-friendly messages
  String _getUserFriendlyErrorMessage(String? technicalError) {
    if (technicalError == null || technicalError.isEmpty) {
      return 'An unexpected error occurred while creating your story';
    }

    final errorLower = technicalError.toLowerCase();

    // Map common technical errors to user-friendly messages
    if (errorLower.contains('null') && errorLower.contains('string')) {
      return 'Story generation failed due to missing information';
    }

    if (errorLower.contains('network') || errorLower.contains('connection')) {
      return 'Network connection issue - please check your internet';
    }

    if (errorLower.contains('timeout') || errorLower.contains('time out')) {
      return 'Story generation took too long - please try again';
    }

    if (errorLower.contains('server') || errorLower.contains('503') || errorLower.contains('502')) {
      return 'Our story service is temporarily unavailable';
    }

    if (errorLower.contains('rate limit') || errorLower.contains('too many requests')) {
      return 'Too many stories generated recently - please wait a moment';
    }

    if (errorLower.contains('authentication') || errorLower.contains('unauthorized')) {
      return 'Authentication issue - please restart the app';
    }

    if (errorLower.contains('format') || errorLower.contains('parse') || errorLower.contains('json')) {
      return 'Story data format error - please try again';
    }

    // Generic fallback for unknown errors
    return 'Story generation failed - please try again';
  }
}
