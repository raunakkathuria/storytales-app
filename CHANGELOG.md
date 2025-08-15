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

## [1.0.8] - 2025-08-15 - Image Quality & Code Quality Improvements

### Added
- **Enhanced Image Generation Prompts**: Implemented optimized prompts for sharper, clearer story images
- **Anti-Blur Technology**: Added specific prompt instructions to prevent depth-of-field blur and ensure crystal-clear character details
- **Consistent Image Quality**: Applied enhanced prompts across all story generation paths (regular, background, and workshop)

### Changed
- **Improved Prompt Engineering**: Updated image generation prompts to use "crystal clear, Pixar-style 3D render" with "perfect sharp focus" and "bright, even lighting"
- **Eliminated Blur-Inducing Terms**: Removed "cinematic lighting" and other terms that could cause unwanted blur effects
- **Character Clarity Focus**: Enhanced prompts specifically target "distinct facial features" and "razor-sharp clarity throughout the entire scene"

### Fixed
- **Image Sharpness Issue**: Resolved blurred character images in story pages by optimizing AI generation prompts
- **Code Quality Improvements**: Fixed 17 code quality issues including deprecated API usage, unused elements, and test print statements
- **Modern Flutter APIs**: Updated all `withOpacity()` calls to use `withValues(alpha:)` for Flutter 3.27+ compatibility
- **Test Code Cleanup**: Converted debug print statements to comments in test files

### Technical Improvements
- **Prompt Consistency**: Applied enhanced prompts across `StoryGenerationBloc` and `StoryWorkshopBloc` for uniform image quality
- **Code Refactoring**: Created centralized `PromptEnhancementService` to eliminate code duplication and improve maintainability
- **DRY Principle**: Removed duplicated prompt enhancement code from multiple BLoCs, now managed in single service
- **Code Modernization**: Updated deprecated Flutter APIs to current standards
- **Reduced Technical Debt**: Eliminated unused code and improved overall code quality metrics
- **Better Test Hygiene**: Cleaned up test output by removing debug print statements
- **Enhanced Testing**: Added comprehensive unit tests for prompt enhancement service

### Benefits
- **Sharper Story Images**: Characters and scenes now render with crystal-clear detail and sharp focus
- **Consistent Quality**: Cover images and page images now maintain similar sharpness levels
- **Future-Proof Code**: Updated to modern Flutter APIs and best practices
- **Cleaner Codebase**: Reduced code quality issues from 21 to 4 (81% improvement)

## [Unreleased] - Phase 2 (In Progress)

### Removed - 2025-08-06
- **Firebase Authentication System Removal** 🔄
  - Completely removed Firebase Authentication system to prepare for Supabase JWT authentication
  - Removed firebase_auth and cloud_firestore dependencies from pubspec.yaml
  - Deleted entire authentication feature directory with all Firebase auth components
  - Removed AuthBloc, AuthWrapper, and all authentication UI components
  - Updated dependency injection to remove all auth-related registrations
  - Maintained core Firebase services (Analytics, Crashlytics) for other features
  - **Benefits**: Clean foundation for Supabase JWT implementation, reduced bundle size, simplified architecture
  - **Status**: Core app features remain fully functional, authentication features temporarily disabled

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

- **Pre-Generated Stories API** ✅
  - API integration for fetching curated stories from server
  - Transition from asset-based to API-driven approach
  - Network-aware error handling with retry functionality
  - Comprehensive test coverage and analytics integration

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

- **In-App Feedback**
  - Feedback collection system
  - Bug reporting system
  - Feature request system
  - User satisfaction surveys

## [1.0.7] - 2025-08-06 - Pre-Generated Stories API Integration

### Added
- **Pre-Generated Stories API Integration**: Transitioned from asset-based pre-generated stories to a fully API-driven approach
- **Enhanced StoryApiClient**: Added `fetchPreGeneratedStories()` and `fetchStoryById()` methods with comprehensive error handling
- **Repository Layer Updates**: New `loadApiPreGeneratedStories()` and `fetchAndSaveApiStoryById()` methods in `StoryRepositoryImpl`
- **Enhanced Data Models**: Added API response parsing methods (`fromApiPreGeneratedJson`, `fromSingleApiStoryJson`) to `StoryModel`
- **Network-Aware Error Handling**: LibraryBloc now includes retry functionality with user-friendly error messages
- **Retry Mechanism**: Added `RetryLoadStories` event and `showRetryButton` state for improved UX
- **Comprehensive Test Coverage**: 3 tests for API integration scenarios (success, duplicates, errors) plus enhanced background generation tests

### Changed
- **Removed Story Assets**: Eliminated pre-generated story JSON file and image assets to reduce app bundle size
- **Enhanced ImageService**: Added graceful empty path handling with fallback widgets
- **Updated StoryModel**: Now uses API UUIDs directly instead of prefixed IDs for better consistency
- **Improved Error Messages**: Creative, magical-themed error messages for various network failure scenarios
- **Enhanced Analytics**: Detailed error tracking with categorized failure types for better monitoring

### Technical Improvements
- **Dynamic Content Loading**: Fresh stories available without app updates through API integration
- **Scalable Architecture**: Easy addition of new stories via API without app releases
- **Network-Aware UI**: Clear feedback for connectivity issues with retry functionality
- **Duplicate Prevention**: Smart logic using story UUIDs to prevent duplicate API stories
- **Transaction-Based Operations**: Database consistency with proper error handling
- **Clean Architecture**: Proper separation of concerns with BLoC pattern maintained

### Benefits
- **Reduced App Bundle Size**: Removed story assets to minimize app size
- **Better User Experience**: Network-aware error handling with user-friendly retry functionality
- **Production Ready**: Comprehensive logging, analytics integration, and robust error handling

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
