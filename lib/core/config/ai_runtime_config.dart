import 'package:flutter/foundation.dart';
import 'env_config.dart';

/// Runtime configuration for AI services.
/// 
/// This class provides a compatibility layer that delegates to [EnvConfig]
/// for all configuration values. It maintains backward compatibility with
/// existing code while centralizing configuration management.
class AiRuntimeConfig {
  AiRuntimeConfig._();

  /// Whether to use a proxy for AI requests.
  static bool get useProxy => EnvConfig.useProxy;

  /// Base URL for the AI proxy server.
  static String get proxyBaseUrl => EnvConfig.proxyBaseUrl;

  /// Gemini API key.
  static String get geminiApiKey => EnvConfig.geminiApiKey;

  /// Groq API key.
  static String get groqApiKey => EnvConfig.groqApiKey;

  /// OpenRouter API key.
  static String get openRouterApiKey => EnvConfig.openRouterApiKey;

  /// Gemini model name.
  static const String geminiModel = 'gemini-2.0-flash';

  /// Whether the proxy is enabled.
  static bool get proxyEnabled => EnvConfig.proxyEnabled;

  /// Whether direct vendor calls are allowed.
  static bool get allowDirectVendorCalls => EnvConfig.allowDirectVendorCalls;

  /// Log current configuration for debugging.
  static void logConfig() {
    if (!kDebugMode) return;
    
    debugPrint('[AiRuntimeConfig] Proxy Enabled: $proxyEnabled');
    if (proxyEnabled) {
      debugPrint('[AiRuntimeConfig] Proxy URL: $proxyBaseUrl');
    } else {
      debugPrint('[AiRuntimeConfig] Direct calls allowed: $allowDirectVendorCalls');
      debugPrint('[AiRuntimeConfig] Gemini key configured: ${geminiApiKey.isNotEmpty}');
      debugPrint('[AiRuntimeConfig] Groq key configured: ${groqApiKey.isNotEmpty}');
      debugPrint('[AiRuntimeConfig] OpenRouter key configured: ${openRouterApiKey.isNotEmpty}');
    }
  }
}