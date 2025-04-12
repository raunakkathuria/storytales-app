# StoryTales

StoryTales is an AI-powered storytelling app for children aged 3-12 that generates personalized stories with illustrations. This repository contains the technical specification, wireframes, and implementation guidelines for Phase 1 of the app.

## Project Overview

StoryTales allows users to:
- Generate personalized children's stories using AI
- Read pre-generated bundled stories
- Save stories to a local library for offline reading
- Access 2 free stories before hitting a subscription paywall
- View discussion questions at the end of each story

The app is built with Flutter using the BLoC pattern for state management, SQLite for local storage, and Firebase Analytics for event tracking.

## Phase 1 Scope

Phase 1 is focused on delivering a functional MVP with core features:
- Story generation with AI (2 free stories, then subscription required)
- Pre-generated bundled stories
- Local library with offline reading
- Simple subscription model
- Firebase Analytics integration
- Child-friendly UI following the branding guidelines

Future phases will add user accounts, cross-device sync, enhanced library features, and more advanced personalization.

## Documentation Structure

### Project Tracking

- [CHANGELOG](docs/CHANGELOG.md) - Comprehensive record of all changes and implementation status

### Specifications

- [Phase 1 Technical Specification](docs/specification/phase-one-technical-specification.md) - Detailed implementation guide for Phase 1
- [Future Phases](docs/specification/future-phases.md) - Overview of features planned for Phases 2-4
- [Architecture](docs/specification/architecture.md) - High-level architecture diagrams and explanations
- [Data Model](docs/specification/data-model.md) - Database schema, entity relationships, and data structures
- [Wireframes Description](docs/specification/wireframes-description.md) - Detailed descriptions of the UI wireframes

### Guidelines

- [Branding](docs/guidelines/branding.md) - Color palette, typography, and visual style guidelines
- [Coding Guidelines](docs/guidelines/coding-guidelines.md) - Best practices for code organization and style

### Wireframes

- [App Homepage](wireframes/app-homepage.txt) - Library screen with story cards
- [Story Page](wireframes/story-page.txt) - Individual story page with illustration and text
- [Story Question](wireframes/story-question.txt) - Discussion questions page at the end of stories
- [Images](wireframes/images/) - Visual wireframes for reference

### Examples

- [Sample Pre-Generated Story](docs/examples/sample-pre-generated-story.json) - Example of pre-generated stories format
- [Sample AI Response](docs/examples/sample-ai-response.json) - Example of AI service response format
- [Examples README](docs/examples/README.md) - Explanation of example files and their usage

### AI

- [Developer Prompt](docs/ai/developer-prompt.md) - Instructions for AI-assisted development

## Implementation Requirements

### Core Features

- **Story Generation**: AI integration for generating short, child-friendly stories
- **Pre-Generated Stories**: Bundled stories available offline after installation
- **Story Library**: Tab-based library with "All Stories" and "Favorites" tabs
- **Subscription Model**: 2 free stories, then subscription required
- **Offline Access**: Read saved stories without internet
- **UI & Error Handling**: Child-friendly interface with consistent branding

### Technical Stack

- **Flutter** (3.10+) for cross-platform development
- **BLoC Pattern** for state management
- **SQLite** for local storage
- **Dio** for HTTP requests to the AI service
- **Firebase Analytics** for event tracking
- **In-App Purchase** for subscription handling

## Getting Started

1. Clone this repository
2. Review the [Phase 1 Technical Specification](docs/specification/phase-one-technical-specification.md)
3. Understand the [Data Model](docs/specification/data-model.md) and [Wireframes](docs/specification/wireframes-description.md)
4. Follow the [Branding](docs/guidelines/branding.md) and [Coding Guidelines](docs/guidelines/coding-guidelines.md)
5. Implement the app according to the specifications

## Phase 1 Completion Criteria

Phase 1 will be considered complete when:
- 1,000+ active users within a reasonable timeframe
- ≥ 4.0 average rating in app stores
- ≥95% story generation success rate
- ≥98% crash-free sessions
- User feedback on the MVP's core features has been gathered

Once these criteria are met, development will proceed to Phase 2 (User Accounts, Enhanced UX).
