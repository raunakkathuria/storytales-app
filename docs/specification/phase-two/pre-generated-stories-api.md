# Pre-Generated Stories API

This document outlines the implementation of the Pre-Generated Stories API feature for Phase 2 of the StoryTales app.

## Overview

The Pre-Generated Stories API feature allows the app to fetch curated, high-quality stories from a remote API endpoint and integrate them seamlessly with the existing local story library. This enhances the user experience by providing fresh, professionally crafted content alongside user-generated stories.

## Implementation Status

✅ **Completed** - API integration, data models, repository methods, and BLoC integration

## Architecture

### API Client Integration

The feature extends the existing `StoryApiClient` with a new method:

```dart
Future<List<Map<String, dynamic>>> fetchPreGeneratedStories()
```

This method:
- Makes a GET request to `/api/pregenerated-stories`
- Handles network errors gracefully with user-friendly messages
- Returns a list of story data in the expected format
- Includes comprehensive logging for debugging

### Data Model Extensions

The `StoryModel` class has been extended with a new factory constructor:

```dart
StoryModel.fromApiPreGeneratedJson(Map<String, dynamic> json)
```

This constructor:
- Converts API response format to internal story format
- Generates unique IDs with `api_pre_gen_` prefix
- Marks stories as pre-generated (`isPregenerated: true`)
- Handles image URLs from the API directly
- Sets appropriate metadata (author, timestamps, etc.)

### Repository Layer

The `StoryRepository` interface and implementation have been enhanced:

#### New Interface Method
```dart
Future<void> loadApiPreGeneratedStories();
```

#### Implementation Features
- **Duplicate Prevention**: Checks for existing stories before saving
- **Error Handling**: Gracefully handles API failures without breaking the app
- **Unique ID Generation**: Uses `api_pre_gen_${apiId}` format for story IDs
- **Batch Processing**: Efficiently processes multiple stories from the API

### BLoC Integration

The `LibraryBloc` has been enhanced with:

#### New Event
```dart
class LoadApiPreGeneratedStories extends LibraryEvent
```

#### Background Loading
- API stories are loaded automatically when loading all stories
- Failures don't prevent the library from loading existing stories
- Comprehensive analytics tracking for success and failure cases

#### Manual Refresh
- Users can trigger explicit API story loading
- Refreshes the current view after successful loading
- Maintains current tab state (All Stories vs Favorites)

## API Endpoint Specification

### Story List Endpoint
```
GET /stories
```

### Individual Story Endpoint
```
GET /stories/{id}
```

### Expected Response Formats

#### Story List Response Format
```json
{
  "stories": [
    {
      "id": "unique_story_id",
      "title": "Story Title",
      "summary": "Brief story description",
      "age_range": "6-8 years",
      "genre": "Adventure",
      "theme": "Courage & Bravery",
      "is_premium": false,
      "created_at": "2025-08-01T15:16:47.076556"
    }
  ]
}
```

#### Individual Story Response Format
```json
{
  "id": "1ab20354-fd8f-49bf-b78d-f4086af4dfda",
  "title": "Test Hero and the Hollow Log",
  "summary": "A brave little mouse helps a bear who's stuck in a log, with help from his forest friends.",
  "age_range": "6-8 years",
  "genre": "Adventure",
  "theme": "Courage & Bravery",
  "is_premium": false,
  "created_at": "2025-08-01T15:16:47.076556",
  "story_data": {
    "data": {
      "pages": [
        {
          "content": "In a cozy burrow under a giant oak tree lived Test Hero, a brave little mouse with a heart full of kindness.",
          "image_url": "https://storage.googleapis.com/storytales-api-development/stories/e9945214-de64-4b21-ba24-053b7769dc00/page_01.jpg",
          "section_number": 1
        },
        {
          "content": "He loved helping his friends in the Sunny Meadow Forest, always ready for an adventure.",
          "image_url": "https://storage.googleapis.com/storytales-api-development/stories/e9945214-de64-4b21-ba24-053b7769dc00/page_01.jpg",
          "section_number": 1
        }
      ],
      "questions": [
        "What made Test Hero brave?",
        "How did the forest friends help?"
      ]
    }
  }
}
```

### Error Handling
The API client handles various error scenarios:
- **Network timeouts**: User-friendly timeout messages
- **Connection errors**: Offline/connectivity guidance
- **Server errors**: Graceful degradation with existing stories
- **Authentication errors**: Clear authentication guidance
- **Rate limiting**: Appropriate retry guidance

## Configuration

### Development Environment
```json
{
  "apiBaseUrl": "http://localhost:8080",
  "apiTimeoutSeconds": 120,
  "useMockData": false,
  "environment": "development"
}
```

### Production Environment
The production configuration should point to the actual API server:
```json
{
  "apiBaseUrl": "https://api.storytales.app",
  "apiTimeoutSeconds": 30,
  "useMockData": false,
  "environment": "production"
}
```

## User Experience

### Automatic Loading
- API stories are loaded automatically when the app starts
- Users see both local and API stories in their library
- No additional UI elements required for basic functionality

### Manual Refresh
- Future enhancement: Pull-to-refresh gesture
- Background loading with progress indicators
- Seamless integration with existing library UI

### Offline Support
- API stories are cached locally after first load
- App continues to work offline with cached stories
- Background sync when connectivity is restored

## Analytics Integration

The feature includes comprehensive analytics tracking:

### Success Events
- `api_pregenerated_stories_loaded`: Successful API story loading
- Story count and timestamp information

### Error Events
- `api_pregenerated_stories_load_error`: API loading failures
- `api_pregenerated_stories_background_load_error`: Background loading failures
- Detailed error categorization and context

## Testing

### Unit Tests
- Repository method testing with mocked dependencies
- Error handling verification
- Duplicate prevention testing
- BLoC event handling validation

### Integration Tests
- End-to-end API integration testing
- Database persistence verification
- UI state management testing

## Security Considerations

### Data Validation
- All API responses are validated before processing
- Malformed data is rejected gracefully
- Image URLs are validated for security

### Privacy
- No user data is sent to the API
- Stories are fetched anonymously
- Local storage follows existing privacy patterns

## Performance Considerations

### Efficient Loading
- Stories are loaded in batches
- Duplicate checking is optimized with database queries
- Background loading doesn't block UI

### Memory Management
- Large images are handled efficiently
- Database transactions are used for batch operations
- Proper resource cleanup

## Future Enhancements

### Planned Features
1. **Story Categories**: Organize API stories by themes/genres
2. **Personalized Recommendations**: AI-driven story suggestions
3. **Offline Sync**: Background synchronization improvements
4. **Content Updates**: Incremental story updates from API
5. **User Feedback**: Rating and feedback system for API stories

### Technical Improvements
1. **Caching Strategy**: Advanced caching with expiration
2. **Incremental Loading**: Pagination support for large story sets
3. **Content Delivery**: CDN integration for faster image loading
4. **Analytics Enhancement**: Detailed usage tracking for API stories

## Troubleshooting

### Common Issues

#### API Connection Failures
- Check network connectivity
- Verify API endpoint configuration
- Review firewall/proxy settings

#### Duplicate Stories
- Stories are automatically deduplicated by ID
- Manual database cleanup if needed
- Check ID generation logic

#### Performance Issues
- Monitor database query performance
- Optimize image loading strategies
- Review background loading frequency

### Debug Information
- Comprehensive logging in `StoryApiClient`
- Analytics events for error tracking
- Database query logging available

## Migration Guide

### Existing Installations
- No database migrations required
- Existing stories remain unchanged
- API stories are added incrementally

### Development Setup
1. Ensure API server is running on `localhost:8080`
2. Update `app_config_dev.json` with correct endpoint
3. Test with sample API responses
4. Verify analytics integration

This feature enhances the StoryTales app by providing users with a rich library of professionally crafted stories while maintaining the existing user experience and performance characteristics.
