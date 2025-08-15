import 'package:equatable/equatable.dart';
import 'story_workshop_state.dart';

/// Events for the Story Workshop BLoC
abstract class StoryWorkshopEvent extends Equatable {
  const StoryWorkshopEvent();

  @override
  List<Object?> get props => [];
}

/// Start a new story generation job
class StartStoryGeneration extends StoryWorkshopEvent {
  final String prompt;
  final String? ageRange;
  final String? theme;
  final String? genre;

  const StartStoryGeneration({
    required this.prompt,
    this.ageRange,
    this.theme,
    this.genre,
  });

  @override
  List<Object?> get props => [prompt, ageRange, theme, genre];
}

/// Update progress of an active job
class UpdateJobProgress extends StoryWorkshopEvent {
  final String jobId;
  final double progress;

  const UpdateJobProgress({
    required this.jobId,
    required this.progress,
  });

  @override
  List<Object?> get props => [jobId, progress];
}

/// Mark a job as completed
class CompleteJob extends StoryWorkshopEvent {
  final String jobId;

  const CompleteJob({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Mark a job as failed
class FailJob extends StoryWorkshopEvent {
  final String jobId;
  final String error;

  const FailJob({
    required this.jobId,
    required this.error,
  });

  @override
  List<Object?> get props => [jobId, error];
}

/// Retry a failed job
class RetryJob extends StoryWorkshopEvent {
  final String jobId;

  const RetryJob({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Dismiss a failed job
class DismissFailedJob extends StoryWorkshopEvent {
  final String jobId;

  const DismissFailedJob({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Clear all completed jobs (immediate cleanup)
class ClearCompletedJobs extends StoryWorkshopEvent {
  const ClearCompletedJobs();
}

/// Initialize workshop with existing jobs (on app restart)
class InitializeWorkshop extends StoryWorkshopEvent {
  final Map<String, StoryGenerationJob> activeJobs;
  final Map<String, StoryGenerationJob> failedJobs;

  const InitializeWorkshop({
    required this.activeJobs,
    required this.failedJobs,
  });

  @override
  List<Object?> get props => [activeJobs, failedJobs];
}
