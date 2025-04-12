# StoryTales Wireframes Description

This document provides detailed descriptions of the wireframes for the StoryTales app. These wireframes serve as the visual reference for implementing the UI components in Phase 1.

## Overview

The wireframes cover three main screens:
1. **App Homepage** - The main library screen with story cards
2. **Story Page** - Individual pages of a story with illustrations and text
3. **Story Question** - The final page of a story with discussion questions

## 1. App Homepage

![App Homepage](../wireframes/images/app-homepage.jpeg)

### Key Components:

- **Tab Bar**
  - Located at the top of the screen
  - Contains two tabs: "All Stories" (active, underlined in red) and "Favorites"
  - Allows users to switch between viewing all stories and favorite stories

- **Story Cards**
  - Displayed in a grid layout (2 columns)
  - Each card features:
    - Background: Illustrated image (e.g., kids in a spaceship)
    - Overlay Icons (top-right corner):
      - ♥️ Favorite icon - For marking stories as favorites
      - 🗑️ Delete icon - For removing stories from the library
    - Overlay Text (bottom-left):
      - Title: Story title (e.g., "Luna's Garden Whispers")
      - Time: Estimated reading time (e.g., "5 minutes")

- **Floating Action Button**
  - Located at the bottom-right corner of the screen
  - Plus icon (➕) for creating new stories
  - Tapping this button initiates the story generation flow

## 2. Story Page

![Story Page](../wireframes/images/story-page.jpeg)

### Key Components:

- **Header**
  - Located at the top of the screen
  - Contains:
    - Time (left) - Estimated reading time
    - Indicators (center) - Dots showing the current page position
    - Icons (top-right):
      - ♥️ Favorite icon - For marking the story as a favorite
      - ❌ Close icon - For returning to the library screen

- **Background Illustration**
  - Full-screen illustration related to the story content
  - Colorful and engaging visuals appropriate for children

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
  - Identical to the Story Page header
  - Contains time, page indicators, and action icons

- **Background Illustration**
  - Full-screen illustration (same character as in the story)
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

## Implementation Guidelines

When implementing these screens, consider the following:

1. **Responsive Design**
   - Ensure the layouts adapt to different screen sizes
   - Maintain proper spacing and readability on various devices

2. **Accessibility**
   - Use sufficient contrast for text overlays
   - Ensure touch targets are appropriately sized
   - Consider text scaling for users with visual impairments

3. **Animations & Transitions**
   - Implement smooth transitions between pages
   - Consider subtle animations for page turns
   - Keep animations child-friendly and not distracting

4. **Branding Consistency**
   - Apply the "Under the Sea" color palette from the branding document
   - Use the specified fonts for headings and body text
   - Maintain consistent styling across all screens

5. **Interactive Elements**
   - Ensure favorite and delete icons have appropriate feedback when tapped
   - Make the floating action button prominent and easy to tap
   - Implement intuitive swipe gestures for page navigation

These wireframes serve as a visual guide for the UI implementation. The actual implementation should follow the clean architecture and BLoC pattern as specified in the technical documentation.
