import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import 'package:storytales/core/widgets/animated_logo.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_bloc.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_event.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_state.dart';

/// A card widget that displays loading state while a story is being generated.
class LoadingStoryCard extends StatefulWidget {
  final String tempStoryId;
  final String prompt;
  final String? ageRange;
  final DateTime startTime;

  const LoadingStoryCard({
    super.key,
    required this.tempStoryId,
    required this.prompt,
    this.ageRange,
    required this.startTime,
  });

  @override
  State<LoadingStoryCard> createState() => _LoadingStoryCardState();
}

class _LoadingStoryCardState extends State<LoadingStoryCard>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  Timer? _statusTimer;
  int _currentStatusIndex = 0;

  final List<String> _statusMessages = [
    "Creating your story...",
    "Weaving magic...",
    "Adding characters...",
    "Almost ready...",
  ];

  @override
  void initState() {
    super.initState();

    // Initialize shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _shimmerController.repeat();
    _pulseController.repeat(reverse: true);

    // Start status message cycling
    _startStatusCycling();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startStatusCycling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentStatusIndex = (_currentStatusIndex + 1) % _statusMessages.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryGenerationBloc, StoryGenerationState>(
      builder: (context, state) {
        // Check if this loading card should show error state
        if (state is BackgroundGenerationFailure &&
            state.tempStoryId == widget.tempStoryId) {
          return _buildErrorCard(state.error);
        }

        return _buildLoadingCard();
      },
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Animated background with shimmer effect
          _buildShimmerBackground(),

          // Central animated wizard
          _buildCentralWizard(),

          // Simple status message at bottom
          _buildSimpleStatus(),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: StoryTalesTheme.errorColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Error background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  StoryTalesTheme.errorColor.withValues(alpha: 0.1),
                  StoryTalesTheme.errorColor.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),

          // Error content
          _buildErrorContent(error),
        ],
      ),
    );
  }

  Widget _buildShimmerBackground() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                StoryTalesTheme.primaryColor.withValues(alpha: 0.1),
                StoryTalesTheme.accentColor.withValues(alpha: 0.1),
                StoryTalesTheme.primaryColor.withValues(alpha: 0.1),
              ],
              stops: [
                (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                _shimmerAnimation.value.clamp(0.0, 1.0),
                (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCentralWizard() {
    return const Center(
      child: AnimatedLogo(size: 60),
    );
  }

  Widget _buildSimpleStatus() {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: ResponsiveText(
                text: _statusMessages[_currentStatusIndex],
                style: const TextStyle(
                  color: StoryTalesTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: StoryTalesTheme.fontFamilyBody,
                  shadows: [
                    Shadow(
                      color: Colors.white,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildErrorContent(String error) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cancel/close button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.read<StoryGenerationBloc>().add(
                      ClearFailedStoryGeneration(tempStoryId: widget.tempStoryId),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      color: StoryTalesTheme.errorColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Error content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon and title
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: StoryTalesTheme.errorColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ResponsiveText(
                      text: "Story creation failed",
                      style: TextStyle(
                        color: StoryTalesTheme.errorColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: StoryTalesTheme.fontFamilyHeading,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Original prompt
              ResponsiveText(
                text: widget.prompt,
                style: const TextStyle(
                  color: StoryTalesTheme.textColor,
                  fontSize: 14,
                  fontFamily: StoryTalesTheme.fontFamilyBody,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Error message
              ResponsiveText(
                text: _getChildFriendlyErrorMessage(error),
                style: TextStyle(
                  color: StoryTalesTheme.textLightColor,
                  fontSize: 12,
                  fontFamily: StoryTalesTheme.fontFamilyBody,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            ],
          ),
        ],
      ),
    );
  }

  String _getChildFriendlyErrorMessage(String error) {
    if (error.toLowerCase().contains('network') ||
        error.toLowerCase().contains('connection')) {
      return "Can't reach the Story Wizard right now";
    } else if (error.toLowerCase().contains('subscription') ||
               error.toLowerCase().contains('limit')) {
      return "You've used all your free stories";
    } else if (error.toLowerCase().contains('timeout')) {
      return "The Story Wizard is taking a break";
    } else {
      return "Something went wrong in the story realm";
    }
  }
}
