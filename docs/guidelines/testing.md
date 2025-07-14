# Testing Guidelines

This document outlines the testing strategies and best practices for the StoryTales app. Following these guidelines ensures that the app is thoroughly tested and maintains high quality.

## Testing Levels

### Unit Testing

Unit tests focus on testing individual components in isolation, such as BLoCs, repositories, and services.

#### BLoC Testing

BLoCs should be thoroughly tested to ensure that they handle events correctly and emit the expected states.

```dart
void main() {
  group('LibraryBloc', () {
    late LibraryBloc libraryBloc;
    late MockStoryRepository mockStoryRepository;
    late MockAnalyticsService mockAnalyticsService;

    setUp(() {
      mockStoryRepository = MockStoryRepository();
      mockAnalyticsService = MockAnalyticsService();
      libraryBloc = LibraryBloc(
        repository: mockStoryRepository,
        analyticsService: mockAnalyticsService,
      );
    });

    tearDown(() {
      libraryBloc.close();
    });

    test('initial state is LibraryInitial', () {
      expect(libraryBloc.state, isA<LibraryInitial>());
    });

    blocTest<LibraryBloc, LibraryState>(
      'emits [LibraryLoading, LibraryLoaded] when LoadAllStories is added',
      build: () {
        when(mockStoryRepository.getAllStories())
            .thenAnswer((_) async => [mockStory1, mockStory2]);
        return libraryBloc;
      },
      act: (bloc) => bloc.add(const LoadAllStories()),
      expect: () => [
        isA<LibraryLoading>(),
        isA<LibraryLoaded>(),
      ],
      verify: (_) {
        verify(mockStoryRepository.getAllStories()).called(1);
      },
    );

    // More tests...
  });
}
```

#### Repository Testing

Repositories should be tested to ensure that they interact correctly with data sources and return the expected results.

```dart
void main() {
  group('StoryRepositoryImpl', () {
    late StoryRepositoryImpl repository;
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      repository = StoryRepositoryImpl(
        databaseService: mockDatabaseService,
      );
    });

    test('getAllStories returns a list of stories', () async {
      // Arrange
      when(mockDatabaseService.getStories())
          .thenAnswer((_) async => [mockStoryModel1, mockStoryModel2]);

      // Act
      final result = await repository.getAllStories();

      // Assert
      expect(result, [isA<Story>(), isA<Story>()]);
      verify(mockDatabaseService.getStories()).called(1);
    });

    // More tests...
  });
}
```

#### Service Testing

Services should be tested to ensure that they perform their functions correctly.

```dart
void main() {
  group('ConnectivityService', () {
    late ConnectivityService connectivityService;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockConnectivity = MockConnectivity();
      connectivityService = ConnectivityService(
        connectivity: mockConnectivity,
      );
    });

    test('isConnected returns true when connected', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Act
      final result = await connectivityService.isConnected();

      // Assert
      expect(result, true);
      verify(mockConnectivity.checkConnectivity()).called(1);
    });

    // More tests...
  });
}
```

### Widget Testing

Widget tests focus on testing individual widgets and their interactions.

```dart
void main() {
  group('StoryCard', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      // Arrange
      final story = Story(
        id: '1',
        title: 'Test Story',
        summary: 'Test Summary',
        coverImagePath: 'assets/images/test.png',
        createdAt: DateTime.now(),
        author: 'Test Author',
        ageRange: '3-6',
        readingTime: '5 min',
        originalPrompt: 'Test Prompt',
        genre: 'Fantasy',
        theme: 'Adventure',
        tags: ['fantasy', 'adventure'],
        isPregenerated: false,
        isFavorite: false,
        pages: [],
        questions: [],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StoryCard(
              story: story,
              onTap: () {},
              onFavoriteToggle: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Story'), findsOneWidget);
      expect(find.text('5 min'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    // More tests...
  });
}
```

### Integration Testing

Integration tests focus on testing the interaction between different parts of the app.

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Create and read a story', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const StoryTalesApp());
      await tester.pumpAndSettle();

      // Act - Navigate to story creation
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();

      // Fill in the form
      await tester.enterText(
        find.byType(TextFormField).first,
        'A story about a friendly dragon',
      );
      await tester.pumpAndSettle();

      // Select age range
      await tester.tap(find.text('Age Range'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3-6').last);
      await tester.pumpAndSettle();

      // Generate story
      await tester.tap(find.text('Generate Story'));
      await tester.pumpAndSettle();

      // Wait for story generation
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Assert - Story reader is shown
      expect(find.byType(StoryReaderPage), findsOneWidget);
      expect(find.text('Page 1 of'), findsOneWidget);

      // More assertions...
    });
  });
}
```

## Mocking

### Mockito

Use Mockito to create mock objects for testing.

```dart
// Create a mock class
@GenerateMocks([StoryRepository, AnalyticsService])
void main() {
  // Use the mock in tests
  final mockStoryRepository = MockStoryRepository();
  when(mockStoryRepository.getAllStories())
      .thenAnswer((_) async => [mockStory1, mockStory2]);
}
```

### Fake Implementations

For more complex dependencies, create fake implementations that can be used in tests.

```dart
class FakeStoryRepository implements StoryRepository {
  final List<Story> _stories = [];

  @override
  Future<List<Story>> getAllStories() async {
    return _stories;
  }

  @override
  Future<Story> getStoryById(String id) async {
    return _stories.firstWhere((story) => story.id == id);
  }

  // Add a story to the fake repository
  void addStory(Story story) {
    _stories.add(story);
  }

  // More implementations...
}
```

## Test Coverage

### Coverage Goals

- **Unit Tests**: Aim for 80% coverage of BLoCs, repositories, and services
- **Widget Tests**: Cover all critical UI components
- **Integration Tests**: Cover main user flows

### Running Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Organization

### File Structure

Tests should mirror the structure of the main code:

```
test/
  core/
    services/
      connectivity_service_test.dart
      analytics_service_test.dart
    theme/
      theme_test.dart
  features/
    library/
      data/
        repositories/
          story_repository_impl_test.dart
      presentation/
        bloc/
          library_bloc_test.dart
        widgets/
          story_card_test.dart
    story_generation/
      ...
    story_reader/
      ...
    subscription/
      ...
  integration_test/
    app_test.dart
```

### Naming Conventions

- Test files should end with `_test.dart`
- Test groups should describe the component being tested
- Test names should clearly describe what is being tested

## Best Practices

### General

1. **Test One Thing at a Time**: Each test should focus on testing one specific behavior
2. **Arrange, Act, Assert**: Structure tests with clear sections for setup, action, and verification
3. **Use Descriptive Names**: Test names should clearly describe what is being tested
4. **Keep Tests Independent**: Tests should not depend on the state from other tests
5. **Clean Up After Tests**: Use `tearDown` to clean up resources after tests

### BLoC Testing

1. **Test Initial State**: Verify that the BLoC starts with the expected initial state
2. **Test Event Handling**: Verify that the BLoC handles events correctly
3. **Test State Transitions**: Verify that the BLoC emits the expected states in the correct order
4. **Test Error Handling**: Verify that the BLoC handles errors correctly

### Widget Testing

1. **Test Rendering**: Verify that widgets render correctly
2. **Test Interactions**: Verify that widgets respond correctly to user interactions
3. **Test Edge Cases**: Test widgets with different inputs, including edge cases
4. **Test Accessibility**: Verify that widgets are accessible

### Integration Testing

1. **Test Main Flows**: Focus on testing the main user flows
2. **Test Error Handling**: Verify that the app handles errors gracefully
3. **Test Performance**: Verify that the app performs well under different conditions

## Continuous Integration

### GitHub Actions

Set up GitHub Actions to run tests automatically on every pull request:

```yaml
name: Flutter Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      - run: flutter pub get
      - run: flutter test
```

### Pre-commit Hooks

Set up pre-commit hooks to run tests before committing:

```bash
#!/bin/sh
# .git/hooks/pre-commit

flutter test
```

## Troubleshooting

### Common Issues

1. **Tests Failing Due to Async Operations**: Use `await` and `pumpAndSettle` to wait for async operations to complete
2. **Tests Failing Due to Animations**: Use `pumpAndSettle` to wait for animations to complete
3. **Tests Failing Due to Timeouts**: Increase the timeout for tests that take longer to run

### Debugging Tests

1. **Print Statements**: Use `print` statements to debug tests
2. **Breakpoints**: Use breakpoints in your IDE to debug tests
3. **Test Specific Tests**: Run specific tests to isolate issues

```bash
flutter test test/features/library/presentation/bloc/library_bloc_test.dart
```

## Conclusion

Following these testing guidelines will help ensure that the StoryTales app is thoroughly tested and maintains high quality. Remember that testing is an ongoing process, and tests should be updated as the app evolves.
