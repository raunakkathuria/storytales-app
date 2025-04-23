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

## Logging

The app logs configuration information when it starts up:

```
Loading configuration for environment: development
Loaded configuration: AppConfig(apiBaseUrl: http://0.0.0.0:3000, apiTimeoutSeconds: 120, useMockData: true, environment: development)
```

When making API calls, it also logs:

```
Using API endpoint: http://0.0.0.0:3000
Mock data enabled: true
```

These logs can help diagnose configuration issues.
