import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    appId: '1:1098590842305:web:7b8a58b4000c5930405340',
    messagingSenderId: '1098590842305',
    projectId: 'juslegal-2196',
    authDomain: 'juslegal-2196.firebaseapp.com',
    storageBucket: 'juslegal-2196.firebasestorage.app',
    measurementId: 'G-978QD9MRZR',
  );
  static const FirebaseOptions android = FirebaseOptions(
    // From google-services.json: api_key[0].current_key
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    // From google-services.json: client[0].client_info.mobilesdk_app_id
    appId: '1:1098590842305:android:b605606e88c2024e405340',
    // From google-services.json: project_info.project_number
    messagingSenderId: '1098590842305',
    // From google-services.json: project_info.project_id
    projectId: 'juslegal-2196',
    // From google-services.json: project_info.storage_bucket
    storageBucket: 'juslegal-2196.firebasestorage.app',
  );
}
