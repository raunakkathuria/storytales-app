# StoryTales Wireframes Description

This document provides detailed descriptions of the wireframes for the StoryTales app. These wireframes serve as the visual reference for implementing the UI components in Phase 1.

## Overview

The wireframes cover seven main components:
1. **App Homepage** - The main library screen with story cards
2. **Story Page** - Individual pages of a story with illustrations and text
3. **Story Question** - The final page of a story with discussion questions
4. **Story Creation** - Bottom sheet for creating new stories
5. **Subscription Page** - Page for managing subscription options
6. **Subscribed User View** - Subscription page for users with active subscriptions
7. **Dialog Boxes** - Confirmation dialogs for various actions

## 1. App Homepage

![App Homepage](../wireframes/images/app-homepage.jpeg)

### Key Components:

- **Story Grid**
  - Occupies the full screen area above the bottom navigation
  - Displayed in a grid layout (2 columns)
  - Each card features:
    - Background: Illustrated image (e.g., kids in a spaceship)
    - Overlay Icons (top-right corner):
      - ♥️ Favorite icon - For marking stories as favorites
      - 🗑️ Delete icon - For removing stories from the library
    - Overlay Text (bottom-left):
      - Title: Story title (e.g., "Luna's Garden Whispers")
      - Time: Estimated reading time (e.g., "5 minutes")

- **Bottom Navigation Bar**
  - Located at the bottom of the screen
  - Contains three items:
    - "All Stories" (left) - For viewing all stories
    - "+" (center) - For creating new stories
    - "Favorites" (right) - For viewing favorite stories
  - The center "+" button initiates the story generation flow
  - Provides easy thumb access to key navigation and action elements

## 2. Story Page

![Story Page](../wireframes/images/story-page.jpeg)

### Key Components:

- **Header**
  - Located at the top of the screen with semi-transparent gradient background
  - Contains:
    - Time (left) - Estimated reading time with clock icon
    - Indicators (center) - Dots showing the current page position
    - Icons (top-right):
      - ♥️ Favorite icon - For marking the story as a favorite
      - ❌ Close icon - For returning to the library screen

- **Background Illustration**
  - Edge-to-edge full-screen illustration related to the story content
  - Colorful and engaging visuals appropriate for children
  - Semi-transparent gradient overlay (transparent at top, 60% black at bottom)

- **Text Overlay**
  - Located at the bottom of the screen
  - Features:
    - Semi-transparent dark background for better text readability
    - Story text content (e.g., "That afternoon, Luna rushed to tell her parents about her amazing discovery...")
    - Positioned to not obscure important parts of the illustration

- **Navigation**
  - Swipe left/right or tap on the sides to navigate between pages
  - Page indicators in the header show progress through the story

## 3. Story Question

![Story Question](../wireframes/images/story-question.jpeg)

### Key Components:

- **Header**
  - Identical to the Story Page header with semi-transparent gradient
  - Contains time with clock icon, page indicators, and action icons

- **Background Illustration**
  - Edge-to-edge full-screen illustration (same character as in the story)
  - Same semi-transparent gradient overlay as story pages
  - Serves as a visual backdrop for the discussion questions

- **Text Overlay**
  - Centered on the screen, over the illustration
  - Features:
    - Semi-transparent dark background
    - Title: "Ideas for Discussion"
    - Bulleted questions with icons:
      - "What special gift did Luna discover..."
      - "Why is it important to take care of..."
      - "How did Luna's discovery change..."

- **Footer Information**
  - Located at the bottom of the text overlay
  - Contains:
    - Character name: e.g., "Zoe"
    - Age Range: e.g., "6–8 years"
    - Creation Date: e.g., "4/2/2025"
    - "Thank you for reading!" message

## 4. Story Creation Bottom Sheet

![Story Creation Bottom Sheet](../wireframes/story-creation.txt)

### Key Components:

- **Form State**
  - **Logo and Title**
    - Large centered logo (80px) at the top
    - "Magic story awaits you" title text centered below logo
    - Text uses heading style with 24px font size
  - **Form Fields**
    - Story Prompt: Multi-line text field for entering the story idea
    - Age Range: Dropdown with options (3-6, 7-9, 10-12 years)
    - Theme: Dropdown with options (Friendship, Adventure, Family, etc.)
    - Genre: Dropdown with options (Fantasy, Science Fiction, etc.)
  - **Generate Button**
    - Prominent button at the bottom of the form
    - Labeled "Generate Story"
    - Uses the accent color from the theme

- **Loading State**
  - **Handle Indicator**
    - Same as in form state
  - **Animated Logo**
    - Centered animated logo showing app branding
  - **Status Text**
    - "Creating Your Story..." title
    - Description text explaining the process
  - **Progress Indicator**
    - Linear progress bar showing completion percentage
    - Percentage text below the progress bar
  - **Cancel Button**
    - Option to cancel the story generation process
    - Styled as an outlined button with icon

### Interaction Flow:

- The bottom sheet appears when the user taps the "+" button in the bottom navigation bar
- It slides up from the bottom of the screen with a standard animation
- The form validates input before submission:
  - Story prompt is required and must be at least 3 characters
  - Other fields are optional but recommended
- When "Generate Story" is tapped, the sheet transitions to the loading state
- Progress updates in real-time as the story is generated
- Upon completion, the sheet dismisses and navigates to the new story
- If the user has reached their free story limit, they are redirected to the subscription page

## 5. Subscription Page

![Subscription Page](../wireframes/subscription-page.txt)

### Key Components:

- **Header**
  - App bar with back button and "Subscription" title
  - Icon representing subscription (e.g., bookmark/tag)
  - Title: "Unlock Unlimited Stories"
  - Subtitle: Dynamic text showing free stories remaining or subscription status

- **Subscription Options**
  - Two subscription cards displayed vertically:
    - **Monthly Plan**
      - Title: "Monthly"
      - Price: "$4.99"
      - Period: "per month"
      - Features list with checkmarks
      - Subscribe button
    - **Annual Plan**
      - Title: "Annual"
      - Price: "$39.99"
      - Period: "per year"
      - Features list with checkmarks
      - "Best Value" badge (positioned on the right side)
      - Subscribe button with "Best Value" label

- **Additional Buttons**
  - "Restore Subscription" button for recovering previous purchases
  - Terms and conditions text at the bottom explaining subscription details

- **Visual Design**
  - Cards with elevation and rounded corners
  - Consistent use of brand colors:
    - Primary color for buttons and highlights
    - Accent color for the "Best Value" badge
    - Secondary color for prices and checkmarks

### Interaction Flow:

- User navigates to this page from:
  - Library screen subscription icon
  - Subscription prompt dialog
  - Story creation flow when free limit is reached
- Tapping a subscription option initiates the purchase flow
- After successful purchase, the page updates to show the active subscription
- "Restore Subscription" allows users to recover previously purchased subscriptions

## 6. Subscribed User View

![Subscribed User View](../wireframes/subscription-page-subscribed.txt)

### Key Components:

- **Active Subscription Card**
  - Shows the user's current subscription plan (Monthly or Annual)
  - "Current Plan" badge in top-left corner
  - Disabled "Current Plan" button
  - All the same information as in the regular subscription card

- **Alternative Plan**
  - Shows the other available subscription option
  - "Best Value" badge (positioned on the right side) for annual plan
  - Enabled "Subscribe" button to allow switching plans

- **Management Options**
  - "Restore Subscription" button
  - "Cancel Subscription" button (only shown for active subscribers)
  - Terms and conditions text

### Interaction Flow:

- User can switch between subscription plans
- Tapping "Cancel Subscription" shows a confirmation dialog
- After cancellation, user maintains access until the end of the billing period

## 7. Dialog Boxes

![Dialog Boxes](../wireframes/dialog-boxes.txt)

### Key Components:

- **Subscription Prompt Dialog**
  - Title: "Subscription Required"
  - Content: "You've used all your free stories. Subscribe now to create unlimited stories!"
  - Buttons: "Not Now" (left) and "Subscribe" (right)
  - Appears when user attempts to create a story after reaching the free limit

- **Cancel Subscription Dialog**
  - Title: "Cancel Subscription"
  - Content: "Are you sure you want to cancel your subscription? You will still have access until the end of your current billing period."
  - Buttons: "No" (left) and "Yes" (right)
  - Appears when user taps "Cancel Subscription" button

- **Delete Story Dialog**
  - Title: "Delete Story"
  - Content: "Are you sure you want to delete "[Story Title]"?"
  - Buttons: "No" (left) and "Yes" (right)
  - Appears when user taps the delete icon on a story card

### Visual Design:

- Standard AlertDialog with consistent styling
- Primary color for the cancel/negative action button
- Accent color for non-destructive confirm buttons
- Error color for destructive confirm buttons
- Rounded corners matching the app's design language

### Interaction Flow:

- Dialogs appear centered on screen with a subtle animation
- Background is dimmed to focus attention on the dialog
- Tapping outside the dialog does not dismiss it (requires explicit choice)
- "Yes"/"Subscribe" buttons trigger the corresponding action
- "No"/"Not Now" buttons dismiss the dialog without taking action

## Implementation Guidelines

When implementing these screens, consider the following:

1. **Responsive Design**
   - **Use ResponsiveText for all text elements**:
     - Ensures text scales properly with device settings
     - Maintains consistent typography across different devices
     - Improves accessibility for users with visual impairments
   - **Use ResponsiveIcon for all icons**:
     - Standardizes icon sizing using size categories
     - Adapts to different screen densities and accessibility settings
   - **Follow responsive layout principles**:
     - Ensure layouts adapt to different screen sizes
     - Maintain proper spacing and readability on various devices
     - Use BoxFit.cover with center alignment for images
     - Position text containers with appropriate margins from screen edges (16-24px)
     - For dialogs, ensure proper keyboard handling with sufficient scrolling

2. **Accessibility**
   - Use sufficient contrast for text overlays
   - Ensure touch targets are appropriately sized
   - Consider text scaling for users with visual impairments
   - Implement text with multiple shadows for better readability against varied backgrounds
   - Use semi-bold text weight (FontWeight.w600) for improved legibility
   - Make form fields accessible with proper labels and error messages

3. **Text Overlay Design**
   - Position text container at the bottom of the screen with 24px bottom margin
   - Use semi-transparent black background (70% opacity) with rounded corners (12px radius)
   - Apply consistent padding inside text containers (24px horizontal, 16px vertical)
   - Ensure text container width adapts to screen size with appropriate margins
   - Use consistent text styling across story pages and question pages:
     - White text color for maximum contrast
     - Semi-bold weight (FontWeight.w600) for better readability
     - Text shadows to ensure visibility against any background

4. **Immersive Experience & System UI**
   - Extend content to the edges of the screen (edge-to-edge)
   - Make status bar transparent to maximize immersion
   - Implement smooth transitions between pages
   - Consider subtle animations for page turns
   - Keep animations child-friendly and not distracting
   - For the bottom sheet, use a rounded top border radius (20px) for a modern look

5. **Branding Consistency**
   - Apply the "Storybook Sky" color palette from the branding document
   - Use the specified fonts for headings and body text
   - Maintain consistent styling across all screens
   - Use the accent color for primary actions like the "Generate Story" button

6. **Interactive Elements**
   - Ensure favorite and delete icons have appropriate feedback when tapped
   - Make the bottom navigation buttons prominent and easy to tap
   - Implement intuitive swipe gestures for page navigation
   - Ensure navigation areas cover the left/right halves of the screen for easy page turning
   - For the bottom sheet, implement proper keyboard handling to avoid input fields being covered

7. **Dialog Box Guidelines**
   - Use the ConfirmationDialog utility class for consistent styling
   - Ensure dialog buttons have appropriate colors based on action type
   - Make destructive actions (like delete) use the error color
   - Position the primary action on the right side
   - Ensure dialog content is clear and concise

These wireframes serve as a visual guide for the UI implementation. The actual implementation should follow the clean architecture and BLoC pattern as specified in the technical documentation.
