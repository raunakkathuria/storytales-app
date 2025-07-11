# Troubleshooting Guide

This document provides solutions for common issues that developers might encounter when working with the StoryTales app.

## Connectivity Issues

### "No internet connection" Error

**Symptoms:**
- App shows "No internet connection" error when trying to generate a story
- Error occurs even when the device has internet connectivity

**Possible Causes:**
1. Connectivity service is not detecting the network connection correctly
2. The app is configured to require internet connection even when mock data is enabled
3. The API endpoint is not reachable

**Solutions:**

1. **Check Configuration Settings**
   - Verify that the correct configuration file is being loaded based on the environment
   - For development, check `assets/config/app_config_dev.json`
   - Ensure `useMockData` is set to `true` if you want to use mock data when offline

   ```json
   {
     "apiBaseUrl": "http://0.0.0.0:3000",
     "apiTimeoutSeconds": 120,
     "useMockData": true,
     "environment": "development"
   }
   ```

2. **Verify Environment Setting**
   - Check that the environment is set correctly in `lib/core/config/environment.dart`
   - For development, it should be:

   ```dart
   static const String currentEnvironment = development;
   ```

3. **Test API Endpoint**
   - If using a local Docker container, ensure it's running:
   ```bash
   docker ps
   ```
   - Test the API endpoint directly:
   ```bash
   curl -X POST http://0.0.0.0:3000/story -H "Content-Type: application/json" -d '{"age": 8, "character_name": "Test", "description": "Test story"}'
   ```

4. **Check StoryApiClient Implementation**
   - Ensure the connectivity check respects the `useMockData` setting:

   ```dart
   // Check connectivity only if we're not using mock data
   final isConnected = await _connectivityService.isConnected();
   if (!isConnected && !_appConfig.useMockData) {
     throw Exception('No internet connection');
   }
   ```

5. **Enable Logging**
   - Add logging statements to help diagnose the issue:

   ```dart
   _loggingService.info('Using API endpoint: ${_appConfig.apiBaseUrl}');
   _loggingService.info('Mock data enabled: ${_appConfig.useMockData}');
   ```

## UI Issues

### Dialog Buttons Not Aligned Properly

**Symptoms:**
- Buttons in dialogs are not aligned properly
- Buttons appear too large or too small
- Buttons are stacked vertically when they should be side by side

**Possible Causes:**
1. Fixed dimensions are used instead of responsive ones
2. The dialog is not using the responsive components
3. The screen size detection is not working correctly

**Solutions:**

1. **Use ResponsiveButton Component**
   - Replace standard buttons with `ResponsiveButton`:

   ```dart
   // Instead of this:
   ElevatedButton(
     onPressed: () {},
     child: Text('Button'),
   )

   // Use this:
   ResponsiveButton.primary(
     text: 'Button',
     onPressed: () {},
   )
   ```

2. **Use DialogForm for Consistent Dialogs**
   - Use the `DialogForm` component for all form dialogs:

   ```dart
   DialogForm.show(
     context: context,
     title: 'Dialog Title',
     content: Column(
       mainAxisSize: MainAxisSize.min,
       children: [
         // Form fields
       ],
     ),
     primaryActionText: 'Confirm',
     onPrimaryAction: () => handleConfirm(),
     secondaryActionText: 'Cancel',
     onSecondaryAction: () => Navigator.pop(context),
   )
   ```

3. **Check Screen Size Detection**
   - Ensure the screen size detection is working correctly:

   ```dart
   final screenWidth = MediaQuery.of(context).size.width;
   final isSmallScreen = screenWidth < 360; // iPhone SE and similar
   ```

4. **Use LayoutBuilder for Complex Layouts**
   - Use `LayoutBuilder` to adapt layouts based on available space:

   ```dart
   LayoutBuilder(
     builder: (context, constraints) {
       final useVerticalLayout = constraints.maxWidth < 280;
       return useVerticalLayout
           ? Column(children: [/* ... */])
           : Row(children: [/* ... */]);
     },
   )
   ```

### Dialog Dynamic Resizing Issues

**Symptoms:**
- Dialog changes size when content updates (e.g., cycling loading messages)
- Dialog appears to "jump" or resize during animations
- Inconsistent dialog dimensions across different states

**Possible Causes:**
1. Content with variable height is not constrained
2. Text content changes affect overall layout
3. Complex widget nesting creates layout conflicts

**Solutions:**

1. **Fix Content Area Height**
   - Use `SizedBox` with fixed height for variable content:

   ```dart
   SizedBox(
     height: 60, // Fixed height for message area
     width: double.infinity,
     child: Center(
       child: ResponsiveText(
         text: dynamicMessage,
         style: const TextStyle(fontSize: 16),
         textAlign: TextAlign.center,
         maxLines: 3,
         overflow: TextOverflow.ellipsis,
       ),
     ),
   )
   ```

2. **Avoid Complex Layout Constraints**
   - Use simple layout widgets instead of complex nesting:

   ```dart
   // Instead of: LayoutBuilder + ConstrainedBox + IntrinsicHeight
   // Use simple Column with fixed spacing:
   Column(
     mainAxisSize: MainAxisSize.min,
     children: [
       // Fixed height content areas
       SizedBox(height: 80, child: logo),
       SizedBox(height: 24), // Fixed spacing
       SizedBox(height: 60, child: messageArea),
       // ... other elements
     ],
   )
   ```

3. **Prevent Flutter Layout Assertion Errors**
   - Avoid conflicting layout constraints that cause `!semantics.parentDataDirty` errors:

   ```dart
   // Problematic: Multiple competing constraints
   LayoutBuilder(
     builder: (context, constraints) => ConstrainedBox(
       constraints: BoxConstraints(maxHeight: 320),
       child: IntrinsicHeight(
         child: Column(/* ... */),
       ),
     ),
   )

   // Better: Simple, clear constraints
   Column(
     mainAxisSize: MainAxisSize.min,
     children: [/* ... */],
   )
   ```

### Text Overflow or Truncation

**Symptoms:**
- Text is cut off or truncated
- "..." appears at the end of text that should be fully visible
- Text overflows its container

**Possible Causes:**
1. Fixed height containers are used
2. Text is not using `ResponsiveText`
3. Text style is not appropriate for the available space

**Solutions:**

1. **Use ResponsiveText**
   - Replace standard `Text` widgets with `ResponsiveText`:

   ```dart
   // Instead of this:
   Text(
     'Your text here',
     style: TextStyle(fontSize: 16),
   )

   // Use this:
   ResponsiveText(
     text: 'Your text here',
     style: const TextStyle(fontSize: 16),
   )
   ```

2. **Avoid Fixed Height Containers**
   - Allow containers to size based on their content:

   ```dart
   // Instead of this:
   Container(
     height: 50,
     child: Text('Text that might overflow'),
   )

   // Use this:
   Container(
     child: ResponsiveText(text: 'Text that will adapt'),
   )
   ```

3. **Use Appropriate Text Styles**
   - Use smaller text styles for containers with limited space:

   ```dart
   ResponsiveText(
     text: 'Small text for small spaces',
     style: const TextStyle(fontSize: 12),
   )
   ```

4. **Use Flexible or Expanded for Dynamic Sizing**
   - Wrap text in `Flexible` or `Expanded` widgets in row/column layouts:

   ```dart
   Row(
     children: [
       Icon(Icons.info),
       SizedBox(width: 8),
       Flexible(
         child: ResponsiveText(
           text: 'This text will wrap if needed',
           style: const TextStyle(fontSize: 16),
         ),
       ),
     ],
   )
   ```

## State Management Issues

### BLoC Events Not Triggering State Changes

**Symptoms:**
- UI doesn't update when events are dispatched
- BLoC doesn't emit new states
- Actions don't have the expected effect

**Possible Causes:**
1. Event handler is not registered
2. Event handler has an error
3. State comparison is preventing state updates

**Solutions:**

1. **Check Event Registration**
   - Ensure events are properly registered in the BLoC constructor:

   ```dart
   SubscriptionBloc({
     required SubscriptionRepository repository,
     required AnalyticsService analyticsService,
   })  : _repository = repository,
         _analyticsService = analyticsService,
         super(const SubscriptionInitial()) {
     on<GetFreeStoriesRemaining>(_onGetFreeStoriesRemaining);
     on<PurchaseSubscription>(_onPurchaseSubscription);
     on<RestoreSubscription>(_onRestoreSubscription);
     on<RefreshFreeStoriesCount>(_onRefreshFreeStoriesCount); // Don't forget this!
   }
   ```

2. **Add Logging to Event Handlers**
   - Add logging to event handlers to track execution:

   ```dart
   Future<void> _onRefreshFreeStoriesCount(
     RefreshFreeStoriesCount event,
     Emitter<SubscriptionState> emit,
   ) async {
     _loggingService.info('Refreshing free stories count');
     try {
       final freeStoriesRemaining = await _repository.getFreeStoriesRemaining();
       _loggingService.info('Free stories remaining: $freeStoriesRemaining');
       // ...
     } catch (e) {
       _loggingService.error('Error refreshing free stories count: $e');
       // ...
     }
   }
   ```

3. **Check Equatable Implementation**
   - Ensure the state class properly implements `Equatable`:

   ```dart
   class SubscriptionState extends Equatable {
     const SubscriptionState();

     @override
     List<Object?> get props => []; // Override in subclasses
   }

   class FreeStoriesAvailable extends SubscriptionState {
     final int freeStoriesRemaining;
     final int totalFreeStories;

     const FreeStoriesAvailable({
       required this.freeStoriesRemaining,
       required this.totalFreeStories,
     });

     @override
     List<Object?> get props => [freeStoriesRemaining, totalFreeStories];
   }
   ```

4. **Use BlocObserver for Debugging**
   - Implement a custom `BlocObserver` to log all BLoC events and state changes:

   ```dart
   class AppBlocObserver extends BlocObserver {
     final LoggingService _loggingService;

     AppBlocObserver(this._loggingService);

     @override
     void onEvent(Bloc bloc, Object? event) {
       super.onEvent(bloc, event);
       _loggingService.info('${bloc.runtimeType} $event');
     }

     @override
     void onTransition(Bloc bloc, Transition transition) {
       super.onTransition(bloc, transition);
       _loggingService.info('${bloc.runtimeType} $transition');
     }

     @override
     void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
       super.onError(bloc, error, stackTrace);
       _loggingService.error('${bloc.runtimeType} $error $stackTrace');
     }
   }
   ```

   Then register it in `main.dart`:

   ```dart
   void main() {
     // ...
     Bloc.observer = AppBlocObserver(sl<LoggingService>());
     // ...
   }
   ```

## Database Issues

### Stories Not Appearing in Library

**Symptoms:**
- Library is empty even though stories have been generated
- Stories disappear after app restart
- Only some stories appear in the library

**Possible Causes:**
1. Database queries are not returning the expected results
2. Stories are not being saved correctly
3. Database schema has changed

**Solutions:**

1. **Check Database Queries**
   - Add logging to database queries:

   ```dart
   Future<List<StoryModel>> getStories() async {
     _loggingService.info('Getting all stories from database');
     final db = await _getDatabase();
     final List<Map<String, dynamic>> maps = await db.query('stories');
     _loggingService.info('Found ${maps.length} stories in database');
     return List.generate(maps.length, (i) {
       return StoryModel.fromMap(maps[i]);
     });
   }
   ```

2. **Verify Story Saving Logic**
   - Ensure stories are being saved with all required fields:

   ```dart
   Future<void> saveStory(StoryModel story) async {
     _loggingService.info('Saving story to database: ${story.id}');
     final db = await _getDatabase();

     // Begin transaction
     await db.transaction((txn) async {
       // Save story
       await txn.insert(
         'stories',
         story.toDbMap(),
         conflictAlgorithm: ConflictAlgorithm.replace,
       );

       // Save pages
       for (var page in story.pages) {
         await txn.insert(
           'story_pages',
           (page as StoryPageModel).toDbMap(),
           conflictAlgorithm: ConflictAlgorithm.replace,
         );
       }

       // Save questions
       for (var i = 0; i < story.questions.length; i++) {
         await txn.insert(
           'story_questions',
           {
             'id': 'question_${story.id}_$i',
             'story_id': story.id,
             'question_text': story.questions[i],
             'question_order': i,
           },
           conflictAlgorithm: ConflictAlgorithm.replace,
         );
       }
     });

     _loggingService.info('Story saved successfully: ${story.id}');
   }
   ```

3. **Check Database Schema**
   - Verify that the database schema matches the expected schema:

   ```dart
   Future<void> _createTables(Database db) async {
     _loggingService.info('Creating database tables');

     // Create stories table
     await db.execute('''
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
     ''');

     // Create story pages table
     await db.execute('''
       CREATE TABLE story_pages(
         id TEXT PRIMARY KEY,
         story_id TEXT NOT NULL,
         page_number INTEGER NOT NULL,
         content TEXT NOT NULL,
         image_path TEXT NOT NULL,
         FOREIGN KEY (story_id) REFERENCES stories (id) ON DELETE CASCADE
       )
     ''');

     // Create story questions table
     await db.execute('''
       CREATE TABLE story_questions(
         id TEXT PRIMARY KEY,
         story_id TEXT NOT NULL,
         question_text TEXT NOT NULL,
         question_order INTEGER NOT NULL,
         FOREIGN KEY (story_id) REFERENCES stories (id) ON DELETE CASCADE
       )
     ''');

     _loggingService.info('Database tables created successfully');
   }
   ```

4. **Use Database Inspector**
   - Use Flutter DevTools Database Inspector to examine the database:
     1. Run the app in debug mode
     2. Open DevTools
     3. Go to the "Database" tab
     4. Inspect the tables and their contents

## Performance Issues

### Slow App Startup

**Symptoms:**
- App takes a long time to start
- Splash screen is displayed for too long
- Initial animations are choppy

**Possible Causes:**
1. Too much work is being done on the main thread during startup
2. Database operations are blocking the UI thread
3. Assets are not being loaded efficiently

**Solutions:**

1. **Use Isolates for Heavy Computations**
   - Move heavy computations to a separate isolate:

   ```dart
   Future<void> processData() async {
     final result = await compute(heavyComputation, inputData);
     // Use result
   }

   // This function runs in a separate isolate
   List<ProcessedData> heavyComputation(List<RawData> inputData) {
     // Heavy computation
     return processedData;
   }
   ```

2. **Use Background Threads for Database Operations**
   - Ensure database operations are not blocking the UI thread:

   ```dart
   Future<void> initializeDatabase() async {
     // This runs in a background thread
     final database = await openDatabase(
       join(await getDatabasesPath(), 'storytales.db'),
       onCreate: (db, version) async {
         await _createTables(db);
       },
       version: 1,
     );

     // Store the database instance
     _database = database;
   }
   ```

3. **Optimize Asset Loading**
   - Load assets asynchronously and only when needed:

   ```dart
   Future<void> preloadAssets() async {
     // Load only essential assets at startup
     await precacheImage(AssetImage('assets/images/logo.png'), context);

     // Load other assets in the background
     Future.microtask(() async {
       await precacheImage(AssetImage('assets/images/background.png'), context);
       // ...
     });
   }
   ```

4. **Implement Lazy Loading**
   - Load data only when it's needed:

   ```dart
   class LazyLoadingRepository {
     List<Story>? _cachedStories;

     Future<List<Story>> getAllStories() async {
       if (_cachedStories != null) {
         return _cachedStories!;
       }

       // Load stories from database
       final stories = await _databaseService.getStories();
       _cachedStories = stories;
       return stories;
     }
   }
   ```

### Memory Leaks

**Symptoms:**
- App crashes after extended use
- Performance degrades over time
- Memory usage increases steadily

**Possible Causes:**
1. Subscriptions are not being canceled
2. Large objects are being held in memory
3. Circular references are preventing garbage collection

**Solutions:**

1. **Cancel Subscriptions**
   - Always cancel subscriptions in the `dispose` method:

   ```dart
   class _MyWidgetState extends State<MyWidget> {
     late StreamSubscription _subscription;

     @override
     void initState() {
       super.initState();
       _subscription = stream.listen((data) {
         // Handle data
       });
     }

     @override
     void dispose() {
       _subscription.cancel();
       super.dispose();
     }
   }
   ```

2. **Use Weak References**
   - Use weak references for objects that should not prevent garbage collection:

   ```dart
   final weakRef = WeakReference<LargeObject>(largeObject);

   // Later, when you need the object
   final obj = weakRef.target;
   if (obj != null) {
     // Use obj
   }
   ```

3. **Avoid Circular References**
   - Break circular references by using weak references or null out references:

   ```dart
   class Parent {
     Child? child;

     void clearReferences() {
       child = null;
     }
   }

   class Child {
     Parent parent;

     Child(this.parent);
   }
   ```

4. **Use Memory Profiling Tools**
   - Use Flutter DevTools Memory Profiler to identify memory leaks:
     1. Run the app in debug mode
     2. Open DevTools
     3. Go to the "Memory" tab
     4. Take snapshots before and after suspected memory leak
     5. Compare snapshots to identify retained objects

## Conclusion

This troubleshooting guide covers common issues that developers might encounter when working with the StoryTales app. If you encounter an issue that is not covered in this guide, please refer to the project documentation or reach out to the development team for assistance.

Remember to check the logs first when troubleshooting issues, as they often provide valuable information about what's going wrong.
