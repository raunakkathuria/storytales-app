import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'firebase_options.dart';
import 'package:storytales/core/di/injection_container.dart' as di;
import 'package:storytales/core/services/auth/authentication_service.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/core/theme/theme.dart';
import 'package:storytales/features/library/presentation/bloc/library_bloc.dart';
import 'package:storytales/features/library/presentation/bloc/library_event.dart';
import 'package:storytales/features/library/presentation/pages/library_page.dart';
import 'package:storytales/features/story_generation/presentation/bloc/story_generation_bloc.dart';
import 'package:storytales/features/story_reader/presentation/bloc/story_reader_bloc.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:storytales/features/subscription/presentation/bloc/subscription_event.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Initialize dependency injection
  await di.init();

  // Initialize authentication system
  try {
    final authService = di.sl<AuthenticationService>();
    await authService.initializeAuthentication();
  } catch (e) {
    // Log error but don't prevent app from starting
    final loggingService = di.sl<LoggingService>();
    loggingService.error('Failed to initialize authentication: $e');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

/// The main app widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LibraryBloc>(
          create: (context) => di.sl<LibraryBloc>()..add(const LoadAllStories()),
        ),
        BlocProvider<StoryGenerationBloc>(
          create: (context) => di.sl<StoryGenerationBloc>(),
        ),
        BlocProvider<StoryReaderBloc>(
          create: (context) => di.sl<StoryReaderBloc>(),
        ),
        BlocProvider<SubscriptionBloc>(
          create: (context) => di.sl<SubscriptionBloc>()..add(const CheckSubscription()),
        ),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          title: 'StoryTales',
          debugShowCheckedModeBanner: false,
          theme: StoryTalesTheme.buildThemeData(context),
          home: const LibraryPage(),
        ),
      ),
    );
  }
}
