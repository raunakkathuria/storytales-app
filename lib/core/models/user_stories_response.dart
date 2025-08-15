import 'package:storytales/core/models/pagination_info.dart';

/// Model representing a user story item from the API.
class UserStoryItem {
  final String id;
  final String title;
  final String summary;
  final String coverImagePath;
  final DateTime createdAt;
  final String author;
  final String? ageRange;
  final String readingTime;
  final String? originalPrompt;
  final String? genre;
  final String? theme;
  final List<String> tags;

  const UserStoryItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.coverImagePath,
    required this.createdAt,
    required this.author,
    this.ageRange,
    required this.readingTime,
    this.originalPrompt,
    this.genre,
    this.theme,
    required this.tags,
  });

  /// Creates a UserStoryItem from JSON response.
  factory UserStoryItem.fromJson(Map<String, dynamic> json) {
    return UserStoryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      coverImagePath: json['cover_image_path'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: json['author'] as String,
      ageRange: json['age_range'] as String?,
      readingTime: json['reading_time'] as String,
      originalPrompt: json['original_prompt'] as String?,
      genre: json['genre'] as String?,
      theme: json['theme'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Converts UserStoryItem to JSON for caching.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'cover_image_path': coverImagePath,
      'created_at': createdAt.toIso8601String(),
      'author': author,
      'age_range': ageRange,
      'reading_time': readingTime,
      'original_prompt': originalPrompt,
      'genre': genre,
      'theme': theme,
      'tags': tags,
    };
  }

  @override
  String toString() {
    return 'UserStoryItem(id: $id, title: $title, author: $author, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStoryItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model representing the paginated user stories API response.
class UserStoriesResponse {
  final List<UserStoryItem> stories;
  final PaginationInfo pagination;
  final String subscriptionTier;
  final int storiesRemaining;

  const UserStoriesResponse({
    required this.stories,
    required this.pagination,
    required this.subscriptionTier,
    required this.storiesRemaining,
  });

  /// Creates a UserStoriesResponse from JSON response.
  factory UserStoriesResponse.fromJson(Map<String, dynamic> json) {
    return UserStoriesResponse(
      stories: (json['stories'] as List<dynamic>)
          .map((story) => UserStoryItem.fromJson(story as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
      subscriptionTier: json['subscription_tier'] as String,
      storiesRemaining: json['stories_remaining'] as int,
    );
  }

  /// Converts UserStoriesResponse to JSON for caching.
  Map<String, dynamic> toJson() {
    return {
      'stories': stories.map((story) => story.toJson()).toList(),
      'pagination': pagination.toJson(),
      'subscription_tier': subscriptionTier,
      'stories_remaining': storiesRemaining,
    };
  }

  /// Creates a copy with updated values.
  UserStoriesResponse copyWith({
    List<UserStoryItem>? stories,
    PaginationInfo? pagination,
    String? subscriptionTier,
    int? storiesRemaining,
  }) {
    return UserStoriesResponse(
      stories: stories ?? this.stories,
      pagination: pagination ?? this.pagination,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      storiesRemaining: storiesRemaining ?? this.storiesRemaining,
    );
  }

  @override
  String toString() {
    return 'UserStoriesResponse(stories: ${stories.length}, pagination: $pagination, subscriptionTier: $subscriptionTier, storiesRemaining: $storiesRemaining)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStoriesResponse &&
        other.stories.length == stories.length &&
        other.pagination == pagination &&
        other.subscriptionTier == subscriptionTier &&
        other.storiesRemaining == storiesRemaining;
  }

  @override
  int get hashCode {
    return Object.hash(
      stories.length,
      pagination,
      subscriptionTier,
      storiesRemaining,
    );
  }
}
