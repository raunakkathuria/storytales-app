# Performance Best Practices

This document outlines key performance considerations for the StoryTales app, with a focus on providing a smooth, responsive user experience, particularly for the story reading functionality.

## Image Loading Strategies

### Strategic Preloading

```dart
// Efficient preloading that only loads what's needed
void _preloadNextPageImage(Story story, int currentIndex) {
  // Only preload the next page to avoid unnecessary work
  if (currentIndex < story.pages.length - 1) {
    // Use microtask to avoid blocking the UI thread
    Future.microtask(() {
      final imageService = ImageService();
      final nextPage = story.pages[currentIndex + 1];
      imageService.preloadImage(context, nextPage.imagePath);
    });
  }
}
```

**Best Practices:**

1. **Prioritize Visible Content First**
   - Load the current page at full quality immediately
   - Then load adjacent pages (next/previous) that the user might navigate to

2. **Use Background Processing**
   - Always use `Future.microtask()` for image preloading to avoid blocking the UI thread
   - This ensures smooth scrolling and transitions even while loading images

3. **Implement Fallbacks**
   - Always provide placeholder images or loading indicators
   - Handle missing images gracefully with appropriate error states

4. **Avoid Excessive Preloading**
   - Don't preload all images at once, which can cause memory pressure
   - Preload strategically based on user navigation patterns

## Page Transitions & UI Rendering

### Optimized PageView Configuration

```dart
PageView.builder(
  controller: _pageController,
  itemCount: story.pages.length,
  physics: const PageScrollPhysics(),
  pageSnapping: true,
  allowImplicitScrolling: true, // Enable adjacent page caching
  onPageChanged: (index) {
    // Update state when page changes via swipe
    if (index != state.currentPageIndex) {
      context.read<StoryReaderBloc>().add(GoToPage(pageIndex: index));
    }
  },
  itemBuilder: (context, index) {
    return StoryPageView(
      key: ValueKey('page_$index'), // Important for widget identity
      story: story,
      currentPageIndex: index,
      // ...
    );
  },
)
```

**Best Practices:**

1. **Leverage Built-in Flutter Widgets**
   - Use Flutter's built-in `PageView` with its native capabilities
   - Enable `allowImplicitScrolling` for smoother transitions between pages
   - Use `pageSnapping` for a more natural feel

2. **Optimize PageController**
   - Use `keepPage: true` to maintain page state during rebuilds
   - Implement proper error handling for page controller operations
   - Recreate controllers gracefully if they become detached

3. **Avoid Custom Animations When Possible**
   - Prefer Flutter's built-in animations over custom implementations
   - Custom animations often cause jank and performance issues
   - If custom animations are necessary, ensure they're optimized for performance

4. **Widget Keys for Stability**
   - Use unique keys for list items and pages to maintain widget identity
   - This helps Flutter's reconciliation process and prevents unnecessary rebuilds

## Memory Management

1. **Dispose Resources Properly**
   ```dart
   @override
   void dispose() {
     _pageController?.dispose();
     super.dispose();
   }
   ```

2. **Use const Constructors**
   - Whenever possible, use `const` constructors to reduce memory allocations
   - This is especially important for widgets that don't change often

3. **Implement AutomaticKeepAliveClientMixin**
   ```dart
   class _StoryPageViewState extends State<StoryPageView>
       with AutomaticKeepAliveClientMixin {
     @override
     bool get wantKeepAlive => true; // Keep this page in memory when not visible

     @override
     Widget build(BuildContext context) {
       super.build(context); // Required for AutomaticKeepAliveClientMixin
       // ...
     }
   }
   ```

4. **Avoid Memory Leaks**
   - Cancel subscriptions and listeners in `dispose()` methods
   - Use weak references when appropriate
   - Be cautious with closures that capture context or state

## Error Handling for UI Components

1. **Graceful Recovery for PageController**
   ```dart
   try {
     _pageController!.animateToPage(
       state.currentPageIndex,
       duration: const Duration(milliseconds: 300),
       curve: Curves.easeInOut,
     );
   } catch (e) {
     // If animation fails, recreate the controller
     _pageController?.dispose();
     _pageController = PageController(
       initialPage: state.currentPageIndex,
       keepPage: true,
     );
     sl<LoggingService>().warning('Recreated page controller due to error: $e');
   }
   ```

2. **Image Loading Error Handling**
   - Always provide fallback images
   - Log errors for debugging
   - Show appropriate UI feedback to users

## Testing Performance

1. **Profile Regularly**
   - Use Flutter DevTools to profile your app
   - Look for jank, excessive rebuilds, and memory leaks

2. **Test on Low-End Devices**
   - Don't just test on high-end devices
   - Ensure smooth performance on older/slower devices

3. **Automated Performance Tests**
   - Consider implementing automated performance tests for critical flows
   - Set performance budgets and monitor them over time

## Conclusion

Following these performance best practices will help ensure that the StoryTales app provides a smooth, responsive experience for users, particularly during the critical story reading experience. Remember that performance optimization is an ongoing process - regularly profile your app and address issues as they arise.
