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
      total: json['total'] as int,
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      hasNext: json['has_next'] as bool,
      hasPrevious: json['has_previous'] as bool,
      limit: json['limit'] as int,
    );
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
