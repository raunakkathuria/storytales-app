import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_bloc.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_event.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_state.dart';
import 'package:storytales/features/story_generation/domain/repositories/story_generation_repository.dart';
import 'package:storytales/features/library/domain/entities/story.dart';

import 'story_generation_background_test.mocks.dart';

@GenerateMocks([StoryGenerationRepository])
void main() {
  group('Background Story Generation', () {
    late StoryGenerationBloc bloc;
    late MockStoryGenerationRepository mockRepository;

    setUp(() {
      mockRepository = MockStoryGenerationRepository();
      bloc = StoryGenerationBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('should emit countdown states when StartGenerationCountdown is added', () async {
      // Arrange
      const event = StartGenerationCountdown(
        prompt: 'A friendly dragon',
        ageRange: '3-5 years',
      );

      // Act
      bloc.add(event);

      // Assert - The countdown starts, then background generation begins immediately
      // This is the actual behavior: countdown and background generation run in parallel
      await expectLater(
        bloc.stream.take(3), // Take first 3 states
        emitsInOrder([
          isA<StoryGenerationCountdown>().having(
            (state) => state.secondsRemaining,
            'secondsRemaining',
            3,
          ),
          isA<StoryGenerationInBackground>(),
          isA<ShowLoadingCard>(),
        ]),
      );
    });

    test('should complete background generation with story', () async {
      // Arrange
      final mockStory = Story(
        id: 'test-story-id',
        title: 'Test Story',
        summary: 'A test story',
        coverImagePath: 'test-image.jpg',
        createdAt: DateTime.now(),
        author: 'Test Author',
        ageRange: '6-8 years',
        readingTime: '5 minutes',
        originalPrompt: 'A magical adventure',
        genre: 'Fantasy',
        theme: 'Adventure',
        tags: const ['fantasy', 'adventure'],
        isPregenerated: false,
        isFavorite: false,
        pages: const [],
        questions: const [],
      );

      // Mock the generateStory method to return a valid story quickly
      when(mockRepository.generateStory(
        prompt: anyNamed('prompt'),
        ageRange: anyNamed('ageRange'),
        theme: anyNamed('theme'),
        genre: anyNamed('genre'),
      )).thenAnswer((_) async {
        // Add a small delay to simulate API call
        await Future.delayed(const Duration(milliseconds: 200));
        return mockStory;
      });

      const event = StartGenerationCountdown(
        prompt: 'A magical adventure',
        ageRange: '6-8 years',
      );

      // Act
      bloc.add(event);

      // Wait for the background generation to complete
      // The sequence should be: countdown states, background generation, then completion
      await expectLater(
        bloc.stream.where((state) => state is BackgroundGenerationComplete).take(1),
        emits(isA<BackgroundGenerationComplete>()
            .having((state) => state.story, 'story', isA<Story>())),
      );
    });
  });
}
