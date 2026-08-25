import 'package:flutter/foundation.dart' show kDebugMode, debugPrint, PlatformDispatcher;
import 'package:flutter/material.dart' show FlutterError;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      _crashlytics = FirebaseCrashlytics.instance;
      _isAvailable = true;
      
      // Load user consent preferences
      final prefs = await SharedPreferences.getInstance();
      _analyticsEnabled = prefs.getBool(_analyticsConsentKey) ?? false;
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
    if (_crashlytics != null) {
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
}