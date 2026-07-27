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
