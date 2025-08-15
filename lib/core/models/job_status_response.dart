/// Response model for job status checking
class JobStatusResponse {
  final String jobId;
  final String status;
  final String? progress;
  final String? estimatedRemaining;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? error;

  const JobStatusResponse({
    required this.jobId,
    required this.status,
    this.progress,
    this.estimatedRemaining,
    required this.startedAt,
    this.completedAt,
    this.error,
  });

  factory JobStatusResponse.fromJson(Map<String, dynamic> json) {
    return JobStatusResponse(
      jobId: json['job_id'] as String,
      status: json['status'] as String,
      progress: json['progress'] as String?,
      estimatedRemaining: json['estimated_remaining'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'status': status,
      'progress': progress,
      'estimated_remaining': estimatedRemaining,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'error': error,
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing' || status == 'started';
}
