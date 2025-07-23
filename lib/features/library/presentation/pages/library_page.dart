import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/confirmation_dialog.dart';
import 'package:storytales/core/widgets/responsive_icon.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import 'package:storytales/features/library/domain/entities/story.dart';
import 'package:storytales/features/library/presentation/bloc/library_bloc.dart';
import 'package:storytales/features/library/presentation/bloc/library_event.dart';
import 'package:storytales/features/library/presentation/bloc/library_state.dart';
import 'package:storytales/features/library/presentation/widgets/story_card.dart';
import 'package:storytales/features/library/presentation/widgets/loading_story_card.dart';
import 'package:storytales/features/story_generation/presentation/widgets/story_creation_dialog.dart';
import 'package:storytales/features/story_reader/presentation/pages/story_reader_page.dart';
import 'package:storytales/features/authentication/presentation/widgets/auth_wrapper.dart';
import 'package:storytales/features/subscription/presentation/pages/subscription_page.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_bloc.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_state.dart';

/// The main library page that displays the user's stories.
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0; // Track the selected bottom nav index separately
  final Map<String, Map<String, dynamic>> _loadingCards = {}; // Track loading cards

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      // Update the selected index when tab controller changes
      setState(() {
        _selectedIndex = _tabController.index == 0 ? 0 : 2;
      });

      if (_tabController.index == 0) {
        context.read<LibraryBloc>().add(const LoadAllStories());
      } else {
        context.read<LibraryBloc>().add(const LoadFavoriteStories());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StoryTales', style: TextStyle(color: StoryTalesTheme.primaryColor)),
        toolbarHeight: 56, // Standard height for better visibility
        backgroundColor: StoryTalesTheme.surfaceColor, // White background
        elevation: 1, // Slight shadow for definition
        actions: [
          // Profile button for account management
          const ProfileButton(),

          const SizedBox(width: 8), // Add spacing between buttons

          // Subscription button
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              // Show a different icon if subscribed
              if (state is SubscriptionActive) {
                return IconButton(
                  icon: ResponsiveIcon(
                    icon: Icons.verified, // Use verified icon for active subscription
                    color: StoryTalesTheme.accentColor, // Use accent color (Sunset Orange) for brand consistency
                    sizeCategory: IconSizeCategory.medium,
                  ),
                  tooltip: 'Subscription Active', // For accessibility
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                  ),
                );
              }

              // Default icon for non-subscribers
              return IconButton(
                icon: ResponsiveIcon(
                  icon: Icons.card_membership,
                  color: StoryTalesTheme.accentColor, // Keep the accent color for the icon
                  sizeCategory: IconSizeCategory.medium,
                ),
                tooltip: 'Subscribe', // For accessibility
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                ),
              );
            },
          ),
          const SizedBox(width: 8), // Add a bit of padding on the right
        ],
      ),
      body: SafeArea(
        child: BlocListener<StoryGenerationBloc, StoryGenerationState>(
          listener: (context, state) {
            // Handle loading card display
            if (state is ShowLoadingCard) {
              setState(() {
                _loadingCards[state.tempStoryId] = {
                  'tempStoryId': state.tempStoryId,
                  'prompt': state.prompt,
                  'ageRange': state.ageRange,
                  'startTime': state.startTime,
                };
              });
            }

            // Handle loading card removal
            if (state is RemoveLoadingCard) {
              setState(() {
                _loadingCards.remove(state.tempStoryId);
              });
            }

            // When a story is generated in the background, refresh the library
            if (state is BackgroundGenerationComplete) {
              // Refresh the library to show the new story
              context.read<LibraryBloc>().add(const LoadAllStories());

              // Also refresh the subscription state to update free stories count
              context.read<SubscriptionBloc>().add(const RefreshFreeStoriesCount());
            }

            // Also handle background generation failure
            if (state is BackgroundGenerationFailure) {
              // Show error message to user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Story generation failed: ${state.error}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
          child: BlocBuilder<LibraryBloc, LibraryState>(
            builder: (context, state) {
              if (state is LibraryLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is LibraryLoaded) {
                return _buildStoryGrid(state.stories);
              } else if (state is LibraryEmpty) {
                // Check if we have loading cards to show
                final showLoadingCards = _selectedIndex == 0;
                final loadingCardsList = showLoadingCards ? _loadingCards.values.toList() : <Map<String, dynamic>>[];

                if (loadingCardsList.isNotEmpty) {
                  // Show loading cards instead of empty state
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: loadingCardsList.length,
                    itemBuilder: (context, index) {
                      final loadingCardData = loadingCardsList[index];
                      return LoadingStoryCard(
                        tempStoryId: loadingCardData['tempStoryId'],
                        prompt: loadingCardData['prompt'],
                        ageRange: loadingCardData['ageRange'],
                        startTime: loadingCardData['startTime'],
                      );
                    },
                  );
                }

                // Show regular empty state
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const ResponsiveIcon(
                          icon: Icons.auto_stories,
                          sizeCategory: IconSizeCategory.large,
                          color: StoryTalesTheme.accentColor,
                        ),
                        const SizedBox(height: 16),
                        ResponsiveText(
                          text: state.message,
                          style: StoryTalesTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (state.activeTab == LibraryTab.all)
                          ElevatedButton(
                            onPressed: () => _navigateToStoryGeneration(context),
                            child: const ResponsiveText(
                              text: 'Create Your First Story',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: StoryTalesTheme.fontFamilyBody,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              } else if (state is LibraryError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const ResponsiveIcon(
                          icon: Icons.error_outline,
                          sizeCategory: IconSizeCategory.large,
                          color: StoryTalesTheme.errorColor,
                        ),
                        const SizedBox(height: 16),
                        ResponsiveText(
                          text: 'Error: ${state.message}',
                          style: StoryTalesTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.read<LibraryBloc>().add(const LoadAllStories()),
                          child: const ResponsiveText(
                            text: 'Try Again',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: StoryTalesTheme.fontFamilyBody,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          // Handle the special case for the center "+" button
          if (index == 1) {
            _navigateToStoryGeneration(context);
          } else {
            setState(() {
              _selectedIndex = index;
              // Update the tab controller for the other tabs
              _tabController.animateTo(index == 0 ? 0 : 1);
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: ResponsiveIcon(
              icon: Icons.book,
              sizeCategory: IconSizeCategory.medium,
              color: _selectedIndex == 0
                  ? StoryTalesTheme.primaryColor
                  : StoryTalesTheme.textLightColor,
            ),
            label: 'All Stories',
          ),
          BottomNavigationBarItem(
            icon: ResponsiveIcon(
              icon: Icons.add_circle,
              sizeCategory: IconSizeCategory.large, // Larger size for emphasis
              color: StoryTalesTheme.accentColor,
            ),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: ResponsiveIcon(
              icon: Icons.favorite,
              sizeCategory: IconSizeCategory.medium,
              color: _selectedIndex == 2
                  ? StoryTalesTheme.primaryColor
                  : StoryTalesTheme.textLightColor,
            ),
            label: 'Favorites',
          ),
        ],
        selectedItemColor: StoryTalesTheme.primaryColor,
        unselectedItemColor: StoryTalesTheme.textLightColor,
        selectedLabelStyle: const TextStyle(
          fontSize: 14, // Body Small category per guidelines
          fontFamily: StoryTalesTheme.fontFamilyBody,
          fontWeight: FontWeight.bold,
          height: 1.5, // Add some height to prevent text clipping
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14, // Body Small category per guidelines
          fontFamily: StoryTalesTheme.fontFamilyBody,
          height: 1.5, // Add some height to prevent text clipping
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  Widget _buildStoryGrid(List<Story> stories) {
    // Only show loading cards on "All Stories" tab (index 0)
    final showLoadingCards = _selectedIndex == 0;
    final loadingCardsList = showLoadingCards ? _loadingCards.values.toList() : <Map<String, dynamic>>[];
    final totalItems = loadingCardsList.length + stories.length;

    // Show empty state with loading cards if no regular stories but has loading cards
    if (stories.isEmpty && loadingCardsList.isNotEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: loadingCardsList.length,
        itemBuilder: (context, index) {
          final loadingCardData = loadingCardsList[index];
          return LoadingStoryCard(
            tempStoryId: loadingCardData['tempStoryId'],
            prompt: loadingCardData['prompt'],
            ageRange: loadingCardData['ageRange'],
            startTime: loadingCardData['startTime'],
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // Show loading cards first
        if (index < loadingCardsList.length) {
          final loadingCardData = loadingCardsList[index];
          return LoadingStoryCard(
            tempStoryId: loadingCardData['tempStoryId'],
            prompt: loadingCardData['prompt'],
            ageRange: loadingCardData['ageRange'],
            startTime: loadingCardData['startTime'],
          );
        }

        // Show regular stories after loading cards
        final storyIndex = index - loadingCardsList.length;
        final story = stories[storyIndex];
        return StoryCard(
          story: story,
          onTap: () => _navigateToStoryReader(context, story),
          onFavoriteToggle: () => _toggleFavorite(context, story),
        );
      },
    );
  }

  void _navigateToStoryGeneration(BuildContext context) async {
    // First check if the user can create a story
    final subscriptionBloc = context.read<SubscriptionBloc>();
    final subscriptionState = subscriptionBloc.state;

    // If the user has an active subscription or free stories remaining, show the creation form
    if (subscriptionState is SubscriptionActive ||
        subscriptionState is FreeStoriesAvailable) {
      StoryCreationDialog.show(context);
    }
    // Otherwise, show a dialog prompting them to subscribe
    else {
      _showSubscriptionPromptDialog(context);
    }
  }


  void _showSubscriptionPromptDialog(BuildContext context) {
    ConfirmationDialog.show(
      context: context,
      title: 'Subscription Required',
      content: 'You\'ve used all your free stories. Subscribe now to create unlimited stories!',
      confirmText: 'Subscribe',
      cancelText: 'Not Now',
      onConfirm: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SubscriptionPage()),
        );
      },
      isDestructive: false, // This is not a destructive action
    );
  }

  void _navigateToStoryReader(BuildContext context, Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryReaderPage(storyId: story.id),
      ),
    );
  }

  void _toggleFavorite(BuildContext context, Story story) {
    context.read<LibraryBloc>().add(ToggleFavorite(storyId: story.id));
  }

}
