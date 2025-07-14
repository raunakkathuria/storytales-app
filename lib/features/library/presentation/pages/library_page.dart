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
import 'package:storytales/features/story_generation/presentation/widgets/story_creation_dialog.dart';
import 'package:storytales/features/story_reader/presentation/pages/story_reader_page.dart';
import 'package:storytales/features/authentication/presentation/widgets/auth_wrapper.dart';
import 'package:storytales/features/subscription/presentation/pages/subscription_page.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_state.dart';

/// The main library page that displays the user's stories.
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0; // Track the selected bottom nav index separately

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
        child: BlocBuilder<LibraryBloc, LibraryState>(
          builder: (context, state) {
            if (state is LibraryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is LibraryLoaded) {
              return _buildStoryGrid(state.stories);
            } else if (state is LibraryEmpty) {
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
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return StoryCard(
          story: story,
          onTap: () => _navigateToStoryReader(context, story),
          onFavoriteToggle: () => _toggleFavorite(context, story),
          onDelete: () => _deleteStory(context, story),
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

  void _deleteStory(BuildContext context, Story story) {
    ConfirmationDialog.show(
      context: context,
      title: 'Delete Story',
      content: 'Are you sure you want to delete "${story.title}"?',
      confirmText: 'Yes',
      cancelText: 'No',
      onConfirm: () {
        context.read<LibraryBloc>().add(DeleteStory(storyId: story.id));

        // Refresh the free stories count in the subscription bloc
        // This ensures the subscription page shows the correct count after a story is deleted
        context.read<SubscriptionBloc>().add(const RefreshFreeStoriesCount());
      },
    );
  }
}
