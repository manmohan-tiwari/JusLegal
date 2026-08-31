import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ??
            const String.fromEnvironment(
              'FIREBASE_WEB_API_KEY',
              defaultValue: '',
            ),
        appId: '1:1098590842305:web:7b8a58b4000c5930405340',
        messagingSenderId: '1098590842305',
        projectId: 'juslegal-2196',
        authDomain: 'juslegal-2196.firebaseapp.com',
        storageBucket: 'juslegal-2196.firebasestorage.app',
        measurementId: 'G-978QD9MRZR',
      );

  static const FirebaseOptions android = FirebaseOptions(
    // These values come from android/app/google-services.json.
    // They are public Firebase project identifiers, not secrets.
    apiKey: 'AIzaSyBcbXzMdaAMFnowgVALIEJbprzLeSeGDJY',
    appId: '1:1098590842305:android:b605606e88c2024e405340',
    messagingSenderId: '1098590842305',
    projectId: 'juslegal-2196',
    storageBucket: 'juslegal-2196.firebasestorage.app',
  );
}
