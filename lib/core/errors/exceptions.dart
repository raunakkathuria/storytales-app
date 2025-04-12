/// Base exception class for the app.
abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when there is a network error.
class NetworkException extends AppException {
  NetworkException([super.message = 'Network error occurred']);
}

/// Exception thrown when there is a server error.
class ServerException extends AppException {
  ServerException([super.message = 'Server error occurred']);
}

/// Exception thrown when there is a database error.
class DatabaseException extends AppException {
  DatabaseException([super.message = 'Database error occurred']);
}

/// Exception thrown when a resource is not found.
class NotFoundException extends AppException {
  NotFoundException([super.message = 'Resource not found']);
}

/// Exception thrown when a user has reached the free story limit.
class FreeStoryLimitException extends AppException {
  FreeStoryLimitException(
      [super.message = 'You have reached the free story limit']);
}

/// Exception thrown when a subscription is required.
class SubscriptionRequiredException extends AppException {
  SubscriptionRequiredException(
      [super.message = 'Subscription required to access this feature']);
}

/// Exception thrown when a story generation fails.
class StoryGenerationException extends AppException {
  StoryGenerationException([super.message = 'Failed to generate story']);
}

/// Exception thrown when a subscription purchase fails.
class SubscriptionPurchaseException extends AppException {
  SubscriptionPurchaseException([super.message = 'Failed to purchase subscription']);
}

/// Exception thrown when a subscription restoration fails.
class SubscriptionRestoreException extends AppException {
  SubscriptionRestoreException([super.message = 'Failed to restore subscription']);
}

/// Exception thrown when a validation error occurs.
class ValidationException extends AppException {
  ValidationException([super.message = 'Validation error occurred']);
}

/// Exception thrown when an unexpected error occurs.
class UnexpectedException extends AppException {
  UnexpectedException([super.message = 'An unexpected error occurred']);
}
