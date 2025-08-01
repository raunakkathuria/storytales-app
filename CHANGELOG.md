# Changelog

All notable changes to the StoryTales project will be documented in this file.

For a more detailed changelog with implementation status, see [docs/CHANGELOG.md](docs/CHANGELOG.md).

## [1.0.1] - 2025-04-23

### Added
- New `ResponsiveButton` component for consistent button styling across devices
- Enhanced dialog responsiveness for small screens
- Improved configuration system with better documentation

### Changed
- Improved dialog form layout on small screens
- Enhanced dropdown items to use ResponsiveText for better accessibility
- Updated wireframe documentation to reflect recent UI changes

### Fixed
- Fixed "No internet connection" error when using mock data
- Improved connectivity handling to fall back to mock data when offline
- Fixed button alignment issues on iPhone devices
- Fixed dialog button sizing on small screens

## [1.0.0] - Phase 1 Completion - 2025-04-20

### Core Features Implemented
- Story generation with AI integration
- Local storage for generated and pre-bundled stories
- Tab-based library with "All Stories" and "Favorites" views
- Story reader with full-screen immersive experience
- Discussion questions at the end of each story
- Basic subscription model with 2 free stories limit
- Offline access to saved stories

### UI Enhancements
- Full-page immersive reading experience with edge-to-edge content
- Consistent visual design across story pages and question pages
- Semi-transparent header with reading time (with clock icon), page indicators, and action buttons
- Optimized text overlay for better readability against background images
- Consistent gradient overlays for improved text contrast
- Text shadows for better visibility against varied backgrounds
- Unified dot-based page indicators for all stories regardless of length
- Improved subscription flow to show subscription page earlier when free story limit is reached
- Enhanced + button behavior to check subscription status before showing story creation screen

### Technical Implementation
- Clean architecture with BLoC pattern for state management
- SQLite for local storage of stories and user preferences
- Firebase Analytics integration for usage tracking
- Firebase Crashlytics integration for crash reporting
- Comprehensive error handling for network and API issues
- Responsive design for various device sizes
- "Storybook Sky" color palette implemented throughout the app

## [1.0.2] - 2025-06-24 - Phase 2 Enhancement & Bug Fixes

### Added
- Enhanced story creation dialog with improved responsiveness
- Fixed dialog sizing issues to prevent dynamic resizing based on text content
- Improved text wrapping and overflow handling in loading dialogs
- Updated form field text to use child-friendly terminology ("Your story" instead of "Story Prompt")
- Enhanced validation messages with more encouraging, conversational language

### Changed
- Story creation dialog now uses responsive font sizing for better accessibility
- Loading dialog maintains consistent dimensions while cycling through messages
- Improved dialog layout to prevent Flutter rendering errors and overflow issues

### Fixed
- Fixed story creation dialog text sizing inconsistencies
- Resolved dropdown text truncation issues in age range selection
- Fixed Flutter assertion errors in loading dialog layout
- Eliminated RenderFlex overflow errors in dialog components

## [1.0.3] - 2025-07-20

### Added
- Enhanced API client with comprehensive logging and error handling
- Development environment configuration management
- Background generation test suite for countdown and state transitions
- Production Firebase setup with emulator fallback support

### Fixed
- Library auto-refresh when background story generation completes
- BLoC emitter disposal issue preventing state emission after dialog closure
- Proper event-driven architecture with Timer.run() for post-dialog events

### Changed
- Improved Firebase emulator connection with graceful fallback to production
- Enhanced API client logging for better debugging and monitoring
- Better error handling in story generation with detailed DioException logging

## [1.0.4] - 2025-07-21 - Error Handling & User Experience Improvements

### Added
- Comprehensive error handling with user-friendly, creative "Story Wizard" themed error messages
- Specific error messages for different network failure scenarios (timeout, connection error, authentication, rate limiting, server errors)
- Enhanced API client logging for better debugging and troubleshooting
- `generateSampleStory` method for explicit development/testing purposes
- **Comprehensive analytics tracking** for story generation failures with detailed error categorization

### Changed
- **BREAKING**: Removed silent fallback to mock data when API calls fail
- Story generation now always informs users of actual errors instead of silently returning sample stories
- Error messages are now creative and child-friendly, using magical storytelling themes (🧙‍♂️, 🌟, 🔮, etc.)
- Enhanced DioException handling with specific error categorization
- Analytics now capture detailed failure information including error types, technical details, and user context

### Fixed
- Users will no longer receive unexpected sample stories when API calls fail
- Transparent error reporting ensures users understand when story generation fails
- Proper error propagation through the application layers

### Technical Improvements
- Better separation of concerns between production and development/testing scenarios
- Enhanced logging for API requests and responses
- Improved error handling architecture for better user experience
- **Analytics Integration**: Detailed error tracking with categorized failure types (timeout_error, connection_error, auth_error, rate_limit_error, server_error, etc.)
- Rich analytics data including prompt context, API endpoints, environment details, and timestamps
- Both user-friendly and technical error details captured for comprehensive monitoring

## [1.0.5] - 2025-07-24 - Enhanced Loading Experience

### Added
- **Animated Loading Story Card**: Implemented a new `LoadingStoryCard` widget with a central animated wizard (60px size) and magical sparkle effects.
- **Simplified Status Messages**: Reduced and refined status messages during story generation to 4 concise, cycling options ("Creating your story...", "Weaving magic...", "Adding characters...", "Almost ready...").
- **Loading Card Priority**: Ensured loading cards appear first in the story grid for immediate visual feedback.

### Changed
- **Countdown Timer**: Reduced the story generation countdown from 5 seconds to 3 seconds for a snappier user experience.
- **Loading Card UI**: Removed the cancel button and simplified the overall layout of the loading card to focus on the animated wizard and status messages.

## [Unreleased] - Phase 2 (In Progress)

### Completed
- **Authentication & User Management** ✅
  - Firebase Authentication with OTP (one-time password) authentication
  - Persistent authentication across app restarts
  - User profiles stored in Firestore
  - Account management and settings screen
  - Email entry and OTP verification flows
  - Profile settings with optional display name
  - Secure OTP generation and verification
  - Integration with Firebase emulator for development

- **Background Story Generation** ✅
  - Timer-based countdown mechanism during story generation
  - Background processing with proper BLoC state management
  - Library auto-refresh when background generation completes
  - Event-driven architecture for post-dialog state updates

- **Production Configuration** ✅
  - Firebase production setup with environment-specific configuration
  - Enhanced API client with comprehensive logging
  - Development environment management with emulator support

### In Development
- **Cross-Device Synchronization**
  - Cloud-based story storage
  - Conflict resolution for offline changes
  - Background sync capabilities
  - Offline support with queuing

### Coming Soon
- **Enhanced Library Features**
  - Advanced search and filtering
  - Tags system for flexible categorization
  - Enhanced UI with animations
  - Organization tools (batch operations, collections, reading lists)

- **Pre-Generated Stories API**
  - Cloud Functions API for serving pre-generated stories
  - Curated story collections
  - Discovery UI for browsing and discovering stories
  - Integration with the existing library system

- **In-App Feedback**
  - Feedback collection system
  - Bug reporting system
  - Feature request system
  - User satisfaction surveys

## [1.0.6] - 2025-07-30 - Error Handling & Dialog Improvements

### Added
- Comprehensive error handling with user-friendly, creative "Story Wizard" themed error messages for various API failure types (timeout, connection, authentication, rate limiting, server errors).
- Automatic clearing of failed story generation cards when a user attempts to create a new story.

### Changed
- Replaced "Cancel" button with "Close" in story generation dialog countdown and progress indicators.
- Modified dialog button actions to only close the dialog without cancelling the background story generation process.
- Updated styling of informational and error snackbar messages to use larger font sizes and appropriate brand colors.
- Eliminated redundant error pop-ups by ensuring `BackgroundGenerationFailure` state only triggers in-dialog error display.

### Removed
- `CancelStoryGeneration` event and its corresponding handler from the BLoC.
- Unused `StoryGenerationCanceled` state.
- Outdated reference to `CancelStoryGeneration` in `docs/wireframes/responsive-implementation.md`.
