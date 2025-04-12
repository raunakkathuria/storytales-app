import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/core/widgets/confirmation_dialog.dart';
import 'package:storytales/core/widgets/responsive_icon.dart';
import 'package:storytales/core/widgets/responsive_text.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:storytales/features/subscription/presentation/widgets/subscription_card.dart';

/// Page for managing subscriptions.
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) => const ResponsiveText(
            text: 'Subscription',
            style: TextStyle(
              color: StoryTalesTheme.textColor, // Dark text for white background
              fontFamily: StoryTalesTheme.fontFamilyHeading,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        toolbarHeight: 40, // Reduced from default 56
        backgroundColor: StoryTalesTheme.surfaceColor, // White background
        elevation: 0, // No shadow
        iconTheme: IconThemeData(
          color: StoryTalesTheme.textColor, // Dark back button
        ),
        // No actions - removing the cancel button
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          // Store the navigator and scaffold messenger to avoid using context across async gaps
          Navigator.of(context);
          final scaffoldMessenger = ScaffoldMessenger.of(context);

          if (state is SubscriptionPurchased) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: ResponsiveText(
                  text: 'Subscription purchased successfully!',
                  style: TextStyle(
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                    fontSize: 16,
                  ),
                ),
                backgroundColor: StoryTalesTheme.successColor,
              ),
            );
            // Removed auto-navigation to keep user on subscription page
          } else if (state is SubscriptionPurchaseFailed) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: ResponsiveText(
                  text: 'Purchase failed: ${state.error}',
                  style: const TextStyle(
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                    fontSize: 16,
                  ),
                ),
                backgroundColor: StoryTalesTheme.errorColor,
              ),
            );
          } else if (state is SubscriptionRestored) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: ResponsiveText(
                  text: state.wasSuccessful
                      ? 'Subscription restored successfully!'
                      : 'No active subscription found to restore.',
                  style: const TextStyle(
                    fontFamily: StoryTalesTheme.fontFamilyBody,
                    fontSize: 16,
                  ),
                ),
                backgroundColor:
                    state.wasSuccessful ? StoryTalesTheme.successColor : StoryTalesTheme.errorColor,
              ),
            );
            // Removed auto-navigation to keep user on subscription page
          }
        },
        builder: (context, state) {
          if (state is SubscriptionPurchasing || state is SubscriptionRestoring) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(context, state),

                const SizedBox(height: 32),

                // Subscription options
                _buildSubscriptionOptions(context, state),

                const SizedBox(height: 24),

                // Restore subscription button
                OutlinedButton(
                  onPressed: () => context.read<SubscriptionBloc>().add(const RestoreSubscription()),
                  child: const ResponsiveText(
                    text: 'Restore Subscription',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: StoryTalesTheme.fontFamilyBody,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel subscription button (only shown if subscription is active)
                if (state is SubscriptionActive)
                  OutlinedButton(
                    onPressed: () => _showCancelSubscriptionDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StoryTalesTheme.errorColor,
                      side: BorderSide(color: StoryTalesTheme.errorColor),
                    ),
                    child: const ResponsiveText(
                      text: 'Cancel Subscription',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: StoryTalesTheme.fontFamilyBody,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Terms and conditions
                _buildTermsAndConditions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SubscriptionState state) {
    // Skip header completely for subscribed users
    if (state is SubscriptionActive) {
      return const SizedBox.shrink(); // No header for subscribers
    }

    String title = 'Unlock Unlimited Stories';
    String subtitle = 'Subscribe to create as many stories as you want!';

    if (state is SubscriptionRequired) {
      // User has used all free stories, subscription is required
      subtitle = 'You\'ve used all ${state.freeStoryLimit} of your free stories. Subscribe to continue creating!';
    } else if (state is FreeStoriesAvailable) {
      // User still has free stories remaining
      subtitle = 'You have ${state.freeStoriesRemaining} free ${state.freeStoriesRemaining == 1 ? "story" : "stories"} remaining. Subscribe for unlimited stories!';
    }

    return Column(
      children: [
        ResponsiveIcon(
          icon: Icons.auto_stories,
          sizeCategory: IconSizeCategory.large,
          color: StoryTalesTheme.primaryColor,
        ),

        const SizedBox(height: 16),

        ResponsiveText(
          text: title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: StoryTalesTheme.fontFamilyHeading,
            color: StoryTalesTheme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        ResponsiveText(
          text: subtitle,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: StoryTalesTheme.fontFamilyBody,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubscriptionOptions(BuildContext context, SubscriptionState state) {
    // Determine if user is subscribed and which plan they have
    final bool isSubscribed = state is SubscriptionActive;

    // Get the subscription type from the state
    final String currentPlan = isSubscribed
        ? (state).subscriptionType
        : '';

    return Column(
      children: [
        // Monthly subscription
        SubscriptionCard(
          title: 'Monthly',
          price: '\$4.99',
          period: 'per month',
          features: const [
            'Unlimited story generation',
            'Access to all themes and genres',
            'New features as they launch',
          ],
          isRecommended: false,
          isCurrentPlan: isSubscribed && currentPlan == 'monthly',
          onSubscribe: isSubscribed
              ? null
              : () => _purchaseSubscription(context, 'monthly', 'monthly_sub_001'),
        ),

        const SizedBox(height: 16),

        // Annual subscription
        SubscriptionCard(
          title: 'Annual',
          price: '\$39.99',
          period: 'per year',
          features: const [
            'Unlimited story generation',
            'Access to all themes and genres',
            'New features as they launch',
            'Save 33% compared to monthly',
          ],
          isRecommended: true,
          isCurrentPlan: isSubscribed && currentPlan == 'annual',
          onSubscribe: isSubscribed
              ? null
              : () => _purchaseSubscription(context, 'annual', 'annual_sub_001'),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return const ResponsiveText(
      text: 'By subscribing, you agree to our Terms of Service and Privacy Policy. '
      'Subscriptions will automatically renew unless canceled at least 24 hours before the end of the current period. '
      'You can manage your subscriptions in your App Store or Google Play account settings.',
      style: TextStyle(
        fontSize: 12,
        color: StoryTalesTheme.textLightColor,
        fontFamily: StoryTalesTheme.fontFamilyBody,
      ),
      textAlign: TextAlign.center,
    );
  }

  void _purchaseSubscription(BuildContext context, String type, String id) {
    context.read<SubscriptionBloc>().add(
      PurchaseSubscription(
        subscriptionType: type,
        subscriptionId: id,
      ),
    );
  }

  /// Show a dialog to confirm subscription cancellation
  void _showCancelSubscriptionDialog(BuildContext context) {
    ConfirmationDialog.show(
      context: context,
      title: 'Cancel Subscription',
      content: 'Are you sure you want to cancel your subscription? '
          'You will still have access until the end of your current billing period.',
      confirmText: 'Yes',
      cancelText: 'No',
      onConfirm: () {
        context.read<SubscriptionBloc>().add(const ResetSubscription());
      },
    );
  }
}
