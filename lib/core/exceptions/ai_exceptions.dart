/// SecurityAudit: Exception for user-facing error messages.
/// Contains sanitized error information safe to display to end users.
/// Does NOT include PII, stack traces, or sensitive system details.
class UserFacingException implements Exception {
  final String message;
  final String? category;
  final bool isRetryable;

  UserFacingException(
    this.message, {
    this.category,
    this.isRetryable = false,
  });

  @override
  String toString() => 'UserFacingException: $message';
}

class RateLimitException implements Exception {
  final String message;
  final String providerName;

  RateLimitException(this.message, this.providerName);

  @override
  String toString() => 'RateLimitException: $message (Provider: $providerName)';
}

/// Retained for UI error mapping. Credentials are server-side only.
class ApiKeyException implements Exception {
  final String providerName;

  ApiKeyException(this.providerName);

  @override
  String toString() =>
      'ApiKeyException: Invalid or missing server configuration for $providerName';
}

class AllProvidersFailedException implements Exception {
  final String openRouterError;
  final String groqError;

  AllProvidersFailedException(this.openRouterError, this.groqError);

  @override
  String toString() =>
      'AllProvidersFailedException: OpenRouter failed with "$openRouterError", Groq failed with "$groqError"';
}

class ParseException implements Exception {
  final String message;

  ParseException(this.message);

  @override
  String toString() => 'ParseException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// SecurityAudit: Helper methods for error sanitization and handling.
/// Removes PII and sensitive information from error messages before logging.
class ErrorSanitizer {
  /// Patterns that indicate PII that should be redacted from logs
  static final List<RegExp> _piiPatterns = [
    RegExp(r'\b\d{10}\b'), // Phone numbers
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Emails
    RegExp(r'\b\d{5}[\s-]?\d{5}[\s-]?\d{4}[\s-]?\d{3}[\s-]?\d{2}\b'), // Aadhar-like
    RegExp(r'\b[A-Z]{5}\d{4}[A-Z]{1}\b'), // PAN-like
    RegExp(r'₹[\d,]+'), // Amount in rupees
    RegExp(r'\$[\d,]+'), // Amount in dollars
  ];

  /// Sanitizes error message by removing PII patterns.
  /// Returns a safe message for logging and display.
  static String sanitizeForLog(String errorMessage) {
    String sanitized = errorMessage;
    
    for (final pattern in _piiPatterns) {
      sanitized = sanitized.replaceAll(pattern, '[REDACTED]');
    }
    
    return sanitized;
  }

  /// Converts exceptions to user-facing messages.
  /// Returns appropriate, non-technical message for end users.
  static UserFacingException toUserFacing(Object error) {
    if (error is UserFacingException) {
      return error;
    }

    if (error is RateLimitException) {
      return UserFacingException(
        'Too many requests. Please wait a moment and try again.',
        category: 'rate_limit',
        isRetryable: true,
      );
    }

    if (error is NetworkException) {
      return UserFacingException(
        'Network error. Please check your connection and try again.',
        category: 'network',
        isRetryable: true,
      );
    }

    if (error is ParseException) {
      return UserFacingException(
        'Unable to process AI response. Please try again.',
        category: 'parse_error',
        isRetryable: true,
      );
    }

    if (error is AllProvidersFailedException) {
      return UserFacingException(
        'AI services are temporarily unavailable. Please try again later.',
        category: 'all_providers_failed',
        isRetryable: true,
      );
    }

    if (error is ArgumentError) {
      return UserFacingException(
        error.message ?? 'Invalid input. Please check your entries.',
        category: 'validation_error',
        isRetryable: false,
      );
    }

    // Generic fallback for unknown errors
    return UserFacingException(
      'An unexpected error occurred. Please try again.',
      category: 'unknown_error',
      isRetryable: true,
    );
  }
}
