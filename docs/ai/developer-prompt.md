You are a skilled Flutter developer experienced with the BLoC pattern, local SQLite storage, in-app purchases, Firebase Analytics, and theming. Your task is to implement **Phase 1** of the "StoryTales" children's storytelling app.

Please follow these references and instructions carefully:

1. **Phased Implementation Plan** (docs/specification/phase-one-technical-specification.md and docs/specification/future-phases.md)
   - Build only the **Phase 1** scope: AI-based story generation with 2 free stories before subscription paywall, pre-generated offline stories, local library, minimal UI, etc.

2. **Technical Specification** (docs/specification/phase-one-technical-specification.md and docs/specification/data-model.md)
   - Covers system architecture (Flutter + SQLite + BLoC + Dio), data models, error handling, subscription gating, and analytics approach.
   - The data model document provides detailed database schema, entity relationships, and JSON formats.

3. **Branding Document** (docs/guidelines/branding.md)
   - Ensure you keep **all brand color definitions** (the "Under the Sea" palette described in the Branding Document or whichever chosen palette) in **one theme file** (e.g., `theme.dart`), rather than spreading hex codes across multiple widgets.
   - Follow the recommended color roles (primary, secondary, accent, background).
   - Use child-friendly fonts and a consistent, playful style aligned with the brand vision.

4. **Wireframes** (wireframes/ and docs/specification/wireframes-description.md)
   - Follow the UI designs provided in the wireframes for the app homepage, story pages, and discussion questions.
   - Refer to the wireframes description document for detailed explanations of each screen component.
   - Implement the tab-based library with "All Stories" and "Favorites" tabs.
   - Create story cards with background illustrations, favorite/delete icons, and title/reading time.
   - Build the story reader with full-screen illustrations and text overlays.

**Key Requirements**:

- **Core MVP Features (Phase 1)**:
  - Story generation (2 free stories, then subscription required)
  - Pre-generated bundled stories
  - Local library with offline reading
  - Simple subscription model using in-app purchases or stubs
  - **Firebase Analytics** to log critical events (story creation, subscription prompt) as specified in the Firebase Analytics Integration section
  - BLoC-based UI with clean architecture following the wireframes

- **UI Implementation**:
  - **Library Screen**:
    - Tab bar with "All Stories" and "Favorites" tabs
    - Grid of story cards with background illustrations
    - Favorite and delete icons on each card
    - Story title and reading time displayed on cards
    - Floating action button for creating new stories
  - **Story Reader**:
    - Header with reading time, page indicators, and action icons
    - Full-screen illustrations as backgrounds
    - Semi-transparent text overlay for story content
    - Discussion questions page at the end of each story
    - Character info, age range, and creation date on the final page

- **Brand Theme & UI**:
  - Centralize color definitions in a single file (e.g., `theme.dart`)
  - Use semantic color roles instead of hardcoding hex codes in widgets
  - Maintain child-friendly fonts, sizes, and visual style from the Branding Document

- **Coding Guidelines** (docs/guidelines/coding-guidelines.md):
  - One class or small cohesive set of classes per file
  - BLoC for state management, with repository/services for data logic
  - Test coverage for major flows (unit + widget tests)
  - Thorough error handling, referencing the domain exceptions from the Tech Spec

- **Deployment**:
  - Basic store submissions prep for iOS and Android
  - This is still MVP scope, so no user login or cross-device sync in Phase 1 (these features are planned for Phase 2 as described in docs/specification/future-phases.md)
  - Comply with store guidelines (especially if child-directed content)

**Deliverables**:
- A Flutter project implementing Phase 1 with the brand theme stored in a single theme file
- Basic test coverage
- Minimal documentation for how to swap color palettes if needed (just by editing the theme file)
- Confirmation that all references (Phased Plan, Tech Spec, Branding Doc, Coding Guidelines) are followed

If you have any questions or need clarifications, please ask. We'll proceed to Phase 2 (user accounts, cross-device sync) once Phase 1 is stable and meets the success criteria (1,000+ active users, 4.0 rating, etc.).
