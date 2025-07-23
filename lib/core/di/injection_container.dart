import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:storytales/features/library/data/repositories/story_repository_impl.dart';
import 'package:storytales/features/library/domain/repositories/story_repository.dart';
import 'package:storytales/features/library/presentation/bloc/library_bloc.dart';
import 'package:storytales/features/story_generation/data/datasources/story_api_client.dart';
import 'package:storytales/features/story_generation/data/repositories/story_generation_repository_impl.dart';
import 'package:storytales/features/story_generation/domain/repositories/story_generation_repository.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_bloc.dart';
import 'package:storytales/features/story_reader/presentation/bloc/story_reader_bloc.dart';
import 'package:storytales/features/subscription/data/datasources/subscription_local_data_source.dart';
import 'package:storytales/features/authentication/data/datasources/auth_data_source.dart';
import 'package:storytales/features/authentication/data/datasources/firebase_auth_data_source.dart';
import 'package:storytales/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:storytales/features/authentication/domain/repositories/auth_repository.dart';
import 'package:storytales/features/authentication/domain/usecases/get_current_user.dart';
import 'package:storytales/features/authentication/domain/usecases/get_stored_email.dart';
import 'package:storytales/features/authentication/domain/usecases/is_authenticated.dart';
import 'package:storytales/features/authentication/domain/usecases/is_sign_in_link.dart';
import 'package:storytales/features/authentication/domain/usecases/send_otp_to_email.dart';
import 'package:storytales/features/authentication/domain/usecases/send_sign_in_link_to_email.dart';
import 'package:storytales/features/authentication/domain/usecases/sign_in_with_email_link.dart';
import 'package:storytales/features/authentication/domain/usecases/sign_out.dart';
import 'package:storytales/features/authentication/domain/usecases/update_user_profile.dart';
import 'package:storytales/features/authentication/domain/usecases/verify_otp.dart';
import 'package:storytales/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:storytales/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:storytales/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_bloc.dart';

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
          is_favorite INTEGER NOT NULL
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
    version: 1,
  );
  sl.registerSingleton<Database>(database);

  // Initialize Firebase services
  final firebaseAnalytics = FirebaseAnalytics.instance;
  sl.registerSingleton<FirebaseAnalytics>(firebaseAnalytics);

  final firebaseCrashlytics = FirebaseCrashlytics.instance;
  sl.registerSingleton<FirebaseCrashlytics>(firebaseCrashlytics);

  final firebaseAuth = FirebaseAuth.instance;
  sl.registerSingleton<FirebaseAuth>(firebaseAuth);

  final firestore = FirebaseFirestore.instance;
  sl.registerSingleton<FirebaseFirestore>(firestore);


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


  //! Data sources
  // Register Dio
  final dio = Dio();
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

  // Register Authentication data sources
  sl.registerLazySingleton<AuthDataSource>(
    () => FirebaseAuthDataSource(
      firebaseAuth: sl(),
      firestore: sl(),
      sharedPreferences: sl(),
    ),
  );

  //! Repositories
  sl.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(
      databaseService: sl(),
    ),
  );

  sl.registerLazySingleton<StoryGenerationRepository>(
    () => StoryGenerationRepositoryImpl(
      apiClient: sl(),
      storyRepository: sl(),
      subscriptionRepository: sl(),
      analyticsService: sl(),
    ),
  );

  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Register Authentication repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dataSource: sl(),
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

  // Register Authentication use cases
  sl.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<IsAuthenticated>(
    () => IsAuthenticated(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<SendSignInLinkToEmail>(
    () => SendSignInLinkToEmail(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<SignInWithEmailLink>(
    () => SignInWithEmailLink(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<SignOut>(
    () => SignOut(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<UpdateUserProfile>(
    () => UpdateUserProfile(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<IsSignInLink>(
    () => IsSignInLink(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<GetStoredEmail>(
    () => GetStoredEmail(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<SendOtpToEmail>(
    () => SendOtpToEmail(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<VerifyOtp>(
    () => VerifyOtp(sl<AuthRepository>()),
  );

  // Register Authentication BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      getCurrentUser: sl<GetCurrentUser>(),
      isAuthenticated: sl<IsAuthenticated>(),
      sendSignInLinkToEmail: sl<SendSignInLinkToEmail>(),
      signInWithEmailLink: sl<SignInWithEmailLink>(),
      signOut: sl<SignOut>(),
      updateUserProfile: sl<UpdateUserProfile>(),
      isSignInLink: sl<IsSignInLink>(),
      getStoredEmail: sl<GetStoredEmail>(),
      sendOtpToEmail: sl<SendOtpToEmail>(),
      verifyOtp: sl<VerifyOtp>(),
    ),
  );
}
