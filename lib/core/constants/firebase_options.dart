import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:juslegal/core/config/app_config.dart';

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

  static FirebaseOptions get web => FirebaseOptions(
        // Firebase Web API keys identify the Firebase project; access must be
        // protected with Firebase Auth, App Check, and API restrictions.
        apiKey: const String.fromEnvironment(
          'FIREBASE_WEB_API_KEY',
          defaultValue: 'AIzaSyDCf5TS-vM4Dr2JzJpISv2M1CKQnvZmG7M',
        ),
        appId: '1:1098590842305:web:7b8a58b4000c5930405340',
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        projectId: AppConfig.firebaseProjectId,
        authDomain: AppConfig.firebaseAuthDomain,
        storageBucket: AppConfig.firebaseStorageBucket,
        measurementId: AppConfig.firebaseMeasurementId,
      );

  static FirebaseOptions get android => FirebaseOptions(
    // These values come from android/app/google-services.json.
    // They are public Firebase project identifiers, not secrets.
    apiKey: 'AIzaSyBcbXzMdaAMFnowgVALIEJbprzLeSeGDJY',
    appId: '1:1098590842305:android:b605606e88c2024e405340',
    messagingSenderId: AppConfig.firebaseMessagingSenderId,
    projectId: AppConfig.firebaseProjectId,
    storageBucket: AppConfig.firebaseStorageBucket,
  );
}
