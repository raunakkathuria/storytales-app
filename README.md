# StoryTales

StoryTales is an AI-powered storytelling app for children aged 3-12 that generates personalized stories with illustrations. This repository contains the technical specifications, wireframes, and implementation guidelines for the app.

## Current Development Status

- **Phase 1**: ✅ Completed (April 2025) - Version 1.0.0
- **Phase 1 Patch**: ✅ Released (April 23, 2025) - Version 1.0.1
- **Phase 2**: ✅ Major Features Complete (September 2025) - Version 2.0.1
  - Authentication system fully implemented with custom API
  - Story generation optimized with 50% API call reduction
  - Enhanced library features with auto-refresh functionality

For detailed implementation status, see the [CHANGELOG](docs/CHANGELOG.md).

## Project Overview

StoryTales allows users to:
- Generate personalized children's stories using AI
- Read pre-generated bundled stories
- Save stories to a local library for offline reading
- Access 2 free stories before hitting a subscription paywall
- View discussion questions at the end of each story

The app is built with Flutter using the BLoC pattern for state management, SQLite for local storage, and Firebase Analytics for event tracking. Authentication features have been temporarily removed to prepare for future Supabase JWT implementation.

## Completed Features (Phase 1)

Phase 1 delivered a functional MVP with core features:
- Story generation with AI (2 free stories, then subscription required)
- Pre-generated bundled stories
- Local library with offline reading
- Simple subscription model
- Firebase Analytics integration
- Child-friendly UI following the branding guidelines

## Current Development (Phase 2)

Phase 2 is enhancing the app with:
- **Authentication & User Management** ✅ (Implemented) - v2.0.0
  - Custom API authentication system with device-based account recovery
  - OTP-based email verification replacing Firebase Authentication
  - Single-purpose screen architecture with comprehensive session management
  - Persistent verification state recovery and error handling
- **Background Story Generation** ✅ (Enhanced) - v2.0.1
  - Timer-based countdown mechanism during story generation
  - Intelligent API polling optimization (50% reduction in calls)
  - Automatic library refresh when generation completes
  - Progress timing aligned with actual generation time (120s)
  - Permanent error detection for immediate failure feedback
  - Enhanced BLoC state management for background processes
- **Production Configuration** ✅ (Implemented)
  - Firebase production setup with emulator fallback (Analytics & Crashlytics only)
  - Enhanced API client with comprehensive logging
  - Environment-specific configuration management
- **Cross-Device Synchronization** 📅 (Planned)
  - Foundation established with custom authentication system
  - Cloud sync capabilities planned for future implementation
- **Enhanced Library Features** 📅 (Planned)
  - Advanced search and filtering
  - Tags system for categorization
- **Pre-Generated Stories API** ✅ (Implemented)
  - API integration for fetching curated stories from server
  - Automatic background loading of API stories
  - Seamless integration with existing library system
- **In-App Feedback** 📅 (Planned)
  - Feedback collection and bug reporting

## Documentation Structure

### Project Tracking

- [CHANGELOG](docs/CHANGELOG.md) - Comprehensive record of all changes and implementation status

### Specifications

#### Phase 1
- [Phase 1 Technical Specification](docs/specification/phase-one-technical-specification.md) - Detailed implementation guide for Phase 1
- [Architecture](docs/specification/architecture.md) - High-level architecture diagrams and explanations
- [Data Model](docs/specification/data-model.md) - Database schema, entity relationships, and data structures
- [Wireframes Description](docs/specification/wireframes-description.md) - Detailed descriptions of the UI wireframes

#### Phase 2
- [Phase 2 Overview](docs/specification/phase-two/overview.md) - Comprehensive overview of Phase 2 features
- [Authentication & User Management](docs/specification/phase-two/authentication-user-management.md) - Specifications for user accounts
- [Cross-Device Synchronization](docs/specification/phase-two/cross-device-synchronization.md) - Specifications for cloud sync
- [Enhanced Library Features](docs/specification/phase-two/enhanced-library-features.md) - Specifications for library improvements
- [Pre-Generated Stories API](docs/specification/phase-two/pre-generated-stories-api.md) - Specifications for curated stories API
- [In-App Feedback](docs/specification/phase-two/in-app-feedback.md) - Specifications for feedback mechanisms

#### Future Phases
- [Future Phases](docs/specification/future-phases.md) - Overview of features planned for Phases 3-4

### Guidelines

- [Branding](docs/guidelines/branding.md) - Color palette, typography, and visual style guidelines
- [Coding Guidelines](docs/guidelines/coding-guidelines.md) - Best practices for code organization and style
- [Components](docs/guidelines/components.md) - Reusable UI components and usage guidelines
- [Performance Best Practices](docs/guidelines/performance-best-practices.md) - Guidelines for optimizing performance
- [Responsive Design](docs/guidelines/responsive-design.md) - Guidelines for responsive UI implementation
- [Testing](docs/guidelines/testing.md) - Testing strategies and best practices

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
- **Pre-Generated Stories**: API-driven stories available with network connectivity
- **Story Library**: Tab-based library with "All Stories" and "Favorites" tabs
- **Subscription Model**: 2 free stories, then subscription required
- **Offline Access**: Read saved stories without internet
- **UI & Error Handling**: Child-friendly interface with consistent branding and comprehensive, magical-themed error messages

### Technical Stack

- **Flutter** (3.10+) for cross-platform development
- **BLoC Pattern** for state management
- **SQLite** for local storage
- **Dio** for HTTP requests to the AI service and pre-generated stories API
- **Firebase Analytics** for event tracking
- **Firebase Crashlytics** for crash reporting
- **In-App Purchase** for subscription handling

### Current Technical Stack

- **Authentication**: Custom API with device-based account recovery and OTP verification
- **User Profiles**: Fully implemented with local caching and API synchronization  
- **Session Management**: Server-side session handling with proper sign-out functionality
- **Story Generation**: Optimized polling system with intelligent error handling

## Getting Started

1. Clone this repository
2. Review the appropriate technical specification based on the feature you're working on:
   - For Phase 1 features: [Phase 1 Technical Specification](docs/specification/phase-one-technical-specification.md)
   - For Phase 2 features: [Phase 2 Overview](docs/specification/phase-two/overview.md)
3. Understand the [Data Model](docs/specification/data-model.md) and [Wireframes](docs/specification/wireframes-description.md)
4. Follow the [Branding](docs/guidelines/branding.md) and [Coding Guidelines](docs/guidelines/coding-guidelines.md)
5. Implement the app according to the specifications

## Phase Completion Criteria

### Phase 1 (Completed)

Phase 1 was considered complete when:
- 1,000+ active users within a reasonable timeframe
- ≥ 4.0 average rating in app stores
- ≥95% story generation success rate
- ≥98% crash-free sessions
- User feedback on the MVP's core features was gathered

### Phase 2 (In Progress)

Phase 2 will be considered complete when:
- Enhanced library features are implemented
- Pre-generated stories API is integrated ✅
- In-app feedback mechanisms are in place
- User satisfaction metrics show improvement over Phase 1
- Authentication system is fully operational ✅
- Story generation system is optimized ✅

**Current Status**: Core Phase 2 features are complete with authentication system implemented and story generation optimized.
