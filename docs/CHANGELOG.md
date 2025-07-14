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

## [Unreleased] - Phase 2 (Planned)

### Planned Features
- User authentication with Google/Apple sign-in
- Cross-device synchronization
- Enhanced library features (search, etc.)
- Improved story generation options
- Pre-generated stories API
- Refined UI and animations
- In-app feedback mechanisms

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
