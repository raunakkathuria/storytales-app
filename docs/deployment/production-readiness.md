# StoryTales Production Readiness Guide

## Introduction

This document provides comprehensive guidance for preparing the StoryTales app for production release to the Apple App Store, Google Play Store, and Huawei AppGallery. It covers the necessary steps to replace mock services with production implementations and meet the requirements of each app store platform.

### Purpose

- Ensure all development/mock services are replaced with production implementations
- Document the requirements for each app store platform
- Provide a checklist for production readiness
- Outline the release process and post-release monitoring

### App Overview

StoryTales is an AI-powered storytelling app for children that includes:
- Story generation with AI integration
- Local storage for generated and pre-bundled stories
- Tab-based library with "All Stories" and "Favorites" views
- Story reader with full-screen immersive experience
- Discussion questions at the end of each story
- Basic subscription model with 2 free stories limit
- Offline access to saved stories

### Current Status

The app has completed Phase 1 development, which focused on delivering a functional MVP with core features. The app currently uses several mock services for development purposes, which need to be replaced with production implementations before release.

## Mock Services Replacement

### 1. Firebase Analytics Implementation

#### Current Implementation

The app currently uses a mock analytics service that logs events to the console instead of sending them to Firebase:

```dart
// In injection_container.dart
// Firebase Analytics is commented out for now since we don't have Firebase set up
// final firebaseAnalytics = FirebaseAnalytics.instance;
// sl.registerSingleton<FirebaseAnalytics>(firebaseAnalytics);

// Instead, use a mock implementation of AnalyticsService
sl.registerLazySingleton<AnalyticsService>(
  () => MockAnalyticsService(logger: sl<LoggingService>()),
);
```

#### Required Changes

1. **Create a Firebase Project**:
   - Go to the [Firebase Console](https://console.firebase.google.com/)
   - Create a new project for StoryTales
   - Add both iOS and Android apps to the project
   - Download configuration files (`GoogleService-Info.plist` for iOS, `google-services.json` for Android)

2. **Add Firebase Configuration Files**:
   - Add `GoogleService-Info.plist` to the iOS project (using Xcode)
   - Add `google-services.json` to the `android/app` directory

3. **Update Dependency Injection**:
   - Uncomment and use the real Firebase Analytics implementation:

   ```dart
   // In injection_container.dart
   final firebaseAnalytics = FirebaseAnalytics.instance;
   sl.registerSingleton<FirebaseAnalytics>(firebaseAnalytics);

   sl.registerLazySingleton<AnalyticsService>(
     () => AnalyticsService(analytics: sl<FirebaseAnalytics>()),
   );
   ```

4. **Configure Firebase in main.dart**:
   - Ensure Firebase is properly initialized before the app starts:

   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     await init(); // Initialize dependency injection
     runApp(const StoryTalesApp());
   }
   ```

5. **Add Firebase Crashlytics** (Recommended):
   - Add the Crashlytics dependency to `pubspec.yaml`:
   ```yaml
   firebase_crashlytics: ^latest_version
   ```
   - Initialize Crashlytics in `main.dart`:
   ```dart
   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
   ```

### 2. Environment Configuration System

#### Current Implementation

The app now includes an environment configuration system that allows for different settings based on the environment (development, staging, production). This system is implemented in the `lib/core/config/` directory and includes:

- `AppConfig` class for holding environment-specific settings
- `Environment` class for defining environment constants
- JSON configuration files for each environment in `assets/config/`

The system is already set up, but the environment is currently set to development:

```dart
// In lib/core/config/environment.dart
static const String currentEnvironment = development;
```

#### Required Changes

1. **Update Environment Setting**:
   - Change the environment setting to production before release:

   ```dart
   // In lib/core/config/environment.dart
   static const String currentEnvironment = production;
   ```

2. **Verify Production Configuration**:
   - Ensure the production configuration file (`assets/config/app_config.json`) contains the correct values:

   ```json
   {
     "apiBaseUrl": "https://api.storytales.app",
     "apiTimeoutSeconds": 120,
     "useMockData": false,
     "environment": "production"
   }
   ```

3. **Remove Development Configurations** (Optional):
   - For added security, you may want to remove development and staging configuration files from the production build:

   ```bash
   # Before building for production
   rm assets/config/app_config_dev.json
   rm assets/config/app_config_staging.json
   ```

4. **Verify API Integration**:
   - Ensure the `StoryApiClient` is properly using the configuration:

   ```dart
   // This should already be implemented
   final response = await _dio.post(
     '${_appConfig.apiBaseUrl}/story',
     // ...
   );
   ```

### 3. Story Generation API

#### Current Implementation

The app currently uses a sample JSON file instead of making real API calls when `useMockData` is set to true:

```dart
// In StoryApiClient.generateStory()
try {
  // API call implementation
  // ...
} catch (e) {
  // Error handling with fallback for development
  _loggingService.error('Error calling API: $e');

  // Check if we should use mock data based on configuration
  if (!_appConfig.useMockData) {
    // In production, we don't want to use mock data, so rethrow the error
    throw Exception('Failed to generate story: $e');
  }

  // Fall back to sample response during development
  final jsonString = await rootBundle.loadString('assets/data/sample-ai-response.json');
  final sampleResponse = json.decode(jsonString);
  // ...
}
```

#### Required Changes

1. **Implement Real API Endpoint**:
   - Deploy a backend service for story generation
   - Secure the API with proper authentication
   - Ensure the API returns data in the same format as the sample JSON

2. **Update API Endpoint in Configuration**:
   - Ensure the production configuration file has the correct API endpoint:

   ```json
   {
     "apiBaseUrl": "https://your-actual-api-endpoint.com",
     "apiTimeoutSeconds": 120,
     "useMockData": false,
     "environment": "production"
   }
   ```

3. **Add API Key**:
   - Add your API key to the headers:

   ```dart
   options: Options(
     headers: {
       'Content-Type': 'application/json',
       'Accept': 'application/json',
       'Authorization': 'Bearer YOUR_API_KEY',
     },
     // ...
   ),
   ```

4. **Error Handling**:
   - Ensure comprehensive error handling for API failures
   - Implement retry logic for transient failures
   - Add logging for API errors

### 3. In-App Purchase Implementation

#### Current Implementation

The subscription functionality is currently stubbed:

```dart
// In SubscriptionBloc._onPurchaseSubscription()
try {
  // In a real implementation, this would call the in-app purchase API
  // For Phase 1, we'll just set the subscription status to active
  await _repository.setSubscriptionStatus(true);

  // ...
}
```

#### Required Changes

1. **Configure Products in App Store Connect and Google Play Console**:
   - Create subscription products in each platform's developer console
   - Use consistent product IDs across platforms (e.g., `monthly_subscription`, `annual_subscription`)

2. **Implement Real In-App Purchase Flow**:
   - Update the `SubscriptionBloc` to use the `in_app_purchase` package:

   ```dart
   Future<void> _onPurchaseSubscription(
     PurchaseSubscription event,
     Emitter<SubscriptionState> emit,
   ) async {
     emit(SubscriptionPurchasing(subscriptionType: event.subscriptionType));

     try {
       // Get the product details
       final productDetails = await _inAppPurchase.queryProductDetails({event.subscriptionId});

       // Purchase the product
       final purchaseParam = PurchaseParam(productDetails: productDetails.first);
       await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

       // Note: The actual purchase completion will be handled in the purchase stream listener
       // See the implementation notes below
     } catch (e) {
       emit(SubscriptionPurchaseFailed(error: e.toString()));

       // Log analytics event for error
       await _analyticsService.logError(
         errorType: 'subscription_purchase_error',
         errorMessage: e.toString(),
       );
     }
   }
   ```

3. **Add Purchase Stream Listener**:
   - Add a listener for purchase updates in the `SubscriptionBloc` constructor:

   ```dart
   SubscriptionBloc({
     required SubscriptionRepository repository,
     required AnalyticsService analyticsService,
     required InAppPurchase inAppPurchase,
   })  : _repository = repository,
         _analyticsService = analyticsService,
         _inAppPurchase = inAppPurchase,
         super(const SubscriptionInitial()) {
     // ...

     // Listen for purchase updates
     _purchaseStreamSubscription = _inAppPurchase.purchaseStream.listen(
       (purchases) {
         _handlePurchaseUpdates(purchases);
       },
       onError: (error) {
         // Handle purchase stream errors
       },
     );
   }
   ```

4. **Implement Receipt Validation**:
   - Add server-side receipt validation for security
   - For iOS, validate receipts with the App Store
   - For Android, validate purchases with Google Play

5. **Update Restore Purchases Functionality**:
   - Implement real restore purchases functionality:

   ```dart
   Future<void> _onRestoreSubscription(
     RestoreSubscription event,
     Emitter<SubscriptionState> emit,
   ) async {
     emit(const SubscriptionRestoring());

     try {
       // Restore purchases
       await _inAppPurchase.restorePurchases();

       // Note: The actual restoration will be handled in the purchase stream listener
       // This just initiates the process
     } catch (e) {
       emit(SubscriptionRestoreFailed(error: e.toString()));

       // Log analytics event for error
       await _analyticsService.logError(
         errorType: 'subscription_restore_error',
         errorMessage: e.toString(),
       );
     }
   }
   ```

## Platform-Specific Requirements

### Apple App Store Requirements

#### Account and Setup

1. **Apple Developer Account**:
   - Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year)
   - Complete all legal agreements
   - Set up a team if applicable

2. **App Store Connect Setup**:
   - Create a new app in App Store Connect
   - Configure app information (name, bundle ID, SKU)
   - Set up app pricing and availability

3. **Xcode Configuration**:
   - Update iOS deployment target (recommend iOS 14+)
   - Configure app capabilities (in-app purchase)
   - Set up app groups if needed
   - Configure signing certificates and provisioning profiles

#### App Store Submission Requirements

1. **App Information**:
   - App name and subtitle
   - Keywords (for search optimization)
   - Description (primary and promotional)
   - Support URL and marketing URL
   - Privacy policy URL (required)

2. **Visual Assets**:
   - App icon (1024x1024 pixels)
   - Screenshots for different device sizes:
     - iPhone (6.5", 5.5", and 4.7" displays)
     - iPad (12.9" and 9.7" displays)
   - App preview videos (optional but recommended)

3. **App Review Guidelines Compliance**:
   - 4.2 Minimum Functionality (ensure app is complete)
   - 3.1.1 In-App Purchase (proper implementation)
   - 5.1.4 Kids Category (if applicable)
   - 1.3 Children's Apps (COPPA compliance)

4. **App Privacy Details**:
   - Complete privacy questionnaire in App Store Connect
   - Disclose all data collection practices
   - Provide privacy nutrition label information

5. **Build Submission**:
   - Generate an archive using Xcode
   - Upload the build to App Store Connect
   - Submit for review

### Google Play Store Requirements

#### Account and Setup

1. **Google Play Developer Account**:
   - Register for a [Google Play Developer account](https://play.google.com/console/signup) ($25 one-time fee)
   - Complete account details and payment information
   - Accept developer agreement

2. **Google Play Console Setup**:
   - Create a new app in the Google Play Console
   - Configure app details (name, default language)
   - Set up app categorization

3. **Android App Signing**:
   - Generate upload key
   - Configure key.properties
   - Set up Play App Signing (recommended)

#### Play Store Submission Requirements

1. **App Information**:
   - App title and short description
   - Full description
   - Categorization and tags
   - Contact details (email, website, phone)
   - Privacy policy URL (required)

2. **Visual Assets**:
   - App icon (512x512 pixels)
   - Feature graphic (1024x500 pixels)
   - Screenshots (minimum 2):
     - Phone screenshots (16:9 aspect ratio)
     - Tablet screenshots (16:9 aspect ratio)
   - Promo video (optional but recommended)

3. **Content Rating**:
   - Complete the content rating questionnaire
   - Ensure appropriate rating for children's content
   - Declare target audience age range

4. **Data Safety Section**:
   - Disclose all data collection practices
   - Specify how data is used and shared
   - Identify security practices

5. **Build Submission**:
   - Generate a signed app bundle:
     ```bash
     flutter build appbundle --release
     ```
   - Upload the app bundle to the Google Play Console
   - Set up testing tracks (internal, closed, open)
   - Submit for review

### Huawei AppGallery Requirements

#### Account and Setup

1. **Huawei Developer Account**:
   - Register for a [Huawei Developer account](https://developer.huawei.com/consumer/en/console)
   - Complete account verification
   - Accept developer agreement

2. **AppGallery Connect Setup**:
   - Create a new app in AppGallery Connect
   - Configure app information
   - Set up app categorization

3. **HMS Core Integration**:
   - Replace Google services with HMS equivalents
   - Implement HMS In-App Purchases instead of Google's
   - Use HMS Analytics instead of Firebase

#### AppGallery Submission Requirements

1. **App Information**:
   - App name and introduction
   - Detailed description
   - App classification and tags
   - Developer information
   - Privacy policy URL (required)

2. **Visual Assets**:
   - App icon (1024x1024 pixels)
   - Feature graphic (1080x720 pixels)
   - Screenshots (minimum 2):
     - Phone screenshots
     - Tablet screenshots (if applicable)
   - Promo video (optional)

3. **Content Rating**:
   - Complete the content rating questionnaire
   - Ensure appropriate rating for children's content

4. **Build Submission**:
   - Create a Huawei-specific flavor
   - Generate a signed APK:
     ```bash
     flutter build apk --flavor huawei --release
     ```
   - Upload the APK to AppGallery Connect
   - Submit for review

## Pre-Release Checklist

### Final Testing

1. **Functional Testing**:
   - Verify all features work as expected
   - Test on multiple device sizes and OS versions
   - Verify offline functionality
   - Test subscription flow with sandbox accounts

2. **Performance Testing**:
   - Check app startup time
   - Verify smooth animations and transitions
   - Test memory usage during extended use
   - Verify battery consumption is reasonable

3. **Security Testing**:
   - Verify secure storage of sensitive data
   - Test subscription validation
   - Ensure proper error handling
   - Verify network security

4. **Usability Testing**:
   - Conduct user testing with target audience
   - Verify accessibility features
   - Check text readability on all screens
   - Verify intuitive navigation

### Optimization

1. **Performance Optimization**:
   - Reduce app size by optimizing assets
   - Implement lazy loading where appropriate
   - Optimize database queries
   - Reduce memory usage

2. **Battery Optimization**:
   - Minimize background processes
   - Optimize network requests
   - Reduce unnecessary animations
   - Implement proper wake locks

3. **Storage Optimization**:
   - Implement proper caching strategies
   - Clean up temporary files
   - Optimize database schema
   - Reduce app size

### Compliance Verification

1. **Privacy Compliance**:
   - COPPA (Children's Online Privacy Protection Act)
   - GDPR (General Data Protection Regulation)
   - CCPA (California Consumer Privacy Act)
   - App store-specific privacy requirements

2. **Accessibility Compliance**:
   - Screen reader compatibility
   - Sufficient color contrast
   - Proper text scaling
   - Touch target sizes

3. **Content Compliance**:
   - Age-appropriate content
   - No offensive material
   - Proper content ratings
   - Appropriate advertising (if applicable)

## Release Process

### Build Generation

1. **iOS Build**:
   ```bash
   flutter build ipa --release
   ```

2. **Android Build**:
   ```bash
   flutter build appbundle --release
   ```

3. **Huawei Build**:
   ```bash
   flutter build apk --flavor huawei --release
   ```

### Submission Workflow

1. **Apple App Store**:
   - Upload build using Xcode or Transporter
   - Complete App Store Connect information
   - Submit for review
   - Typical review time: 1-3 days

2. **Google Play Store**:
   - Upload app bundle to Google Play Console
   - Complete store listing information
   - Submit for review
   - Typical review time: 1-2 days

3. **Huawei AppGallery**:
   - Upload APK to AppGallery Connect
   - Complete app information
   - Submit for review
   - Typical review time: 1-3 days

### Phased Rollout Strategy

1. **Internal Testing**:
   - Release to internal team members
   - Verify production configuration
   - Test on production environment

2. **Closed Beta**:
   - Release to limited external testers
   - Gather feedback on real-world usage
   - Monitor for crashes and issues

3. **Open Beta**:
   - Expand to larger test audience
   - Final validation before full release
   - Last opportunity for major changes

4. **Staged Rollout**:
   - Release to 10% of users initially
   - Gradually increase to 25%, 50%, and 100%
   - Monitor metrics at each stage

## Post-Release Monitoring

### Analytics Tracking

1. **Key Metrics to Monitor**:
   - Daily and monthly active users
   - Retention rates (1-day, 7-day, 30-day)
   - Session duration and frequency
   - Conversion rate (free to paid)
   - Story generation success rate

2. **Firebase Analytics Dashboard**:
   - Set up custom dashboards for key metrics
   - Configure alerts for anomalies
   - Track user journey and funnels
   - Monitor subscription events

### Crash Reporting

1. **Firebase Crashlytics**:
   - Monitor crash-free users percentage
   - Investigate top crashes
   - Track crash trends over time
   - Set up alerts for critical crashes

2. **ANR (Application Not Responding)**:
   - Monitor ANR rates
   - Investigate causes of ANRs
   - Implement fixes for common ANRs

### User Feedback Collection

1. **In-App Feedback**:
   - Implement feedback form
   - Collect user ratings
   - Gather feature requests
   - Track common issues

2. **App Store Reviews**:
   - Monitor reviews across all platforms
   - Respond to user reviews
   - Address common complaints
   - Highlight positive feedback

### Update Planning

1. **Hotfix Process**:
   - Prepare for emergency fixes
   - Streamline approval for critical updates
   - Test hotfixes thoroughly
   - Monitor impact of hotfixes

2. **Feature Update Planning**:
   - Prioritize based on user feedback
   - Plan regular update schedule
   - Communicate upcoming features
   - Maintain backward compatibility

## Conclusion

This document provides a comprehensive guide for preparing the StoryTales app for production release. By following these steps, you can ensure that all mock services are replaced with production implementations and that the app meets the requirements of each app store platform.

Remember that app store requirements and best practices evolve over time, so it's important to check the latest documentation from each platform before submission.

## References

- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Developer Policy Center](https://play.google.com/about/developer-content-policy/)
- [Huawei AppGallery Review Guidelines](https://developer.huawei.com/consumer/en/doc/development/AppGallery-connect-Guides/agcappcenterreviewguide-0000001111845114)
- [Flutter Deployment Documentation](https://docs.flutter.dev/deployment)
- [Firebase Documentation](https://firebase.google.com/docs)
- [In-App Purchase Plugin Documentation](https://pub.dev/packages/in_app_purchase)
