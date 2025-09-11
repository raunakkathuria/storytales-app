/// Model representing pagination metadata for API responses.
class PaginationInfo {
  final int total;
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final int limit;

  const PaginationInfo({
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.limit,
  });

  /// Creates a PaginationInfo from JSON response.
  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: _parseIntSafely(json['total']) ?? 0,
      currentPage: _parseIntSafely(json['current_page']) ?? 1,
      totalPages: _parseIntSafely(json['total_pages']) ?? 0,
      hasNext: _parseBoolSafely(json['has_next']) ?? false,
      hasPrevious: _parseBoolSafely(json['has_previous']) ?? false,
      limit: _parseIntSafely(json['limit']) ?? 10,
    );
  }

  /// Safely parses an integer from various input types, allowing null.
  static int? _parseIntSafely(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  /// Safely parses a boolean from various input types, allowing null.
  static bool? _parseBoolSafely(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  /// Converts PaginationInfo to JSON for caching.
  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'current_page': currentPage,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_previous': hasPrevious,
      'limit': limit,
    };
  }

  /// Creates a copy with updated values.
  PaginationInfo copyWith({
    int? total,
    int? currentPage,
    int? totalPages,
    bool? hasNext,
    bool? hasPrevious,
    int? limit,
  }) {
    return PaginationInfo(
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
      limit: limit ?? this.limit,
    );
  }

  @override
  String toString() {
    return 'PaginationInfo(total: $total, currentPage: $currentPage, totalPages: $totalPages, hasNext: $hasNext, hasPrevious: $hasPrevious, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationInfo &&
        other.total == total &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.hasNext == hasNext &&
        other.hasPrevious == hasPrevious &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    return Object.hash(
      total,
      currentPage,
      totalPages,
      hasNext,
      hasPrevious,
      limit,
    );
  }
}
