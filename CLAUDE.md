# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StoryTales is an AI-powered storytelling app for children aged 3-12 built with Flutter. The app generates personalized stories with illustrations and includes a library for offline reading. This is currently in Phase 2 development, with authentication features temporarily removed in preparation for Supabase JWT implementation.

## Common Development Commands

### Flutter Development
```bash
# Run the app in debug mode
flutter run

# Run tests
flutter test

# Run specific test file
flutter test test/story_generation_job_system_test.dart

# Generate code (for mocks, etc.)
flutter packages pub run build_runner build

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Analyze code for issues
flutter analyze

# Format code
dart format .

# Check for outdated packages
flutter pub outdated
```

### Firebase Setup
```bash
# Initialize Firebase (already configured)
# The app uses Firebase Analytics and Crashlytics
# Configuration files are in ios/Runner/GoogleService-Info.plist and android/app/google-services.json
```

### Testing Commands
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test categories
flutter test test/story_generation_*_test.dart
```

## Project Architecture

### Clean Architecture with BLoC Pattern
The project follows Clean Architecture principles with three main layers:

1. **Presentation Layer** (`lib/features/*/presentation/`)
   - UI widgets and pages
   - BLoC classes for state management
   - User interaction handling

2. **Domain Layer** (`lib/features/*/domain/`)
   - Business entities
   - Repository interfaces
   - Use case logic

3. **Data Layer** (`lib/features/*/data/`)
   - Repository implementations
   - Data sources (API clients, local storage)
   - Data models

### Key Features Structure
- `features/library/` - Story library and browsing
- `features/story_generation/` - AI story creation workflow
- `features/story_reader/` - Story reading experience
- `features/subscription/` - Subscription management
- `features/profile/` - User authentication and profile management
- `core/` - Shared services, utilities, and configuration

### State Management
Uses the BLoC pattern with flutter_bloc package. Each feature has its own BLoCs:
- `LibraryBloc` - Manages story library state
- `StoryGenerationBloc` - Handles story creation
- `StoryWorkshopBloc` - Manages story creation dialog
- `StoryReaderBloc` - Controls story reading experience
- `SubscriptionBloc` - Manages subscription state
- `ProfileBloc` - Manages user authentication and profile state

### Dependency Injection
Uses GetIt service locator pattern. All dependencies are registered in `core/di/injection_container.dart`.

## Important Development Guidelines

### Responsive Design Requirements
- **Always use `ResponsiveText`** instead of standard `Text` widgets
- **Always use `ResponsiveIcon`** instead of standard `Icon` widgets with fixed sizes
- Follow the responsive design guidelines in `docs/guidelines/responsive-design.md`

### Code Style Requirements
- Follow the coding guidelines in `docs/guidelines/coding-guidelines.md`
- Use BLoC pattern for state management
- Keep business logic out of UI widgets
- Use clean architecture layers consistently
- Avoid deprecated Flutter APIs (use `withValues()` instead of `withOpacity()`, etc.)

### Database Schema
SQLite database with tables:
- `stories` - Main story metadata
- `story_pages` - Individual story pages with content and images
- `story_tags` - Story categorization tags
- `story_questions` - Discussion questions for stories

The database automatically handles schema migrations between versions.

## Development Environment Setup

### Environment Configuration
The app supports multiple environments:
- Development: `assets/config/app_config_dev.json`
- Staging: `assets/config/app_config_staging.json`
- Production: `assets/config/app_config.json`

Environment is controlled by `lib/core/config/environment.dart`.

### Firebase Integration
- **Analytics**: Firebase Analytics for usage tracking
- **Crashlytics**: Crash reporting and stability monitoring
- **Custom Authentication**: Device-based authentication with custom API integration

### API Integration
- Story generation via external AI API
- Pre-generated stories API for curated content
- User authentication and profile management via custom API
- All API calls use Dio with comprehensive error handling

## Testing Strategy

### Test Structure
- Unit tests for BLoCs and repositories
- Widget tests for UI components  
- Integration tests for complete workflows
- Mock services using Mockito

### Key Test Files
- `story_generation_*_test.dart` - Story creation workflow tests
- `user_stories_pagination_test.dart` - API pagination tests
- `pregenerated_stories_api_test.dart` - Curated stories tests
- `user_authentication_*_test.dart` - Authentication system tests
- `profile_*_test.dart` - User profile and state management tests

## Current Development Status (Phase 2)

### Completed Features ✅
- Core storytelling functionality
- Pre-generated stories API integration
- Background story generation with timer
- Enhanced workshop dialog UX
- Production Firebase configuration

### Completed Features ✅
- User authentication with custom API integration
- Device-based account recovery system
- OTP-based email verification
- Session management with proper sign-out
- Single-purpose screen architecture for authentication flows
- Persistent verification state recovery
- Comprehensive error handling and retry mechanisms

### Current Branch
Working on branch: `phase2/user_authentication_stories`

## Performance Considerations

### Image Loading
- Uses strategic preloading for story images
- Background thread processing with `Future.microtask()`
- Memory-efficient caching strategy

### UI Performance
- Leverages Flutter's PageView with `allowImplicitScrolling`
- Implements proper error handling for controllers
- Uses const constructors where possible

## Debugging and Logging

### Logging Service
Comprehensive logging via `LoggingService`:
- Info level for general operations
- Error level for exceptions and failures
- Integrated with Firebase Crashlytics

### Common Debugging Commands
```bash
# View logs while running
flutter logs

# Debug with observatory
flutter run --observatory-port=8888

# Profile performance
flutter run --profile
```

## Known Issues and Workarounds

### Story Workshop Dialog
Recent fixes addressed positioning and dialog functionality issues. The workshop indicator has enhanced error handling and button cleanup.

### SQLite Constraints
Fixed UNIQUE constraint errors in story saving through improved database handling in recent commits.

### Authentication System
The authentication system has been reimplemented using a custom API with device-based authentication, OTP verification, and comprehensive session management. The system provides user profiles, account recovery, and seamless authentication flows through dedicated single-purpose screens.