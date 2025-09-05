import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_bloc.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_event.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_state.dart';
import 'package:storytales/features/story_generation/domain/repositories/story_generation_repository.dart';
import 'package:storytales/features/profile/domain/repositories/profile_repository.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/features/library/domain/entities/story.dart';

import 'story_generation_background_test.mocks.dart';

@GenerateMocks([StoryGenerationRepository, ProfileRepository, LoggingService])
void main() {
  group('Background Story Generation', () {
    late StoryGenerationBloc bloc;
    late MockStoryGenerationRepository mockRepository;
    late MockProfileRepository mockProfileRepository;
    late MockLoggingService mockLoggingService;

    setUp(() {
      mockRepository = MockStoryGenerationRepository();
      mockProfileRepository = MockProfileRepository();
      mockLoggingService = MockLoggingService();
      bloc = StoryGenerationBloc(
        repository: mockRepository,
        profileRepository: mockProfileRepository,
        loggingService: mockLoggingService,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('should emit countdown states when StartGenerationCountdown is added', () async {
      // Arrange
      const event = StartGenerationCountdown(
        prompt: 'A friendly dragon',
        ageRange: '3-5',
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

    test('should handle background generation flow', () async {
      // Arrange
      final mockStory = Story(
        id: 'test-story-id',
        title: 'Test Story',
        summary: 'A test story',
        coverImagePath: 'test-image.jpg',
        createdAt: DateTime.now(),
        author: 'Test Author',
        ageRange: '6-8',
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
        return mockStory;
      });

      // Act - Directly trigger background generation
      bloc.add(const StartBackgroundGeneration(
        prompt: 'A magical adventure',
        ageRange: '6-8',
      ));

      // Assert - Check that background generation starts
      await expectLater(
        bloc.stream.take(2),
        emitsInOrder([
          isA<StoryGenerationInBackground>(),
          isA<ShowLoadingCard>(),
        ]),
      );
    });
  });
}
