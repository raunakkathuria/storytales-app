## Coding Guidelines

Adopt these best practices to keep the codebase **simple** and **maintainable**:

1. **Directory Structure & Modularization**
   - **One feature → one folder** with subfolders for `data`, `presentation`, `domain`.
   - Example: `features/story_generation/data/`, `features/story_generation/domain/`, etc.
2. **Naming Conventions**
   - Classes: `UpperCamelCase` (e.g., `StoryApiClient`, `StoryRepository`).
   - Methods/variables: `lowerCamelCase` (e.g., `generateStory`, `storyCount`).
3. **BLoC / Cubit**
   - Keep logic out of widgets.
   - Each BLoC handles a discrete feature set: generating stories, library listing, subscription checks.
4. **Clean Architecture Layers**
   - **Data layer**: Repositories, local DB, external API calls.
   - **Domain layer**: Entities (e.g., `Story`, `StoryPage`) + business rules.
   - **Presentation layer**: Flutter UI + BLoC states.
   - **State Management Patterns**:
     - Use distinct state classes for different UI states:
       ```dart
       // Example of subscription states
       abstract class SubscriptionState extends Equatable {
         const SubscriptionState();
         @override
         List<Object?> get props => [];
       }

       class SubscriptionRequired extends SubscriptionState {
         final int generatedStoryCount;
         final int freeStoryLimit;
         const SubscriptionRequired({
           required this.generatedStoryCount,
           required this.freeStoryLimit,
         });
         @override
         List<Object?> get props => [generatedStoryCount, freeStoryLimit];
       }

       class FreeStoriesAvailable extends SubscriptionState {
         final int freeStoriesRemaining;
         final int totalFreeStories;
         const FreeStoriesAvailable({
           required this.freeStoriesRemaining,
           required this.totalFreeStories,
         });
         @override
         List<Object?> get props => [freeStoriesRemaining, totalFreeStories];
       }
       ```
     - Handle state transitions in the BLoC:
       ```dart
       // Example of state transition in a BLoC
       Future<void> _onGetFreeStoriesRemaining(
         GetFreeStoriesRemaining event,
         Emitter<SubscriptionState> emit,
       ) async {
         try {
           final freeStoriesRemaining = await _repository.getFreeStoriesRemaining();
           final freeStoryLimit = _repository.getFreeStoryLimit();

           if (freeStoriesRemaining <= 0) {
             // User has no free stories remaining, subscription is required
             emit(SubscriptionRequired(
               generatedStoryCount: await _repository.getGeneratedStoryCount(),
               freeStoryLimit: freeStoryLimit,
             ));
           } else {
             // User still has free stories remaining
             emit(FreeStoriesAvailable(
               freeStoriesRemaining: freeStoriesRemaining,
               totalFreeStories: freeStoryLimit,
             ));
           }
         } catch (e) {
           emit(SubscriptionError(message: e.toString()));
         }
       }
       ```
5. **Standard Flutter Modules & Widgets**
   - **Use Flutter's standard widgets** whenever possible instead of custom implementations.
   - Follow Material Design (or Cupertino) guidelines for consistency.
   - Leverage Flutter's built-in capabilities:
     - Use `Navigator` for routing instead of custom solutions
     - Prefer `ListView.builder` over manual list implementations
     - Use `showModalBottomSheet` for bottom sheets instead of custom overlays
     - Implement `InheritedWidget` or `Provider` for state management when appropriate
   - Only create custom widgets when standard ones don't meet requirements.
6. **Responsive Design & Accessibility**
   - **Always use ResponsiveText** instead of standard Text widgets:
     ```dart
     // Instead of this:
     Text('Hello World', style: TextStyle(fontSize: 16))

     // Use this:
     ResponsiveText(
       text: 'Hello World',
       style: const TextStyle(fontSize: 16),
     )
     ```
   - **Always use ResponsiveIcon** with appropriate size categories:
     ```dart
     // Instead of this:
     Icon(Icons.favorite, size: 24)

     // Use this:
     ResponsiveIcon(
       icon: Icons.favorite,
       sizeCategory: IconSizeCategory.medium,
     )
     ```
   - **Follow text size guidelines** from the Responsive Design Guide
   - **Ensure touch targets** are at least 44x44px for good accessibility
   - **Test with different text scaling factors** (0.8, 1.0, 1.5)
   - **Avoid fixed-height containers** for text elements

7. **Avoiding Deprecated Methods**
   - **Never use deprecated APIs** as they may be removed in future Flutter versions.
   - Common replacements to use:
     - Use `withValues(alpha: 0.5)` instead of deprecated `withOpacity(0.5)`
     - Use `surfaceColor` instead of deprecated `backgroundColor`
     - Use `ColorScheme.surface` instead of `ColorScheme.background`
     - Use `ThemeData.colorScheme` instead of direct color properties
     - Use `MediaQuery.of(context).size` instead of `MediaQuery.of(context).devicePixelRatio`
     - Use `ResponsiveText` instead of standard `Text` widgets
     - Use `ResponsiveIcon` instead of standard `Icon` widgets with fixed sizes
   - Check Flutter documentation and lint warnings to identify deprecated methods.
   - Run `flutter pub outdated` regularly to identify packages with newer versions.
7. **File Size & Organization**
   - Generally **1 class per file** if a class is non-trivial.
   - Avoid "god" classes > 300–400 lines. Split code logically.
8. **Error Handling**
   - Centralize custom exceptions (`StoryGenerationException`, etc.).
   - Show friendly fallback messages in the UI.
9. **Testing**
   - Keep test files in `test/` mirroring the main code structure.
   - Write short, focused tests with descriptive test names.
10. **Performance**
    - Use `const` constructors where possible.
    - Cache repeated DB or API calls if it improves speed.
    - **Image Loading Best Practices:**
      - Prefer background thread processing for image preloading using `Future.microtask()`
      - Implement strategic preloading that prioritizes visible and adjacent content
      - Avoid loading all images at once; instead, load on-demand based on user navigation
    - **UI Transitions:**
      - Leverage Flutter's built-in widgets like `PageView` with their native capabilities
      - Use `allowImplicitScrolling` for smoother page transitions
      - Prefer simple transitions over complex custom animations that might cause jank
      - Implement proper error handling for UI controllers to prevent crashes
11. **Commenting & Documentation**
    - Add doc comments (`///`) to classes/methods explaining purpose if not obvious.
    - Keep in-line comments minimal and relevant.
12. **Consistency**
    - Use Dart's official style: run `dart format` or `flutter format`.
    - Lint your code with `dart analyze`.
    - Enable and follow the Flutter linter rules in `analysis_options.yaml`.
