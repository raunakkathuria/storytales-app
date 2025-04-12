## Brand Vision & Audience

**StoryTales** is an **AI-powered** mobile app that generates **personalized children’s stories**. The **primary audience** includes:

- **Parents/Caregivers** of children aged 3–12
- **Educators/Schools** wanting creative storytelling solutions
- **Children** aged 8–12 who can read independently

### Brand Attributes

- **Playful & Creative**: Encourages imagination, fosters curiosity.
- **Friendly & Safe**: Conveys warmth and trust for families.
- **Educational Yet Fun**: Supports learning goals without feeling rigid.

## Color Palette & Theme

To ensure a **unified** and **easy-to-update** aesthetic, **all brand colors** must be stored in a **single theme file** (e.g. `theme.dart`) in your Flutter project, rather than scattered across multiple files.

### Palette Example: *Storybook Sky*

| **Color**           | **Hex**   | **Role**                               |
| ------------------- | --------- | -------------------------------------- |
| **Sky Blue**        | `#7DCDEE` | Primary color (app bar, headings)      |
| **Lavender Purple** | `#A18CD1` | Secondary color (cards, sections)      |
| **Cloud White**     | `#F8F9FA` | Background color (main screens)        |
| **Sunset Orange**   | `#FF9A76` | Accent color (buttons, highlights)     |

> **Note**: This is the current **Phase 1** color scheme. If you switch to another brand theme (e.g. **Candyland Carnival**, **Galaxy Adventures**), **update the theme file** references accordingly. By maintaining a single file for color definitions, you can **easily swap** or tweak these palettes as needed.

#### Semantic Color Roles

Use **semantic color roles** in your theme file, for example:

```
dart


CopyEdit
class StoryTalesTheme {
  static final Color primaryColor = Color(0xFF7DCDEE);    // Sky Blue
  static final Color secondaryColor = Color(0xFFA18CD1);  // Lavender Purple
  static final Color backgroundColor = Color(0xFFF8F9FA); // Cloud White
  static final Color accentColor = Color(0xFFFF9A76);     // Sunset Orange

  // Optionally define text styles, shape themes, etc.
}
```

Then, all widgets reference `StoryTalesTheme.primaryColor` (etc.), rather than raw hex codes. This approach:

1. **Simplifies** color updates (just edit the single theme file).
2. **Ensures** branding consistency across every screen.

## Typography Guidelines

1. **Title/Display Fonts**:
   - Use a **playful or rounded** display font for headings (e.g., “Baloo Bhaijaan,” “Pangolin,” or “Nunito”).
   - This sets a fun tone while remaining readable.
2. **Body Text**:
   - A clean, highly readable sans-serif (e.g. “Open Sans,” “Poppins,” “Quicksand”).
   - **Font size**: 14–16pt recommended for general text in children’s content.
   - Maintain at least **1.5 line spacing** for readability.
3. **Styling**:
   - Avoid using multiple typefaces in the same screen.
   - Headings and subheadings should use consistent sizes to maintain hierarchy.

## Illustrations & Iconography

1. **Style**:
   - Whimsical or cartoonish icons that match the overall theme (e.g., sky and cloud motifs for the *Storybook Sky* palette).
2. **Consistency**:
   - Use a single icon set (or a single illustration style) to avoid mismatched visuals.
3. **Usage**:
   - Keep icons at comfortable sizes (48px or 32px min) to accommodate younger users.

## Tone & Voice

**StoryTales** aims to be:

- **Friendly**: Simple, warm language.
- **Encouraging**: Congratulatory prompts after generating a story, positive reinforcement.
- **Imaginative**: Embellish instructions with storytelling phrases (e.g., “Ready to embark on a new adventure?”).

No complicated jargon — the app caters to both parents and young readers.

## Implementation Guidelines

### Single Theme File

- **File Name**: e.g., `theme.dart` or `storytales_theme.dart`.
- **Content**:
  - **Color definitions** (`primaryColor`, `secondaryColor`, `accentColor`, etc.).
  - **Text styles** (heading, body, captions) if desired.
  - **Any brand-related constants** (e.g. corner radius, consistent card shape).
- **Usage**:
  - In your **MaterialApp** theme or `ThemeData` config, reference these color constants.
  - **Do not** hardcode hex codes in random widgets.

### Testing/Swapping Palettes

To explore new palettes:

1. **Clone** the existing theme file, rename or create a new set of color constants.
2. Switch references in `main.dart` or `app.dart` to the new set.
3. Run the app — you instantly see the UI’s new look without changing widget-level code.

### Accessibility & Contrast

- Maintain **accessible contrast** for important text.
- When using pastel backgrounds, ensure text is in darker complementary colors.
- For smaller text (below 14pt), ensure a ratio of at least **4.5:1** (WCAG AA) if possible.

## Examples & Previews

Below is a **sample** theme definition in Flutter:

```
dart


CopyEdit
import 'package:flutter/material.dart';

class StoryTalesTheme {
  // Primary brand colors (Storybook Sky)
  static const Color primaryColor = Color(0xFF7DCDEE);    // Sky Blue
  static const Color secondaryColor = Color(0xFFA18CD1);  // Lavender Purple
  static const Color backgroundColor = Color(0xFFF8F9FA); // Cloud White
  static const Color accentColor = Color(0xFFFF9A76);     // Sunset Orange

  // Generate a corresponding ThemeData
  static ThemeData buildThemeData() {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      textTheme: TextTheme(
        headline1: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: accentColor,
        ),
        bodyText2: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      // More theme customizations ...
    );
  }
}
```

### UI Preview

When you run the app referencing `StoryTalesTheme.buildThemeData()`, all primary app bars, buttons, backgrounds, and headings adopt this cohesive color scheme. If you **swap** out the color constants with another set (e.g. **Candyland Carnival**), it changes globally without rewriting individual widgets.
