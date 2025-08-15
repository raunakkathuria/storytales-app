import 'package:equatable/equatable.dart';

/// States for the Story Workshop (modal overlay system)
abstract class StoryWorkshopState extends Equatable {
  const StoryWorkshopState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no active generations
class StoryWorkshopInitial extends StoryWorkshopState {
  const StoryWorkshopInitial();
}

/// State with active story generations
class StoryWorkshopActive extends StoryWorkshopState {
  final Map<String, StoryGenerationJob> activeJobs;
  final Map<String, StoryGenerationJob> failedJobs;

  const StoryWorkshopActive({
    required this.activeJobs,
    required this.failedJobs,
  });

  @override
  List<Object?> get props => [activeJobs, failedJobs];

  /// Check if there are any jobs (active or failed)
  bool get hasJobs => activeJobs.isNotEmpty || failedJobs.isNotEmpty;

  /// Check if there are only failed jobs (no active ones)
  bool get hasOnlyFailedJobs => activeJobs.isEmpty && failedJobs.isNotEmpty;
}

/// Individual story generation job
class StoryGenerationJob extends Equatable {
  final String jobId;
  final String tempStoryId;
  final String prompt;
  final String? ageRange;
  final String? theme;
  final String? genre;
  final DateTime startTime;
  final StoryJobStatus status;
  final double? progress;
  final String? error;

  const StoryGenerationJob({
    required this.jobId,
    required this.tempStoryId,
    required this.prompt,
    this.ageRange,
    this.theme,
    this.genre,
    required this.startTime,
    required this.status,
    this.progress,
    this.error,
  });

  @override
  List<Object?> get props => [
    jobId,
    tempStoryId,
    prompt,
    ageRange,
    theme,
    genre,
    startTime,
    status,
    progress,
    error,
  ];

  /// Create a copy with updated fields
  StoryGenerationJob copyWith({
    String? jobId,
    String? tempStoryId,
    String? prompt,
    String? ageRange,
    String? theme,
    String? genre,
    DateTime? startTime,
    StoryJobStatus? status,
    double? progress,
    String? error,
  }) {
    return StoryGenerationJob(
      jobId: jobId ?? this.jobId,
      tempStoryId: tempStoryId ?? this.tempStoryId,
      prompt: prompt ?? this.prompt,
      ageRange: ageRange ?? this.ageRange,
      theme: theme ?? this.theme,
      genre: genre ?? this.genre,
      startTime: startTime ?? this.startTime,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }

  /// Get display title for the job
  String get displayTitle {
    if (prompt.length <= 30) return prompt;
    return '${prompt.substring(0, 27)}...';
  }

  /// Get estimated completion time
  String get estimatedTime {
    switch (status) {
      case StoryJobStatus.generating:
        return '2-5 minutes';
      case StoryJobStatus.completed:
        return 'Complete';
      case StoryJobStatus.failed:
        return 'Failed';
    }
  }
}

/// Status of a story generation job
enum StoryJobStatus {
  generating,
  completed,
  failed,
}
