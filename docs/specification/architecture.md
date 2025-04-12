# High-Level Architecture (Phase 1)

Below is a high-level architecture diagram and a component diagram for Phase 1 of the StoryTales app, as described in the Phased Implementation Plan and the Technical Specification. These visuals illustrate how the app’s pieces fit together—focusing on the client-side (Flutter), local storage for offline reading, and direct interaction with the AI service to generate stories.

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
   - **StoryReaderScreen**: Renders a selected story page by page.  
   - **GenerationFlow**: Collects user input (age, character name, etc.) and calls BLoC to generate a new story.

2. **BLoCs**  
   - **StoryGenerationBloc**: Coordinates AI calls and ensures the user still has free generations available (or is subscribed).  
   - **LibraryBloc**: Loads stories from local DB to show in the library.  
   - **SubscriptionBloc**: Handles subscription checks (2 free stories limit, local subscription status).

3. **Data/Domain Layer**  
   - **StoryRepository**:  
     - Mediates between the AI API (via `StoryApiClient`) and local storage (via `LocalStorageService`).  
     - Checks online/offline status (using `ConnectivityService`).  
   - **LocalStorageService** (SQLite):  
     - Saves story text & images so they’re readable offline.  
     - Persists pre-generated stories on first launch.  
   - **SubscriptionService** (SharedPreferences):  
     - Tracks whether the user has an active subscription.  
     - Counts how many free stories they have generated (limit: 2).  
   - **StoryApiClient** (Dio HTTP):  
     - Sends generation requests to the AI service.  
     - Receives story text + image URLs, passes them back to the repository.

4. **External AI Service**  
   - Returns story JSON (and possibly image references).  
   - The Flutter app stores this data locally for offline access.

---

### Tech Stack Summary

- **Flutter** (3.10+, Dart 3.0+) for cross-platform (iOS/Android) UI.  
- **flutter_bloc** for state management (BLoC pattern).  
- **sqflite** for local database operations.  
- **Dio** for network requests to the AI API.  
- **SharedPreferences** for storing subscription flags and free-story usage counters.  

---

## Pros & Cons of This Architecture (Phase 1)

**Pros**  
1. **Simplicity**: No extra backend to maintain; direct AI API calls and local gating for subscriptions.  
2. **Offline Capability**: SQLite-based library ensures offline reading of generated/preloaded stories.  
3. **Rapid MVP**: Minimal overhead; straightforward to implement an early product and gather user feedback.

**Cons**  
1. **Security**: Subscription checks are purely client-side; advanced users could bypass them on rooted devices.  
2. **No Cross-Device Sync**: Without a server, story data and subscription info live only on local storage.  
3. **Scaling Limitations**: If you need user accounts or advanced analytics soon, you’ll eventually need a backend.

---

### Transition to a Lightweight Backend (Future Phases)

As detailed in the [Phased Implementation Plan](), **Phase 2** or **Phase 3** may introduce a lightweight backend to handle:

- **User Authentication & Cross-Device Sync**  
- **Server-Side Subscription Validation**  
- **More Robust Analytics & Personalization**

At that point, the architecture evolves to route calls through your own **server** instead of the app talking directly to the AI API, offering better control, security, and multi-device features. For Phase 1, the **local-only** approach is typically faster to develop and release.

---

**Use these diagrams** alongside the [Technical Specification]() to guide your Phase 1 development. They provide a clear overview of the major components, how they interact, and the boundary between the Flutter client and the external AI service.