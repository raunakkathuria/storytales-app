# StoryTales Data Model

This document outlines the data model for the StoryTales app. It describes the database schema, entity relationships, and data structures for the application.

## Current Data Model Status

- **Phase 1**: ✅ Completed (April 2025) - Local SQLite database
- **Phase 2**: 🚧 In Progress - Adding user profiles and cloud storage

For Phase 2 data model extensions, please refer to the [Phase 2 Data Model Extensions](phase-two/data-model-extensions.md) document.

---

# Phase 1 Data Model

The following sections describe the original data model implemented in Phase 1, which focuses on local storage using SQLite.

## Database Schema

The app uses SQLite for local storage with the following tables:

### 1. Stories Table

Stores metadata about each story.

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT | Primary key, unique identifier for the story |
| title | TEXT | Story title |
| summary | TEXT | Brief summary of the story |
| cover_image_path | TEXT | Path to the cover image |
| created_at | TEXT | ISO timestamp when the story was created |
| author | TEXT | Author of the story (e.g., "StoryTales AI") |
| age_range | TEXT | Target age range (e.g., "3-6") |
| reading_time | TEXT | Estimated reading time (e.g., "5 min") |
| original_prompt | TEXT | The prompt used to generate the story |
| genre | TEXT | Story genre (e.g., "Fantasy") |
| theme | TEXT | Story theme (e.g., "Friendship") |
| is_pregenerated | INTEGER | Boolean flag (0/1) indicating if this is a pre-generated story |
| is_favorite | INTEGER | Boolean flag (0/1) indicating if the story is marked as favorite |

### 2. Story Tags Table

Stores tags associated with stories.

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT | Primary key, unique identifier for the tag entry |
| story_id | TEXT | Foreign key referencing stories.id |
| tag | TEXT | Tag value (e.g., "fantasy") |

### 3. Pages Table

Stores individual pages of each story.

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT | Primary key, unique identifier for the page |
| story_id | TEXT | Foreign key referencing stories.id |
| page_number | INTEGER | Page number within the story (0-based index) |
| content | TEXT | Text content of the page |
| image_path | TEXT | Path to the page's illustration image |

### 4. Questions Table

Stores discussion questions for each story.

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT | Primary key, unique identifier for the question |
| story_id | TEXT | Foreign key referencing stories.id |
| question_text | TEXT | Text of the discussion question |
| question_order | INTEGER | Order of the question in the list (0-based index) |

## Entity Relationships

```
Story (1) ---> (*) Page
Story (1) ---> (*) DiscussionQuestion
```

- A Story has multiple Pages (one-to-many relationship)
- A Story has multiple DiscussionQuestions (one-to-many relationship)

## Domain Entities

### Story Entity

```dart
class Story {
  final String id;
  final String title;
  final String summary;
  final String coverImagePath;
  final DateTime createdAt;
  final String author;
  final String ageRange;
  final String readingTime;
  final String originalPrompt;
  final String genre;
  final String theme;
  final List<String> tags;
  final bool isPregenerated;
  final bool isFavorite;
  final List<StoryPage> pages;
  final List<String> questions;

  Story({
    required this.id,
    required this.title,
    required this.summary,
    required this.coverImagePath,
    required this.createdAt,
    required this.author,
    required this.ageRange,
    required this.readingTime,
    required this.originalPrompt,
    required this.genre,
    required this.theme,
    required this.tags,
    required this.isPregenerated,
    required this.isFavorite,
    required this.pages,
    required this.questions,
  });
}
```

### StoryPage Entity

```dart
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
```

### StoryTag Entity

```dart
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
```

### StoryQuestion Entity

```dart
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
```

## Data Models (DTOs)

These models extend the domain entities to add serialization/deserialization functionality:

### StoryModel

```dart
class StoryModel extends Story {
  StoryModel({
    required String id,
    required String title,
    required String summary,
    required String coverImagePath,
    required DateTime createdAt,
    required String author,
    required String ageRange,
    required String readingTime,
    required String originalPrompt,
    required String genre,
    required String theme,
    required List<String> tags,
    required bool isPregenerated,
    required bool isFavorite,
    required List<StoryPage> pages,
    required List<String> questions,
  }) : super(
    id: id,
    title: title,
    summary: summary,
    coverImagePath: coverImagePath,
    createdAt: createdAt,
    author: author,
    ageRange: ageRange,
    readingTime: readingTime,
    originalPrompt: originalPrompt,
    genre: genre,
    theme: theme,
    tags: tags,
    isPregenerated: isPregenerated,
    isFavorite: isFavorite,
    pages: pages,
    questions: questions,
  );

  // Convert from pre-generated stories JSON format
  factory StoryModel.fromPreGeneratedJson(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    final data = json['data'];

    return StoryModel(
      id: 'pre_gen_${DateTime.now().millisecondsSinceEpoch}',
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
      pages: (data['pages'] as List).asMap().entries.map((entry) {
        return StoryPage(
          id: 'page_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
          storyId: 'pre_gen_${DateTime.now().millisecondsSinceEpoch}',
          pageNumber: entry.key,
          content: entry.value['content'],
          imagePath: entry.value['image_url'],
        );
      }).toList(),
      questions: List<String>.from(data['questions']),
    );
  }

  // Convert from AI response JSON format
  factory StoryModel.fromAiResponseJson(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    final data = json['data'];

    return StoryModel(
      id: 'ai_gen_${DateTime.now().millisecondsSinceEpoch}',
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
      pages: (data['pages'] as List).asMap().entries.map((entry) {
        return StoryPage(
          id: 'page_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
          storyId: 'ai_gen_${DateTime.now().millisecondsSinceEpoch}',
          pageNumber: entry.key,
          content: entry.value['content'],
          imagePath: entry.value['image_url'],
        );
      }).toList(),
      questions: List<String>.from(data['questions']),
    );
  }

  // Convert to database format
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
}
```

### StoryPageModel

```dart
class StoryPageModel extends StoryPage {
  StoryPageModel({
    required String id,
    required String storyId,
    required int pageNumber,
    required String content,
    required String imagePath,
  }) : super(
    id: id,
    storyId: storyId,
    pageNumber: pageNumber,
    content: content,
    imagePath: imagePath,
  );

  // Convert to database format
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'story_id': storyId,
      'page_number': pageNumber,
      'content': content,
      'image_path': imagePath,
    };
  }
}
```

### StoryTagModel

```dart
class StoryTagModel extends StoryTag {
  StoryTagModel({
    required String id,
    required String storyId,
    required String tag,
  }) : super(
    id: id,
    storyId: storyId,
    tag: tag,
  );

  // Convert to database format
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'story_id': storyId,
      'tag': tag,
    };
  }
}
```

### StoryQuestionModel

```dart
class StoryQuestionModel extends StoryQuestion {
  StoryQuestionModel({
    required String id,
    required String storyId,
    required String questionText,
    required int questionOrder,
  }) : super(
    id: id,
    storyId: storyId,
    questionText: questionText,
    questionOrder: questionOrder,
  );

  // Convert to database format
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'story_id': storyId,
      'question_text': questionText,
      'question_order': questionOrder,
    };
  }
}
```

## Pre-Generated Stories Format

The pre-generated stories are stored in a JSON file (`assets/data/pre_generated_stories.json`) with the following structure:

```json
{
  "stories": [
    {
      "metadata": {
        "author": "StoryTales AI",
        "age_range": "3-6",
        "reading_time": "5 min",
        "created_at": "2025-03-01T12:00:00Z",
        "original_prompt": "A story about a friendly dragon",
        "tags": [
          "fantasy",
          "friendship",
          "adventure"
        ],
        "genre": "Fantasy",
        "theme": "Friendship"
      },
      "data": {
        "title": "Ember the Friendly Dragon",
        "summary": "Ember is a small dragon who wants to make friends, but everyone is afraid of him. One day, he meets a brave little girl who sees the kindness in his heart.",
        "cover_image_url": "assets/images/stories/ember_dragon.webp",
        "pages": [
          {
            "content": "Once upon a time, in a land of rolling hills and tall mountains, there lived a small dragon named Ember. Ember was not like other dragons. His scales were bright blue, and instead of breathing fire, he could only make small puffs of smoke.",
            "image_url": "assets/images/stories/ember_page1.webp"
          },
          {
            "content": "Ember wanted to make friends, but whenever he flew near the village, people would run away screaming, \"Dragon! Dragon!\" This made Ember very sad. \"Why won't anyone be my friend?\" he wondered.",
            "image_url": "assets/images/stories/ember_page1.webp"
          },
          // More pages...
        ],
        "questions": [
          "Why were people afraid of Ember?",
          "How did Lily help Ember?",
          "What did the villagers learn in the end?"
        ]
      }
    },
    // More pre-generated stories...
  ]
}
```

The actual file contains multiple pre-generated stories that will be loaded by the app on first launch.

## AI Story Generation Response Format

The external AI service is expected to return stories in the following format:

```json
{
  "metadata": {
    "author": "StoryTales AI",
    "age_range": "7-9",
    "reading_time": "6 min",
    "created_at": "2025-04-10T15:45:00Z",
    "original_prompt": "A story about a boy who fixes a robot",
    "tags": [
      "technology",
      "friendship",
      "imagination"
    ],
    "genre": "Science Fiction",
    "theme": "Friendship"
  },
  "data": {
    "title": "Max and the Friendly Robot",
    "summary": "Max finds and repairs an old robot toy that magically comes to life, becoming his best friend and taking him on amazing adventures.",
    "cover_image_url": "https://ai-service.example.com/images/story_123456_cover.jpg",
    "pages": [
      {
        "content": "Max loved building things. His room was filled with creations made from blocks, cardboard boxes, and anything else he could find.",
        "image_url": "https://ai-service.example.com/images/story_123456_page_0.jpg"
      },
      {
        "content": "One rainy Saturday, Max found an old toy robot in the attic. It was dusty and missing a few parts, but Max thought it was perfect.",
        "image_url": "https://ai-service.example.com/images/story_123456_page_1.jpg"
      },
      // More pages...
    ],
    "questions": [
      "What made Beep the robot special?",
      "Why do you think Max was able to bring Beep to life when others couldn't?",
      "If you had a robot friend like Beep, what adventures would you want to go on?",
      "What does it mean to see 'potential in broken things'?"
    ]
  }
}
```

For a complete example, see [sample-ai-response.json](../examples/sample-ai-response.json).

The app will need to:
1. Download and store the images locally
2. Generate unique IDs for pages and questions
3. Convert the response to the local database format
4. Save everything to SQLite

## Subscription Data

Subscription data is stored in SharedPreferences with the following keys:

- `generated_story_count`: Number of stories the user has generated (Integer)
- `has_active_subscription`: Whether the user has an active subscription (Boolean)

## Implementation Notes

1. **Image Storage**:
   - Pre-generated story images are stored in the assets folder (`assets/images/stories/`)
   - AI-generated story images need to be downloaded from the provided URLs and stored in the app's documents directory
   - Image paths in the database should be updated to point to the local paths after downloading

2. **JSON Parsing**:
   - Use the `StoryModel.fromPreGeneratedJson()` method to parse pre-generated stories
   - Use the `StoryModel.fromAiResponseJson()` method to parse AI-generated stories
   - These methods handle the conversion from the JSON format to the database format

3. **Tags Handling**:
   - Tags are stored in a separate table with a many-to-one relationship with stories
   - When loading stories from the database, fetch the associated tags and add them to the Story object
   - When saving stories to the database, insert each tag as a separate row in the Story Tags table

4. **Favorites Functionality**:
   - The `is_favorite` flag in the Stories table enables filtering for the Favorites tab
   - The LibraryBloc should provide methods to toggle favorite status and filter stories
   - When toggling favorite status, only update the `is_favorite` field in the Stories table

5. **Reading Time**:
   - Reading time is provided in the metadata as a string (e.g., "5 min")
   - Store this value as-is in the database
   - For display purposes, you can extract the numeric value if needed

6. **Database Initialization**:
   - The database should be created on first app launch
   - Pre-generated stories should be loaded from the JSON asset and inserted into the database
   - Use the following process:
     1. Read the `assets/data/pre_generated_stories.json` file
     2. Parse the JSON using `json.decode()`
     3. Iterate through the `stories` array
     4. For each story, use `StoryModel.fromPreGeneratedJson()` to create a Story object
     5. Save the Story object to the database using the appropriate repository methods

## Phase 2 Data Model Extensions

For information about the Phase 2 data model extensions, including user profiles, cloud storage, and cross-device synchronization, please refer to the [Phase 2 Data Model Extensions](phase-two/data-model-extensions.md) document.
