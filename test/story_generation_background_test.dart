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

      // Assert
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<StoryGenerationCountdown>().having(
            (state) => state.secondsRemaining,
            'secondsRemaining',
            3,
          ),
          isA<StoryGenerationCountdown>().having(
            (state) => state.secondsRemaining,
            'secondsRemaining',
            2,
          ),
          isA<StoryGenerationCountdown>().having(
            (state) => state.secondsRemaining,
            'secondsRemaining',
            1,
          ),
          isA<StoryGenerationCountdown>().having(
            (state) => state.secondsRemaining,
            'secondsRemaining',
            0,
          ),
          isA<StoryGenerationInBackground>(),
        ]),
      );
    });

    test('should emit StoryGenerationInBackground after countdown completes', () async {
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

      // Mock the generateStory method to return a valid story for any call
      when(mockRepository.generateStory(
        prompt: anyNamed('prompt'),
        ageRange: anyNamed('ageRange'),
        theme: anyNamed('theme'),
        genre: anyNamed('genre'),
      )).thenAnswer((_) async => mockStory);

      const event = StartGenerationCountdown(
        prompt: 'A magical adventure',
        ageRange: '6-8 years',
      );

      // Act
      bloc.add(event);

      // Wait for countdown to complete (3 seconds + buffer)
      await Future.delayed(const Duration(seconds: 4));

      // Assert
      expect(
        bloc.state,
        isA<BackgroundGenerationComplete>()
            .having((state) => state.story, 'story', isA<Story>()),
      );
    });
  });
}
