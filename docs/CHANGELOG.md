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

## [1.0.7] - 2025-08-06

### Added
- **Pre-Generated Stories API Integration**
  - Transitioned from asset-based pre-generated stories to fully API-driven approach
  - Enhanced StoryApiClient with `fetchPreGeneratedStories()` and `fetchStoryById()` methods
  - Added comprehensive error handling for network failures and API issues
  - Implemented repository layer updates with `loadApiPreGeneratedStories()` and `fetchAndSaveApiStoryById()` methods
  - Enhanced StoryModel with API response parsing methods (`fromApiPreGeneratedJson`, `fromSingleApiStoryJson`)
  - Added network-aware error handling with retry functionality in LibraryBloc
  - Implemented `RetryLoadStories` event and `showRetryButton` state for improved UX
  - Added comprehensive test coverage: 3 tests for API integration scenarios (success, duplicates, errors)
  - Enhanced background generation tests for countdown and completion states
  - Implemented duplicate prevention logic using story UUIDs to prevent duplicate API stories
  - Added transaction-based database operations for consistency and proper error handling

### Changed
- **Removed Story Assets**: Eliminated pre-generated story JSON file and image assets to reduce app bundle size
- **Enhanced ImageService**: Added graceful empty path handling with fallback widgets for missing images
- **Updated StoryModel**: Now uses API UUIDs directly instead of prefixed IDs for better consistency
- **Improved Error Messages**: Creative, magical-themed error messages for various network failure scenarios
- **Enhanced Analytics**: Detailed error tracking with categorized failure types for better monitoring

### Technical Improvements
- **Dynamic Content Loading**: Fresh stories available without app updates through API integration
- **Scalable Architecture**: Easy addition of new stories via API without requiring app releases
- **Network-Aware UI**: Clear feedback for connectivity issues with user-friendly retry functionality
- **Clean Architecture**: Proper separation of concerns with BLoC pattern maintained throughout
- **Comprehensive Logging**: Enhanced API client with detailed request/response logging for debugging
- **Production Ready**: Robust error handling, analytics integration, and comprehensive test coverage

### Benefits
- **Reduced App Bundle Size**: Removed story assets to minimize app download and installation size
- **Better User Experience**: Network-aware error handling with intuitive retry functionality
- **Improved Scalability**: Dynamic content loading enables rapid content updates without app store releases
- **Enhanced Reliability**: Comprehensive error handling and fallback mechanisms for network issues

## [2.0.0] - 2025-09-01

### Added
- **Complete Authentication System Implementation** ✅
  - Device-based user authentication with automatic account recovery
  - OTP-based email verification system replacing Firebase Authentication
  - Session management with proper sign-out functionality
  - Single-purpose screen architecture with dedicated authentication flows:
    - `RegisterPage` - Standalone user registration
    - `LoginPage` - Standalone user login  
    - `VerifyEmailPage` - Standalone OTP verification for registration
    - `LoginVerifyPage` - Standalone OTP verification for login
    - `ProfileEditPage` - Dedicated profile editing screen
  - Persistent OTP verification state recovery system
  - Comprehensive error handling and retry mechanisms for expired/invalid OTPs
  - Intelligent API loop detection for signed-out users (409→404 pattern)
  - Support for new `is_authenticated` API field with backward compatibility
  - Enhanced UserProfile entity with session tracking (`sessionId`, `sessionCreatedAt`)
  - Robust API pattern abstraction for authentication states
  - Comprehensive test coverage with 6+ test files covering all authentication scenarios

### Changed
- **Architecture Migration**: Completely replaced Firebase Authentication with custom API integration
- **UI/UX Improvements**: 
  - Simplified profile screen with single-purpose design
  - Removed duplicate headers and verbose content across authentication screens
  - Standardized terminology from "OTP" to "verification code" throughout app
  - Enhanced ProfileHeader with tappable edit icon for seamless navigation
  - Improved error messages with magical-themed, user-friendly language
- **API Integration**: Enhanced UserApiClient with comprehensive authentication endpoints
- **State Management**: Significantly improved ProfileBloc with robust state handling for all authentication scenarios
- **Code Quality**: Standardized debug logging, removed unused imports, fixed async safety issues

### Fixed
- **Authentication Flow Issues**: Resolved sign-out users being automatically re-authenticated
- **API Response Parsing**: Fixed login verification failure despite API success due to nested response structure  
- **BLoC Context Management**: Resolved BlocProvider context errors during screen navigation
- **State Recovery**: Fixed users getting stuck in anonymous state after incomplete registration
- **Infinite API Loops**: Eliminated 409→404 API call loops for signed-out users
- **Session Management**: Proper server-side session invalidation preventing database pollution

### Technical Improvements
- **Clean Architecture**: Maintained clean architecture principles with enhanced repository pattern
- **Dependency Injection**: Updated GetIt container with new authentication services
- **Error Handling**: Comprehensive error recovery with retry mechanisms and user guidance
- **Performance**: Optimized API calls with intelligent caching and loop detection
- **Testing**: Extensive test coverage including unit, widget, and integration tests
- **Documentation**: Enhanced inline documentation and code comments throughout authentication system

### Benefits
- ✅ **Zero Firebase Dependency**: Complete independence from Firebase Authentication
- ✅ **Device-Based Recovery**: Seamless account recovery across device reinstalls
- ✅ **Robust Error Handling**: Users never get permanently stuck in error states
- ✅ **Clean User Experience**: Focused, single-purpose screens with clear navigation
- ✅ **Scalable Architecture**: Easy to extend with additional authentication methods
- ✅ **Production Ready**: Comprehensive testing and error handling for all edge cases

## [Unreleased] - Phase 2 (In Progress)

### Completed
- **Authentication & User Management** ✅ (docs/specification/phase-two/authentication-user-management.md)
  - **MAJOR UPDATE**: Completely reimplemented with custom API replacing Firebase Authentication [v2.0.0]
  - Device-based user authentication with automatic account recovery [Implemented]
  - OTP-based email verification system [Implemented]
  - Session management with proper sign-out functionality [Implemented]
  - Single-purpose screen architecture for authentication flows [Implemented]
  - Persistent OTP verification state recovery [Implemented]
  - Comprehensive error handling and retry mechanisms [Implemented]
  - Enhanced UserProfile entity with session tracking [Implemented]
  - Intelligent API loop detection for signed-out users [Implemented]
  - Support for new `is_authenticated` API field [Implemented]
  - Robust API pattern abstraction for authentication states [Implemented]
  - Comprehensive test coverage with multiple test files [Implemented]

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

- **Pre-Generated Stories API** ✅ (docs/specification/phase-two/pre-generated-stories-api.md)
  - Transitioned from asset-based pre-generated stories to fully API-driven approach [Implemented]
  - Enhanced StoryApiClient with fetchPreGeneratedStories() and fetchStoryById() methods [Implemented]
  - Added comprehensive error handling for network failures and API issues [Implemented]
  - Implemented repository layer updates with loadApiPreGeneratedStories() and fetchAndSaveApiStoryById() [Implemented]
  - Enhanced StoryModel with API response parsing methods (fromApiPreGeneratedJson, fromSingleApiStoryJson) [Implemented]
  - Added network-aware error handling with retry functionality in LibraryBloc [Implemented]
  - Implemented RetryLoadStories event and showRetryButton state for improved UX [Implemented]
  - Removed pre-generated story assets (JSON file and images) to reduce app bundle size [Implemented]
  - Enhanced ImageService with graceful empty path handling and fallback widgets [Implemented]
  - Updated StoryModel to use API UUIDs directly instead of prefixed IDs [Implemented]
  - Added creative, magical-themed error messages for various network failure scenarios [Implemented]
  - Enhanced analytics with detailed error tracking and categorized failure types [Implemented]
  - Implemented duplicate prevention logic using story UUIDs [Implemented]
  - Added comprehensive test coverage: 3 tests for API integration scenarios (success, duplicates, errors) [Implemented]
  - Enhanced background generation tests for countdown and completion states [Implemented]
  - Implemented transaction-based database operations for consistency [Implemented]
  - Added dynamic content loading enabling fresh stories without app updates [Implemented]
  - Created scalable architecture for easy addition of new stories via API [Implemented]

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
