import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/animated_logo.dart';
import 'package:storytales/core/widgets/dialog_form.dart';
import 'package:storytales/core/widgets/responsive_button.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_bloc.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_event.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_state.dart';
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
      }
    });

    // Dispatch the event to check if the user can generate a story
    bloc.add(const CheckCanGenerateStory());

    // Wait for the result
    final canGenerate = await completer.future;

    if (canGenerate) {
      // User can generate a story, show the dialog
      return showDialog(
        context: context,
        builder: (context) => const StoryCreationDialog(),
      );
    } else {
      // User cannot generate a story, navigate to the subscription page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SubscriptionPage(),
        ),
      );

      // Return a completed future since we're not showing a dialog
      return Future.value();
    }
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

  final List<String> _ageRanges = ['0-2 years', '3-5 years', '6-8 years', '9-12 years', '13+ years'];

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
        if (state is StoryGenerationLoading) {
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
          // Close the dialog
          Navigator.pop(context);

          // Navigate to the subscription page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SubscriptionPage(),
            ),
          );
        } else if (state is StoryGenerationFailure) {
          setState(() {
            _isLoading = false;
          });

          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ResponsiveText(
                text: state.error,
                style: const TextStyle(
                  fontFamily: StoryTalesTheme.fontFamilyBody,
                  fontSize: 16,
                ),
              ),
              backgroundColor: StoryTalesTheme.errorColor,
              action: state.isRetryable
                  ? SnackBarAction(
                      label: 'Retry',
                      onPressed: () => _generateStory(),
                    )
                  : null,
            ),
          );
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
              labelText: 'Story Prompt',
              hintText: 'Enter a prompt for your story (e.g., "A friendly dragon")',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontFamily: StoryTalesTheme.fontFamilyBody,
              color: StoryTalesTheme.textColor,
            ),
            maxLines: 3,
            minLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a prompt';
              }
              if (value.trim().length < 3) {
                return 'Prompt is too short';
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
            value: _selectedAgeRange,
            icon: const Icon(Icons.arrow_drop_down),
            style: const TextStyle(
              color: StoryTalesTheme.textColor,
              fontSize: 16,
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

        // Description with cycling messages
        ResponsiveText(
          text: _loadingMessages[_currentMessageIndex],
          style: const TextStyle(
            color: StoryTalesTheme.textColor,
            fontSize: 16,
            fontFamily: StoryTalesTheme.fontFamilyBody,
          ),
          textAlign: TextAlign.center,
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

        // Cancel button
        ResponsiveButton.outlined(
          text: 'Cancel',
          onPressed: () {
            context.read<StoryGenerationBloc>().add(const CancelStoryGeneration());
            Navigator.pop(context);
          },
          icon: Icons.cancel,
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
      // Instead of creating a subscription, we'll use the BlocConsumer
      // to handle the state changes. Just trigger the check directly.
      final bloc = context.read<StoryGenerationBloc>();

      // Trigger the check
      bloc.add(const CheckCanGenerateStory());

      // The BlocConsumer will handle the CanGenerateStory state and
      // automatically trigger the GenerateStory event when appropriate
    }
  }

  // This method will be called by the BlocConsumer when it receives CanGenerateStory
  void _onCanGenerateStory() {
    final bloc = context.read<StoryGenerationBloc>();
    bloc.add(
      GenerateStory(
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
}
