# Changelog

All notable changes to the StoryTales project will be documented in this file.

## [1.0.0] - Phase 1 Completion - 2025-04-13

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

### Known Issues
- None at this time

### Bug Fixes
- Fixed story generation error by moving sample AI response file to the correct assets directory

## [Upcoming] - Phase 2 Plans
- User accounts and authentication
- Cross-device synchronization
- Enhanced personalization options
- Improved story generation with more customization options
- Social sharing features
