part of 'app_config.dart';

const String _environmentFile = String.fromEnvironment(
  'JUSLEGAL_ENV_FILE',
  defaultValue: '.env',
);

const String _compileTimeEnvironment = String.fromEnvironment(
  'JUSLEGAL_ENV',
  defaultValue: '',
);
const String _compileTimeGeminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);
const String _compileTimeWebsiteUrl = String.fromEnvironment(
  'WEBSITE_URL',
  defaultValue: '',
);
const String _compileTimeFirebaseProjectId = String.fromEnvironment(
  'FIREBASE_PROJECT_ID',
  defaultValue: '',
);
const String _compileTimeFirebaseAuthDomain = String.fromEnvironment(
  'FIREBASE_AUTH_DOMAIN',
  defaultValue: '',
);
const String _compileTimeFirebaseStorageBucket = String.fromEnvironment(
  'FIREBASE_STORAGE_BUCKET',
  defaultValue: '',
);
const String _compileTimeFirebaseMessagingSenderId = String.fromEnvironment(
  'FIREBASE_MESSAGING_SENDER_ID',
  defaultValue: '',
);
const String _compileTimeFirebaseMeasurementId = String.fromEnvironment(
  'FIREBASE_MEASUREMENT_ID',
  defaultValue: '',
);
const String _compileTimeDefaultCountryCode = String.fromEnvironment(
  'DEFAULT_COUNTRY_CODE',
  defaultValue: '',
);
const String _compileTimeFeatureAiEnabled = String.fromEnvironment(
  'FEATURE_AI_ENABLED',
  defaultValue: '',
);
const String _compileTimeFeatureDocumentGenerationEnabled = String.fromEnvironment(
  'FEATURE_DOCUMENT_GENERATION_ENABLED',
  defaultValue: '',
);
const String _compileTimeFeatureImageGenerationEnabled = String.fromEnvironment(
  'FEATURE_IMAGE_GENERATION_ENABLED',
  defaultValue: '',
);
const String _compileTimeFeatureAnalyticsConsentEnabled = String.fromEnvironment(
  'FEATURE_ANALYTICS_CONSENT_ENABLED',
  defaultValue: '',
);
const String _compileTimeFeaturePerformanceMonitoringEnabled = String.fromEnvironment(
  'FEATURE_PERFORMANCE_MONITORING_ENABLED',
  defaultValue: '',
);
const String _compileTimeFeatureRemoteConfigEnabled = String.fromEnvironment(
  'FEATURE_REMOTE_CONFIG_ENABLED',
  defaultValue: '',
);
const String _compileTimeFeatureUserEngagementTrackingEnabled = String.fromEnvironment(
  'FEATURE_USER_ENGAGEMENT_TRACKING_ENABLED',
  defaultValue: '',
);
const String _compileTimeAnalyticsConsentExpiryDays = String.fromEnvironment(
  'ANALYTICS_CONSENT_EXPIRY_DAYS',
  defaultValue: '',
);

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
      _EnvironmentState.boolValue('FEATURE_ANALYTICS_CONSENT_ENABLED', true);
  static bool get performanceMonitoringEnabled =>
      _EnvironmentState.boolValue('FEATURE_PERFORMANCE_MONITORING_ENABLED', true);
  static bool get remoteConfigEnabled =>
      _EnvironmentState.boolValue('FEATURE_REMOTE_CONFIG_ENABLED', true);
  static bool get userEngagementTrackingEnabled =>
      _EnvironmentState.boolValue('FEATURE_USER_ENGAGEMENT_TRACKING_ENABLED', true);
  static Duration get consentExpiryDuration => Duration(
        days: int.tryParse(_EnvironmentState.value(
              'ANALYTICS_CONSENT_EXPIRY_DAYS',
              '180',
            )) ??
            180,
      );
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
  static String get geminiApiKey =>
      _EnvironmentState.value('GEMINI_API_KEY', '');

  static bool get isValid =>
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
    final buildValue = switch (key) {
      'JUSLEGAL_ENV' => _compileTimeEnvironment,
      'GEMINI_API_KEY' => _compileTimeGeminiApiKey,
      'WEBSITE_URL' => _compileTimeWebsiteUrl,
      'FIREBASE_PROJECT_ID' => _compileTimeFirebaseProjectId,
      'FIREBASE_AUTH_DOMAIN' => _compileTimeFirebaseAuthDomain,
      'FIREBASE_STORAGE_BUCKET' => _compileTimeFirebaseStorageBucket,
      'FIREBASE_MESSAGING_SENDER_ID' => _compileTimeFirebaseMessagingSenderId,
      'FIREBASE_MEASUREMENT_ID' => _compileTimeFirebaseMeasurementId,
      'DEFAULT_COUNTRY_CODE' => _compileTimeDefaultCountryCode,
      'FEATURE_AI_ENABLED' => _compileTimeFeatureAiEnabled,
      'FEATURE_DOCUMENT_GENERATION_ENABLED' =>
        _compileTimeFeatureDocumentGenerationEnabled,
      'FEATURE_IMAGE_GENERATION_ENABLED' => _compileTimeFeatureImageGenerationEnabled,
      'FEATURE_ANALYTICS_CONSENT_ENABLED' =>
        _compileTimeFeatureAnalyticsConsentEnabled,
      'FEATURE_PERFORMANCE_MONITORING_ENABLED' =>
        _compileTimeFeaturePerformanceMonitoringEnabled,
      'FEATURE_REMOTE_CONFIG_ENABLED' => _compileTimeFeatureRemoteConfigEnabled,
      'FEATURE_USER_ENGAGEMENT_TRACKING_ENABLED' =>
        _compileTimeFeatureUserEngagementTrackingEnabled,
      'ANALYTICS_CONSENT_EXPIRY_DAYS' => _compileTimeAnalyticsConsentExpiryDays,
      _ => '',
    };
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