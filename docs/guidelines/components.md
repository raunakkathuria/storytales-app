# Component Guidelines

This document provides detailed information about the reusable components in the StoryTales app, their purpose, usage examples, and best practices.

## Core Components

### ResponsiveText

A wrapper around Flutter's standard `Text` widget that automatically adjusts text size based on the device's text scaling factor and screen size.

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

#### Best Practices

- Always use `ResponsiveText` instead of standard `Text` widgets
- Provide a base font size in the style parameter
- Use semantic font sizes from the theme (e.g., `StoryTalesTheme.bodyMedium`)
- Consider text alignment for different screen sizes

### ResponsiveIcon

Provides consistent icon sizing across different devices and screen densities.

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

#### Best Practices

- Always use `ResponsiveIcon` instead of standard `Icon` widgets
- Choose the appropriate size category based on the icon's importance
- Use consistent size categories for similar icons throughout the app
- Consider the icon's context when choosing a size category

### ResponsiveButton

A button component that adapts to different screen sizes, ensuring proper sizing and touch targets across devices.

```dart
// Standard button
ResponsiveButton(
  text: 'Button Text',
  onPressed: () => handlePress(),
  backgroundColor: StoryTalesTheme.primaryColor,
  textColor: StoryTalesTheme.surfaceColor,
  fontSize: 16.0,
)

// Primary button (using factory constructor)
ResponsiveButton.primary(
  text: 'Primary Button',
  onPressed: () => handlePress(),
  isFullWidth: false,
)

// Accent button (using factory constructor)
ResponsiveButton.accent(
  text: 'Accent Button',
  onPressed: () => handlePress(),
  isFullWidth: true,
)

// Outlined button (using factory constructor)
ResponsiveButton.outlined(
  text: 'Outlined Button',
  onPressed: () => handlePress(),
  borderColor: StoryTalesTheme.primaryColor,
  textColor: StoryTalesTheme.primaryColor,
)

// Button with icon
ResponsiveButton.primary(
  text: 'Button with Icon',
  onPressed: () => handlePress(),
  icon: Icons.add,
  iconSizeCategory: IconSizeCategory.small,
)
```

#### Key Features

- **Adaptive Sizing**: Automatically adjusts padding, font size, and minimum size based on screen dimensions
- **Factory Constructors**: Provides convenient constructors for common button styles
- **Icon Support**: Optional icon parameter for buttons with icons
- **Full Width Option**: Can expand to fill the available width
- **Consistent Styling**: Maintains consistent styling across the app

#### Best Practices

- Use the appropriate factory constructor for the button's purpose
- Consider using `isFullWidth: true` for primary actions on small screens
- Use a smaller font size for buttons with longer text
- Ensure sufficient contrast between text and background colors
- Use consistent button styles for similar actions throughout the app

### DialogForm

A utility class for creating consistent form dialogs across the app.

```dart
// Show a dialog form
DialogForm.show(
  context: context,
  title: 'Dialog Title',
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Form fields
    ],
  ),
  primaryActionText: 'Confirm',
  onPrimaryAction: () => handleConfirm(),
  secondaryActionText: 'Cancel',
  onSecondaryAction: () => Navigator.pop(context),
)

// Create a dialog form widget
DialogForm(
  title: 'Dialog Title',
  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Form fields
    ],
  ),
  primaryActionText: 'Confirm',
  onPrimaryAction: () => handleConfirm(),
  secondaryActionText: 'Cancel',
  onSecondaryAction: () => Navigator.pop(context),
)
```

#### Key Features

- **Responsive Layout**: Adapts to different screen sizes, switching to vertical button layout on narrow screens
- **Consistent Styling**: Maintains consistent styling across all dialogs
- **Loading State**: Supports a loading state with optional loading indicator
- **Accessibility**: Uses `ResponsiveText` and `ResponsiveButton` for better accessibility

#### Best Practices

- Use a clear, concise title that describes the dialog's purpose
- Keep the content focused on a single task or decision
- Use the primary action for the main action (e.g., "Confirm", "Save")
- Use the secondary action for cancellation or dismissal
- Consider using a loading state for actions that may take time to complete

### ConfirmationDialog

A utility class for creating consistent confirmation dialogs across the app.

```dart
ConfirmationDialog.show(
  context: context,
  title: 'Delete Story',
  content: 'Are you sure you want to delete this story?',
  confirmText: 'Delete',
  cancelText: 'Cancel',
  onConfirm: () => handleDelete(),
  isDestructive: true,
)
```

#### Key Features

- **Responsive Layout**: Adapts to different screen sizes
- **Consistent Styling**: Maintains consistent styling across all confirmation dialogs
- **Destructive Action Support**: Special styling for destructive actions
- **Accessibility**: Uses `ResponsiveText` and `ResponsiveButton` for better accessibility

#### Best Practices

- Use a clear, concise title that describes the action being confirmed
- Clearly explain the consequences of the action in the content
- Use appropriate text for the confirm and cancel buttons
- Set `isDestructive: true` for actions that delete data or have other permanent consequences
- Use consistent terminology across all confirmation dialogs

## Layout Components

### AnimatedLogo

A component that displays the app logo with optional animation.

```dart
AnimatedLogo(
  size: 80,
  animate: true,
)
```

#### Key Features

- **Responsive Sizing**: Adapts to different screen sizes
- **Animation**: Optional animation for visual interest
- **Consistent Branding**: Maintains consistent branding across the app

#### Best Practices

- Use a consistent size for the logo in similar contexts
- Consider using animation for loading screens or other waiting states
- Ensure the logo is visible against the background

## Form Components

### ResponsiveDropdown

A dropdown component that adapts to different screen sizes.

```dart
ResponsiveDropdown<String>(
  value: selectedValue,
  items: items.map((item) => DropdownMenuItem(
    value: item,
    child: ResponsiveText(text: item),
  )).toList(),
  onChanged: (value) => handleChange(value),
  decoration: InputDecoration(
    labelText: 'Label',
    border: OutlineInputBorder(),
  ),
)
```

#### Key Features

- **Responsive Sizing**: Adapts to different screen sizes
- **Consistent Styling**: Maintains consistent styling across all dropdowns
- **Accessibility**: Uses `ResponsiveText` for better accessibility

#### Best Practices

- Use clear, concise labels for dropdowns
- Provide a reasonable default value when possible
- Consider the dropdown's width on different screen sizes
- Use consistent styling for all dropdowns in the app

## Best Practices for All Components

1. **Consistency**: Use the same component for the same purpose throughout the app
2. **Accessibility**: Ensure all components are accessible to users with different abilities
3. **Responsiveness**: Test components on different screen sizes to ensure they adapt properly
4. **Performance**: Be mindful of performance implications, especially for components used in lists
5. **Maintainability**: Keep components focused on a single responsibility
6. **Documentation**: Document any custom components with clear usage examples
7. **Testing**: Write tests for components to ensure they behave as expected
