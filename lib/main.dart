import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
  show defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:juslegal/core/core.dart';
import 'package:juslegal/l10n/gen/app_localizations.dart';

import 'providers/locale_provider.dart';
import 'services/auth_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) usePathUrlStrategy();

  final logger = AppLogger();

  try {
    await EnvConfig.initialize();
    if (kDebugMode) EnvConfig.printConfig();
  } catch (e, stackTrace) {
    logger.error('Failed to initialize EnvConfig', tag: 'Main', error: e, stackTrace: stackTrace);
  }

  bool firebaseInitialized = false;
  try {
    final existingApps = Firebase.apps;
    final hasDefaultApp = existingApps.any((app) => app.name == defaultFirebaseAppName);
    if (hasDefaultApp) {
      firebaseInitialized = true;
      logger.info('Firebase default app already initialized (via JS SDK on web)', tag: 'Main');
      logger.debug('Firebase Apps: ${Firebase.apps.map((e) => e.name).toList()}', tag: 'Main');
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseInitialized = true;
      logger.info('Firebase initialized successfully', tag: 'Main');
      logger.debug('Firebase Apps: ${Firebase.apps.map((e) => e.name).toList()}', tag: 'Main');
    }
  } catch (e, stackTrace) {
    logger.error(
      'Firebase initialization failed. Continuing without Firebase (limited functionality)',
      tag: 'Main',
      error: e,
      stackTrace: stackTrace,
    );
  }

  if (firebaseInitialized) {
    if (kIsWeb && AuthConfig.persistSession) {
      try {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      } catch (e, stackTrace) {
        logger.warning('Firebase Auth persistence setup failed: $e', tag: 'Main');
        if (kDebugMode) logger.debug('$stackTrace', tag: 'Main');
      }
    }
    try {
      await SafeAnalytics.initialize();
      logger.info('Analytics initialized: ${SafeAnalytics.isAvailable}', tag: 'Main');
      logger.debug('Analytics consent: ${SafeAnalytics.analyticsEnabled}', tag: 'Main');
      logger.debug('Crashlytics consent: ${SafeAnalytics.crashlyticsEnabled}', tag: 'Main');
    } catch (e, stackTrace) {
      logger.error('Analytics initialization failed', tag: 'Main', error: e, stackTrace: stackTrace);
    }
  }

  try {
    await Hive.initFlutter();
    await Hive.openBox('cases');
    await Hive.openBox('settings');
  } catch (e, stackTrace) {
    logger.error('Failed to initialize Hive storage boxes', tag: 'Main', error: e, stackTrace: stackTrace);
  }

  try {
    await AppConfig.initialize();
  } catch (e, stackTrace) {
    logger.error('Failed to initialize AppConfig', tag: 'Main', error: e, stackTrace: stackTrace);
  }

  if (SafeAnalytics.analyticsEnabled) {
    try {
      await SafeAnalytics.logEvent(
        name: 'app_started',
        parameters: {
          'firebase_initialized': firebaseInitialized,
          'platform': defaultTargetPlatform.name,
          'is_debug': kDebugMode,
        },
      );
    } catch (e) {
      logger.warning('Failed to log app_started event: $e', tag: 'Main');
    }
  }

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (context) => ProviderScope(
        child: JusLegalApp(firebaseAvailable: firebaseInitialized),
      ),
    ),
  );
}

class JusLegalApp extends ConsumerStatefulWidget {
  const JusLegalApp({super.key, required this.firebaseAvailable});

  final bool firebaseAvailable;

  @override
  ConsumerState<JusLegalApp> createState() => _JusLegalAppState();
}

class _JusLegalAppState extends ConsumerState<JusLegalApp> {
  late final GoRouter _router;
  late final RouterRefreshNotifier _routerRefresh;

  @override
  void initState() {
    super.initState();
    _routerRefresh = RouterRefreshNotifier();
    _router = buildRouter(
      firebaseAvailable: widget.firebaseAvailable,
      getAuthState: () => ref.read(authProvider),
      refreshListenable: _routerRefresh,
    );
  }

  @override
  void dispose() {
    _routerRefresh.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, __) => _routerRefresh.refresh());
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'JusLegal',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
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
