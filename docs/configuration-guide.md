# StoryTales Configuration Guide

This guide explains how to configure the StoryTales app for different environments and scenarios.

## Environment Configuration

The app supports three environments:
- **Development**: For local development and testing
- **Staging**: For pre-production testing
- **Production**: For the live app

The current environment is set in `lib/core/config/environment.dart`:

```dart
static const String currentEnvironment = development; // or staging, or production
```

## Configuration Files

Each environment has its own configuration file:
- Development: `assets/config/app_config_dev.json`
- Staging: `assets/config/app_config_staging.json`
- Production: `assets/config/app_config.json`

## Key Configuration Options

### API Endpoint

The `apiBaseUrl` setting determines which API endpoint the app will use:

```json
"apiBaseUrl": "http://0.0.0.0:3000"  // Local Docker container
```

For local development with Docker, use `http://0.0.0.0:3000` or `http://localhost:3000`.
For production, use your actual API endpoint.

### Mock Data

The `useMockData` setting controls whether the app uses real API calls or mock data:

```json
"useMockData": true  // Use mock data from assets/data/sample-ai-response.json
```

When `useMockData` is `true`:
- The app will use mock data from `assets/data/sample-ai-response.json` if API calls fail
- The app will still try to connect to the API first if internet is available
- If there's no internet connection, it will automatically fall back to mock data

When `useMockData` is `false`:
- The app will require an internet connection
- If there's no connection, it will show a "No internet connection" error
- No mock data will be used, even if API calls fail

### API Timeout

The `apiTimeoutSeconds` setting controls how long the app will wait for API responses:

```json
"apiTimeoutSeconds": 120  // Wait up to 120 seconds for API responses
```

## Common Configurations

### Local Development with Mock Data

```json
{
  "apiBaseUrl": "http://0.0.0.0:3000",
  "apiTimeoutSeconds": 120,
  "useMockData": true,
  "environment": "development"
}
```

### Local Development with Docker API

```json
{
  "apiBaseUrl": "http://0.0.0.0:3000",
  "apiTimeoutSeconds": 120,
  "useMockData": false,
  "environment": "development"
}
```

### Production with Fallback to Mock Data

```json
{
  "apiBaseUrl": "https://api.storytales.app",
  "apiTimeoutSeconds": 120,
  "useMockData": true,
  "environment": "production"
}
```

### Production without Mock Data

```json
{
  "apiBaseUrl": "https://api.storytales.app",
  "apiTimeoutSeconds": 120,
  "useMockData": false,
  "environment": "production"
}
```

## Firebase Configuration

### Development vs Production

The app automatically detects the environment and configures Firebase accordingly:

**Development Mode (kDebugMode = true):**
- Attempts to connect to Firebase emulators (localhost:9099 for Auth, localhost:8080 for Firestore)
- Falls back to production Firebase if emulators are not available
- Logs connection status for debugging

**Production Mode (kDebugMode = false):**
- Uses production Firebase services directly
- Enhanced security and performance optimizations

### Firebase Emulator Setup

For local development with Firebase emulators:

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Start emulators: `firebase emulators:start --only auth,firestore`
3. The app will automatically connect to emulators in debug mode

### API Key Configuration

**Important:** Never commit actual API keys to version control.

- Production API keys should be configured through secure deployment processes
- Development configurations can use placeholder values
- The app logs API key configuration status (masked for security)

## Troubleshooting

### "No internet connection" Error

If you're seeing a "No internet connection" error:

1. Check if your device has internet access
2. If you're using a local Docker API, make sure it's running
3. Set `useMockData` to `true` in your configuration file to enable fallback to mock data
4. Check the logs for more information about the API connection

### API Connection Issues

If the app is having trouble connecting to the API:

1. Check the logs for the current API endpoint: `Using API endpoint: [url]`
2. Verify that the API is running at that endpoint
3. Try accessing the API directly with a tool like curl or Postman
4. Check if your device can reach the API endpoint (e.g., firewall issues)

### Firebase Connection Issues

If you're having trouble with Firebase:

1. **Emulator Connection Failed:** Check if Firebase emulators are running
2. **Production Connection Issues:** Verify Firebase project configuration
3. **Authentication Problems:** Check Firebase Auth configuration and API keys

### Background Generation Issues

If stories aren't appearing in the library after background generation:

1. Check BLoC state management logs
2. Verify that BackgroundGenerationComplete events are being emitted
3. Ensure library refresh events are being handled properly

## Logging

The app provides comprehensive logging for debugging:

### Configuration Logging
```
Loading configuration for environment: development
Loaded configuration: AppConfig(apiBaseUrl: http://0.0.0.0:3000, apiTimeoutSeconds: 120, useMockData: true, environment: development)
```

### API Client Logging
```
Using API endpoint: http://0.0.0.0:3000
Mock data enabled: true
API key configured: Yes (32 chars)
Making API request to: http://0.0.0.0:3000/story
```

### Firebase Logging
```
🔧 Connected to Firebase emulators for development
🚀 Using production Firebase services
⚠️ Could not connect to emulators, using production Firebase
```

These logs help diagnose configuration and connectivity issues.
