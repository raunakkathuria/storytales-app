import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_workshop_bloc.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_workshop_event.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_workshop_state.dart';
import 'package:storytales/features/library/domain/repositories/story_repository.dart';
import 'package:storytales/features/library/domain/entities/story.dart';

import 'story_generation_background_test.mocks.dart';

// Create additional mocks
class MockLibraryRepository extends Mock implements StoryRepository {}
class MockLoggingService extends Mock implements LoggingService {}

void main() {
  group('Story Workshop System Tests', () {
    late StoryWorkshopBloc bloc;
    late MockStoryGenerationRepository mockStoryRepository;
    late MockLibraryRepository mockLibraryRepository;
    late MockLoggingService mockLoggingService;

    setUp(() {
      // Set up GetIt for testing
      final getIt = GetIt.instance;
      if (!getIt.isRegistered<LoggingService>()) {
        mockLoggingService = MockLoggingService();
        getIt.registerSingleton<LoggingService>(mockLoggingService);
      }

      mockStoryRepository = MockStoryGenerationRepository();
      mockLibraryRepository = MockLibraryRepository();
      bloc = StoryWorkshopBloc(
        storyRepository: mockStoryRepository,
        libraryRepository: mockLibraryRepository,
      );
    });

    tearDown(() {
      bloc.close();
      // Clean up GetIt after each test
      final getIt = GetIt.instance;
      if (getIt.isRegistered<LoggingService>()) {
        getIt.unregister<LoggingService>();
      }
    });

    test('should start with initial state', () {
      expect(bloc.state, equals(const StoryWorkshopInitial()));
    });

    test('should handle multiple story generations', () async {
      // Mock successful story generation
      when(mockStoryRepository.canGenerateStory()).thenAnswer((_) async => true);
      when(mockStoryRepository.generateStory(
        prompt: anyNamed('prompt'),
        ageRange: anyNamed('ageRange'),
        theme: anyNamed('theme'),
        genre: anyNamed('genre'),
      )).thenAnswer((_) async => _createMockStory());
      when(mockLibraryRepository.saveStory(any)).thenAnswer((_) async {});

      // Start first story generation
      bloc.add(const StartStoryGeneration(
        prompt: 'A brave knight',
        ageRange: '6-8 years',
      ));

      // Wait for the first job to be added
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<StoryWorkshopActive>().having(
            (state) => state.activeJobs.length,
            'active jobs count',
            1,
          ),
        ]),
      );

      // Start second story generation
      bloc.add(const StartStoryGeneration(
        prompt: 'A magical dragon',
        ageRange: '3-5 years',
      ));

      // Wait for the second job to be added
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<StoryWorkshopActive>().having(
            (state) => state.activeJobs.length,
            'active jobs count',
            2,
          ),
        ]),
      );
    });

    test('should handle job completion and auto-removal', () async {
      // Mock successful story generation
      when(mockStoryRepository.canGenerateStory()).thenAnswer((_) async => true);
      when(mockStoryRepository.generateStory(
        prompt: anyNamed('prompt'),
        ageRange: anyNamed('ageRange'),
        theme: anyNamed('theme'),
        genre: anyNamed('genre'),
      )).thenAnswer((_) async => _createMockStory());
      when(mockLibraryRepository.saveStory(any)).thenAnswer((_) async {});

      // Start story generation
      bloc.add(const StartStoryGeneration(
        prompt: 'A brave knight',
        ageRange: '6-8 years',
      ));

      // Wait for active state
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<StoryWorkshopActive>().having(
            (state) => state.activeJobs.length,
            'active jobs count',
            1,
          ),
        ]),
      );

      // Complete the job
      final activeState = bloc.state as StoryWorkshopActive;
      final jobId = activeState.activeJobs.keys.first;
      bloc.add(CompleteJob(jobId: jobId));

      // Should return to initial state (auto-removal)
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<StoryWorkshopInitial>(),
        ]),
      );
    });

    test('should handle job failure and retry', () async {
      // Mock story generation failure
      when(mockStoryRepository.canGenerateStory()).thenAnswer((_) async => true);
      when(mockStoryRepository.generateStory(
        prompt: anyNamed('prompt'),
        ageRange: anyNamed('ageRange'),
        theme: anyNamed('theme'),
        genre: anyNamed('genre'),
      )).thenThrow(Exception('Generation failed'));

      // Start story generation
      bloc.add(const StartStoryGeneration(
        prompt: 'A brave knight',
        ageRange: '6-8 years',
      ));

      // Wait for active state then failure
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<StoryWorkshopActive>().having(
            (state) => state.activeJobs.length,
            'active jobs count',
            1,
          ),
          isA<StoryWorkshopActive>().having(
            (state) => state.failedJobs.length,
            'failed jobs count',
            1,
          ),
        ]),
      );

      // Retry the failed job
      final failedState = bloc.state as StoryWorkshopActive;
      final jobId = failedState.failedJobs.keys.first;

      // Mock successful retry
      when(mockStoryRepository.generateStory(
        prompt: anyNamed('prompt'),
        ageRange: anyNamed('ageRange'),
        theme: anyNamed('theme'),
        genre: anyNamed('genre'),
      )).thenAnswer((_) async => _createMockStory());
      when(mockLibraryRepository.saveStory(any)).thenAnswer((_) async {});

      bloc.add(RetryJob(jobId: jobId));

      // Should move back to active jobs
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<StoryWorkshopActive>().having(
            (state) => state.activeJobs.length,
            'active jobs count after retry',
            1,
          ),
        ]),
      );
    });

    test('should handle job dismissal', () async {
      // Mock story generation failure
      when(mockStoryRepository.canGenerateStory()).thenAnswer((_) async => true);
      when(mockStoryRepository.generateStory(
        prompt: anyNamed('prompt'),
        ageRange: anyNamed('ageRange'),
        theme: anyNamed('theme'),
        genre: anyNamed('genre'),
      )).thenThrow(Exception('Generation failed'));

      // Start story generation
      bloc.add(const StartStoryGeneration(
        prompt: 'A brave knight',
        ageRange: '6-8 years',
      ));

      // Wait for failure
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<StoryWorkshopActive>().having(
            (state) => state.activeJobs.length,
            'active jobs count',
            1,
          ),
          isA<StoryWorkshopActive>().having(
            (state) => state.failedJobs.length,
            'failed jobs count',
            1,
          ),
        ]),
      );

      // Dismiss the failed job
      final failedState = bloc.state as StoryWorkshopActive;
      final jobId = failedState.failedJobs.keys.first;
      bloc.add(DismissFailedJob(jobId: jobId));

      // Should return to initial state
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<StoryWorkshopInitial>(),
        ]),
      );
    });

    test('should handle workshop initialization with existing jobs', () {
      final existingActiveJobs = {
        'job1': StoryGenerationJob(
          jobId: 'job1',
          tempStoryId: 'temp1',
          prompt: 'A brave knight',
          ageRange: '6-8 years',
          startTime: DateTime.now(),
          status: StoryJobStatus.generating,
        ),
      };

      final existingFailedJobs = {
        'job2': StoryGenerationJob(
          jobId: 'job2',
          tempStoryId: 'temp2',
          prompt: 'A magical dragon',
          ageRange: '3-5 years',
          startTime: DateTime.now(),
          status: StoryJobStatus.failed,
          error: 'Generation failed',
        ),
      };

      bloc.add(InitializeWorkshop(
        activeJobs: existingActiveJobs,
        failedJobs: existingFailedJobs,
      ));

      expect(
        bloc.stream,
        emitsInOrder([
          isA<StoryWorkshopActive>()
              .having((state) => state.activeJobs.length, 'active jobs', 1)
              .having((state) => state.failedJobs.length, 'failed jobs', 1),
        ]),
      );
    });

    test('should handle subscription limit reached', () async {
      // Mock subscription limit reached
      when(mockStoryRepository.canGenerateStory()).thenAnswer((_) async => false);

      // Start story generation
      bloc.add(const StartStoryGeneration(
        prompt: 'A brave knight',
        ageRange: '6-8 years',
      ));

      // Should remain in initial state (no job created)
      await Future.delayed(const Duration(milliseconds: 100));
      expect(bloc.state, equals(const StoryWorkshopInitial()));
    });

    test('should provide correct job display information', () {
      final job = StoryGenerationJob(
        jobId: 'job1',
        tempStoryId: 'temp1',
        prompt: 'A very long prompt that should be truncated for display purposes',
        ageRange: '6-8 years',
        startTime: DateTime.now(),
        status: StoryJobStatus.generating,
      );

      expect(job.displayTitle, equals('A very long prompt that sho...'));
      expect(job.estimatedTime, equals('2-5 minutes'));
    });

    test('should handle state transitions correctly', () {
      const initialState = StoryWorkshopInitial();
      // StoryWorkshopInitial doesn't have hasJobs property, so we check the type instead
      expect(initialState, isA<StoryWorkshopInitial>());

      final activeState = StoryWorkshopActive(
        activeJobs: {'job1': StoryGenerationJob(
          jobId: 'job1',
          tempStoryId: 'temp1',
          prompt: 'Test',
          startTime: DateTime.now(),
          status: StoryJobStatus.generating,
        )},
        failedJobs: {},
      );
      expect(activeState.hasJobs, isTrue);
      expect(activeState.hasOnlyFailedJobs, isFalse);

      final failedOnlyState = StoryWorkshopActive(
        activeJobs: {},
        failedJobs: {'job1': StoryGenerationJob(
          jobId: 'job1',
          tempStoryId: 'temp1',
          prompt: 'Test',
          startTime: DateTime.now(),
          status: StoryJobStatus.failed,
        )},
      );
      expect(failedOnlyState.hasJobs, isTrue);
      expect(failedOnlyState.hasOnlyFailedJobs, isTrue);
    });
  });
}

/// Helper function to create a mock story for testing
Story _createMockStory() {
  return Story(
    id: 'test-story-id',
    title: 'Test Story',
    summary: 'A test story summary',
    coverImagePath: '/test/path',
    createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    author: 'Test Author',
    ageRange: '6-8 years',
    readingTime: '5 minutes',
    originalPrompt: 'Test prompt',
    genre: 'Adventure',
    theme: 'Friendship',
    isPregenerated: false,
    isFavorite: false,
    pages: [],
    tags: [],
    questions: [],
  );
}
