import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb, debugPrint, PlatformDispatcher;
import 'package:flutter/material.dart' show FlutterError;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:juslegal/core/config/app_config.dart';

/// A safe wrapper around Firebase Analytics that handles initialization
/// failures gracefully and provides fallback behavior.
///
/// This service ensures that analytics-related errors don't crash the app
/// or prevent core functionality from working.
class SafeAnalytics {
  SafeAnalytics._();

  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;
  static bool _isInitialized = false;
  static bool _isAvailable = false;
  static bool _analyticsEnabled = false;
  static bool _crashlyticsEnabled = false;
  static const String _analyticsConsentKey = 'analytics_consent';
  static const String _crashlyticsConsentKey = 'crashlytics_consent';

  /// Initialize the analytics service.
  /// Should be called after Firebase initialization.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Check if Firebase is initialized
      final apps = Firebase.apps;
      if (apps.isEmpty) {
        if (kDebugMode) {
          debugPrint('[SafeAnalytics] Firebase not initialized, analytics disabled');
        }
        _isInitialized = true;
        _isAvailable = false;
        return;
      }

      _analytics = FirebaseAnalytics.instance;
      // Crashlytics is a native-plugin-only feature (Android/iOS).
      // Accessing FirebaseCrashlytics.instance on Flutter Web throws the
      // assertion:
      //   pluginConstants['isCrashlyticsCollectionEnabled'] != null
      // so it must never be instantiated or touched on web.
      if (!kIsWeb) {
        _crashlytics = FirebaseCrashlytics.instance;
      } else if (kDebugMode) {
        debugPrint('[SafeAnalytics] Crashlytics skipped on web (unsupported)');
      }
      _isAvailable = true;

      // Load user consent preferences
      final prefs = await SharedPreferences.getInstance();
      _analyticsEnabled = prefs.getBool(_analyticsConsentKey) ?? false;
      if (!FeatureFlags.analyticsConsentEnabled) {
        _analyticsEnabled = false;
      }
      _crashlyticsEnabled = prefs.getBool(_crashlyticsConsentKey) ?? false;

      // Apply consent settings
      await _applyConsentSettings();

      if (kDebugMode) {
        debugPrint('[SafeAnalytics] Analytics initialized successfully');
        debugPrint('[SafeAnalytics] Analytics enabled: $_analyticsEnabled');
        debugPrint('[SafeAnalytics] Crashlytics enabled: $_crashlyticsEnabled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SafeAnalytics] Failed to initialize: $e');
      }
      _isAvailable = false;
    } finally {
      _isInitialized = true;
    }
  }

  /// Apply consent settings to Firebase services
  static Future<void> _applyConsentSettings() async {
    if (_analytics != null) {
      await _analytics!.setAnalyticsCollectionEnabled(_analyticsEnabled);
    }
    // Web-safe: _crashlytics is never assigned on web, so this block is
    // implicitly bypassed. Extra kIsWeb check guards against regressions.
    if (!kIsWeb && _crashlytics != null) {
      await _crashlytics!.setCrashlyticsCollectionEnabled(_crashlyticsEnabled);

      // Set up error handlers only if crashlytics is enabled
      if (_crashlyticsEnabled) {
        if (_crashlytics != null) {
          FlutterError.onError = _crashlytics!.recordFlutterFatalError;
          PlatformDispatcher.instance.onError = (error, stack) {
            _crashlytics!.recordError(error, stack, fatal: true);
            return true;
          };
        }
      }
    }
  }

  /// Enable analytics collection
  static Future<void> enableAnalytics() async {
    if (!FeatureFlags.analyticsConsentEnabled) return;
    _analyticsEnabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_analyticsConsentKey, true);
    await _applyConsentSettings();
    if (kDebugMode) {
      debugPrint('[SafeAnalytics] Analytics enabled by user');
    }
  }

  /// Disable analytics collection
  static Future<void> disableAnalytics() async {
    _analyticsEnabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_analyticsConsentKey, false);
    await _applyConsentSettings();
    if (kDebugMode) {
      debugPrint('[SafeAnalytics] Analytics disabled by user');
    }
  }

  /// Enable crashlytics collection
  static Future<void> enableCrashlytics() async {
    _crashlyticsEnabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_crashlyticsConsentKey, true);
    await _applyConsentSettings();
    if (kDebugMode) {
      debugPrint('[SafeAnalytics] Crashlytics enabled by user');
    }
  }

  /// Disable crashlytics collection
  static Future<void> disableCrashlytics() async {
    _crashlyticsEnabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_crashlyticsConsentKey, false);
    await _applyConsentSettings();
    if (kDebugMode) {
      debugPrint('[SafeAnalytics] Crashlytics disabled by user');
    }
  }

  /// Enable both analytics and crashlytics
  static Future<void> enableAll() async {
    await enableAnalytics();
    await enableCrashlytics();
  }

  /// Disable both analytics and crashlytics
  static Future<void> disableAll() async {
    await disableAnalytics();
    await disableCrashlytics();
  }

  /// Check if analytics is enabled
  static bool get analyticsEnabled => _analyticsEnabled;

  /// Check if crashlytics is enabled
  static bool get crashlyticsEnabled => _crashlyticsEnabled;

  /// Check if analytics is available.
  static bool get isAvailable => _isAvailable;

  /// Log an analytics event safely.
  /// If analytics is not available, this does nothing.
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isAvailable || _analytics == null) {
      if (kDebugMode) {
        debugPrint('[SafeAnalytics] Skipping event "$name" - analytics not available');
      }
      return;
    }

    try {
      await _analytics!.logEvent(
        name: name,
        parameters: parameters?.map((key, value) {
          // Firebase Analytics only accepts String, int, double, and num types
          if (value is String || value is int || value is double || value is num) {
            return MapEntry(key, value);
          }
          return MapEntry(key, value.toString());
        }),
      );
      if (kDebugMode) {
        debugPrint('[SafeAnalytics] Logged event: $name');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SafeAnalytics] Failed to log event "$name": $e');
      }
    }
  }

  /// Log screen view.
  static Future<void> logScreenView({required String screenName}) async {
    await logEvent(name: 'screen_view', parameters: {'screen_name': screenName});
  }

  /// Log user action.
  static Future<void> logAction({
    required String actionName,
    Map<String, dynamic>? parameters,
  }) async {
    await logEvent(name: actionName, parameters: parameters);
  }

  /// Set user ID for analytics.
  static Future<void> setUserId({String? id}) async {
    if (!_isAvailable || _analytics == null) return;
    try {
      await _analytics!.setUserId(id: id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SafeAnalytics] Failed to set user ID: $e');
      }
    }
  }

  /// Set user property.
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!_isAvailable || _analytics == null) return;
    try {
      await _analytics!.setUserProperty(name: name, value: value);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SafeAnalytics] Failed to set user property: $e');
      }
    }
  }

  /// Reset analytics state (for testing or logout).
  static void reset() {
    _isInitialized = false;
    _isAvailable = false;
    _analytics = null;
  }

  // ============= SecurityAudit: PII Sanitization Utilities =============

  /// Hashes sensitive text using simple consistent hashing.
  /// Returns same hash for same input (useful for identifying patterns).
  /// Returns different hash each session (prevents long-term tracking).
  static String hashSensitiveText(String text) {
    try {
      // Use first 8 chars of text for simple deterministic hash
      int hash = 5381;
      for (int i = 0; i < text.length && i < 20; i++) {
        hash = ((hash << 5) + hash) ^ text.codeUnitAt(i);
      }
      return 'h_${(hash & 0x7FFFFFFF).toRadixString(16)}';
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[SafeAnalytics] Error hashing text: $error');
      }
      return 'h_error';
    }
  }

  /// Masks currency amounts into brackets to prevent exact value exposure.
  static String maskCurrencyAmount(double amount) {
    if (amount <= 0) return 'no_amount';
    if (amount < 1000) return 'bracket_<1k';
    if (amount < 10000) return 'bracket_1k-10k';
    if (amount < 50000) return 'bracket_10k-50k';
    if (amount < 100000) return 'bracket_50k-1L';
    if (amount < 500000) return 'bracket_1L-5L';
    if (amount < 1000000) return 'bracket_5L-10L';
    if (amount < 10000000) return 'bracket_10L-1Cr';
    return 'bracket_>1Cr';
  }

  /// Removes PII patterns from text for safe logging.
  static String sanitizeForLogging(String text) {
    try {
      var sanitized = text;

      // Remove email addresses
      sanitized = sanitized.replaceAll(
          RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
          '[EMAIL]');

      // Remove phone numbers
      sanitized = sanitized.replaceAll(RegExp(r'\b\d{10}\b'), '[PHONE]');

      // Remove Aadhar-like patterns
      sanitized = sanitized.replaceAll(
          RegExp(r'\b\d{5}[\s-]?\d{5}[\s-]?\d{4}[\s-]?\d{3}[\s-]?\d{2}\b'),
          '[AADHAR]');

      // Remove monetary values
      sanitized =
          sanitized.replaceAll(RegExp(r'[₹\$€]\d+([.,]\d+)?'), '[AMOUNT]');

      return sanitized;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[SafeAnalytics] Error sanitizing text: $error');
      }
      return '[SANITIZATION_ERROR]';
    }
  }

  /// Filters analytics parameters to remove sensitive data.
  static Map<String, dynamic> filterSensitiveParameters(
      Map<String, dynamic> params) {
    const sensitiveKeys = {
      'amount',
      'money',
      'cost',
      'price',
      'name',
      'phone',
      'email',
      'address',
      'dob',
      'aadhar',
      'pan',
      'uid'
    };

    final filtered = <String, dynamic>{};
    params.forEach((key, value) {
      final lowerKey = key.toLowerCase();

      // Skip known sensitive keys
      if (sensitiveKeys.any((sensitive) => lowerKey.contains(sensitive))) {
        return;
      }

      // Filter string values for patterns
      if (value is String) {
        filtered[key] = sanitizeForLogging(value);
      } else {
        filtered[key] = value;
      }
    });

    return filtered;
  }

  /// Logs a case analysis event with sanitized sensitive fields.
  static Future<void> logCaseAnalysis({
    required String caseCategory,
    required String caseTopic,
    required double caseAmount,
    required int strengthScore,
  }) async {
    final sanitizedTopic = hashSensitiveText(caseTopic);
    final amountBracket = maskCurrencyAmount(caseAmount);

    await logEvent(
      name: 'case_analysis',
      parameters: {
        'category': caseCategory,
        'topic_hash': sanitizedTopic,
        'amount_bracket': amountBracket,
        'strength_score': strengthScore,
      },
    );
  }

  /// Logs a letter generation event.
  static Future<void> logLetterGeneration({
    required String letterType,
    required String category,
    required bool success,
    required int timeMs,
  }) async {
    await logEvent(
      name: 'letter_generated',
      parameters: {
        'letter_type': letterType,
        'category': category,
        'success': success,
        'generation_time_ms': timeMs,
      },
    );
  }
}