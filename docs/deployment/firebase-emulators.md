# Firebase Emulators for Local Development

This document provides instructions for setting up and using Firebase emulators for local development and testing of the StoryTales app.

## Overview

Firebase emulators allow you to run local versions of Firebase services, which is useful for:

- Developing and testing without affecting production data
- Working offline without an internet connection
- Testing authentication flows without creating real users
- Developing and testing Firestore rules

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

### 3. Initialize Firebase Emulators

In the project root directory:

```bash
firebase init emulators
```

During the initialization, select the following emulators:
- Authentication (for testing sign-in)
- Firestore (for user profiles)

### 4. Configure firebase.json

The `firebase.json` file should include the emulator configuration. Here's an example:

```json
{
  "emulators": {
    "auth": {
      "port": 9099
    },
    "firestore": {
      "port": 8080
    },
    "ui": {
      "enabled": true,
      "port": 4000
    }
  }
}
```

## Running the Emulators

Start the emulators with:

```bash
firebase emulators:start
```

This will start the local emulators with a UI available at http://localhost:4000 by default.

## Connecting the App to Emulators

The StoryTales app is already configured to connect to the Firebase emulators in debug mode. The configuration is in `lib/main.dart`:

```dart
// Connect to Firebase emulators in debug mode
if (kDebugMode) {
  // Connect to Auth emulator
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  // Connect to Firestore emulator
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

## Testing Email Link Authentication

When testing email link authentication with the emulator:

1. Start the emulators with `firebase emulators:start`
2. Run the app in debug mode
3. Navigate to the sign-in screen and enter an email address
4. Check the Authentication emulator UI (http://localhost:4000/auth) to see the email link
5. Click on the link in the emulator UI or copy it to use in your app

## Working with Firestore Data

The Firestore emulator starts with an empty database. You can:

1. Create test data through the emulator UI
2. Let your app create the data as it runs
3. Import/export data for reuse:

```bash
# Export data
firebase emulators:export ./emulator-data

# Start with exported data
firebase emulators:start --import=./emulator-data
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: If you see errors about ports being in use, you can change the ports in `firebase.json`.

2. **Connection refused**: Make sure the emulators are running before starting the app.

3. **Authentication issues**: For email link authentication, make sure to use the link from the emulator UI.

### Logs

Check the emulator logs in the terminal where you started the emulators for detailed error information.

## Best Practices

1. **Use separate test accounts** for development to avoid confusion.

2. **Export emulator data** regularly to preserve your test setup.

3. **Clear emulator data** occasionally to test with a clean state.

4. **Test both with emulators and production** before releasing to ensure everything works in both environments.
