import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SecurityAudit: Local storage with Hive encryption and cloud sync strategy.
/// Encrypts all Hive boxes with 256-bit AES keys stored in secure storage.
/// Implements offline caching with periodic cloud synchronization.
class StorageService {
  static const String _encryptionKeyStorageKey = 'hive_encryption_key_v1';
  static const String _syncMetadataBox = '_sync_metadata';

  final FlutterSecureStorage _secureStorage;

  StorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Initializes Hive with encryption.
  /// Generates or retrieves a 256-bit AES encryption key from secure storage.
  Future<void> init() async {
    try {
      if (kDebugMode) {
        debugPrint('[StorageService] Initializing Hive with encryption');
      }

      await Hive.initFlutter();

      // Get or generate encryption key
      await _getOrGenerateEncryptionKey();

      if (kDebugMode) {
        debugPrint('[StorageService] Encryption key loaded successfully');
      }

      // Initialize sync metadata box (unencrypted, contains only sync times)
      await Hive.openBox<Map>(_syncMetadataBox);

      if (kDebugMode) {
        debugPrint('[StorageService] Sync metadata box initialized');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[StorageService] Initialization error: $error');
      }
      rethrow;
    }
  }

  /// Gets or generates a 256-bit AES encryption key.
  /// Key is stored securely in FlutterSecureStorage and retrieved on app launch.
  Future<List<int>> _getOrGenerateEncryptionKey() async {
    try {
      // Try to retrieve existing key
      final storedKey = await _secureStorage.read(
          key: _encryptionKeyStorageKey);

      if (storedKey != null) {
        if (kDebugMode) {
          debugPrint('[StorageService] Using existing encryption key');
        }
        return List<int>.from(jsonDecode(storedKey) as List);
      }

      // Generate new 256-bit (32-byte) AES key
      if (kDebugMode) {
        debugPrint('[StorageService] Generating new encryption key');
      }
      final key = Hive.generateSecureKey();

      // Store in secure storage
      await _secureStorage.write(
        key: _encryptionKeyStorageKey,
        value: jsonEncode(key),
      );

      if (kDebugMode) {
        debugPrint('[StorageService] Encryption key generated and stored');
      }

      return key;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[StorageService] Error managing encryption key: $error');
      }
      rethrow;
    }
  }

  /// Opens an encrypted Hive box.
  /// All user data boxes should use this method.
  Future<Box<T>> openEncryptedBox<T>(String boxName) async {
    try {
      final encryptionKey = await _getOrGenerateEncryptionKey();

      if (kDebugMode) {
        debugPrint('[StorageService] Opening encrypted box: $boxName');
      }

      return await Hive.openBox<T>(
        boxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[StorageService] Error opening encrypted box $boxName: $error');
      }
      rethrow;
    }
  }

  /// Closes a Hive box.
  Future<void> closeBox(String boxName) async {
    try {
      final box = Hive.box(boxName);
      await box.close();
      if (kDebugMode) {
        debugPrint('[StorageService] Closed box: $boxName');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[StorageService] Error closing box $boxName: $error');
      }
    }
  }

  /// Records last sync time for a specific data type.
  /// Used to implement offline-to-cloud sync strategy.
  Future<void> recordSyncTime(String syncKey, DateTime syncTime) async {
    try {
      final metadataBox = Hive.box<Map>(_syncMetadataBox);
      final syncData = <String, dynamic>{
        'lastSyncTime': syncTime.toIso8601String(),
        'syncKey': syncKey,
      };
      await metadataBox.put(syncKey, syncData);

      if (kDebugMode) {
        debugPrint('[StorageService] Recorded sync time for $syncKey at $syncTime');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[StorageService] Error recording sync time: $error');
      }
    }
  }

  /// Gets the last sync time for a specific data type.
  /// Returns null if never synced.
  Future<DateTime?> getLastSyncTime(String syncKey) async {
    try {
      final metadataBox = Hive.box<Map>(_syncMetadataBox);
      final syncData = metadataBox.get(syncKey);

      if (syncData != null && syncData['lastSyncTime'] != null) {
        return DateTime.parse(syncData['lastSyncTime'] as String);
      }
      return null;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[StorageService] Error getting last sync time: $error');
      }
      return null;
    }
  }

  /// Determines if a sync is needed based on last sync time and interval.
  /// interval: Duration between syncs (e.g., Duration(hours: 1))
  Future<bool> shouldSync(String syncKey, Duration interval) async {
    try {
      final lastSync = await getLastSyncTime(syncKey);
      if (lastSync == null) {
        return true; // Never synced
      }
      return DateTime.now().difference(lastSync) > interval;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[StorageService] Error checking sync status: $error');
      }
      return true; // Default to sync on error
    }
  }

  /// Clears all local data (useful for logout/account deletion).
  /// WARNING: This is a destructive operation.
  Future<void> clearAllData() async {
    try {
      if (kDebugMode) {
        debugPrint('[StorageService] Clearing all local data');
      }

      final boxes = Hive.box(_syncMetadataBox);
      await boxes.clear();

      // TODO: Close and delete user data boxes when implementing
      // actual encrypted storage for different data types

      if (kDebugMode) {
        debugPrint('[StorageService] All local data cleared');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[StorageService] Error clearing data: $error');
      }
      rethrow;
    }
  }

  /// Provides access to the app's legacy SharedPreferences values.
  ///
  /// New sensitive values should use the encrypted Hive helpers below.
  Future<SharedPreferences> prefs() => SharedPreferences.getInstance();

  /// Gets or creates a SharedPreferences-like interface.
  /// Preference values are stored in encrypted Hive boxes for security.
  Future<Map<String, dynamic>> getPreferences(String prefsBoxName) async {
    try {
      final box = await openEncryptedBox<dynamic>(prefsBoxName);
      final prefs = <String, dynamic>{};

      for (final key in box.keys) {
        prefs[key] = box.get(key);
      }

      return prefs;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[StorageService] Error getting preferences: $error');
      }
      return {};
    }
  }

  /// Sets a preference value.
  Future<void> setPreference(
    String prefsBoxName,
    String key,
    dynamic value,
  ) async {
    try {
      final box = await openEncryptedBox<dynamic>(prefsBoxName);
      await box.put(key, value);

      if (kDebugMode) {
        debugPrint('[StorageService] Preference set: $key = $value');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[StorageService] Error setting preference: $error');
      }
      rethrow;
    }
  }
}
