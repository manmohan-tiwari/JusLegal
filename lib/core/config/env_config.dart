// Unified environment configuration for JusLegal.
//
// All API keys and environment-specific values are loaded via `--dart-define`
// flags at build time. This file provides a single source of truth for
// configuration across the app.
//
// ## Build Instructions
//
// ### Debug (with direct API keys):
// ```bash
// flutter run \
//   --dart-define=GEMINI_API_KEY=your_gemini_key \
//   --dart-define=GROQ_API_KEY=your_groq_key \
//   --dart-define=OPENROUTER_API_KEY=your_openrouter_key
// ```
//
// ### Debug (with proxy):
// ```bash
// flutter run \
//   --dart-define=JUSLEGAL_USE_AI_PROXY=true \
//   --dart-define=JUSLEGAL_AI_PROXY_BASE_URL=https://your-proxy.com/api
// ```
//
// ### Release (Web):
// ```bash
// flutter build web \
//   --dart-define=GEMINI_API_KEY=your_gemini_key \
//   --dart-define=GROQ_API_KEY=your_groq_key \
//   --dart-define=OPENROUTER_API_KEY=your_openrouter_key
// ```
//
// ### Release (Android):
// ```bash
// flutter build appbundle \
//   --dart-define=GEMINI_API_KEY=your_gemini_key \
//   --dart-define=GROQ_API_KEY=your_groq_key \
//   --dart-define=OPENROUTER_API_KEY=your_openrouter_key
// ```


import 'package:flutter/foundation.dart';

/// Configuration status for debugging and validation.
enum ConfigStatus {
  /// All required keys are configured.
  configured,
  
  /// Some keys are missing; using fallback/proxy mode.
  partial,
  
  /// No keys configured; app may not function properly.
  missing,
}

class EnvConfig {
  EnvConfig._();

  // ==================== AI Provider API Keys ====================
  
   /// Google Gemini API key.
   /// Get from: https://aistudio.google.com/apikey
   static const String geminiApiKey = 
       String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

   /// Groq API key.
   /// Get from: https://console.groq.com/keys
   static const String groqApiKey = 
       String.fromEnvironment('GROQ_API_KEY', defaultValue: '');

   /// OpenRouter API key.
   /// Get from: https://openrouter.ai/keys
   static const String openRouterApiKey = 
       String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');

  // ==================== AI Proxy Configuration ====================
  
  /// Whether to use a proxy for AI requests.
  static const bool useProxy = 
      bool.fromEnvironment('JUSLEGAL_USE_AI_PROXY', defaultValue: false);

  /// Base URL for the AI proxy server.
  static const String proxyBaseUrl = 
      String.fromEnvironment('JUSLEGAL_AI_PROXY_BASE_URL', defaultValue: '');

  // ==================== Firebase Configuration ====================
  
  /// Firebase project ID.
  /// This should match your Firebase project.
  static const String firebaseProjectId = 
      String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'juslegal-2196');

  /// Firebase web API key (for web platform).
  /// Get from Firebase Console > Project Settings > General > Your apps > SDK setup and configuration
  static const String firebaseWebApiKey = 
      String.fromEnvironment('FIREBASE_WEB_API_KEY', defaultValue: '');

  /// Firebase web app ID.
  static const String firebaseWebAppId = 
      String.fromEnvironment('FIREBASE_WEB_APP_ID', defaultValue: '');

  /// Firebase Android app ID.
  static const String firebaseAndroidAppId = 
      String.fromEnvironment('FIREBASE_ANDROID_APP_ID', defaultValue: '');

  /// Firebase iOS app ID.
  static const String firebaseIOSAppId = 
      String.fromEnvironment('FIREBASE_IOS_APP_ID', defaultValue: '');

  /// Firebase messaging sender ID.
  static const String firebaseMessagingSenderId = 
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');

  // ==================== Computed Properties ====================

  /// Whether the proxy is enabled (configured and non-empty URL).
  static bool get proxyEnabled => useProxy && proxyBaseUrl.trim().isNotEmpty;

  /// Whether direct vendor calls are allowed.
  /// In release mode, direct calls are only allowed if proxy is not enabled.
  /// In debug mode, direct calls are always allowed if keys are provided.
  static bool get allowDirectVendorCalls {
    if (proxyEnabled) return false;
    return kDebugMode || hasAnyApiKey();
  }

  /// Check if any AI API key is configured.
  static bool hasAnyApiKey() {
    return geminiApiKey.isNotEmpty || 
           groqApiKey.isNotEmpty || 
           openRouterApiKey.isNotEmpty;
  }

  /// Get the overall configuration status.
  static ConfigStatus get configStatus {
    final keyCount = [
      if (geminiApiKey.isNotEmpty) 1 else 0,
      if (groqApiKey.isNotEmpty) 1 else 0,
      if (openRouterApiKey.isNotEmpty) 1 else 0,
    ].reduce((a, b) => a + b);

    if (keyCount >= 2) return ConfigStatus.configured;
    if (keyCount >= 1) return ConfigStatus.partial;
    return ConfigStatus.missing;
  }

  /// Whether Firebase credentials are configured.
  static bool get isFirebaseConfigured {
    // Check if at least the project ID is set to a non-default value
    return firebaseProjectId.isNotEmpty && 
           firebaseProjectId != 'juslegal-2196' || 
           firebaseWebApiKey.isNotEmpty;
  }

  /// Mask a sensitive key showing only the last 4 characters.
  static String _maskKey(String key) {
    if (key.isEmpty) return '(not set)';
    return key.length > 4
        ? '${'*' * (key.length - 4)}${key.substring(key.length - 4)}'
        : '****';
  }

  /// Print configuration status for debugging.
  static void printConfig() {
    if (!kDebugMode) return;
    
    debugPrint('=== EnvConfig ===');
    debugPrint('Config Status: ${configStatus.name}');
    debugPrint('Proxy Enabled: $proxyEnabled');
    if (proxyEnabled) {
      debugPrint('Proxy URL: ${_maskKey(proxyBaseUrl)}');
    }
    debugPrint('Gemini Key: ${_maskKey(geminiApiKey)}');
    debugPrint('Groq Key: ${_maskKey(groqApiKey)}');
    debugPrint('OpenRouter Key: ${_maskKey(openRouterApiKey)}');
    debugPrint('Firebase Project: $firebaseProjectId');
    debugPrint('Firebase Web API Key: ${_maskKey(firebaseWebApiKey)}');
    debugPrint('=================');
  }

  /// Validate that required configuration is present.
  /// Returns a list of missing configuration keys.
  static List<String> validateConfig() {
    final missing = <String>[];
    
    if (geminiApiKey.isEmpty && !proxyEnabled) {
      missing.add('GEMINI_API_KEY');
    }
    if (groqApiKey.isEmpty && !proxyEnabled) {
      missing.add('GROQ_API_KEY');
    }
    if (openRouterApiKey.isEmpty && !proxyEnabled) {
      missing.add('OPENROUTER_API_KEY');
    }
    
    return missing;
  }
}