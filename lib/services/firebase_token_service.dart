import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// SecurityAudit: Manages dynamic Firebase ID tokens for proxy authentication.
/// Replaces static PROXY_AUTH_TOKEN with short-lived, cryptographically signed tokens.
class FirebaseTokenService {
  static final FirebaseTokenService _instance = FirebaseTokenService._internal();

  factory FirebaseTokenService() {
    return _instance;
  }

  FirebaseTokenService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? _cachedToken;
  DateTime? _tokenExpiry;

  /// Gets a valid Firebase ID token, caching when possible.
  /// Returns null if user is not authenticated.
  /// Tokens are automatically refreshed if expired.
  Future<String?> getIdToken() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('[FirebaseTokenService] No authenticated user');
        }
        return null;
      }

      // Use cached token if still valid (refresh 5 minutes before expiry)
      if (_cachedToken != null &&
          _tokenExpiry != null &&
          DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(minutes: 5)))) {
        if (kDebugMode) {
          debugPrint('[FirebaseTokenService] Using cached ID token');
        }
        return _cachedToken;
      }

      // Get fresh token
      if (kDebugMode) {
        debugPrint('[FirebaseTokenService] Fetching fresh ID token');
      }

      final idTokenResult = await currentUser.getIdTokenResult(true);
      _cachedToken = idTokenResult.token;
      _tokenExpiry = idTokenResult.expirationTime;

      if (kDebugMode) {
        debugPrint(
            '[FirebaseTokenService] Token fetched. Expires at: ${idTokenResult.expirationTime}');
      }

      return _cachedToken;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[FirebaseTokenService] Error getting ID token: $error');
      }
      return null;
    }
  }

  /// Clears cached token when user logs out or on auth state changes
  void clearCache() {
    _cachedToken = null;
    _tokenExpiry = null;
    if (kDebugMode) {
      debugPrint('[FirebaseTokenService] Cleared cached token');
    }
  }
}
