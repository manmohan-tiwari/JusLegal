class RateLimitException implements Exception {
  final String message;
  final String providerName;

  RateLimitException(this.message, this.providerName);

  @override
  String toString() => 'RateLimitException: $message (Provider: $providerName)';
}

class ApiKeyException implements Exception {
  final String providerName;

  ApiKeyException(this.providerName);

  @override
  String toString() => 'ApiKeyException: Invalid or missing API key for $providerName';
}

class ParseException implements Exception {
  final String message;

  ParseException(this.message);

  @override
  String toString() => 'ParseException: $message';
}

class AllProvidersFailedException implements Exception {
  final String groqError;
  final String openRouterError;

  AllProvidersFailedException(this.groqError, this.openRouterError);

  @override
  String toString() => 'AllProvidersFailedException: Groq failed with "$groqError", OpenRouter failed with "$openRouterError"';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
