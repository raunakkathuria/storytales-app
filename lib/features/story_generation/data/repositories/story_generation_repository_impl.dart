import 'package:storytales/core/services/analytics/analytics_service.dart';
import 'package:storytales/features/library/domain/entities/story.dart';
import 'package:storytales/features/library/domain/repositories/story_repository.dart';
import 'package:storytales/features/story_generation/data/datasources/story_api_client.dart';
import 'package:storytales/features/story_generation/domain/repositories/story_generation_repository.dart';
import 'package:storytales/features/subscription/domain/repositories/subscription_repository.dart';

/// Implementation of the [StoryGenerationRepository] interface.
class StoryGenerationRepositoryImpl implements StoryGenerationRepository {
  final StoryApiClient _apiClient;
  final StoryRepository _storyRepository;
  final SubscriptionRepository _subscriptionRepository;
  final AnalyticsService _analyticsService;

  StoryGenerationRepositoryImpl({
    required StoryApiClient apiClient,
    required StoryRepository storyRepository,
    required SubscriptionRepository subscriptionRepository,
    required AnalyticsService analyticsService,
  })  : _apiClient = apiClient,
        _storyRepository = storyRepository,
        _subscriptionRepository = subscriptionRepository,
        _analyticsService = analyticsService;

  @override
  Future<bool> canGenerateStory() async {
    return await _subscriptionRepository.canCreateStory();
  }

  @override
  Future<Story> generateStory({
    required String prompt,
    String? ageRange,
    String? theme,
    String? genre,
  }) async {
    // Check if the user can generate a story
    final canGenerate = await canGenerateStory();
    if (!canGenerate) {
      // Log analytics event for subscription prompt
      await _analyticsService.logSubscriptionPromptShown();
      throw Exception('You have reached the free story limit. Please subscribe to generate more stories.');
    }

    try {
      // Generate story using the API client
      final response = await _apiClient.generateStory(
        prompt: prompt,
        ageRange: ageRange,
        theme: theme,
        genre: genre,
      );

      // Save the generated story to the local database
      final story = await _storyRepository.saveAiGeneratedStory(response);

      // Increment the generated story count
      await _subscriptionRepository.incrementGeneratedStoryCount();

      // Log analytics event for story generation
      await _analyticsService.logStoryGenerated(
        storyId: story.id,
        storyTitle: story.title,
        ageRange: story.ageRange,
        genre: story.genre,
        theme: story.theme,
      );

      return story;
    } catch (e) {
      // Log analytics event for error
      await _analyticsService.logError(
        errorType: 'story_generation_error',
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<int> getFreeStoriesRemaining() async {
    return await _subscriptionRepository.getFreeStoriesRemaining();
  }
}
