import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'core/constants/app_config.dart';
import 'core/constants/firebase_options.dart';
import 'core/config/env_config.dart';
import 'core/router/app_router.dart';
import 'core/services/analytics_service.dart';
import 'core/config/theme_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.initialize();

  // Print configuration for debugging
  if (kDebugMode) EnvConfig.printConfig();

  // Initialize Firebase with error handling
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    if (kDebugMode) {
      debugPrint('[Main] Firebase initialized successfully');
      debugPrint('[Main] Firebase Apps: ${Firebase.apps.map((e) => e.name).toList()}');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Main] Firebase initialization failed: $e');
      debugPrint('[Main] Continuing without Firebase (app will work with limited functionality)');
    }
    // For web, continue without Firebase if it fails
    // For mobile, log the error locally using debugPrint since Firebase isn't available yet
    if (!kIsWeb && firebaseInitialized) {
      // Only use Crashlytics if Firebase was successfully initialized
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    } else {
      // Fallback: log error locally using debugPrint
      debugPrint('[Main] Firebase initialization error: $e');
      debugPrint('[Main] Stack trace: ${StackTrace.current}');
    }
  }

  // Initialize Firebase Crashlytics only if Firebase is available
  if (firebaseInitialized) {
    try {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      if (kDebugMode) {
        debugPrint('[Main] Crashlytics initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Main] Crashlytics initialization failed: $e');
      }
    }
  }

  // Initialize SafeAnalytics
  if (firebaseInitialized) {
    try {
      await SafeAnalytics.initialize();
      if (kDebugMode) {
        debugPrint('[Main] Analytics initialized: ${SafeAnalytics.isAvailable}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Main] Analytics initialization failed: $e');
      }
    }
  }

  // Initialize local storage
  await Hive.initFlutter();
  await Hive.openBox('cases');

  // Initialize configuration
  await AppConfig.initialize();

  // Log app start
  await SafeAnalytics.logEvent(
    name: 'app_started',
    parameters: {
      'firebase_initialized': firebaseInitialized,
      'platform': defaultTargetPlatform.name,
      'is_debug': kDebugMode,
    },
  );

runApp(const ProviderScope(child: JusLegalApp()));
}

class JusLegalApp extends StatelessWidget {
  const JusLegalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = buildRouter();
    return MaterialApp.router(
      title: 'JusLegal',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: kDebugMode ? DevicePreview.locale(context) : null,
      builder: kDebugMode ? DevicePreview.appBuilder : null,
    );
  }
}

