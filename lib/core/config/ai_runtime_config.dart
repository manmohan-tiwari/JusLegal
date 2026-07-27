import 'package:flutter/foundation.dart';

/// Compatibility shim for callers that log AI configuration.
/// Provider credentials and URLs are intentionally server-side only.
class AiRuntimeConfig {
  AiRuntimeConfig._();

  static void logConfig() {
    if (kDebugMode) {
      debugPrint(
          '[AiRuntimeConfig] AI requests use the Cloudflare Worker proxy.');
    }
  }
}
