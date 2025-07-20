# StoryTales Changelog

All notable changes to the StoryTales application will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-04-23

### Added
- New `ResponsiveButton` component for consistent button styling across devices
- Enhanced dialog responsiveness for small screens
- Improved configuration system with better documentation
- New component documentation in `docs/guidelines/components.md`
- Updated responsive design guidelines to include button components

### Changed
- Improved dialog form layout on small screens
- Enhanced dropdown items to use ResponsiveText for better accessibility
- Updated wireframe documentation to reflect recent UI changes

### Fixed
- Fixed "No internet connection" error when using mock data
- Improved connectivity handling to fall back to mock data when offline
- Fixed button alignment issues on iPhone devices
- Fixed dialog button sizing on small screens

## [1.0.0] - 2025-04-20

### Added
- Initial release of StoryTales Phase 1 implementation
- Core architecture using Clean Architecture principles
- BLoC pattern for state management across all features
- Dependency injection system using GetIt
- Repository pattern for data access abstraction
- SQLite database for local storage of stories and related data
- Environment configuration system for development, staging, and production environments

#### Story Library Feature
- Tab-based library UI with "All Stories" and "Favorites" tabs
- Grid view displaying story cards with illustrations
- Story card components with background illustrations, favorite/delete functionality
- Title and reading time display on story cards
- Empty state handling with appropriate messaging
- Error state handling with retry options

#### Story Reader Feature
- Immersive reading experience with full-screen illustrations
- Page navigation with swipe gestures
- Semi-transparent text overlay for story content
- Header controls with reading time, page indicators, and action buttons
- Discussion questions page at the end of stories
- Character information display on the final page

#### Story Generation Feature
- AI integration for generating child-friendly stories
- Loading/progress screen during generation
- Error handling for connectivity or API failures
- Free story limit implementation (2 free stories)

#### Subscription Feature
- Subscription gating after 2 free stories
- Subscription UI with plan options (monthly/annual)
- Local storage of subscription status
- Subscription prompt when free limit is reached

#### Responsive Design
- ResponsiveText widget for adaptive text sizing
- ResponsiveIcon widget for consistent icon sizing
- Flexible layouts that adapt to different screen sizes
- Accessibility support for different text scaling preferences

#### Analytics Integration
- Firebase Analytics setup
- Custom event logging for key user actions:
  - Story generation
  - Story viewing
  - Subscription prompts

#### Offline Support
- Pre-generated stories bundled with the app
- Offline reading of saved stories
- Connectivity checks before story generation

### Changed
- N/A (Initial release)

### Fixed
- N/A (Initial release)

## [1.0.2] - 2025-06-24

### Added
- Enhanced story creation dialog with improved responsiveness and user experience
- Fixed dialog sizing issues to prevent dynamic resizing based on text content
- Improved text wrapping and overflow handling in loading dialogs
- Updated form field text to use child-friendly terminology ("Your story" instead of "Story Prompt")
- Enhanced validation messages with more encouraging, conversational language
- Better error handling for dialog layout issues

### Changed
- Story creation dialog now uses responsive font sizing for better accessibility
- Loading dialog maintains consistent dimensions while cycling through messages
- Improved dialog layout to prevent Flutter rendering errors and overflow issues
- Enhanced user experience with more intuitive form field labels and hints

### Fixed
- Fixed story creation dialog text sizing inconsistencies across different devices
- Resolved dropdown text truncation issues in age range selection
- Fixed Flutter assertion errors in loading dialog layout (`!semantics.parentDataDirty`)
- Eliminated RenderFlex overflow errors in dialog components
- Fixed dialog button alignment issues on small screens
- Improved text contrast and readability in form fields

## [1.0.3] - 2025-07-20

### Added
- **Enhanced API Client with Comprehensive Logging**
  - Added detailed request/response logging for debugging
  - Implemented DioException error handling with full error details
  - Added API key configuration logging (masked for security)
  - Enhanced connectivity error handling with fallback mechanisms

- **Development Environment Configuration Management**
  - Created Environment class for managing dev/staging/production configs
  - Added environment-specific configuration loading
  - Implemented proper configuration validation and error handling

- **Background Generation Test Suite**
  - Added comprehensive test coverage for background story generation
  - Implemented countdown mechanism testing
  - Added state transition verification tests
  - Created test utilities for BLoC testing scenarios

- **Production Firebase Setup**
  - Configured Firebase production project integration
  - Added emulator fallback support for development
  - Implemented graceful error handling for emulator connection failures
  - Enhanced Firebase initialization with environment detection

### Fixed
- **Library Auto-Refresh Issue**
  - Fixed critical issue where library wasn't refreshing after background story generation
  - Resolved BLoC emitter disposal problem that prevented state emission
  - Implemented proper event-driven architecture using Timer.run() for post-dialog events
  - Added BackgroundGenerationComplete event handling in LibraryBloc

- **BLoC State Management**
  - Fixed emitter lifecycle management to prevent "done" emitter usage
  - Implemented proper event scheduling after dialog disposal
  - Added error handling for BLoC state transitions
  - Enhanced state emission reliability for background processes

### Changed
- **Firebase Integration**
  - Improved emulator connection with graceful fallback to production services
  - Enhanced Firebase initialization with better error handling
  - Added environment-specific Firebase configuration
  - Implemented debug logging for Firebase connection status

- **API Client Enhancements**
  - Enhanced error logging with detailed DioException information
  - Added request/response logging for better debugging
  - Improved connectivity handling with mock data fallback
  - Added API endpoint and configuration validation

## [Unreleased] - Phase 2 (In Progress)

### Completed
- **Authentication & User Management** ✅ (docs/specification/phase-two/authentication-user-management.md)
  - Firebase Authentication with OTP (one-time password) authentication [Implemented]
  - Persistent authentication across app restarts [Implemented]
  - User profiles stored in Firestore [Implemented]
  - Account management and settings screen [Implemented]
  - Added Firebase Authentication and Firestore dependencies
  - Implemented AuthService with Firebase Authentication
  - Created UserProfile model for storing user data
  - Added authentication BLoC for state management
  - Implemented email link authentication flow
  - Added profile settings screen for account management
  - Updated to latest Firebase packages (firebase_core, firebase_auth, cloud_firestore)
  - Replaced discontinued firebase_dynamic_links with app_links package
  - Updated app_links to the latest version (^6.4.0)
  - Updated flutter_launcher_icons to the latest version (^0.14.3)
  - Added Firebase emulator support for local development and testing
  - Made authentication optional (not mandatory for app usage)
  - Moved sign-in functionality to profile section
  - Created unified ProfilePage for both authenticated and unauthenticated states
  - Improved UI with more visible profile button in app bar
  - Enhanced app bar with title and better spacing
  - Updated profile icon to use accent color for brand consistency
  - Switched from email link authentication to OTP-based authentication for improved testing
  - Added OTP verification screen for entering verification codes
  - Implemented secure OTP generation and verification
  - Enhanced user experience with clearer authentication flow
  - Improved error handling with branded error messages
  - Added logging service integration for OTP codes in development mode
  - Fixed profile update functionality to show success message
  - Made display name field optional in profile settings
  - Standardized age ranges to match API format: "0-2 years", "3-5 years", "6-8 years", "9-12 years", "13+ years"
  - Updated story generation to properly handle age range format with "years" suffix

- **Background Story Generation** ✅
  - Implemented timer-based countdown mechanism during story generation
  - Added background processing with proper BLoC state management
  - Created library auto-refresh when background generation completes
  - Implemented event-driven architecture for post-dialog state updates
  - Added BackgroundGenerationComplete event and state handling
  - Fixed BLoC emitter lifecycle management for background processes
  - Enhanced story generation dialog with countdown display
  - Added comprehensive test coverage for background generation scenarios

- **Production Configuration** ✅
  - Firebase production setup with environment-specific configuration
  - Enhanced API client with comprehensive logging and error handling
  - Development environment management with emulator support
  - Production API endpoint configuration and validation
  - Environment-based configuration loading system
  - Enhanced debugging and monitoring capabilities

### In Development

### Coming Soon
- **Cross-Device Synchronization** (docs/specification/phase-two/cross-device-synchronization.md)
  - Cloud-based story storage
  - Conflict resolution for offline changes
  - Background sync capabilities
  - Offline support with queuing

- **Enhanced Library Features** (docs/specification/phase-two/enhanced-library-features.md)
  - Advanced search and filtering
  - Tags system for flexible categorization
  - Enhanced UI with animations
  - Organization tools (batch operations, collections, reading lists)

- **Pre-Generated Stories API** (docs/specification/phase-two/pre-generated-stories-api.md)
  - Cloud Functions API for serving pre-generated stories
  - Curated story collections
  - Discovery UI for browsing and discovering stories
  - Integration with the existing library system

- **In-App Feedback** (docs/specification/phase-two/in-app-feedback.md)
  - Feedback collection system
  - Bug reporting system
  - Feature request system
  - User satisfaction surveys

## Future Phases

### Phase 3: Advanced Features & Growth
- Personalization with AI suggestions
- Social/family accounts
- Interactive/educational content
- Advanced offline support
- Growth features (referrals, etc.)

### Phase 4: Scaling & Optimization
- Performance optimization
- Global expansion with multi-language support
- Advanced AI capabilities
- Web/tablet versions
- Additional subscription options
