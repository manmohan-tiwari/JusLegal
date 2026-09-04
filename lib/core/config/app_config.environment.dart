part of 'app_config.dart';

enum EnvironmentType { development, staging, production }

class ConfigurationException implements Exception {
  const ConfigurationException(this.message);

  final String message;

  @override
  String toString() => 'ConfigurationException: $message';
}

class AuthConfig {
  AuthConfig._();

  static const Duration tokenRefreshBeforeExpiry = Duration(minutes: 5);
  static const Duration tokenRefreshRetryDelay = Duration(seconds: 2);
  static const int maxTokenRefreshRetries = 2;
  static const bool persistSession = true;
}

class FeatureFlags {
  FeatureFlags._();

  static bool get aiEnabled => _EnvironmentState.boolValue('FEATURE_AI_ENABLED', true);
  static bool get documentGenerationEnabled =>
      _EnvironmentState.boolValue('FEATURE_DOCUMENT_GENERATION_ENABLED', true);
  static bool get imageGenerationEnabled =>
      _EnvironmentState.boolValue('FEATURE_IMAGE_GENERATION_ENABLED', false);
  static bool get analyticsConsentEnabled =>
      _EnvironmentState.boolValue('FEATURE_ANALYTICS_CONSENT_ENABLED', false);
}

class EnvironmentTypeConfig {
  EnvironmentTypeConfig._();

  static EnvironmentType get current => EnvironmentType.values.firstWhere(
        (type) => type.name == _EnvironmentState.value('JUSLEGAL_ENV', 'production'),
        orElse: () => EnvironmentType.production,
      );
}

class EnvironmentState {
  EnvironmentState._();

  static EnvironmentType get environment => EnvironmentTypeConfig.current;
  static String get workerBaseUrl => _EnvironmentState.value(
        'JUSLEGAL_AI_PROXY_BASE_URL',
        WORKER_BASE_URL,
      );
  static String get websiteUrl => _EnvironmentState.value(
        'WEBSITE_URL',
        environment == EnvironmentType.production
            ? 'https://juslegal-2196.web.app'
            : 'https://juslegal-2196-${environment.name}.web.app',
      );
  static String get firebaseProjectId => _EnvironmentState.value(
        'FIREBASE_PROJECT_ID',
        environment == EnvironmentType.production
            ? 'juslegal-2196'
            : 'juslegal-2196-${environment.name}',
      );
  static String get firebaseAuthDomain => _EnvironmentState.value(
        'FIREBASE_AUTH_DOMAIN',
        '$firebaseProjectId.firebaseapp.com',
      );
  static String get firebaseStorageBucket => _EnvironmentState.value(
        'FIREBASE_STORAGE_BUCKET',
        '$firebaseProjectId.firebasestorage.app',
      );
  static String get firebaseMessagingSenderId =>
      _EnvironmentState.value('FIREBASE_MESSAGING_SENDER_ID', '1098590842305');
  static String get firebaseMeasurementId =>
      _EnvironmentState.value('FIREBASE_MEASUREMENT_ID', 'G-978QD9MRZR');
  static String get defaultCountryCode =>
      _EnvironmentState.value('DEFAULT_COUNTRY_CODE', '+91');

    static bool get isValid =>
      Uri.tryParse(workerBaseUrl)?.hasScheme == true &&
      Uri.tryParse(websiteUrl)?.hasScheme == true &&
      defaultCountryCode.startsWith('+');
}

class _EnvironmentState {
  _EnvironmentState._();

  static Map<String, String> _values = const <String, String>{};

  static void load(Map<String, String> values) {
    _values = Map<String, String>.from(values);
  }

  static String value(String key, String defaultValue) {
    final buildValue = String.fromEnvironment(key);
    final configured = buildValue.isNotEmpty ? buildValue : _values[key];
    return configured?.trim().isNotEmpty == true ? configured!.trim() : defaultValue;
  }

  static bool boolValue(String key, bool defaultValue) {
    final raw = value(key, defaultValue.toString()).toLowerCase();
    if (raw == 'true' || raw == '1' || raw == 'yes') return true;
    if (raw == 'false' || raw == '0' || raw == 'no') return false;
    if (kDebugMode) debugPrint('[EnvConfig] Invalid boolean for $key: $raw');
    return defaultValue;
  }
}