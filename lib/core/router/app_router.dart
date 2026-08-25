import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:juslegal/l10n/gen/app_localizations.dart';

import '../../models/legal_result_model.dart';
import '../../screens/authorities_screen.dart';
import '../../screens/complaint_generator_screen.dart';
import '../../screens/email_auth_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/ai_legal_chat_screen.dart';
import '../../screens/case_analysis_screen.dart';
import '../../screens/document_creation_screen.dart';
import '../../screens/document_review_screen.dart';
import '../../screens/legal_advice_screen.dart';
import '../../screens/legal_terms_screen.dart';
import '../../screens/legal_writing_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/my_cases_screen.dart';
import '../../screens/otp_screen.dart';
import '../../screens/privacy_policy_screen.dart';
import '../../screens/problem_analyzer_screen.dart';
import '../../screens/result_screen.dart';
import '../../screens/settings_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouteNames {
  static const String login = 'login';
  static const String emailAuth = 'emailAuth';
  static const String otp = 'otp';
  static const String home = 'home';
  static const String analyzer = 'analyzer';
  static const String result = 'result';
  static const String complaint = 'complaint';
  static const String cases = 'cases';
  static const String authorities = 'authorities';
  static const String settings = 'settings';
  static const String privacyPolicy = 'privacyPolicy';
  static const String firebaseUnavailable = 'firebaseUnavailable';

  // Legal utilities
  static const String aiLawyerChat = 'aiLawyerChat';
  static const String homeLegalAdvice = 'legalAdvice';
  static const String homeCaseAnalysis = 'caseAnalysis';
  static const String homeLegalTerms = 'legalTerms';
  static const String homeLegalWriting = 'legalWriting';
  static const String homeDocumentCreation = 'documentCreation';
  static const String homeDocumentReview = 'documentReview';
  static const String homeContractNegotiation = 'contractNegotiation';
}

GoRouter buildRouter({required bool firebaseAvailable}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;
      if (!firebaseAvailable) {
        if (path == '/privacy-policy' || path == '/firebase-unavailable') {
          return null;
        }
        return '/firebase-unavailable';
      }
      final user = FirebaseAuth.instance.currentUser;

      // If path starts with /home and user is not authenticated, redirect to login
      if (path.startsWith('/home') && user == null) {
        return '/login';
      }

      // Handle root path redirect
      if (path == '/') {
        if (user == null) {
          return '/login';
        } else {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/privacy-policy',
        name: AppRouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/firebase-unavailable',
        name: AppRouteNames.firebaseUnavailable,
        builder: (context, state) => const _FirebaseUnavailableScreen(),
      ),
      GoRoute(
        path: '/login',
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/email-auth',
        name: AppRouteNames.emailAuth,
        builder: (context, state) => const EmailAuthScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: AppRouteNames.otp,
        builder: (context, state) {
          final extra = (state.extra as Map<String, dynamic>?) ?? {};
          return OtpScreen(
            verificationId: extra['verificationId'] as String? ?? '',
            phoneNumber: extra['phoneNumber'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/home',
        name: AppRouteNames.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'analyzer',
            name: AppRouteNames.analyzer,
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return ProblemAnalyzerScreen(initialCategory: category);
            },
          ),
          GoRoute(
            path: 'result',
            name: AppRouteNames.result,
            builder: (context, state) {
              final initialResult = state.extra is LegalResultModel
                  ? state.extra as LegalResultModel
                  : null;
              return ResultScreen(initialResult: initialResult);
            },
          ),
          GoRoute(
            path: 'complaint',
            name: AppRouteNames.complaint,
            builder: (context, state) => const ComplaintGeneratorScreen(),
          ),
          GoRoute(
            path: 'cases',
            name: AppRouteNames.cases,
            builder: (context, state) => const MyCasesScreen(),
          ),
          GoRoute(
            path: 'authorities',
            name: AppRouteNames.authorities,
            builder: (context, state) => const AuthoritiesScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: AppRouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),

          // Legal utility routes
          GoRoute(
            path: 'ai-lawyer-chat',
            name: AppRouteNames.aiLawyerChat,
            builder: (context, state) => const AILegalChatScreen(
              userName: 'there',
            ),
          ),
          GoRoute(
            path: 'legal-advice',
            name: AppRouteNames.homeLegalAdvice,
            builder: (context, state) => const LegalAdviceScreen(),
          ),
          GoRoute(
            path: 'case-analysis',
            name: AppRouteNames.homeCaseAnalysis,
            builder: (context, state) => const CaseAnalysisScreen(),
          ),
          GoRoute(
            path: 'legal-terms',
            name: AppRouteNames.homeLegalTerms,
            builder: (context, state) => const LegalTermsScreen(),
          ),
          GoRoute(
            path: 'legal-writing',
            name: AppRouteNames.homeLegalWriting,
            builder: (context, state) => const LegalWritingScreen(),
          ),
          GoRoute(
            path: 'document-creation',
            name: AppRouteNames.homeDocumentCreation,
            builder: (context, state) => const DocumentCreationScreen(),
          ),
          GoRoute(
            path: 'document-review',
            name: AppRouteNames.homeDocumentReview,
            builder: (context, state) => const DocumentReviewScreen(),
          ),
          GoRoute(
            path: 'contract-negotiation',
            name: AppRouteNames.homeContractNegotiation,
            // Contract review is handled by the document-review workflow.
            builder: (context, state) => const DocumentReviewScreen(),
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
