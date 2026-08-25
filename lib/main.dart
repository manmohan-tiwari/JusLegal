import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode, defaultTargetPlatform;
import 'package:device_preview/device_preview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:juslegal/l10n/gen/app_localizations.dart';
import 'core/constants/app_config.dart';
import 'core/constants/firebase_options.dart';
import 'core/config/env_config.dart';
import 'core/router/app_router.dart';
import 'core/services/analytics_service.dart';
import 'core/config/theme_config.dart';
import 'providers/locale_provider.dart';

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
      debugPrint(
          '[Main] Firebase Apps: ${Firebase.apps.map((e) => e.name).toList()}');
    }
  } catch (_) {
    if (kDebugMode) {
      debugPrint('[Main] Firebase initialization failed');
      debugPrint(
          '[Main] Continuing without Firebase (app will work with limited functionality)');
    }
    if (kDebugMode) {
      debugPrint('[Main] Firebase-dependent features are unavailable');
    }
  }

  // Initialize SafeAnalytics (disabled by default, requires user consent)
  if (firebaseInitialized) {
    try {
      await SafeAnalytics.initialize();
      if (kDebugMode) {
        debugPrint(
            '[Main] Analytics initialized: ${SafeAnalytics.isAvailable}');
        debugPrint('[Main] Analytics consent: ${SafeAnalytics.analyticsEnabled}');
        debugPrint('[Main] Crashlytics consent: ${SafeAnalytics.crashlyticsEnabled}');
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
  await Hive.openBox('settings');

  // Initialize configuration
  await AppConfig.initialize();

  // Log app start (only if analytics is enabled)
  if (SafeAnalytics.analyticsEnabled) {
    await SafeAnalytics.logEvent(
      name: 'app_started',
      parameters: {
        'firebase_initialized': firebaseInitialized,
        'platform': defaultTargetPlatform.name,
        'is_debug': kDebugMode,
      },
    );
  }

  runApp(ProviderScope(
      child: JusLegalApp(firebaseAvailable: firebaseInitialized)));
}

class JusLegalApp extends ConsumerWidget {
  const JusLegalApp({super.key, required this.firebaseAvailable});

  final bool firebaseAvailable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = buildRouter(firebaseAvailable: firebaseAvailable);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'JusLegal',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: kDebugMode ? DevicePreview.locale(context) ?? locale : locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: kDebugMode ? DevicePreview.appBuilder : null,
    );
  }
}
