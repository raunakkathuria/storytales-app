/// Response model for background job operations
class JobResponse {
  final String jobId;
  final String status;
  final String message;
  final String checkStatusUrl;
  final String getResultUrl;
  final String estimatedTime;

  const JobResponse({
    required this.jobId,
    required this.status,
    required this.message,
    required this.checkStatusUrl,
    required this.getResultUrl,
    required this.estimatedTime,
  });

  factory JobResponse.fromJson(Map<String, dynamic> json) {
    return JobResponse(
      jobId: json['job_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      checkStatusUrl: json['check_status_url'] as String,
      getResultUrl: json['get_result_url'] as String,
      estimatedTime: json['estimated_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'status': status,
      'message': message,
      'check_status_url': checkStatusUrl,
      'get_result_url': getResultUrl,
      'estimated_time': estimatedTime,
    };
  }
}
