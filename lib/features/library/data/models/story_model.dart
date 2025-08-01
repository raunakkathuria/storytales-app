import 'package:storytales/features/library/domain/entities/story.dart';
import 'package:uuid/uuid.dart';

/// Data model for [Story] that adds serialization/deserialization functionality.
class StoryModel extends Story {
  StoryModel({
    required super.id,
    required super.title,
    required super.summary,
    required super.coverImagePath,
    required super.createdAt,
    required super.author,
    required super.ageRange,
    required super.readingTime,
    required super.originalPrompt,
    required super.genre,
    required super.theme,
    required super.tags,
    required super.isPregenerated,
    required super.isFavorite,
    required super.pages,
    required super.questions,
  });

  /// Convert from pre-generated stories JSON format
  factory StoryModel.fromPreGeneratedJson(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    final data = json['data'];
    final uuid = const Uuid();
    final storyId = 'pre_gen_${uuid.v4()}';

    final pages = (data['pages'] as List).asMap().entries.map((entry) {
      return StoryPageModel(
        id: 'page_${uuid.v4()}',
        storyId: storyId,
        pageNumber: entry.key,
        content: entry.value['content'],
        imagePath: entry.value['image_url'],
      );
    }).toList();

    final questions = List<String>.from(data['questions']);

    return StoryModel(
      id: storyId,
      title: data['title'],
      summary: data['summary'],
      coverImagePath: data['cover_image_url'],
      createdAt: DateTime.parse(metadata['created_at']),
      author: metadata['author'],
      ageRange: metadata['age_range'],
      readingTime: metadata['reading_time'],
      originalPrompt: metadata['original_prompt'],
      genre: metadata['genre'],
      theme: metadata['theme'],
      tags: List<String>.from(metadata['tags']),
      isPregenerated: true,
      isFavorite: false,
      pages: pages,
      questions: questions,
    );
  }

  /// Convert from AI response JSON format
  factory StoryModel.fromAiResponseJson(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    final data = json['data'];
    final uuid = const Uuid();
    final storyId = 'ai_gen_${uuid.v4()}';

    final pages = (data['pages'] as List).asMap().entries.map((entry) {
      return StoryPageModel(
        id: 'page_${uuid.v4()}',
        storyId: storyId,
        pageNumber: entry.key,
        content: entry.value['content'],
        imagePath: entry.value['image_url'],
      );
    }).toList();

    final questions = List<String>.from(data['questions']);

    return StoryModel(
      id: storyId,
      title: data['title'],
      summary: data['summary'],
      coverImagePath: data['cover_image_url'],
      createdAt: DateTime.parse(metadata['created_at']),
      author: metadata['author'],
      ageRange: metadata['age_range'],
      readingTime: metadata['reading_time'],
      originalPrompt: metadata['original_prompt'],
      genre: metadata['genre'],
      theme: metadata['theme'],
      tags: List<String>.from(metadata['tags']),
      isPregenerated: false,
      isFavorite: false,
      pages: pages,
      questions: questions,
    );
  }

  /// Convert from database map
  factory StoryModel.fromDbMap(
    Map<String, dynamic> map,
    List<StoryPageModel> pages,
    List<String> tags,
    List<String> questions,
  ) {
    return StoryModel(
      id: map['id'],
      title: map['title'],
      summary: map['summary'],
      coverImagePath: map['cover_image_path'],
      createdAt: DateTime.parse(map['created_at']),
      author: map['author'],
      ageRange: map['age_range'],
      readingTime: map['reading_time'],
      originalPrompt: map['original_prompt'],
      genre: map['genre'],
      theme: map['theme'],
      tags: tags,
      isPregenerated: map['is_pregenerated'] == 1,
      isFavorite: map['is_favorite'] == 1,
      pages: pages,
      questions: questions,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() {
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
      'is_pregenerated': isPregenerated ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  /// Create a copy of this StoryModel with the given fields replaced with the new values.
  @override
  StoryModel copyWith({
    String? id,
    String? title,
    String? summary,
    String? coverImagePath,
    DateTime? createdAt,
    String? author,
    String? ageRange,
    String? readingTime,
    String? originalPrompt,
    String? genre,
    String? theme,
    List<String>? tags,
    bool? isPregenerated,
    bool? isFavorite,
    List<StoryPage>? pages,
    List<String>? questions,
  }) {
    return StoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
      ageRange: ageRange ?? this.ageRange,
      readingTime: readingTime ?? this.readingTime,
      originalPrompt: originalPrompt ?? this.originalPrompt,
      genre: genre ?? this.genre,
      theme: theme ?? this.theme,
      tags: tags ?? this.tags,
      isPregenerated: isPregenerated ?? this.isPregenerated,
      isFavorite: isFavorite ?? this.isFavorite,
      pages: pages ?? this.pages,
      questions: questions ?? this.questions,
    );
  }
}

/// Data model for [StoryPage] that adds serialization/deserialization functionality.
class StoryPageModel extends StoryPage {
  StoryPageModel({
    required super.id,
    required super.storyId,
    required super.pageNumber,
    required super.content,
    required super.imagePath,
  });

  /// Convert from database map
  factory StoryPageModel.fromDbMap(Map<String, dynamic> map) {
    return StoryPageModel(
      id: map['id'],
      storyId: map['story_id'],
      pageNumber: map['page_number'],
      content: map['content'],
      imagePath: map['image_path'],
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'story_id': storyId,
      'page_number': pageNumber,
      'content': content,
      'image_path': imagePath,
    };
  }

  /// Create a copy of this StoryPageModel with the given fields replaced with the new values.
  StoryPageModel copyWith({
    String? id,
    String? storyId,
    int? pageNumber,
    String? content,
    String? imagePath,
  }) {
    return StoryPageModel(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      pageNumber: pageNumber ?? this.pageNumber,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

/// Data model for [StoryTag] that adds serialization/deserialization functionality.
class StoryTagModel extends StoryTag {
  StoryTagModel({
    required super.id,
    required super.storyId,
    required super.tag,
  });

  /// Convert from database map
  factory StoryTagModel.fromDbMap(Map<String, dynamic> map) {
    return StoryTagModel(
      id: map['id'],
      storyId: map['story_id'],
      tag: map['tag'],
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'story_id': storyId,
      'tag': tag,
    };
  }

  /// Create a copy of this StoryTagModel with the given fields replaced with the new values.
  StoryTagModel copyWith({
    String? id,
    String? storyId,
    String? tag,
  }) {
    return StoryTagModel(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      tag: tag ?? this.tag,
    );
  }
}

/// Data model for [StoryQuestion] that adds serialization/deserialization functionality.
class StoryQuestionModel extends StoryQuestion {
  StoryQuestionModel({
    required super.id,
    required super.storyId,
    required super.questionText,
    required super.questionOrder,
  });

  /// Convert from database map
  factory StoryQuestionModel.fromDbMap(Map<String, dynamic> map) {
    return StoryQuestionModel(
      id: map['id'],
      storyId: map['story_id'],
      questionText: map['question_text'],
      questionOrder: map['question_order'],
    );
  }

  /// Convert to database map
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'story_id': storyId,
      'question_text': questionText,
      'question_order': questionOrder,
    };
  }

  /// Create a copy of this StoryQuestionModel with the given fields replaced with the new values.
  StoryQuestionModel copyWith({
    String? id,
    String? storyId,
    String? questionText,
    int? questionOrder,
  }) {
    return StoryQuestionModel(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      questionText: questionText ?? this.questionText,
      questionOrder: questionOrder ?? this.questionOrder,
    );
  }
}
