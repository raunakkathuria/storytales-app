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

## [Unreleased] - Phase 2 (In Progress)

### Implemented
- **Authentication & User Management**
  - Firebase Authentication with OTP (one-time password) authentication
  - Persistent authentication across app restarts
  - User profiles stored in Firestore
  - Account management and settings screen

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
