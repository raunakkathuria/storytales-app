import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:storytales/features/story_generation/domain/repositories/story_generation_repository.dart';
import 'package:storytales/features/profile/domain/repositories/profile_repository.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_bloc.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_event.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_state.dart';

import 'story_generation_timing_test.mocks.dart';

@GenerateMocks([StoryGenerationRepository, ProfileRepository, LoggingService])
void main() {
  group('Story Generation Timing Optimization', () {
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

    test('should start background generation immediately during countdown', () async {
      // Arrange
      when(mockRepository.canGenerateStory()).thenAnswer((_) async => true);
      when(mockRepository.getFreeStoriesRemaining()).thenAnswer((_) async => 5);

      // Track the timing of events
      final events = <String>[];
      final startTime = DateTime.now();

      // Listen to state changes
      bloc.stream.listen((state) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;

        if (state is StoryGenerationCountdown) {
          events.add('countdown_${state.secondsRemaining}_at_${elapsed}ms');
        } else if (state is StoryGenerationInBackground) {
          events.add('background_started_at_${elapsed}ms');
        } else if (state is ShowLoadingCard) {
          events.add('loading_card_shown_at_${elapsed}ms');
        }
      });

      // Act - Start the countdown which should immediately trigger background generation
      bloc.add(const StartGenerationCountdown(
        prompt: 'Test story',
        ageRange: '6-8',
        theme: null,
        genre: null,
      ));

      // Wait for the countdown to complete (3+ seconds)
      await Future.delayed(const Duration(seconds: 4));

      // Assert - Background generation should start very early (within first 200ms)
      expect(events, isNotEmpty);

      // Find when background generation started
      final backgroundStartEvent = events.firstWhere(
        (event) => event.contains('background_started'),
        orElse: () => '',
      );

      expect(backgroundStartEvent, isNotEmpty,
        reason: 'Background generation should have started');

      // Extract timing from the event string
      final timingMatch = RegExp(r'at_(\d+)ms').firstMatch(backgroundStartEvent);
      expect(timingMatch, isNotNull);

      final backgroundStartTime = int.parse(timingMatch!.group(1)!);

      // Background generation should start within 200ms (very quickly)
      expect(backgroundStartTime, lessThan(200),
        reason: 'Background generation should start immediately, not after countdown');

      // Background generation started at ${backgroundStartTime}ms
      // All events: ${events.join(', ')}
    });

    test('should show countdown states while background generation runs', () async {
      // Arrange
      final states = <StoryGenerationState>[];

      bloc.stream.listen((state) {
        states.add(state);
      });

      // Act
      bloc.add(const StartGenerationCountdown(
        prompt: 'Test story',
        ageRange: '6-8',
        theme: null,
        genre: null,
      ));

      // Wait for countdown to complete
      await Future.delayed(const Duration(seconds: 4));

      // Assert - Should have countdown states (3, 2, 1, 0)
      final countdownStates = states.whereType<StoryGenerationCountdown>().toList();
      expect(countdownStates.length, equals(4)); // 3, 2, 1, 0

      // Verify countdown sequence
      expect(countdownStates[0].secondsRemaining, equals(3));
      expect(countdownStates[1].secondsRemaining, equals(2));
      expect(countdownStates[2].secondsRemaining, equals(1));
      expect(countdownStates[3].secondsRemaining, equals(0));

      // Should also have background generation states
      final backgroundStates = states.whereType<StoryGenerationInBackground>().toList();
      expect(backgroundStates, isNotEmpty,
        reason: 'Should have background generation states');

      // Countdown sequence: ${countdownStates.map((s) => s.secondsRemaining).join(', ')}
    });
  });
}
