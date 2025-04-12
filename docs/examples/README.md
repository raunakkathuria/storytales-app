# StoryTales Example Files

This directory contains example files that demonstrate the expected data formats for the StoryTales app. These files serve as references for developers implementing the app according to the technical specification.

## Files

### 1. sample-ai-response.json

This file demonstrates the expected response format from the external AI story generation service. It shows:

- The `metadata` section with author, age range, reading time, etc.
- The `data` section with title, summary, cover image, pages, and questions
- The format for story pages, including content and image URLs
- How discussion questions are structured as simple strings

**Usage:**
- Use this as a reference when implementing the `StoryApiClient` to parse AI responses
- Use the `StoryModel.fromAiResponseJson()` method to convert this format to the database format
- Implement logic to download and store images locally

## Pre-Generated Stories

For the format of pre-generated stories, refer to the actual data file used by the app:

- **File Location**: `assets/data/pre_generated_stories.json`
- **Format**: Similar to the AI response format, but contained in a top-level `stories` array
- **Usage**: This file is loaded by the app on first launch to populate the local database with pre-generated stories

## Implementation Notes

When implementing the StoryTales app, you'll need to:

1. **Pre-Generated Stories:**
   - The pre-generated stories are stored in `assets/data/pre_generated_stories.json`
   - Load and parse this file on first app launch
   - For each story in the `stories` array:
     - Convert it to a `StoryModel` using `StoryModel.fromPreGeneratedJson()`
     - Insert the story, pages, tags, and questions into the local SQLite database

2. **AI-Generated Stories:**
   - Call the external AI service to generate new stories
   - Parse the response using `StoryModel.fromAiResponseJson()`
   - Download and store images locally
   - Insert the story, pages, tags, and questions into the local SQLite database

3. **Database Schema:**
   - Refer to the data model document (docs/specification/data-model.md) for the complete database schema
   - Note the tables for tags and the structure for questions

4. **Image Handling:**
   - Pre-generated story images are stored in the `assets/images/stories/` folder
   - AI-generated story images need to be downloaded and stored in the app's documents directory
   - Update image paths in the database to point to the local paths after downloading

5. **Tags and Metadata:**
   - The format includes metadata like genre, theme, and tags
   - Tags are stored in a separate table with a many-to-one relationship with stories
   - When loading stories from the database, fetch the associated tags and add them to the Story object

These example files should be used in conjunction with the technical specification and data model documentation to ensure a consistent implementation of the StoryTales app.
