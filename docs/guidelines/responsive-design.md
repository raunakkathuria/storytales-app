# Responsive Design Guide

## Overview

This guide outlines the responsive design system implemented in the StoryTales app. Following these guidelines ensures a consistent user experience across different device sizes and accessibility settings.

## Core Components

### ResponsiveText

The `ResponsiveText` widget is a wrapper around Flutter's standard `Text` widget that automatically adjusts text size based on the device's text scaling factor and screen size.

```dart
ResponsiveText(
  text: 'Your text here',
  style: TextStyle(
    fontSize: 16, // Base font size
    fontFamily: StoryTalesTheme.fontFamilyBody,
    fontWeight: FontWeight.normal,
  ),
  textAlign: TextAlign.center, // Optional
)
```

#### Key Benefits

- **Accessibility**: Automatically scales with user's device text size settings
- **Consistency**: Maintains proportional text sizes across different devices
- **Simplicity**: Single component to use throughout the app
- **Maintainability**: Centralized control over text scaling behavior

### ResponsiveIcon

The `ResponsiveIcon` widget provides consistent icon sizing across different devices and screen densities.

```dart
ResponsiveIcon(
  icon: Icons.favorite,
  color: StoryTalesTheme.accentColor,
  sizeCategory: IconSizeCategory.medium,
)
```

#### Size Categories

- **IconSizeCategory.small**: For secondary or supporting icons (16-20dp)
- **IconSizeCategory.medium**: For standard UI icons (24-28dp)
- **IconSizeCategory.large**: For featured or prominent icons (32-48dp)
- **IconSizeCategory.extraLarge**: For hero or showcase icons (64-80dp)

### ResponsiveButton

The `ResponsiveButton` widget provides consistent button styling and sizing across different devices and screen densities.

```dart
// Primary button
ResponsiveButton.primary(
  text: 'Primary Button',
  onPressed: () => handlePress(),
  fontSize: 16.0,
)

// Accent button
ResponsiveButton.accent(
  text: 'Accent Button',
  onPressed: () => handlePress(),
  isFullWidth: true,
)

// Outlined button
ResponsiveButton.outlined(
  text: 'Outlined Button',
  onPressed: () => handlePress(),
  borderColor: StoryTalesTheme.primaryColor,
  textColor: StoryTalesTheme.primaryColor,
)
```

#### Key Features

- **Adaptive Sizing**: Automatically adjusts padding, font size, and minimum size based on screen dimensions
- **Factory Constructors**: Provides convenient constructors for common button styles
- **Icon Support**: Optional icon parameter for buttons with icons
- **Full Width Option**: Can expand to fill the available width

#### Best Practices

- Use the appropriate factory constructor for the button's purpose
- Consider using `isFullWidth: true` for primary actions on small screens
- Use a smaller font size for buttons with longer text
- Ensure sufficient contrast between text and background colors

## Text Size Guidelines

For consistent typography, use these base font sizes with `ResponsiveText`:

| Text Type | Base Font Size | Font Weight | Use Case |
|-----------|---------------|-------------|----------|
| Heading Large | 24px | Bold | Page titles, major headings |
| Heading Medium | 20px | Bold | Section headings, dialog titles |
| Heading Small | 18px | Bold | Minor headings, card titles |
| Body Large | 18px | Regular | Featured content, important information |
| Body Medium | 16px | Regular | Standard body text, form fields |
| Body Small | 14px | Regular | Secondary information, captions |
| Caption | 12px | Regular | Labels, timestamps, footnotes |

Example:

```dart
// Heading
ResponsiveText(
  text: 'Story Title',
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: StoryTalesTheme.fontFamilyHeading,
    color: StoryTalesTheme.primaryColor,
  ),
)

// Body text
ResponsiveText(
  text: 'Story content goes here...',
  style: const TextStyle(
    fontSize: 16,
    fontFamily: StoryTalesTheme.fontFamilyBody,
    color: StoryTalesTheme.textColor,
  ),
)
```

## Layout Considerations

### Margins and Padding

- **Screen Margins**: 16-24px from screen edges
- **Content Padding**: 16px between major content sections
- **Item Spacing**: 8-12px between related items

### Containers and Cards

- Use `BorderRadius.circular(16)` for major containers
- Use `BorderRadius.circular(8)` for buttons and smaller elements
- Ensure touch targets are at least 44x44px for good accessibility

### Responsive Layouts

- Use `LayoutBuilder` for complex responsive layouts
- Use `MediaQuery.of(context).size` to adapt to screen dimensions
- Consider orientation changes in critical screens

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      // Tablet/landscape layout
      return wideLayout();
    } else {
      // Phone/portrait layout
      return narrowLayout();
    }
  },
)
```

## Testing Responsive Behavior

### Device Testing

Test your UI on:
- Small phones (e.g., iPhone SE)
- Standard phones (e.g., Pixel 4)
- Large phones (e.g., iPhone Pro Max)
- Tablets (e.g., iPad)

### Accessibility Testing

Test with:
- Text size settings at 80%, 100%, and 150%
- Screen readers enabled
- Different display densities

### Common Issues to Watch For

- Text overflow or truncation
- Elements too close together at larger text sizes
- Touch targets too small on dense layouts
- Poor contrast with background colors

## Migration Guide

### Replacing Text with ResponsiveText

```dart
// Before
Text(
  'Hello World',
  style: TextStyle(fontSize: 16),
)

// After
ResponsiveText(
  text: 'Hello World',
  style: const TextStyle(fontSize: 16),
)
```

### Replacing Icons with ResponsiveIcon

```dart
// Before
Icon(
  Icons.favorite,
  color: Colors.red,
  size: 24,
)

// After
ResponsiveIcon(
  icon: Icons.favorite,
  color: Colors.red,
  sizeCategory: IconSizeCategory.medium,
)
```

## Best Practices

1. **Always use ResponsiveText** instead of regular Text widgets
2. **Always use ResponsiveIcon** instead of regular Icon widgets
3. **Avoid hardcoded dimensions** where possible
4. **Test on multiple device sizes** regularly during development
5. **Consider text expansion** in languages other than English
6. **Use theme colors** consistently for better contrast and readability
7. **Implement proper error handling** for layout constraints
8. **Avoid fixed-height containers** for text elements

## Examples

### Good Example: Responsive Dialog with Centered Logo

```dart
DialogForm(
  title: '', // Empty title since we're showing it in the header
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Logo and title header
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large centered logo
            const AnimatedLogo(size: 80),

            const SizedBox(height: 12),

            // Title text centered below logo
            ResponsiveText(
              text: 'Magic story awaits you',
              style: const TextStyle(
                fontFamily: StoryTalesTheme.fontFamilyHeading,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: StoryTalesTheme.accentColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      // Form fields...
    ],
  ),
  primaryActionText: 'Generate Story',
  onPrimaryAction: () => generateStory(),
)
```

### Bad Example: Fixed Sizing

```dart
// Avoid this approach
Container(
  height: 50, // Fixed height will cause problems with text scaling
  child: Text(
    'This text might overflow if the user has larger text settings',
    style: TextStyle(fontSize: 16),
  ),
)
```

By following these guidelines, we ensure that the StoryTales app provides a consistent, accessible experience for all users regardless of their device or accessibility settings.
