import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// A safe wrapper around Firebase Analytics that handles initialization
/// failures gracefully and provides fallback behavior.
/// 
/// This service ensures that analytics-related errors don't crash the app
/// or prevent core functionality from working.
class SafeAnalytics {
  SafeAnalytics._();

  static FirebaseAnalytics? _analytics;
  static bool _isInitialized = false;
  static bool _isAvailable = false;

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
      _isAvailable = true;
      
      if (kDebugMode) {
        debugPrint('[SafeAnalytics] Analytics initialized successfully');
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