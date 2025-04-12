# StoryTales – Phase 1 Implementation & Technical Specification

**Version**: 1.1
**References**:

- Phased Plan:
- Technical Spec:
- Wireframes: wireframes/
- Wireframes Description: docs/specification/wireframes-description.md
- Data Model: docs/specification/data-model.md

## Overview

**Goal**: Deliver a fully functional MVP of the StoryTales app – an AI-powered storytelling application – to quickly gather **initial user feedback** and validate the concept in the market.

**Scope**:

- This document focuses **exclusively on Phase 1**.
- Future expansions (user accounts, cross-device sync, personalization, etc.) are addressed separately in the “Future Phases” document.

## Core MVP Features

From the Phased Implementation Plan (), Phase 1 requires:

1. **Story Generation**
   - Basic AI integration for generating short, child-friendly stories
   - Simple loading/progress screen
   - Up to 2 free story generations per user (subscription paywall after limit)
2. **Pre-Generated Stories**
   - A small set of bundled stories included in the app
   - Immediately available (offline) after installation
3. **Story Library**
   - Tab-based library display with "All Stories" and "Favorites" tabs
   - Grid view of story cards with illustrations, title, and reading time
   - Favorite and delete functionality for stories
   - Opening a story launches a reader UI with text and images
4. **Subscription Model**
   - Non-subscribers: 2 free stories
   - Premium: Monthly/annual subscriptions
   - Local gating in Phase 1 (SharedPreferences or similar)
5. **Offline Access**
   - Read saved stories without internet
   - No new story generation if offline
6. **UI & Error Handling**
   - Child-friendly interface with consistent branding
   - Story cards with background illustrations and overlay text
   - Story reader with full-screen illustrations and text overlays
   - Discussion questions at the end of stories
   - Show user-friendly errors for connectivity or AI call failures

## Architecture & Components

Below is the recommended **clean architecture** approach for Phase 1.

### 1. App (Flutter)

- **BLoC State Management**
  - At least four main BLoCs:
    1. **StoryGenerationBloc** (handles AI calls + subscription checks)
    2. **LibraryBloc** (manages the display of local stories)
    3. **SubscriptionBloc** (handles subscription status, free story count)
    4. **StoryReaderBloc** (manages story reading experience)
- **Data & Domain Layers**
  - `StoryRepository` orchestrates data flow between the AI client (`StoryApiClient`), local storage (`LocalStorageService`), and connectivity checks (`ConnectivityService`).
- **Local Storage (SQLite)**
  - Stores:
    - **Generated stories** (text + images)
    - **Pre-generated stories** on first run
    - **Story metadata** (reading time, favorite status, etc.)
    - **Discussion questions** for each story
  - Permits offline reading
- **SubscriptionService**
  - Tracks free usage (2 stories) vs. subscription "unlocked"
  - For Phase 1, purely local checks (e.g., a flag `has_active_subscription` in SharedPreferences)

### 2. External AI Story Generation

- **AI Endpoint**: The app calls an external HTTP endpoint using `Dio`.
- **Timeouts**: Up to ~2 minutes. Show a simulated progress bar.

### 3. Optional: Lightweight Backend?

- For Phase 1, an **optional** backend can store subscription receipts or user data.
- If not used, handle everything locally. See the separate architecture diagrams discussed previously.

## Detailed Implementation Steps

1. **Project Setup**

   - Create a **Flutter** app (3.10+).

   - Initialize packages:

     - `flutter_bloc` for state management
     - `sqflite` for local DB
     - `dio` for HTTP
     - `in_app_purchase` or `in_app_purchase_flutter` (platform IAP)

   - Basic folder structure:

     ```
     lib/
       core/
         errors/
         services/
       features/
         story_generation/
         library/
         subscription/
       main.dart
       app.dart
     assets/
       pre_generated_stories.json
     pubspec.yaml
     ```

2. **Local DB & Pre-Generated Stories**

   - Implement `LocalStorageService` to manage two tables: `stories` and `pages`.
   - On first launch, parse `pre_generated_stories.json` → save to local DB.
   - These appear in the library so user sees immediate offline content.

3. **Story Generation Flow**

   - **StoryGenerationBloc** responds to user events:
     1. Check connectivity.
     2. Check subscription/free usage limit.
     3. If allowed, call AI endpoint via `StoryApiClient`.
     4. Parse story JSON → store in SQLite → emit success state.
   - Show `StoryGenerationLoadingScreen` with simulated progress.

4. **Library Screen**

   - **LibraryBloc** loads local DB stories.
   - Tab bar with "All Stories" and "Favorites" tabs.
   - Display stories in a grid (2 columns).
   - Each story card shows:
     - Background illustration
     - Favorite and delete icons in top-right
     - Title and reading time in bottom-left
   - Floating action button (➕) for creating new stories.
   - Tapping a story → open `StoryReaderScreen`.

5. **Story Reader**

   - **StoryReaderBloc** manages page navigation and story state.
   - Header with:
     - Reading time on the left
     - Page indicators (dots) in the center
     - Favorite and close icons on the right
   - Full-screen illustration as background for each page.
   - Semi-transparent text overlay at the bottom with story content.
   - Swipe or tap navigation to move between pages.
   - Final page shows "Ideas for Discussion" with:
     - Bulleted discussion questions
     - Character info, age range, and creation date
     - Thank you message

6. **Subscription Handling**

   - Use `SharedPreferences` to track:
     - `generated_story_count`: # of user-generated stories
     - `has_active_subscription`: bool
   - In-app purchase flow can be minimal or stubbed:
     - After user tries 3rd story: show paywall → if they purchase, set `has_active_subscription = true`.

7. **Offline Considerations**

   - If offline, block new generation requests.
   - Library is still accessible.

8. **Firebase Analytics Setup**

   - **See Firebase Analytics Integration** for details on adding custom event logging.

9. **Error Handling**

   - Wrap AI calls in try/catch.
   - Show user-friendly messages like “Connection timed out. Retry?”
   - If subscription gating fails, display “You’ve reached 2 free stories.”

10. **Testing**

   - Write unit tests for BLoCs, e.g. verifying generation limit logic.
   - Basic widget tests for library listing and story reading.
   - If possible, an integration test for the entire flow: from creation to reading a generated story.

11. **Build & Release**

- Prepare your store listings (icons, screenshots).
- Launch once stable.

## Firebase Analytics Integration

### SDK Installation

**pubspec.yaml** snippet:

```
yaml


CopyEdit
dependencies:
  flutter:
    sdk: flutter

  # Firebase core + analytics
  firebase_core: ^2.8.0
  firebase_analytics: ^10.0.6
  # ... other dependencies like sqflite, dio, bloc, etc.
```

### App Initialization

- **main.dart** (Android & iOS):

```
dart


CopyEdit
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'app.dart';
import 'firebase_options.dart'; // This file is auto-generated by the Firebase CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const StoryTalesApp());
}
```

- Your `StoryTalesApp` can have an optional **`navigatorObservers`** parameter to track screen views automatically:

```
dart


CopyEdit
class StoryTalesApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  const StoryTalesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryTales',
      navigatorObservers: [observer],
      // ...
      home: LibraryScreen(),
    );
  }
}
```

### Logging Events

Use a small **AnalyticsService** or direct calls to `FirebaseAnalytics.instance`. For instance:

```
dart


CopyEdit
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  Future<void> logStoryGenerated({
    required String storyId,
    required String storyTitle,
    int? age,
  }) async {
    await _analytics.logEvent(
      name: 'story_generated',
      parameters: {
        'story_id': storyId,
        'title': storyTitle,
        if (age != null) 'age': age,
      },
    );
  }

  Future<void> logStoryViewed({
    required String storyId,
    required String storyTitle,
  }) async {
    await _analytics.logEvent(
      name: 'story_viewed',
      parameters: {
        'story_id': storyId,
        'title': storyTitle,
      },
    );
  }

  Future<void> logSubscriptionPrompt() async {
    await _analytics.logEvent(name: 'subscription_prompt_shown');
  }

  // More events as needed...
}
```

Then, inside your BLoCs or UI flows, you can do something like:

```
dart


CopyEdit
class StoryGenerationBloc extends Bloc<StoryGenerationEvent, StoryGenerationState> {
  final StoryRepository _repository;
  final SubscriptionService _subscriptionService;
  final AnalyticsService _analytics;

  StoryGenerationBloc({
    required StoryRepository repository,
    required SubscriptionService subscriptionService,
    required AnalyticsService analytics,
  })  : _repository = repository,
        _subscriptionService = subscriptionService,
        _analytics = analytics,
        super(StoryGenerationInitial()) {
    on<GenerateStoryRequested>(_onGenerateStoryRequested);
  }

  Future<void> _onGenerateStoryRequested(
    GenerateStoryRequested event,
    Emitter<StoryGenerationState> emit,
  ) async {
    emit(StoryGenerationLoading());

    try {
      final canCreate = await _subscriptionService.canCreateStory();
      if (!canCreate) {
        await _analytics.logSubscriptionPrompt(); // User hits paywall
        emit(StoryGenerationFailure(
          error: 'You have reached the free story limit.',
          isRetryable: false,
        ));
        return;
      }

      // Generate the story
      final story = await _repository.generateStory(event.request);

      // Log analytics event
      await _analytics.logStoryGenerated(
        storyId: story.id,
        storyTitle: story.title,
        age: event.request.age,
      );

      // ...
      emit(StoryGenerationSuccess(story: story));
    } catch (e) {
      // ...
    }
  }
}
```

## Testing & QA

1. **Unit Tests**
   - BLoC logic: subscription gating, story generation success/failure paths, offline checks.
   - Repositories: ensuring DB inserts and fetches work as expected.
2. **Widget Tests**
   - `LibraryScreen` layout under different story counts.
   - `StoryReaderScreen` page flipping.
3. **Integration Tests**
   - End-to-end flows: open app → generate story → read story → hit paywall at 3rd story.
4. **Beta Testing**
   - Use TestFlight (iOS) or Internal Testing (Google Play) to distribute early builds.
   - Gather feedback from alpha/beta testers.

## Deployment & Release

1. **App Store/Play Console Setup**
   - Register in-app purchase products (monthly, annual).
   - Provide store descriptions, screenshots.
2. **Build Config & Signing**
   - Properly sign iOS and Android releases with your certificates/keys.
   - If using CI/CD, integrate automatic build steps.
3. **Release Strategy**
   - Possibly do a small test region or closed alpha to verify stability.
   - Then roll out publicly once satisfied with user feedback and minimal critical bugs.

## Phase 1 Completion Criteria

Per , moving from Phase 1 to Phase 2 requires:

- **1,000+ active users** within a reasonable timeframe
- **≥ 4.0 average rating** in app stores
- **≥95% story generation success rate**
- **≥98% crash-free sessions**
- User feedback on the MVP’s core features, guiding next-phase improvements

Once these metrics are **reasonably** met (or the team decides to proceed), you can confidently move to **Phase 2** (User Accounts, Enhanced UX).
