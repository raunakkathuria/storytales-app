import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/utils/responsive_text_util.dart';
import 'package:storytales/core/widgets/animated_logo.dart';
import 'package:storytales/core/widgets/dialog_form.dart';
import 'package:storytales/core/widgets/responsive_button.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_bloc.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_event.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_state.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_workshop_bloc.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_workshop_event.dart';
import 'package:storytales/features/story_generation/presentation/widgets/story_workshop_dialog.dart';
import 'package:storytales/features/story_reader/presentation/pages/story_reader_page.dart';
import 'package:storytales/features/subscription/presentation/pages/subscription_page.dart';

/// A dialog for creating a new story.
class StoryCreationDialog extends StatefulWidget {
  const StoryCreationDialog({super.key});

  /// Shows the story creation dialog.
  ///
  /// First checks if the user can generate a story. If they can't,
  /// navigates directly to the subscription page instead of showing the dialog.
  static Future<void> show(BuildContext context) async {
    // Get the StoryGenerationBloc from the parent context
    final bloc = context.read<StoryGenerationBloc>();
    final currentState = bloc.state;

    // First check if there's already a story generation in progress
    if (_isGenerationInProgress(currentState)) {
      // Auto-clear error cards and allow new generation
      if (currentState is BackgroundGenerationFailure) {
        // Clear the error card automatically
        bloc.add(ClearFailedStoryGeneration(tempStoryId: currentState.tempStoryId));
        // Continue with the generation process - don't return early
      } else {
        // Show the workshop dialog instead of snackbar
        StoryWorkshopDialog.show(context);
        return;
      }
    }

    // Check if the user can generate a story by dispatching an event
    // and waiting for the result
    final completer = Completer<bool>();

    // Set up a subscription to listen for the result
    late final StreamSubscription subscription;
    subscription = bloc.stream.listen((state) {
      if (state is CanGenerateStory) {
        completer.complete(true);
        subscription.cancel();
      } else if (state is CannotGenerateStory) {
        completer.complete(false);
        subscription.cancel();
      } else if (state is StoryGenerationSubscriptionRequired) {
        completer.complete(false);
        subscription.cancel();
      }
    });

    // Dispatch the event to check if the user can generate a story
    bloc.add(const CheckCanGenerateStory());

    // Wait for the result
    final canGenerate = await completer.future;

    // Check if the widget is still mounted before using context
    if (!context.mounted) return;

    if (canGenerate) {
      // User can generate a story, show the dialog
      return showDialog(
        context: context,
        builder: (context) => const StoryCreationDialog(),
      );
    } else {
      // User cannot generate a story, navigate to the subscription page
      final navigator = Navigator.of(context);
      navigator.push(
        MaterialPageRoute(
          builder: (context) => const SubscriptionPage(),
        ),
      );

      // Return a completed future since we're not showing a dialog
      return Future.value();
    }
  }

  /// Check if there's a story generation in progress or failed states that need to be cleared
  static bool _isGenerationInProgress(StoryGenerationState state) {
    return state is StoryGenerationLoading ||
           state is StoryGenerationCountdown ||
           state is StoryGenerationInBackground ||
           state is BackgroundGenerationFailure ||
           state is StoryGenerationSubscriptionRequired;
  }

  @override
  State<StoryCreationDialog> createState() => _StoryCreationDialogState();
}

class _StoryCreationDialogState extends State<StoryCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _promptController = TextEditingController();
  String? _selectedAgeRange;
  bool _isLoading = false;
  double _progress = 0.0;
  int _currentMessageIndex = 0;
  Timer? _messageTimer;
  String? _failedTempStoryId; // To store the tempStoryId of a failed generation

  final List<String> _ageRanges = ['0-2', '3-5', '6-8', '9-12', '13+'];

  // List of loading messages to cycle through
  final List<String> _loadingMessages = [
    "The storybook is weaving a magical tale just for you!",
    "Our wizards are crafting your adventure...",
    "Sprinkling fairy dust on your characters...",
    "Dragons and unicorns are joining your story...",
    "Painting colorful worlds for your journey...",
    "The magic quill is writing your special story...",
    "Gathering stardust for your magical tale...",
  ];

  @override
  void dispose() {
    _promptController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryGenerationBloc, StoryGenerationState>(
      listener: (context, state) {
        if (state is StoryGenerationCountdown) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is StoryGenerationInBackground) {
          // Close the dialog when background generation starts
          Navigator.pop(context);
        } else if (state is BackgroundGenerationComplete) {
          // Story is ready - no snackbar needed as user will see it in library
        } else if (state is BackgroundGenerationFailure) {
          // Store the tempStoryId of the failed generation
          _failedTempStoryId = state.tempStoryId;
          // Don't show SnackBar here - the error will be displayed in the dialog itself
          // via _buildErrorDisplay when the dialog is in loading state
        } else if (state is StoryGenerationLoading) {
          // Only start cycling messages when loading first begins
          if (!_isLoading) {
            _startMessageCycling();
          }

          setState(() {
            _isLoading = true;
            _progress = state.progress;
          });
        } else if (state is StoryGenerationSuccess) {
          // Stop message cycling
          _messageTimer?.cancel();

          // Close the dialog
          Navigator.pop(context);

          // Navigate to the story reader page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoryReaderPage(storyId: state.story.id),
            ),
          );
        } else if (state is CanGenerateStory) {
          // User can generate a story, proceed with generation
          _onCanGenerateStory();
        } else if (state is CannotGenerateStory) {
          // Store navigator reference before async operations
          final navigator = Navigator.of(context);

          // Close the dialog
          navigator.pop();

          // Navigate to the subscription page
          navigator.push(
            MaterialPageRoute(
              builder: (context) => const SubscriptionPage(),
            ),
          );
        } else if (state is StoryGenerationSubscriptionRequired) {
          // Store navigator reference before async operations
          final navigator = Navigator.of(context);

          // Close the dialog
          navigator.pop();

          // Navigate to the subscription page with specific context
          navigator.push(
            MaterialPageRoute(
              builder: (context) => const SubscriptionPage(),
            ),
          );

          // Show snackbar with subscription context
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.storiesUsed}/${state.monthlyLimit} free stories used. Subscribe for unlimited stories!'),
              backgroundColor: StoryTalesTheme.primaryColor,
              action: SnackBarAction(
                label: 'Subscribe',
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to subscription page if not already there
                  navigator.push(
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPage(),
                    ),
                  );
                },
              ),
            ),
          );
        } else if (state is StoryGenerationFailure) {
          // Keep _isLoading true to show the loading indicator area,
          // which will now display the error message.
          setState(() {
            _isLoading = true;
          });
          // No SnackBar needed, error will be displayed in the dialog
        }
      },
      builder: (context, state) {
        return DialogForm(
          title: '', // Empty title since we're showing it in the header
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogoHeader(),
              const SizedBox(height: 16),
              _buildFormContent(),
            ],
          ),
          primaryActionText: 'Generate Story',
          onPrimaryAction: _generateStory,
          secondaryActionText: 'Cancel',
          onSecondaryAction: () => Navigator.pop(context),
          isLoading: _isLoading,
          loadingIndicator: _buildLoadingIndicator(),
        );
      },
    );
  }

  Widget _buildFormContent() {
    // Get responsive font size for form fields
    final responsiveFontSize = ResponsiveTextUtil.getScaledFontSize(context, 16.0);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Prompt input
          TextFormField(
            controller: _promptController,
            decoration: const InputDecoration(
              labelText: 'Your story',
              hintText: 'Tell me what you want your story to be about (like "A friendly dragon")',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: TextStyle(
              fontSize: responsiveFontSize,
              fontFamily: StoryTalesTheme.fontFamilyBody,
              color: StoryTalesTheme.textColor,
            ),
            maxLines: 3,
            minLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please tell me about your story';
              }
              if (value.trim().length < 3) {
                return 'Please tell me more about your story';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Age range dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Age Range',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            isExpanded: true,
            initialValue: _selectedAgeRange,
            icon: const Icon(Icons.arrow_drop_down),
            style: TextStyle(
              color: StoryTalesTheme.textColor,
              fontSize: responsiveFontSize,
              fontFamily: StoryTalesTheme.fontFamilyBody,
            ),
            validator: (value) => value == null ? 'Please select an age range' : null,
            items: _ageRanges.map<DropdownMenuItem<String>>((String range) {
              return DropdownMenuItem<String>(
                value: range,
                child: ResponsiveText(
                  text: range,
                  style: const TextStyle(
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                    fontSize: 16,
                    color: StoryTalesTheme.textColor,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAgeRange = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return BlocBuilder<StoryGenerationBloc, StoryGenerationState>(
      builder: (context, state) {
        if (state is StoryGenerationCountdown) {
          return _buildCountdownIndicator(state.secondsRemaining);
        } else if (state is StoryGenerationSubscriptionRequired) {
          return _buildSubscriptionRequiredDisplay(state);
        } else if (state is StoryGenerationFailure) {
          return _buildErrorDisplay(state.error);
        } else {
          return _buildProgressIndicator();
        }
      },
    );
  }

  Widget _buildCountdownIndicator(int secondsRemaining) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Close button in top right
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                color: StoryTalesTheme.textLightColor,
                size: 24,
              ),
            ),
          ],
        ),

        // Animated logo
        const AnimatedLogo(size: 80),

        const SizedBox(height: 24),

        // Title
        ResponsiveText(
          text: 'Your magical story is being created!',
          style: const TextStyle(
            color: StoryTalesTheme.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: StoryTalesTheme.fontFamilyHeading,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Countdown message - improved layout with better text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              ResponsiveText(
                text: 'Your story will appear in your library when ready.',
                style: const TextStyle(
                  color: StoryTalesTheme.textColor,
                  fontSize: 16,
                  fontFamily: StoryTalesTheme.fontFamilyBody,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              ResponsiveText(
                text: 'This will close in $secondsRemaining seconds.',
                style: const TextStyle(
                  color: StoryTalesTheme.textLightColor,
                  fontSize: 14,
                  fontFamily: StoryTalesTheme.fontFamilyBody,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Countdown circle
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: StoryTalesTheme.primaryColor,
              width: 4,
            ),
          ),
          child: Center(
            child: ResponsiveText(
              text: '$secondsRemaining',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: StoryTalesTheme.primaryColor,
                fontFamily: StoryTalesTheme.fontFamilyHeading,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Close button
        ResponsiveButton.outlined(
          text: 'Close',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icons.close,
          borderColor: StoryTalesTheme.primaryColor,
          textColor: StoryTalesTheme.primaryColor,
          fontSize: 16,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated logo
        const AnimatedLogo(size: 80),

        const SizedBox(height: 24),

        // Title
        ResponsiveText(
          text: 'Creating Your Story...',
          style: const TextStyle(
            color: StoryTalesTheme.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: StoryTalesTheme.fontFamilyHeading,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Description with cycling messages - fixed height container to prevent dialog resizing
        SizedBox(
          height: 60, // Fixed height to accommodate 2-3 lines of responsive text
          width: double.infinity,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ResponsiveText(
                text: _loadingMessages[_currentMessageIndex],
                style: const TextStyle(
                  color: StoryTalesTheme.textColor,
                  fontSize: 16,
                  fontFamily: StoryTalesTheme.fontFamilyBody,
                ),
                textAlign: TextAlign.center,
                maxLines: 3, // Allow up to 3 lines for responsive text
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Progress indicator
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: StoryTalesTheme.backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: StoryTalesTheme.backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(StoryTalesTheme.primaryColor),
              minHeight: 12,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Progress percentage
        ResponsiveText(
          text: '${(_progress * 100).toInt()}%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: StoryTalesTheme.primaryColor,
            fontSize: 18,
            fontFamily: StoryTalesTheme.fontFamilyBody,
          ),
        ),

        const SizedBox(height: 24),

        // Close button
        ResponsiveButton.outlined(
          text: 'Close',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icons.close,
          borderColor: StoryTalesTheme.primaryColor,
          textColor: StoryTalesTheme.primaryColor,
          fontSize: 16,
        ),
      ],
    );
  }

  Widget _buildLogoHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Large centered logo for maximum visibility
          const AnimatedLogo(size: 80),

          const SizedBox(height: 12),

          // Title text centered below logo
          ResponsiveText(
            text: 'Magic story awaits you',
            style: const TextStyle(
              fontFamily: StoryTalesTheme.fontFamilyHeading,
              fontWeight: FontWeight.bold,
              fontSize: 24, // Slightly larger text
              color: StoryTalesTheme.accentColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _generateStory() {
    if (_formKey.currentState?.validate() ?? false) {
      // Use the new workshop system for story generation
      final workshopBloc = context.read<StoryWorkshopBloc>();

      // Start story generation in the workshop
      workshopBloc.add(StartStoryGeneration(
        prompt: _promptController.text.trim(),
        ageRange: _selectedAgeRange,
        theme: null,
        genre: null,
      ));

      // Close the dialog
      Navigator.pop(context);

      // Show the workshop dialog
      StoryWorkshopDialog.show(context);
    }
  }


  // This method will be called by the BlocConsumer when it receives CanGenerateStory
  void _onCanGenerateStory() {
    final bloc = context.read<StoryGenerationBloc>();
    bloc.add(
      StartGenerationCountdown(
        prompt: _promptController.text.trim(),
        ageRange: _selectedAgeRange,
        theme: null,
        genre: null,
      ),
    );
  }

  // Start cycling through loading messages
  void _startMessageCycling() {
    // Cancel any existing timer
    _messageTimer?.cancel();

    // Reset to first message and immediately trigger first change
    setState(() {
      _currentMessageIndex = 0;
    });

    // Start cycling immediately
    Timer.run(() {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
        });
      }
    });

    // Create a new timer that cycles every 3 seconds
    _messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          // Move to next message, loop back to start if needed
          _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  Widget _buildSubscriptionRequiredDisplay(StoryGenerationSubscriptionRequired state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Close button in top right
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                color: StoryTalesTheme.textLightColor,
                size: 24,
              ),
            ),
          ],
        ),

        // Subscription icon
        const Icon(
          Icons.star,
          color: StoryTalesTheme.accentColor,
          size: 60,
        ),

        const SizedBox(height: 24),

        // Title
        ResponsiveText(
          text: 'Unlock unlimited stories!',
          style: const TextStyle(
            color: StoryTalesTheme.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: StoryTalesTheme.fontFamilyHeading,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Story usage information
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ResponsiveText(
            text: 'You\'ve used ${state.storiesUsed} of ${state.monthlyLimit} free stories this month.',
            style: const TextStyle(
              color: StoryTalesTheme.textColor,
              fontSize: 16,
              fontFamily: StoryTalesTheme.fontFamilyBody,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),

        const SizedBox(height: 12),

        // Subscription message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ResponsiveText(
            text: state.message,
            style: const TextStyle(
              color: StoryTalesTheme.textLightColor,
              fontSize: 14,
              fontFamily: StoryTalesTheme.fontFamilyBody,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        ),

        const SizedBox(height: 32),

        // Subscribe button
        ResponsiveButton.primary(
          text: 'Get Unlimited Stories',
          onPressed: () {
            final navigator = Navigator.of(context);
            navigator.pop(); // Close dialog
            navigator.push(
              MaterialPageRoute(
                builder: (context) => const SubscriptionPage(),
              ),
            );
          },
          icon: Icons.star,
          fontSize: 16,
        ),

        const SizedBox(height: 12),

        // Close button
        ResponsiveButton.outlined(
          text: 'Maybe Later',
          onPressed: () {
            Navigator.pop(context);
          },
          borderColor: StoryTalesTheme.primaryColor,
          textColor: StoryTalesTheme.primaryColor,
          fontSize: 14,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildErrorDisplay(String errorMessage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Close button in top right
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                // Clear the failed story generation and close the dialog
                if (_failedTempStoryId != null) {
                  context.read<StoryGenerationBloc>().add(ClearFailedStoryGeneration(tempStoryId: _failedTempStoryId!));
                }
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                color: StoryTalesTheme.textLightColor,
                size: 24,
              ),
            ),
          ],
        ),

        // Error icon
        const Icon(
          Icons.error_outline,
          color: StoryTalesTheme.errorColor,
          size: 60,
        ),

        const SizedBox(height: 24),

        // Error title
        ResponsiveText(
          text: 'Story creation failed!',
          style: const TextStyle(
            color: StoryTalesTheme.errorColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: StoryTalesTheme.fontFamilyHeading,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Error message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ResponsiveText(
            text: errorMessage,
            style: const TextStyle(
              color: StoryTalesTheme.textColor,
              fontSize: 16,
              fontFamily: StoryTalesTheme.fontFamilyBody,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(height: 24),

        // Close button
        ResponsiveButton.primary(
          text: 'Close',
          onPressed: () {
            // Clear the failed story generation and close the dialog
            if (_failedTempStoryId != null) {
              context.read<StoryGenerationBloc>().add(ClearFailedStoryGeneration(tempStoryId: _failedTempStoryId!));
            }
            Navigator.pop(context);
          },
          icon: Icons.close,
          fontSize: 16,
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
