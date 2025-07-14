import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/di/injection_container.dart';
import 'package:storytales/core/services/image/image_service.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/animated_logo.dart';
import 'package:storytales/core/widgets/responsive_icon.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import 'package:storytales/features/library/domain/entities/story.dart';
import 'package:storytales/features/library/presentation/bloc/library_bloc.dart';
import 'package:storytales/features/library/presentation/bloc/library_event.dart';
import 'package:storytales/features/library/presentation/bloc/library_state.dart';
import 'package:storytales/features/story_reader/presentation/bloc/story_reader_bloc.dart';
import 'package:storytales/features/story_reader/presentation/bloc/story_reader_event.dart';
import 'package:storytales/features/story_reader/presentation/bloc/story_reader_state.dart';
import 'package:storytales/features/story_reader/presentation/widgets/page_indicator.dart';
import 'package:storytales/features/story_reader/presentation/widgets/story_page_view.dart';
import 'package:storytales/features/story_reader/presentation/widgets/questions_page.dart';

/// Page for reading a story.
class StoryReaderPage extends StatefulWidget {
  final String storyId;

  const StoryReaderPage({
    super.key,
    required this.storyId,
  });

  @override
  State<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends State<StoryReaderPage> {
  // Page controller for smooth transitions
  PageController? _pageController;

  // Keep track of the last page index to avoid accessing PageController.page before it's ready
  int _lastPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set system UI for immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    context.read<StoryReaderBloc>().add(LoadStory(storyId: widget.storyId));
  }

  /// Efficiently preload the next page image to improve navigation
  void _preloadNextPageImage(Story story, int currentIndex) {
    // Use microtask to avoid blocking the UI thread
    Future.microtask(() {
      final imageService = ImageService();

      // If we're on a regular story page (not the last one)
      if (currentIndex < story.pages.length - 1) {
        // Preload the next story page image
        final nextPage = story.pages[currentIndex + 1];
        imageService.preloadImage(context, nextPage.imagePath);
      }

      // If we're on the second-to-last page or the last story page, preload the questions page background
      if (currentIndex == story.pages.length - 2 || currentIndex == story.pages.length - 1) {
        final questionsBackgroundPath = story.pages.isNotEmpty
            ? story.pages.last.imagePath
            : story.coverImagePath;
        imageService.preloadImage(context, questionsBackgroundPath);
      }
    });
  }

  @override
  void dispose() {
    // Dispose of controllers
    _pageController?.dispose();

    // Reset system UI when leaving the page
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryReaderBloc, StoryReaderState>(
      listener: (context, state) {
        if (state is StoryReaderClosing) {
          // Refresh the library before popping, respecting the active tab
          final libraryBloc = BlocProvider.of<LibraryBloc>(context);
          final currentState = libraryBloc.state;
          if (currentState is LibraryLoaded && currentState.activeTab == LibraryTab.favorites) {
            libraryBloc.add(const LoadFavoriteStories());
          } else {
            libraryBloc.add(const LoadAllStories());
          }
          Navigator.pop(context);
        } else if (state is StoryReaderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ResponsiveText(
                text: state.message,
                style: const TextStyle(
                  fontFamily: StoryTalesTheme.fontFamilyBody,
                  fontSize: 16,
                ),
              ),
              backgroundColor: StoryTalesTheme.errorColor,
            ),
          );
        } else if (state is StoryReaderLoaded) {
          // Initialize or update page controller if needed
          if (_pageController == null) {
            _pageController = PageController(
              initialPage: state.currentPageIndex,
              keepPage: true, // Maintain page state when rebuilding
            );
            _lastPageIndex = state.currentPageIndex;
          } else if (_lastPageIndex != state.currentPageIndex) {
            // Safely animate to the new page
            try {
              _pageController!.animateToPage(
                state.currentPageIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } catch (e) {
              // If animation fails (e.g., controller not attached), recreate the controller
              _pageController?.dispose();
              _pageController = PageController(
                initialPage: state.currentPageIndex,
                keepPage: true, // Maintain page state when rebuilding
              );
              sl<LoggingService>().warning('Recreated page controller due to error: $e');
            }

            // Update the last page index
            _lastPageIndex = state.currentPageIndex;

            // Efficiently preload the next page image
            _preloadNextPageImage(state.story, state.currentPageIndex);
          }
        }
      },
      builder: (context, state) {
        if (state is StoryReaderLoading) {
          return _buildLoadingScreen();
        } else if (state is StoryReaderLoaded) {
          return _buildStoryReader(state);
        } else {
          return _buildLoadingScreen();
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              StoryTalesTheme.primaryColor.withValues(alpha: 0.3),
              StoryTalesTheme.backgroundColor,
            ],
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: StoryTalesTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                const AnimatedLogo(size: 150),

                const SizedBox(height: 24),

                // Loading text
                ResponsiveText(
                  text: 'Your magical story is being written...',
                  style: StoryTalesTheme.headingMedium.copyWith(
                    color: StoryTalesTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Subtitle text
                ResponsiveText(
                  text: 'The storybook is coming to life just for you!',
                  style: StoryTalesTheme.bodyMedium.copyWith(
                    color: StoryTalesTheme.textColor.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryReader(StoryReaderLoaded state) {
    final story = state.story;

    // Determine background image path for questions page
    final questionsBackgroundPath = story.pages.isNotEmpty
        ? story.pages.last.imagePath
        : story.coverImagePath;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen content with unified PageView for all pages
          PageView.builder(
            controller: _pageController,
            itemCount: story.pages.length + 1, // +1 for questions page
            physics: const PageScrollPhysics(),
            pageSnapping: true,
            allowImplicitScrolling: true, // Enable adjacent page caching
            onPageChanged: (index) {
              // Update the bloc when page changes via swipe
              if (index != state.currentPageIndex) {
                context.read<StoryReaderBloc>().add(GoToPage(pageIndex: index));
              }
            },
            itemBuilder: (context, index) {
              // Check if this is the questions page (last index)
              if (index == story.pages.length) {
                return QuestionsPage(
                  story: story,
                  onBackPressed: () {
                    // Use the PageController directly for smoother navigation
                    _pageController?.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  backgroundImagePath: questionsBackgroundPath,
                );
              }

              // Regular story page
              return StoryPageView(
                key: ValueKey('page_$index'), // Important for widget identity
                story: story,
                currentPageIndex: index,
                onNextPage: () {
                  // Always use PageController for navigation
                  _pageController?.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                onPreviousPage: () {
                  _pageController?.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              );
            },
          ),

          // Overlay header with manual padding for status bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(state),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(StoryReaderLoaded state) {
    final story = state.story;
    final totalPages = story.pages.length + 1; // +1 for questions page
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.4),
            Colors.black.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Row(
        children: [
          // Reading time with clock icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveIcon(
                icon: Icons.access_time,
                color: StoryTalesTheme.surfaceColor,
                sizeCategory: IconSizeCategory.small,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              const SizedBox(width: 4),
              ResponsiveText(
                text: story.readingTime,
                style: StoryTalesTheme.bodySmall.copyWith(
                  color: StoryTalesTheme.surfaceColor,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Page indicators
          PageIndicator(
            currentPage: state.isQuestionsPage ? totalPages : state.currentPageIndex + 1,
            totalPages: totalPages,
            activeColor: StoryTalesTheme.accentColor,
            inactiveColor: StoryTalesTheme.surfaceColor.withValues(alpha: 0.5),
          ),

          const Spacer(),

          // Action buttons
          Row(
            children: [
              // Favorite button
              IconButton(
                icon: ResponsiveIcon(
                  icon: story.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: story.isFavorite ? StoryTalesTheme.errorColor : StoryTalesTheme.surfaceColor,
                  sizeCategory: IconSizeCategory.medium,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                onPressed: () => context.read<StoryReaderBloc>().add(const ToggleStoryFavorite()),
              ),

              // Close button
              IconButton(
                icon: ResponsiveIcon(
                  icon: Icons.close,
                  color: StoryTalesTheme.surfaceColor,
                  sizeCategory: IconSizeCategory.medium,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                onPressed: () => context.read<StoryReaderBloc>().add(const CloseReader()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
