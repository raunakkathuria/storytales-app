# Firebase Emulators for Local Development

> **⚠️ UPDATED - August 2025**
>
> **Authentication & Firestore Removed**: Firebase Authentication and Firestore have been removed from StoryTales. This document now covers only the remaining Firebase services (Analytics and Crashlytics).

This document provides instructions for setting up and using Firebase emulators for local development and testing of the StoryTales app.

## Overview

Firebase emulators allow you to run local versions of Firebase services. With the current StoryTales configuration, emulators are primarily used for:

- Developing and testing without affecting production Analytics data
- Working offline during development
- Testing crash reporting in a controlled environment

**Note**: Authentication and Firestore emulators are no longer needed since these services have been removed from the app.

## Prerequisites

- Node.js and npm installed
- Firebase CLI installed (`npm install -g firebase-tools`)
- Firebase project configured (should already be set up for the StoryTales project)

## Setup Instructions

### 1. Install Firebase CLI (if not already installed)

```bash
npm install -g firebase-tools
```

### 2. Log in to Firebase

```bash
firebase login
```

### 3. Current Configuration

The current `firebase.json` file is configured for the remaining Firebase services:

```json
{
  "emulators": {
    "ui": {
      "enabled": true,
      "port": 4000
    }
  }
}
```

**Note**: Authentication and Firestore emulator configurations have been removed since these services are no longer used.

## Current Usage

With the simplified Firebase setup, emulators are primarily used for:

1. **Development Environment**: Testing the app without affecting production Analytics data
2. **Offline Development**: Working on core features without internet connectivity
3. **Debugging**: Monitoring Firebase service calls in a controlled environment

## App Configuration

The StoryTales app automatically detects the development environment and configures Firebase services accordingly. The app maintains fallback mechanisms to ensure functionality even when emulators are not running.

## ~~Removed Sections~~

The following sections are no longer applicable since Authentication and Firestore have been removed:

- ~~Email Link Authentication Testing~~
- ~~Firestore Data Management~~
- ~~Authentication Emulator Setup~~
- ~~Firestore Emulator Configuration~~

## Troubleshooting

### Common Issues

1. **Port conflicts**: If you see errors about ports being in use, you can change the ports in `firebase.json`.

2. **Firebase initialization errors**: Ensure Firebase is properly initialized in the app before using any Firebase services.

3. **Analytics not working**: Check that Firebase Analytics is properly configured and the app has the correct Firebase configuration files.

### Logs

Check the emulator logs in the terminal and Flutter console for detailed error information about Firebase service calls.

## Best Practices

1. **Test core features** without Firebase dependencies to ensure app functionality.

2. **Monitor Analytics events** in the Firebase console to verify proper tracking.

3. **Test both development and production** Firebase configurations before releasing.

4. **Keep Firebase configuration files updated** and properly secured.
