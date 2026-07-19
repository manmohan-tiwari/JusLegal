class AIConstants {
  // Groq
  static const String groqModel = 'llama-3.3-70b-versatile';
  static const String groqBaseUrl = 
      'https://api.groq.com/openai/v1/chat/completions';
  
  // OpenRouter  
  static const String openRouterModel = 
      'mistralai/mixtral-8x7b-instruct';
  static const String openRouterBaseUrl = 
      'https://openrouter.ai/api/v1/chat/completions';
  
  // Shared
  static const int maxTokens = 2048;
  static const double temperature = 0.3;
  static const double topP = 0.9;
  static const int timeoutSeconds = 30;
}
