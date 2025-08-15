import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/animated_logo.dart';
import 'package:storytales/core/widgets/responsive_button.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import '../bloc/story_workshop_bloc.dart';
import '../bloc/story_workshop_event.dart';
import '../bloc/story_workshop_state.dart';

/// Modal overlay for managing multiple story generations
class StoryWorkshopModal extends StatelessWidget {
  const StoryWorkshopModal({super.key});

  /// Show the Story Workshop modal
  static Future<void> show(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StoryWorkshopModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryWorkshopBloc, StoryWorkshopState>(
      builder: (context, state) {
        // Auto-close modal if no jobs remain
        if (state is StoryWorkshopInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
          return const SizedBox.shrink();
        }

        if (state is StoryWorkshopActive) {
          return _buildWorkshopContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildWorkshopContent(BuildContext context, StoryWorkshopActive state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildJobsList(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: StoryTalesTheme.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const AnimatedLogo(size: 40),
          const SizedBox(width: 12),
          const Expanded(
            child: ResponsiveText(
              text: 'Story Workshop',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: StoryTalesTheme.fontFamilyHeading,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(BuildContext context, StoryWorkshopActive state) {
    final allJobs = <StoryGenerationJob>[
      ...state.activeJobs.values,
      ...state.failedJobs.values,
    ];

    if (allJobs.isEmpty) {
      return const Center(
        child: ResponsiveText(
          text: 'No active story generations',
          style: TextStyle(
            color: StoryTalesTheme.textLightColor,
            fontSize: 16,
            fontFamily: StoryTalesTheme.fontFamilyBody,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allJobs.length,
      itemBuilder: (context, index) {
        final job = allJobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildJobCard(context, job),
        );
      },
    );
  }

  Widget _buildJobCard(BuildContext context, StoryGenerationJob job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getCardColor(job.status),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(job.status),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobHeader(context, job),
          const SizedBox(height: 12),
          _buildJobContent(context, job),
          if (job.status == StoryJobStatus.generating) ...[
            const SizedBox(height: 12),
            _buildProgressBar(job),
          ],
          if (job.status == StoryJobStatus.failed) ...[
            const SizedBox(height: 12),
            _buildFailedActions(context, job),
          ],
        ],
      ),
    );
  }

  Widget _buildJobHeader(BuildContext context, StoryGenerationJob job) {
    return Row(
      children: [
        _buildStatusIcon(job.status),
        const SizedBox(width: 8),
        Expanded(
          child: ResponsiveText(
            text: job.displayTitle,
            style: const TextStyle(
              fontSize: 18,
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
            fontSize: 14,
            color: StoryTalesTheme.textLightColor,
            fontFamily: StoryTalesTheme.fontFamilyBody,
          ),
        ),
      ],
    );
  }

  Widget _buildJobContent(BuildContext context, StoryGenerationJob job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (job.ageRange != null) ...[
          ResponsiveText(
            text: 'Age Range: ${job.ageRange}',
            style: const TextStyle(
              fontSize: 14,
              color: StoryTalesTheme.textLightColor,
              fontFamily: StoryTalesTheme.fontFamilyBody,
            ),
          ),
          const SizedBox(height: 4),
        ],
        ResponsiveText(
          text: _getStatusMessage(job),
          style: TextStyle(
            fontSize: 14,
            color: _getStatusColor(job.status),
            fontFamily: StoryTalesTheme.fontFamilyBody,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (job.error != null) ...[
          const SizedBox(height: 8),
          ResponsiveText(
            text: job.error!,
            style: const TextStyle(
              fontSize: 14,
              color: StoryTalesTheme.errorColor,
              fontFamily: StoryTalesTheme.fontFamilyBody,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
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
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildFailedActions(BuildContext context, StoryGenerationJob job) {
    return Row(
      children: [
        Expanded(
          child: ResponsiveButton.outlined(
            text: 'Retry',
            onPressed: () {
              context.read<StoryWorkshopBloc>().add(RetryJob(jobId: job.jobId));
            },
            icon: Icons.refresh,
            borderColor: StoryTalesTheme.primaryColor,
            textColor: StoryTalesTheme.primaryColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ResponsiveButton.outlined(
            text: 'Dismiss',
            onPressed: () {
              context.read<StoryWorkshopBloc>().add(DismissFailedJob(jobId: job.jobId));
            },
            icon: Icons.close,
            borderColor: StoryTalesTheme.errorColor,
            textColor: StoryTalesTheme.errorColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(StoryJobStatus status) {
    switch (status) {
      case StoryJobStatus.generating:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(StoryTalesTheme.primaryColor),
          ),
        );
      case StoryJobStatus.completed:
        return const Icon(
          Icons.check_circle,
          color: StoryTalesTheme.successColor,
          size: 20,
        );
      case StoryJobStatus.failed:
        return const Icon(
          Icons.error,
          color: StoryTalesTheme.errorColor,
          size: 20,
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
        return StoryTalesTheme.primaryColor.withValues(alpha: 0.3);
      case StoryJobStatus.completed:
        return StoryTalesTheme.successColor.withValues(alpha: 0.3);
      case StoryJobStatus.failed:
        return StoryTalesTheme.errorColor.withValues(alpha: 0.3);
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
}
