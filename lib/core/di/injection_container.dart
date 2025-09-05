import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:storytales/core/config/app_config.dart';
import 'package:storytales/core/config/environment.dart';
import 'package:storytales/core/services/analytics/analytics_service.dart';
import 'package:storytales/core/services/connectivity/connectivity_service.dart';
import 'package:storytales/core/services/image/image_service.dart';
import 'package:storytales/core/services/local_storage/database_service.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/core/services/device/device_service.dart';
import 'package:storytales/core/services/api/user_api_client.dart';
import 'package:storytales/core/services/auth/authentication_service.dart';
import 'package:storytales/features/library/data/repositories/story_repository_impl.dart';
import 'package:storytales/features/library/domain/repositories/story_repository.dart';
import 'package:storytales/features/library/presentation/bloc/library_bloc.dart';
import 'package:storytales/features/story_generation/data/datasources/story_api_client.dart';
import 'package:storytales/features/story_generation/data/repositories/story_generation_repository_impl.dart';
import 'package:storytales/features/story_generation/domain/repositories/story_generation_repository.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_bloc.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_workshop_bloc.dart';
import 'package:storytales/features/story_reader/presentation/bloc/story_reader_bloc.dart';
import 'package:storytales/features/subscription/data/datasources/subscription_local_data_source.dart';
import 'package:storytales/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:storytales/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:storytales/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:storytales/features/profile/domain/repositories/profile_repository.dart';
import 'package:storytales/features/profile/presentation/bloc/profile_bloc.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  final database = await openDatabase(
    join(await getDatabasesPath(), 'storytales.db'),
    onCreate: (db, version) async {
      // Create stories table
      await db.execute(
        '''
        CREATE TABLE stories(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          summary TEXT NOT NULL,
          cover_image_path TEXT NOT NULL,
          created_at TEXT NOT NULL,
          author TEXT NOT NULL,
          age_range TEXT,
          reading_time TEXT NOT NULL,
          original_prompt TEXT,
          genre TEXT,
          theme TEXT,
          is_pregenerated INTEGER NOT NULL,
          is_favorite INTEGER NOT NULL,
          user_id INTEGER DEFAULT 0,
          story_type TEXT DEFAULT 'pregenerated',
          cache_updated_at TEXT,
          cache_expires_at TEXT
        )
        ''',
      );

      // Create story pages table
      await db.execute(
        '''
        CREATE TABLE story_pages(
          id TEXT PRIMARY KEY,
          story_id TEXT NOT NULL,
          page_number INTEGER NOT NULL,
          content TEXT NOT NULL,
          image_path TEXT NOT NULL,
          FOREIGN KEY (story_id) REFERENCES stories (id) ON DELETE CASCADE
        )
        ''',
      );

      // Create story tags table
      await db.execute(
        '''
        CREATE TABLE story_tags(
          id TEXT PRIMARY KEY,
          story_id TEXT NOT NULL,
          tag TEXT NOT NULL,
          FOREIGN KEY (story_id) REFERENCES stories (id) ON DELETE CASCADE
        )
        ''',
      );

      // Create story questions table
      await db.execute(
        '''
        CREATE TABLE story_questions(
          id TEXT PRIMARY KEY,
          story_id TEXT NOT NULL,
          question_text TEXT NOT NULL,
          question_order INTEGER NOT NULL,
          FOREIGN KEY (story_id) REFERENCES stories (id) ON DELETE CASCADE
        )
        ''',
      );
    },
    version: 2,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Add new columns for user context and caching
        await db.execute('ALTER TABLE stories ADD COLUMN user_id INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE stories ADD COLUMN story_type TEXT DEFAULT "pregenerated"');
        await db.execute('ALTER TABLE stories ADD COLUMN cache_updated_at TEXT');
        await db.execute('ALTER TABLE stories ADD COLUMN cache_expires_at TEXT');
      }
    },
  );
  sl.registerSingleton<Database>(database);

  // Initialize Firebase services
  final firebaseAnalytics = FirebaseAnalytics.instance;
  sl.registerSingleton<FirebaseAnalytics>(firebaseAnalytics);

  final firebaseCrashlytics = FirebaseCrashlytics.instance;
  sl.registerSingleton<FirebaseCrashlytics>(firebaseCrashlytics);



  // Initialize and register LoggingService
  final loggingService = LoggingService();
  loggingService.init();
  sl.registerSingleton<LoggingService>(loggingService);

  // Load and register AppConfig based on the current environment
  loggingService.info('Loading configuration for environment: ${Environment.currentEnvironment}');
  final appConfig = await AppConfig.load(environment: Environment.currentEnvironment);
  loggingService.info('Loaded configuration: $appConfig');
  sl.registerSingleton<AppConfig>(appConfig);

  // Register the real AnalyticsService
  sl.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(analytics: sl<FirebaseAnalytics>()),
  );

  //! Core services
  sl.registerLazySingleton<DatabaseService>(
    () => DatabaseService(),
  );

  // Register Connectivity
  final connectivity = Connectivity();
  sl.registerSingleton<Connectivity>(connectivity);

  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(connectivity: sl()),
  );

  // Register ImageService
  final imageService = ImageService();
  sl.registerSingleton<ImageService>(imageService);

  // Register Device Service
  sl.registerLazySingleton<DeviceService>(
    () => DeviceService(),
  );

  // Register User API Client
  sl.registerLazySingleton<UserApiClient>(
    () => UserApiClient(
      dio: sl(),
      connectivityService: sl(),
      deviceService: sl(),
      appConfig: sl(),
    ),
  );

  // Register Authentication Service
  sl.registerLazySingleton<AuthenticationService>(
    () => AuthenticationService(
      deviceService: sl(),
      userApiClient: sl(),
    ),
  );

  //! Data sources
  // Register Dio with base URL configuration
  final dio = Dio();
  // Configure Dio with the base URL from app config
  dio.options.baseUrl = appConfig.apiBaseUrl;
  dio.options.connectTimeout = Duration(seconds: appConfig.apiTimeoutSeconds);
  dio.options.receiveTimeout = Duration(seconds: appConfig.apiTimeoutSeconds);
  sl.registerSingleton<Dio>(dio);

  sl.registerLazySingleton<StoryApiClient>(
    () => StoryApiClient(
      dio: sl(),
      connectivityService: sl(),
      appConfig: sl(),
    ),
  );

  sl.registerLazySingleton<SubscriptionLocalDataSource>(
    () => SubscriptionLocalDataSource(sharedPreferences: sl()),
  );


  //! Repositories
  sl.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(
      databaseService: sl(),
      storyApiClient: sl(),
    ),
  );

  sl.registerLazySingleton<StoryGenerationRepository>(
    () => StoryGenerationRepositoryImpl(
      userApiClient: sl(),
      authService: sl(),
      storyRepository: sl(),
      subscriptionRepository: sl(),
      analyticsService: sl(),
    ),
  );

  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      localDataSource: sl(),
      profileRepository: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      userApiClient: sl(),
      authenticationService: sl(),
    ),
  );


  //! BLoCs
  sl.registerFactory<LibraryBloc>(
    () => LibraryBloc(
      repository: sl<StoryRepository>(),
      analyticsService: sl<AnalyticsService>(),
    ),
  );

  sl.registerFactory<StoryGenerationBloc>(
    () => StoryGenerationBloc(
      repository: sl<StoryGenerationRepository>(),
      profileRepository: sl<ProfileRepository>(),
      loggingService: sl<LoggingService>(),
    ),
  );

  sl.registerFactory<StoryWorkshopBloc>(
    () => StoryWorkshopBloc(
      storyRepository: sl<StoryGenerationRepository>(),
    ),
  );

  sl.registerFactory<StoryReaderBloc>(
    () => StoryReaderBloc(
      repository: sl<StoryRepository>(),
      analyticsService: sl<AnalyticsService>(),
    ),
  );

  sl.registerFactory<SubscriptionBloc>(
    () => SubscriptionBloc(
      repository: sl<SubscriptionRepository>(),
      analyticsService: sl<AnalyticsService>(),
    ),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      profileRepository: sl<ProfileRepository>(),
      loggingService: sl<LoggingService>(),
    ),
  );

}
