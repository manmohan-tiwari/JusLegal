import 'package:flutter/foundation.dart';

/// Client-side configuration deliberately contains no AI provider credentials.
/// AI requests are sent through the Cloudflare Worker; no provider keys are
/// included in the client application.
class EnvConfig {
  EnvConfig._();

  /// Retained for application-startup compatibility.
  static Future<void> initialize() async {}

  static bool get isAiAvailable => true;

  static void printConfig() {
    if (kDebugMode) {
      debugPrint('[EnvConfig] AI requests use the Cloudflare Worker proxy.');
    }
  }
}
