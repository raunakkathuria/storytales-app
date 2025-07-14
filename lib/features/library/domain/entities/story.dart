/// Entity representing a story in the app.
class Story {
  final String id;
  final String title;
  final String summary;
  final List<StoryPage> pages;
  final List<String> questions;
  final String coverImagePath;
  final String readingTime;
  final DateTime createdAt;
  final String author;
  final String? ageRange;
  final String? originalPrompt;
  final String? genre;
  final String? theme;
  final List<String> tags;
  final bool isPregenerated;
  final bool isFavorite;

  Story({
    required this.id,
    required this.title,
    required this.summary,
    required this.pages,
    required this.questions,
    required this.coverImagePath,
    required this.readingTime,
    required this.createdAt,
    required this.author,
    required this.isPregenerated,
    required this.isFavorite,
    required this.tags,
    this.ageRange,
    this.originalPrompt,
    this.genre,
    this.theme,
  });

  /// Create a copy of this Story with the given fields replaced with the new values.
  Story copyWith({
    String? id,
    String? title,
    String? summary,
    List<StoryPage>? pages,
    List<String>? questions,
    String? coverImagePath,
    String? readingTime,
    DateTime? createdAt,
    String? author,
    String? ageRange,
    String? originalPrompt,
    String? genre,
    String? theme,
    List<String>? tags,
    bool? isPregenerated,
    bool? isFavorite,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      pages: pages ?? this.pages,
      questions: questions ?? this.questions,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      readingTime: readingTime ?? this.readingTime,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
      ageRange: ageRange ?? this.ageRange,
      originalPrompt: originalPrompt ?? this.originalPrompt,
      genre: genre ?? this.genre,
      theme: theme ?? this.theme,
      tags: tags ?? this.tags,
      isPregenerated: isPregenerated ?? this.isPregenerated,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// Entity representing a page in a story.
class StoryPage {
  final String id;
  final String storyId;
  final int pageNumber;
  final String content;
  final String imagePath;

  StoryPage({
    required this.id,
    required this.storyId,
    required this.pageNumber,
    required this.content,
    required this.imagePath,
  });
}

/// Entity representing a tag for a story.
class StoryTag {
  final String id;
  final String storyId;
  final String tag;

  StoryTag({
    required this.id,
    required this.storyId,
    required this.tag,
  });
}

/// Entity representing a discussion question for a story.
class StoryQuestion {
  final String id;
  final String storyId;
  final String questionText;
  final int questionOrder;

  StoryQuestion({
    required this.id,
    required this.storyId,
    required this.questionText,
    required this.questionOrder,
  });
}
