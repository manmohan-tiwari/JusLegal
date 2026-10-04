import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:juslegal/l10n/gen/app_localizations.dart';

import '../../models/legal_result_model.dart';
import '../../services/auth_handler.dart';
import '../../screens/auth_flow_screens.dart';
import '../../screens/home_screen.dart';
import '../../screens/ai_legal_chat_screen.dart';
import '../../screens/document_review_screen.dart';
import '../../screens/legal_terms_screen.dart';
import '../../screens/legal_writing_screen.dart';
import '../../screens/my_cases_screen.dart';
import '../../screens/not_found_screen.dart';
import '../../screens/otp_screen.dart';
import '../../screens/privacy_policy_screen.dart';
import '../../screens/problem_analyzer_screen.dart';
import '../../screens/result_screen.dart';
import '../../screens/settings_screen.dart';
import 'otp_route_params.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class AppRouteNames {
  static const String login = 'login';
  static const String welcome = 'welcome';
  static const String emailAuth = 'emailAuth';
  static const String otp = 'otp';
  static const String home = 'home';
  static const String analyzer = 'analyzer';
  static const String result = 'result';
  static const String cases = 'cases';
  static const String settings = 'settings';
  static const String privacyPolicy = 'privacyPolicy';
  static const String firebaseUnavailable = 'firebaseUnavailable';
  static const String legalTermsRoot = 'legalTermsRoot';

  // Legal utilities
  static const String aiLawyerChat = 'aiLawyerChat';
  static const String homeLegalTerms = 'legalTerms';
  static const String homeLegalWriting = 'legalWriting';
  static const String homeDocumentReview = 'documentReview';
}

Page<dynamic> _buildFadeSlidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.03, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
    },
  );
}

GoRouter buildRouter({
  required bool firebaseAvailable,
  required AuthState Function() getAuthState,
  required Listenable refreshListenable,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) async {
      final path = state.uri.path;
      if (!firebaseAvailable) {
        if (path == '/privacy-policy' ||
            path == '/legal-terms' ||
            path == '/firebase-unavailable') {
          return null;
        }
        return '/firebase-unavailable';
      }
      final user = getAuthState().user;

      // Handle root path redirect
      if (path == '/') {
        if (user != null) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/privacy-policy',
        name: AppRouteNames.privacyPolicy,
        pageBuilder: (context, state) =>
            _buildFadeSlidePage(state, const PrivacyPolicyScreen()),
      ),
      GoRoute(
        path: '/legal-terms',
        name: AppRouteNames.legalTermsRoot,
        pageBuilder: (context, state) =>
            _buildFadeSlidePage(state, const LegalTermsScreen()),
      ),
      GoRoute(
        path: '/firebase-unavailable',
        name: AppRouteNames.firebaseUnavailable,
        builder: (context, state) => const _FirebaseUnavailableScreen(),
      ),
      GoRoute(
        path: '/',
        name: AppRouteNames.welcome,
        pageBuilder: (context, state) =>
            _buildFadeSlidePage(state, const WelcomeScreen()),
      ),
      GoRoute(
        path: '/login',
        name: AppRouteNames.login,
        pageBuilder: (context, state) =>
            _buildFadeSlidePage(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/signup-method',
        pageBuilder: (context, state) =>
            _buildFadeSlidePage(state, const SignUpMethodScreen()),
      ),
      GoRoute(
        path: '/email-signup',
        pageBuilder: (context, state) =>
            _buildFadeSlidePage(state, const EmailSignupScreen()),
      ),
      GoRoute(
        path: '/email-verification',
        name: AppRouteNames.emailAuth,
        pageBuilder: (context, state) => _buildFadeSlidePage(
          state,
          EmailVerificationScreen(email: state.extra as String? ?? ''),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) =>
            _buildFadeSlidePage(state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: '/mobile-signup',
        pageBuilder: (context, state) => _buildFadeSlidePage(
          state,
          const MobileEntryScreen(signup: true),
        ),
      ),
      GoRoute(
        path: '/mobile-login',
        pageBuilder: (context, state) => _buildFadeSlidePage(
          state,
          const MobileEntryScreen(signup: false),
        ),
      ),
      GoRoute(
        path: '/confirm-name',
        pageBuilder: (context, state) => _buildFadeSlidePage(
          state,
          ConfirmNameScreen(user: state.extra! as User),
        ),
      ),
      GoRoute(
        path: '/otp',
        name: AppRouteNames.otp,
        pageBuilder: (context, state) {
          final params = OtpRouteParams.fromExtra(state.extra);
          return _buildFadeSlidePage(
            state,
            OtpScreen(
              verificationId: params.verificationId,
              phoneNumber: params.phoneNumber,
              legalName: params.legalName,
              isSignup: params.isSignup,
            ),
          );
        },
      ),
      GoRoute(
        path: '/analyze',
        name: 'analyzeLegacy',
        pageBuilder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return _buildFadeSlidePage(
            state,
            ProblemAnalyzerScreen(initialCategory: category),
          );
        },
      ),
      GoRoute(
        path: '/home',
        name: AppRouteNames.home,
        pageBuilder: (context, state) =>
            _buildFadeSlidePage(state, const HomeScreen()),
        routes: [
          GoRoute(
            path: 'analyzer',
            name: AppRouteNames.analyzer,
            pageBuilder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return _buildFadeSlidePage(
                state,
                ProblemAnalyzerScreen(initialCategory: category),
              );
            },
          ),
          GoRoute(
            path: 'result',
            name: AppRouteNames.result,
            pageBuilder: (context, state) {
              final initialResult = state.extra is LegalResultModel
                  ? state.extra as LegalResultModel
                  : null;
              return _buildFadeSlidePage(
                state,
                ResultScreen(initialResult: initialResult),
              );
            },
          ),
          GoRoute(
            path: 'cases',
            name: AppRouteNames.cases,
            pageBuilder: (context, state) =>
                _buildFadeSlidePage(state, const MyCasesScreen()),
          ),
          GoRoute(
            path: 'settings',
            name: AppRouteNames.settings,
            pageBuilder: (context, state) =>
                _buildFadeSlidePage(state, const SettingsScreen()),
          ),

          // Legal utility routes
          GoRoute(
            path: 'ai-lawyer-chat',
            name: AppRouteNames.aiLawyerChat,
            pageBuilder: (context, state) => _buildFadeSlidePage(
              state,
              const AILegalChatScreen(userName: 'there'),
            ),
          ),
          GoRoute(
            path: 'legal-terms',
            name: AppRouteNames.homeLegalTerms,
            pageBuilder: (context, state) =>
                _buildFadeSlidePage(state, const LegalTermsScreen()),
          ),
          GoRoute(
            path: 'legal-writing',
            name: AppRouteNames.homeLegalWriting,
            pageBuilder: (context, state) =>
                _buildFadeSlidePage(state, const LegalWritingScreen()),
          ),
          GoRoute(
            path: 'document-review',
            name: AppRouteNames.homeDocumentReview,
            pageBuilder: (context, state) =>
                _buildFadeSlidePage(state, const DocumentReviewScreen()),
          ),
        ],
      ),
    ],
  );
}

class _FirebaseUnavailableScreen extends StatelessWidget {
  const _FirebaseUnavailableScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.serviceUnavailable)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.signInFeaturesTemporarilyUnavailable,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
