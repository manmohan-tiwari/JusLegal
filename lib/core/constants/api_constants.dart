// ignore: constant_identifier_names
const String WORKER_BASE_URL =
    'https://juslegal-ai-proxy.juslegal-ai.workers.dev';

// ignore: constant_identifier_names
const String OPENROUTER_MODEL = 'openrouter/auto';

// ignore: constant_identifier_names
const String GROQ_MODEL = 'llama-3.3-70b-versatile';

class ApiConstants {
  // Shared Settings
  static const double temperature = 0.2;
  static const int maxTokens = 1200;
  static const int letterMaxTokens = 2400;
  static const int maxRetries = 2;
  static const int retryDelayMs = 1000;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
