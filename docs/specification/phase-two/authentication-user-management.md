# Authentication & User Management - Phase 2

> **⚠️ DEPRECATED - August 2025**
>
> **This specification is deprecated.** The Firebase Authentication system described in this document has been completely removed from the StoryTales app to prepare for future Supabase JWT authentication implementation.
>
> **Current Status**:
> - ❌ Firebase Authentication system removed
> - ❌ User profiles and account management disabled
> - ❌ Cross-device synchronization postponed
> - ✅ Core storytelling features remain fully functional
>
> **Future Plans**: This functionality will be reimplemented using Supabase JWT authentication when the backend APIs become available.

## Overview

~~The Authentication & User Management feature introduces user accounts to StoryTales, enabling personalized experiences and cross-device synchronization. This document outlines the technical specifications, implementation details, and best practices for this feature.~~

**Historical Note**: This document describes the Firebase Authentication system that was implemented and later removed. It is preserved for reference purposes only.

## Key Components

1. **Firebase Authentication**: Email OTP (one-time password) authentication with persistent sessions
2. **User Profiles**: Cloud-based user data storage with Firestore
3. **Account Management**: Settings screen for profile management and sign-out
4. **Session Management**: Persistent authentication across app restarts and device reboots

## Technical Specifications

### 1. Firebase Authentication Setup

#### 1.1 Dependencies

The implementation requires Firebase Authentication, Firebase Firestore, and supporting packages for handling dynamic links and local storage.

#### 1.2 Firebase Configuration

- Enable Email/Password authentication in Firebase Console
- Set up security rules for Firestore
- Configure Firebase Auth Emulator for local testing

### 2. Authentication Service

The `AuthService` class will handle all authentication-related functionality:

- **Current User Management**: Methods to get the current user and check login status
- **OTP Authentication**: Methods to send OTP codes and verify them for authentication
- **User Profile Management**: Methods to create, retrieve, and update user profiles
- **Session Management**: Methods to handle persistent authentication and sign-out

### 3. User Profile Model

The `UserProfile` model will store user-specific data:

- **Basic Information**: User ID, email, display name, profile photo
- **Preferences**: User-specific settings and preferences
- **Timestamps**: Account creation and last login dates

### 4. Authentication BLoC

The authentication BLoC will manage the authentication state and handle authentication-related events:

#### 4.1 Events
- Check authentication status
- Send OTP code
- Verify OTP code
- Sign out
- Update user profile

#### 4.2 States
- Initial state
- Loading state
- Authenticated state (with user profile)
- Unauthenticated state
- OTP sent state
- OTP verification failed state
- Error state
- Profile update success state

### 5. UI Components

#### 5.1 Email Entry Screen

A screen where users can enter their email address to receive an OTP code:

- Email input field with validation
- Send OTP button
- Error message display
- Loading indicator

#### 5.2 OTP Verification Screen

A screen where users can enter the OTP code they received:

- OTP input field with validation
- Verify OTP button
- Resend OTP option
- Error message display
- Loading indicator

#### 5.3 Profile Settings Screen

A screen where authenticated users can manage their profile:

- Display and edit user information (display name, etc.)
- View account information (email, creation date)
- Sign out option
- Profile update functionality

### 6. Dependency Injection

Update the dependency injection container to include the new authentication services.

### 7. App Initialization

Update the main app to handle authentication state:

- Check authentication state on app start
- Navigate to appropriate screens based on authentication state

## Security Considerations

1. **Token Management**: Secure handling of authentication tokens
2. **Session Persistence**: Appropriate persistence settings for authentication state
3. **Firestore Security Rules**: Proper rules to restrict data access to authenticated users
4. **Error Handling**: Comprehensive error handling for authentication failures

## User Experience Guidelines

1. **Seamless Authentication**: Minimize friction in the authentication process
2. **Persistent Sessions**: Keep users logged in across app restarts
3. **Clear Feedback**: Provide clear feedback during authentication processes
4. **Error Recovery**: Easy recovery paths for authentication errors

## Testing Strategy

1. **Unit Tests**: Test authentication service and BLoC
2. **Widget Tests**: Test authentication UI components
3. **Integration Tests**: Test the complete authentication flow
4. **Security Tests**: Verify security rules and token handling

## Implementation Timeline

1. **Week 1**: Firebase project setup and configuration
2. **Week 2**: OTP-based authentication implementation
3. **Week 3**: Persistent authentication and user profiles
4. **Week 4**: Account management and settings screen

## Future Considerations

1. **Additional Authentication Methods**: Potential to add Google/Apple sign-in later
2. **Multi-Device Management**: Tracking and managing user sessions across devices
3. **Account Recovery**: Additional account recovery options
4. **Enhanced Security**: Additional security features like biometric authentication
