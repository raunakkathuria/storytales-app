# High-Level Architecture

This document provides an overview of the architecture for the StoryTales app. For Phase 1-specific architecture details, see the original architecture description below. For Phase 2 architecture details, refer to the [Phase 2 documentation](phase-two/README.md).

## Current Architecture Status

- **Phase 1**: ✅ Completed (April 2025)
- **Phase 2**: 🚧 In Progress - See [Phase 2 Overview](phase-two/overview.md) for details

**Important Update (August 2025)**: The Firebase Authentication system has been completely removed to prepare for future Supabase JWT implementation. The architecture has been simplified to focus on core storytelling features while maintaining a clean foundation for future authentication integration.

**Current State**:
- ✅ Core storytelling features fully functional
- ✅ Pre-generated stories API integration
- ✅ Firebase Analytics and Crashlytics
- ❌ Authentication and user management temporarily removed
- ❌ Cross-device synchronization postponed

---

# Original Phase 1 Architecture

Below is a high-level architecture diagram and a component diagram for Phase 1 of the StoryTales app, as described in the Phased Implementation Plan and the Technical Specification. These visuals illustrate how the app's pieces fit together—focusing on the client-side (Flutter), local storage for offline reading, and direct interaction with the AI service to generate stories.

```
┌────────────────────────────────────────────────┐
│                StoryTales App                 │
│ (Flutter UI & BLoC State Management Layer)    │
│       - Subscription checks (local)           │
│       - Offline story library (SQLite)        │
│       - Pre-generated story assets            │
│       - Minimal in-app purchase logic         │
│       - Firebase Analytics for usage events   │
└───────────────┬───────────────────────────────┘
                │  (HTTP calls via Dio)
                v
┌────────────────────────────────────────────────┐
│        External AI Story Generation API        │
│   - Receives user inputs (age, name, etc.)     │
│   - Returns text + image URLs for stories      │
└────────────────────────────────────────────────┘

```

**Key Points**

- **Flutter App**: Houses all UI screens (Library, Story Reader, Generation Flow), plus BLoC classes to manage state and business logic.
- **Local Storage**: Uses SQLite to store generated stories and the pre-loaded ones for offline reading.
- **AI API**: The app calls an **external AI service** directly. In Phase 1, there is no custom backend; subscription tracking and story limits happen locally.

## Component Diagram (Phase 1)

Below is a more **detailed look** at the internal components within the Flutter app, showing how data and logic flow between them.

                                                 ┌────────────────────────────┐
                                                 │ External AI Story Gen API │
                                                 └──────────────▲─────────────┘
                                                                │
                                                                │ (Dio HTTP)
                                                                │
    ┌────────────────────────┐         ┌────────────────────────┴────────────────────────┐
    │   Presentation Layer   │         │                 Data / Domain Layer            │
    │  (Flutter UI + BLoC)   │         │ (Repositories, Services, Local Storage, etc.)  │
    └───────────▲────────────┘         └───────────────────────────────────────────────┘
                │ BLoC events/states
                │
       ┌─────────────────────┐
       │     UI Widgets      │
       │  (Library, Reader,  │  <--- Renders, listens to BLoC states
       │  Generation Flow)   │
       └─────────────────────┘

**Main Components**:

1. **UI Widgets / Screens**
   - **Home/LibraryScreen**: Displays list of stories (both generated & pre-generated).
   - **StoryReaderScreen**: Renders a selected story page by page with optimized navigation.
   - **GenerationFlow**: Collects user input (age, character name, etc.) and calls BLoC to generate a new story.

2. **BLoCs**
   - **StoryGenerationBloc**: Coordinates AI calls and ensures the user still has free generations available (or is subscribed).
   - **LibraryBloc**: Loads stories from local DB to show in the library.
   - **SubscriptionBloc**: Handles subscription checks (2 free stories limit, local subscription status).
   - **StoryReaderBloc**: Manages page navigation, image preloading, and story state.

3. **Data/Domain Layer**
   - **StoryRepository**:
     - Mediates between the AI API (via `StoryApiClient`) and local storage (via `LocalStorageService`).
     - Checks online/offline status (using `ConnectivityService`).
   - **LocalStorageService** (SQLite):
     - Saves story text & images so they're readable offline.
     - Persists pre-generated stories on first launch.
   - **SubscriptionService** (SharedPreferences):
     - Tracks whether the user has an active subscription.
     - Counts how many free stories they have generated (limit: 2).
   - **StoryApiClient** (Dio HTTP):
     - Sends generation requests to the AI service.
     - Receives story text + image URLs, passes them back to the repository.
   - **ImageService**:
     - Handles image loading, caching, and preloading.
     - Provides fallback mechanisms for missing images.
     - Optimizes memory usage with strategic preloading.

4. **External AI Service**
   - Returns story JSON (and possibly image references).
   - The Flutter app stores this data locally for offline access.

**Performance Optimizations**:

1. **Image Loading Strategy**
   - Efficient image preloading mechanism that prioritizes the next page
   - Uses `Future.microtask()` to avoid blocking the UI thread
   - Strategically preloads only necessary images to reduce memory pressure

2. **Page Navigation**
   - Leverages Flutter's built-in `PageView` with `allowImplicitScrolling` for smooth transitions
   - Uses `PageController` with `keepPage: true` to maintain page state during rebuilds
   - Implements robust error handling for page controller operations

---

### Tech Stack Summary (Current)

- **Flutter** (3.10+, Dart 3.0+) for cross-platform (iOS/Android) UI.
- **flutter_bloc** for state management (BLoC pattern).
- **sqflite** for local database operations.
- **Dio** for network requests to the AI API and pre-generated stories API.
- **SharedPreferences** for storing subscription flags and free-story usage counters.
- **Firebase Analytics** for usage tracking and event monitoring.
- **Firebase Crashlytics** for crash reporting and stability monitoring.

### Removed Components (August 2025)

- **Firebase Authentication**: Removed to prepare for Supabase JWT implementation
- **Firebase Firestore**: Removed along with authentication system
- **User Profile Management**: Temporarily disabled
- **Cross-Device Synchronization**: Postponed until new authentication system

---

## Pros & Cons of This Architecture (Phase 1)

**Pros**
1. **Simplicity**: No extra backend to maintain; direct AI API calls and local gating for subscriptions.
2. **Offline Capability**: SQLite-based library ensures offline reading of generated/preloaded stories.
3. **Rapid MVP**: Minimal overhead; straightforward to implement an early product and gather user feedback.

**Cons**
1. **Security**: Subscription checks are purely client-side; advanced users could bypass them on rooted devices.
2. **No Cross-Device Sync**: Without a server, story data and subscription info live only on local storage.
3. **Scaling Limitations**: If you need user accounts or advanced analytics soon, you'll eventually need a backend.

---

### Transition to a Lightweight Backend (Phase 2)

As detailed in the [Phase 2 Overview](phase-two/overview.md), Phase 2 introduces a lightweight backend to handle:

- **User Authentication & Cross-Device Sync**
- **Server-Side Subscription Validation**
- **More Robust Analytics & Personalization**

The architecture evolves to route calls through our own **server** instead of the app talking directly to the AI API, offering better control, security, and multi-device features. This transition is currently in progress.

---

**Use these diagrams** alongside the [Technical Specification]() to guide your Phase 1 development. They provide a clear overview of the major components, how they interact, and the boundary between the Flutter client and the external AI service.
