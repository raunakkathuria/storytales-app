import 'package:flutter_test/flutter_test.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_bloc.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_event.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_state.dart';
import 'package:mockito/mockito.dart';
import 'package:storytales/features/story_generation/domain/repositories/story_generation_repository.dart';

// Mock repository
class MockStoryGenerationRepository extends Mock implements StoryGenerationRepository {}

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
            5,
          ),
          isA<StoryGenerationCountdown>().having(
            (state) => state.secondsRemaining,
            'secondsRemaining',
            4,
          ),
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
          isA<StoryGenerationInBackground>(),
        ]),
      );
    });

    test('should emit StoryGenerationInBackground after countdown completes', () async {
      // Arrange
      const event = StartGenerationCountdown(
        prompt: 'A magical adventure',
        ageRange: '6-8 years',
      );

      // Act
      bloc.add(event);

      // Wait for countdown to complete
      await Future.delayed(const Duration(seconds: 6));

      // Assert
      expect(
        bloc.state,
        isA<StoryGenerationInBackground>()
            .having((state) => state.prompt, 'prompt', 'A magical adventure')
            .having((state) => state.ageRange, 'ageRange', '6-8 years'),
      );
    });
  });
}
