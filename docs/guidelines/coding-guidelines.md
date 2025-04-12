## Coding Guidelines

Adopt these best practices to keep the codebase **simple** and **maintainable**:

1. **Directory Structure & Modularization**
   - **One feature → one folder** with subfolders for `data`, `presentation`, `domain`.
   - Example: `features/story_generation/data/`, `features/story_generation/domain/`, etc.
2. **Naming Conventions**
   - Classes: `UpperCamelCase` (e.g., `StoryApiClient`, `StoryRepository`).
   - Methods/variables: `lowerCamelCase` (e.g., `generateStory`, `storyCount`).
3. **BLoC / Cubit**
   - Keep logic out of widgets.
   - Each BLoC handles a discrete feature set: generating stories, library listing, subscription checks.
4. **Clean Architecture Layers**
   - **Data layer**: Repositories, local DB, external API calls.
   - **Domain layer**: Entities (e.g., `Story`, `StoryPage`) + business rules.
   - **Presentation layer**: Flutter UI + BLoC states.
5. **File Size & Organization**
   - Generally **1 class per file** if a class is non-trivial.
   - Avoid “god” classes > 300–400 lines. Split code logically.
6. **Error Handling**
   - Centralize custom exceptions (`StoryGenerationException`, etc.).
   - Show friendly fallback messages in the UI.
7. **Testing**
   - Keep test files in `test/` mirroring the main code structure.
   - Write short, focused tests with descriptive test names.
8. **Performance**
   - Use `const` constructors where possible.
   - Cache repeated DB or API calls if it improves speed.
   - Use lazy loading for images if needed.
9. **Commenting & Documentation**
   - Add doc comments (`///`) to classes/methods explaining purpose if not obvious.
   - Keep in-line comments minimal and relevant.
10. **Consistency**

- Use Dart’s official style: run `dart format` or `flutter format`.
- Lint your code with `dart analyze`.