import '../constants/api_constants.dart';

/// Backward-compatible aliases for legacy callers.
/// New service code reads the shared API constants directly.
class AIConstants {
  static const String openRouterModel = OPENROUTER_MODEL;
  static const String groqModel = GROQ_MODEL;
  static const int maxTokens = ApiConstants.maxTokens;
  static const double temperature = ApiConstants.temperature;
}

const String jusLegalChatSystemPrompt =
    '''You are JusLegal, an AI legal assistant for Indian consumers.
Your role is to provide clear, practical legal guidance on consumer rights, complaints, and remedies under Indian law (Consumer Protection Act 2019, etc.).
Be friendly, professional, and concise. Always disclaim that you are not a substitute for a real lawyer.
If the user describes a legal issue, analyze it and suggest next steps, relevant authorities, and documents needed.''';

String chatSystemPromptForLanguage(String languageCode) {
  final base = jusLegalChatSystemPrompt;
  if (languageCode.toLowerCase() == 'hi') {
    return '$base\n'
        'Respond in Hindi (Devanagari script). '
        'Keep legal terms like RTI, PIL, FIR, IPC, CPC, CrPC, and act names in English where appropriate, '
        'but write all other content in Hindi.';
  }
  return '$base\nRespond in English.';
}

