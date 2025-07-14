# Data Model Extensions for Phase 2

This document outlines the extensions to the data model required for Phase 2 of the StoryTales app. It builds upon the existing data model defined in [data-model.md](../data-model.md) and describes the new entities, relationships, and schema changes needed to support the Phase 2 features.

## Overview of Changes

Phase 2 introduces several new features that require extensions to the data model:

1. **User Authentication**: New user-related entities and authentication data
2. **Cloud Storage**: Cloud versions of existing entities for synchronization
3. **Enhanced Library**: New entities for tags, collections, and search
4. **Pre-Generated Stories**: Entities for story collections and discovery
5. **In-App Feedback**: Entities for feedback, bug reports, and surveys

## 1. User Authentication Data Model

### 1.1 Users Collection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, matches Firebase Auth UID |
| email | String | User's email address |
| displayName | String (optional) | User's display name |
| photoUrl | String (optional) | URL to user's profile photo |
| createdAt | Timestamp | When the user account was created |
| lastLoginAt | Timestamp | When the user last logged in |
| preferences | Map | User preferences (theme, notifications, etc.) |
| deviceTokens | Array | FCM tokens for user's devices |

### 1.2 Authentication State (Local)

| Key | Type | Description |
|-----|------|-------------|
| auth_user_id | String | Current user's ID |
| auth_email | String | Current user's email |
| auth_display_name | String | Current user's display name |
| auth_photo_url | String | Current user's photo URL |
| auth_last_login | Timestamp | Last login timestamp |

## 2. Cloud Storage Data Model

### 2.1 Stories Collection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| userId | String | Owner of the story (reference to Users) |
| title | String | Story title |
| summary | String | Brief summary |
| coverImagePath | String | Path to cover image in Firebase Storage |
| createdAt | Timestamp | Creation timestamp |
| updatedAt | Timestamp | Last update timestamp |
| author | String | Author name |
| ageRange | String | Target age range |
| readingTime | String | Estimated reading time |
| originalPrompt | String | Original prompt used for generation |
| genre | String | Story genre |
| theme | String | Story theme |
| tags | Array | List of tag IDs |
| collections | Array | List of collection IDs |
| isPregenerated | Boolean | Whether the story is pre-generated |
| isFavorite | Boolean | Whether the story is marked as favorite |
| syncStatus | String | Synchronization status (synced, pending, conflict) |
| lastSyncedAt | Timestamp | Last synchronization timestamp |
| readingProgress | Map | Reading progress information |

### 2.2 Pages Subcollection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| storyId | String | Parent story ID |
| pageNumber | Number | Page number within the story |
| content | String | Text content |
| imagePath | String | Path to page illustration in Firebase Storage |

### 2.3 Questions Subcollection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| storyId | String | Parent story ID |
| questionText | String | Text of the discussion question |
| questionOrder | Number | Order in the list |

### 2.4 Sync Metadata (Local)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, matches entity ID |
| entityType | String | Type of entity (story, page, question) |
| lastSyncedAt | Timestamp | When the entity was last synced |
| syncStatus | String | Sync status (synced, pending, conflict) |
| localUpdatedAt | Timestamp | When the entity was last updated locally |
| cloudUpdatedAt | Timestamp | When the entity was last updated in the cloud |
| conflictResolution | String | How conflicts should be resolved |

## 3. Enhanced Library Data Model

### 3.1 Tags Collection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| userId | String | Owner of the tag |
| name | String | Tag name |
| color | String | Tag color (hex code) |
| createdAt | Timestamp | Creation timestamp |
| updatedAt | Timestamp | Last update timestamp |
| storyCount | Number | Number of stories with this tag |

### 3.2 Collections Collection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| userId | String | Owner of the collection |
| name | String | Collection name |
| description | String | Collection description |
| coverImagePath | String | Path to cover image |
| createdAt | Timestamp | Creation timestamp |
| updatedAt | Timestamp | Last update timestamp |
| storyIds | Array | List of story IDs in the collection |
| isPublic | Boolean | Whether the collection is public |

### 3.3 Reading Lists Collection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| userId | String | Owner of the reading list |
| name | String | Reading list name |
| description | String | Reading list description |
| createdAt | Timestamp | Creation timestamp |
| updatedAt | Timestamp | Last update timestamp |
| storyIds | Array | List of story IDs in the reading list |
| currentStoryId | String | Currently reading story ID |
| isCompleted | Boolean | Whether the reading list is completed |

### 3.4 Search History (Local)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| userId | String | User who performed the search |
| query | String | Search query |
| timestamp | Timestamp | When the search was performed |
| resultCount | Number | Number of results returned |
| filters | Map | Filters applied to the search |

## 4. Pre-Generated Stories Data Model

### 4.1 Story Collections Collection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| title | String | Collection title |
| description | String | Collection description |
| coverImagePath | String | Path to cover image |
| type | String | Collection type (themed, seasonal, etc.) |
| storyIds | Array | List of story IDs in the collection |
| published | Boolean | Whether the collection is published |
| createdAt | Timestamp | Creation timestamp |
| updatedAt | Timestamp | Last update timestamp |
| featuredOrder | Number | Order in featured collections list |
| ageRange | String | Target age range |
| tags | Array | List of tags |

### 4.2 Pre-Generated Stories Collection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| title | String | Story title |
| summary | String | Brief summary |
| coverImageUrl | String | URL to cover image |
| author | String | Author name |
| ageRange | String | Target age range |
| readingTime | String | Estimated reading time |
| genre | String | Story genre |
| theme | String | Story theme |
| collectionIds | Array | List of collection IDs |
| createdAt | Timestamp | Creation timestamp |
| updatedAt | Timestamp | Last update timestamp |
| isPublished | Boolean | Whether the story is published |
| downloadCount | Number | Number of times the story has been downloaded |

### 4.3 Pre-Generated Pages Subcollection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| storyId | String | Parent story ID |
| pageNumber | Number | Page number within the story |
| content | String | Text content |
| imageUrl | String | URL to page illustration |

### 4.4 Pre-Generated Questions Subcollection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| storyId | String | Parent story ID |
| questionText | String | Text of the discussion question |
| questionOrder | Number | Order in the list |

## 5. In-App Feedback Data Model

### 5.1 Feedback Collection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| userId | String | User who submitted the feedback |
| type | String | Feedback type (general, bug, feature, etc.) |
| content | String | Feedback content |
| deviceInfo | Map | Information about the user's device |
| appVersion | String | Version of the app when feedback was submitted |
| screenshots | Array | URLs to attached screenshots |
| createdAt | Timestamp | Submission timestamp |
| status | String | Status of the feedback (new, in progress, resolved, etc.) |
| response | String | Response to the feedback |
| category | String | Feedback category |
| priority | String | Feedback priority |

### 5.2 Surveys Collection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| title | String | Survey title |
| description | String | Survey description |
| type | String | Survey type (rating, NPS, etc.) |
| questions | Array | List of survey questions |
| trigger | Map | Trigger conditions |
| active | Boolean | Whether the survey is active |
| createdAt | Timestamp | Creation timestamp |
| expiresAt | Timestamp | Expiration timestamp |
| targetUserIds | Array | List of target user IDs (empty for all users) |

### 5.3 Survey Responses Collection (Firestore)

| Field | Type | Description |
|-------|------|-------------|
| id | String | Primary key, unique identifier |
| surveyId | String | Survey ID |
| userId | String | User who responded |
| responses | Map | Responses to survey questions |
| createdAt | Timestamp | Response timestamp |
| deviceInfo | Map | Information about the user's device |
| appVersion | String | Version of the app when response was submitted |

## Entity Relationships

```
User (1) ---> (*) Story
User (1) ---> (*) Tag
User (1) ---> (*) Collection
User (1) ---> (*) ReadingList
User (1) ---> (*) Feedback
User (1) ---> (*) SurveyResponse

Story (1) ---> (*) Page
Story (1) ---> (*) Question
Story (*) <---> (*) Tag
Story (*) <---> (*) Collection
Story (*) <---> (*) ReadingList

StoryCollection (1) ---> (*) PreGeneratedStory
PreGeneratedStory (1) ---> (*) PreGeneratedPage
PreGeneratedStory (1) ---> (*) PreGeneratedQuestion

Survey (1) ---> (*) SurveyResponse
```

## Local vs. Cloud Storage Strategy

### Local Storage (SQLite)

- User authentication state
- Downloaded stories and related data
- Offline changes queue
- Search history
- Sync metadata
- User preferences

### Cloud Storage (Firestore)

- User profiles
- Stories and related data
- Tags, collections, and reading lists
- Pre-generated stories and collections
- Feedback and surveys

## Migration Strategy

To migrate from the Phase 1 data model to the Phase 2 data model:

1. **Create Cloud Schema**: Set up Firestore collections and security rules
2. **User Authentication**: Implement user authentication and profile creation
3. **Data Migration**: When a user signs in for the first time, migrate their local data to the cloud
4. **Schema Updates**: Update the local SQLite schema to include new tables and fields
5. **Sync Implementation**: Implement the synchronization mechanism between local and cloud storage

## Security Considerations

### Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Stories
    match /stories/{storyId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Tags
    match /tags/{tagId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Collections
    match /collections/{collectionId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Reading Lists
    match /readingLists/{readingListId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Feedback
    match /feedback/{feedbackId} {
      allow create: if request.auth != null;
      allow read, update: if request.auth != null && resource.data.userId == request.auth.uid;
    }

    // Pre-Generated Stories
    match /storyCollections/{collectionId} {
      allow read: if request.auth != null;
    }

    match /preGeneratedStories/{storyId} {
      allow read: if request.auth != null;
    }

    // Surveys
    match /surveys/{surveyId} {
      allow read: if request.auth != null;
    }

    match /surveyResponses/{responseId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

### Data Encryption

- Sensitive user data should be encrypted before storage
- Authentication tokens should be securely stored
- Consider field-level encryption for particularly sensitive data

## Future Considerations

1. **Scalability**: As the user base grows, consider sharding strategies for Firestore
2. **Performance**: Monitor query performance and optimize indexes
3. **Storage Costs**: Implement data archiving strategies for older, less accessed data
4. **Multi-Region**: Consider multi-region deployment for improved availability and performance
5. **Advanced Security**: Implement more sophisticated security rules as needed
