class ApiConstants {
  // Groq Settings
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqModel = 'llama-3.3-70b-versatile';

  // OpenRouter Settings
  static const String openrouterBaseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String openrouterModel = 'meta-llama/llama-3.3-70b-instruct:free';
  static const String appName = 'JusLegal';
  static const String appUrl = 'https://juslegal-2196.web.app';

  // Shared Settings
  static const double temperature = 0.2;
  static const int maxTokens = 1200;
  static const int maxRetries = 2;
  static const int retryDelayMs = 1000;

  // API Endpoints
  static const String chatCompletionsEndpoint = '/chat/completions';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static const String contentTypeHeader = 'Content-Type';
  static const String authorizationHeader = 'Authorization';
  static const String httpRefererHeader = 'HTTP-Referer';
  static const String xTitleHeader = 'X-Title';
}
