import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App-level configuration values loaded from the local .env file.
class EnvConfig {
  EnvConfig._();

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Ignore missing .env files during startup.
    }
  }

  static bool get isAiAvailable => true;

  static String get siliconflowApiKey =>
      dotenv.env['SILICONFLOW_API_KEY'] ??
      const String.fromEnvironment('SILICONFLOW_API_KEY', defaultValue: '');

  /// Build-time token required by the AI proxy. Do not hard-code it in source.
  static String get proxyAuthToken =>
      dotenv.env['PROXY_AUTH_TOKEN'] ??
      const String.fromEnvironment('PROXY_AUTH_TOKEN', defaultValue: '');

  static void printConfig() {
    if (kDebugMode) {
      debugPrint('[EnvConfig] AI requests use the Cloudflare Worker proxy.');
      debugPrint(
          '[EnvConfig] SiliconFlow key loaded: ${siliconflowApiKey.isNotEmpty}');
    }
  }
}
