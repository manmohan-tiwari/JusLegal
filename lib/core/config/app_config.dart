// -----------------------------------------------------------------------------
// app_config.dart — Unified configuration, constants, strings, theme, animations
// and document templates for JusLegal.
//
// Consolidates the former:
//   core/config/ai_config.dart, ai_runtime_config.dart, env_config.dart,
//   templates.dart, theme_config.dart
//   core/constants/api_constants.dart, app_animations.dart, app_strings.dart,
//   app_config.dart
// -----------------------------------------------------------------------------
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../models/document_category_model.dart';
import '../../models/document_type_model.dart';
import '../../models/form_field_model.dart';
import '../../models/form_template_model.dart';

part 'app_config.templates.dart';
part 'app_config.theme.dart';
part 'app_config.animations.dart';
part 'app_config.environment.dart';

// ============================== API / WORKER =================================

// ignore: constant_identifier_names
const String WORKER_BASE_URL = String.fromEnvironment(
  'JUSLEGAL_AI_PROXY_BASE_URL',
  defaultValue: 'https://juslegal-ai-proxy.juslegalai.workers.dev',
);

class ApiConstants {
  // Shared Settings
  static const double temperature = 0.2;
  static const int maxTokens = 1200;
  static const int letterMaxTokens = 2400;
  static const int maxRetries = 2;
  static const int retryDelayMs = 1000;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// Client-side mirror of the Worker request envelope limits.
///
/// The Worker is authoritative and selects the upstream model based on the
/// endpoint. These values only keep the app from creating requests that the
/// Worker would reject; matching values must be updated alongside
/// `juslegal-ai-proxy/src/index.ts`.
class WorkerAiRequestLimits {
  static const int maxMessages = 20;
  static const int maxMessageContentChars = 20000;
  static const int maxTotalMessageChars = 60000;
  static const int maxTokens = 2400;
  static const double minTemperature = 0;
  static const double maxTemperature = 1;
}

const String jusLegalChatSystemPrompt =
    '''You are JusLegal, a progressive AI legal assistant specializing in Indian consumer protection law.

CONVERSATIONAL BEHAVIOR:
1. PROGRESSIVE STEP-BY-STEP GUIDANCE: Provide ONLY immediate relevant action or information (1-2 sentences in "message" or "action"), ONE important question (in "question"), and available options (in "options"). Then wait for the user's answer.
2. DO NOT DUMP ALL INFORMATION: Never dump full legal explanations or complete multi-step workflows in one turn.
3. REMEMBER FACTS & DO NOT REPEAT QUESTIONS: Use the compact Case State provided. Never ask a question the user has already answered.
4. DYNAMIC FOR ALL CONSUMER ISSUES: Works dynamically for banking/UPI fraud, account takeover, damaged orders, refund refusals, defective products, landlord disputes, service issues, etc.
5. NEVER CONTROL UI FORMATTING WITH MARKDOWN HEADINGS OR SPECIAL TEXT:
   - NEVER put button labels, option text, or headers like "Quick Options Presented:", "Question:", "Action Checklist:", "Legal Context:" inside the "message" text body.
   - All interactive UI elements must be output ONLY as dedicated JSON fields.

RESPONSE SCHEMA (STRICT JSON ONLY):
Respond strictly with a JSON object containing these exact fields:
{
  "type": "message" | "question" | "action" | "escalation" | "resolution",
  "message": "Short empathetic guidance text (1-3 sentences max). Do NOT include questions or headers here.",
  "question": "ONE single important follow-up question (or null if resolution/no question needed).",
  "action": {
    "title": "Short title for immediate action (e.g. 'Do this now') or null if no action card required.",
    "items": ["Immediate step 1", "Immediate step 2"]
  },
  "options": [
    {"label": "Option Button Label", "value": "option_value_code_or_text"}
  ],
  "legalContext": "Short 1-sentence legal protection or circular reference note (or null if not applicable to current step).",
  "nextStep": "Short 1-sentence description of what happens next (or null).",
  "caseState": {
    "caseType": "banking_fraud | damaged_order | refund | defective_product | landlord_dispute | general",
    "knownFacts": {"fact_key": "fact_value"},
    "missingImportantFacts": ["missing_fact_1"],
    "currentStage": "triage | immediate_securing | reporting | evidence_gathering | escalation | resolved",
    "previousActions": ["action_1"],
    "escalationStatus": "none | bank_helpline | ombudsman | cyber_crime | consumer_court"
  }
}''';

String chatSystemPromptForLanguage(String languageCode) {
  final base = jusLegalChatSystemPrompt;
  if (languageCode.toLowerCase() == 'hi') {
    return '$base\n'
        'Output valid JSON. Write message, question, action title/items, options labels, and legalContext strings in Hindi (Devanagari script). '
        'Keep legal terms like RBI, RTI, FIR, IPC, NCH, and Act names in English script/acronyms where appropriate.';
  }
  return '$base\nRespond in English.';
}

// ============================ RUNTIME / ENV ==================================

/// Compatibility shim for callers that log AI configuration.
/// Provider credentials and URLs are intentionally server-side only.
class AiRuntimeConfig {
  AiRuntimeConfig._();

  static void logConfig() {
    if (kDebugMode) {
      debugPrint(
          '[AiRuntimeConfig] AI requests use the Cloudflare Worker proxy.');
    }
  }
}

/// App-level configuration values. Provider keys deliberately do not belong in
/// this client application; requests are authenticated with Firebase and sent
/// to the Cloudflare Worker.
class EnvConfig {
  EnvConfig._();

  static ConfigurationException? configurationError;

  static Future<void> initialize() async {
    configurationError = null;
    try {
      if (_environmentFile.isNotEmpty) {
        await dotenv.dotenv.load(
          fileName: _environmentFile,
          isOptional: true,
        );
      }
      _EnvironmentState.load(dotenv.dotenv.env);
      if (!EnvironmentState.isValid) {
        throw const ConfigurationException(
          'Worker URL, website URL, and country code must be valid.',
        );
      }
    } catch (error, stackTrace) {
      _EnvironmentState.load(const <String, String>{});
      configurationError = error is ConfigurationException
          ? error
          : ConfigurationException('Unable to load environment configuration: $error');
      if (kDebugMode) {
        debugPrint('[EnvConfig] Optional environment file was not loaded: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  static bool get isAiAvailable => FeatureFlags.aiEnabled;

  static void printConfig() {
    if (kDebugMode) {
      debugPrint('[EnvConfig] environment=${EnvironmentTypeConfig.current.name} '
          'baseUrl=${EnvironmentState.workerBaseUrl} '
          'firebaseProject=${EnvironmentState.firebaseProjectId}');
    }
  }
}

// ============================== APP CONFIG ===================================

class AppConfig {
  static Future<void> initialize() async {
    // No longer needs to load environment variables
    // All configuration is now hardcoded or handled by Firebase
  }

  // App Information
  static String get appName => 'JusLegal';
  static String get appVersion => '1.0.0';
  static String get appBuildNumber => '1';
  static String get supportEmail => 'support@juslegal.app';

  // URLs
  static String get privacyPolicyUrl => '${EnvironmentState.websiteUrl}/privacy';
  static String get termsOfServiceUrl => '${EnvironmentState.websiteUrl}/terms';
  static String get websiteUrl => EnvironmentState.websiteUrl;

  // Firebase identifiers are public configuration, but remain environment-aware.
  static String get firebaseProjectId => EnvironmentState.firebaseProjectId;
  static String get firebaseAuthDomain => EnvironmentState.firebaseAuthDomain;
  static String get firebaseStorageBucket => EnvironmentState.firebaseStorageBucket;
  static String get firebaseMessagingSenderId => EnvironmentState.firebaseMessagingSenderId;
  static String get firebaseMeasurementId => EnvironmentState.firebaseMeasurementId;

  // Legal Disclaimers
  static String get appTagline => 'Know Your Rights. Take Action.';
  static String get onboardingDisclaimer =>
      'JusLegal provides general legal guidance based on Indian law. It does not replace professional legal advice. For complex or criminal matters, always consult a practicing advocate.';
  static String get resultDisclaimer =>
      'ℹ️ General guidance only. Not legal advice.';
  static String get documentDisclaimer =>
      'This document was generated for reference purposes. Review carefully before sending.';

  // External Service URLs
  static String get cyberCrimeUrl => 'https://cybercrime.gov.in';
  static String get rbiComplaintUrl => 'https://cms.rbi.org.in';
  static String get dgcaUrl => 'https://dgca.gov.in';
  static String get googleMapsUrl => 'https://www.google.com/maps/search';

  // Optional API Keys (for future use)
  static String? get apiKey => null;
  static String? get analyticsKey => null;

  // Phone authentication
  static String get defaultCountryCode => EnvironmentState.defaultCountryCode;

  // Validation
  static bool get isConfigured => true;

  // Debug helper (comment out in production)
  static void printConfig() {
    // print('=== AppConfig ===');
    // print('App Name: $appName');
    // print('Version: $appVersion ($appBuildNumber)');
    // print('Support Email: $supportEmail');
    // print('Privacy Policy: $privacyPolicyUrl');
    // print('Terms of Service: $termsOfServiceUrl');
    // print('Website: $websiteUrl');
    // print('Configured: $isConfigured');
    // print('================');
  }
}

// ============================== APP STRINGS ==================================

class AppStrings {
  static String get appName => AppConfig.appName;
  static String get tagline => AppConfig.appTagline;
  static String get onboardingDisclaimer => AppConfig.onboardingDisclaimer;
  static String get resultDisclaimer => AppConfig.resultDisclaimer;
  static String get documentDisclaimer => AppConfig.documentDisclaimer;

  // AI Provider Strings
  static const String errorProblemEmpty = 'Problem summary cannot be empty.';
  static const String eventAnalysisStarted = 'analysis_started';
  static const String eventAnalysisCompleted = 'analysis_completed';
  static const String eventAnalysisError = 'analysis_error';

  // Authority Names
  static const String authNationalConsumerHelpline =
      'National Consumer Helpline';
  static const String authCyberCrimePortal = 'Cyber Crime Portal';
  static const String authRBIPortal = 'RBI Complaint Portal';
  static const String authDGCA = 'DGCA';
  static const String authTRAI = 'TRAI Consumer Portal';
  static const String authFSSAI = 'FSSAI';
  static const String authMedicalCouncil = 'Medical Council of India';
  static const String authDistrictConsumer = 'District Consumer Commission';
  static const String authTrafficPolice = 'Traffic Police (Local)';
  static const String authEducationRegulatory = 'Education Regulatory Authority';
  static const String authAirlineGrievance = 'Airline Grievance Officer';
  static const String authConsumerCommission = 'Consumer Commission';

  // Action Labels
  static const String actionCallNow = 'Call Now';
  static const String actionFileOnline = 'File Online';
  static const String actionVisitWebsite = 'Visit Website';
  static const String actionFindNearest = 'Find nearest';
  static const String actionContactAirline = 'Contact airline';

  // Chat Error Messages (localized en/hi – resolved via localeProvider)
  static const Map<String, Map<String, String>> chatErrorMessages = {
    'serviceUnavailable': {
      'en': 'AI services are unavailable. Please try again shortly.',
      'hi': 'AI सेवाएँ उपलब्ध नहीं हैं। कृपया थोड़ी देर बाद पुनः प्रयास करें।',
    },
    'network': {
      'en': 'Could not reach the AI service. Check your connection and try again.',
      'hi': 'AI सेवा से संपर्क नहीं हो सका। अपना कनेक्शन जाँचें और फिर प्रयास करें।',
    },
    'generic': {
      'en': 'Could not get an AI response. Please try again.',
      'hi': 'AI उत्तर प्राप्त नहीं हो सका। कृपया पुनः प्रयास करें।',
    },
    'cancelled': {
      'en': 'Previous request cancelled. Sending your new message…',
      'hi': 'पिछला अनुरोध रद्द किया गया। आपका नया संदेश भेजा जा रहा है…',
    },
  };

  static String chatErrorMessage(String key, String languageCode) {
    final messages = chatErrorMessages[key];
    if (messages == null) return '';
    return messages[languageCode] ?? messages['en']!;
  }

  // Error Messages
  static const String errServiceUnavailable =
      'Service temporarily unavailable. Please try again in a few minutes.';
  static const String errNoInternet =
      'No internet connection. Please check your network and try again.';
  static const String errTooManyRequests =
      'Too many requests. Please wait a moment and try again.';
  static const String errConfigError =
      'Service configuration error. Please try again later.';
  static const String errParseError =
      'Unable to process AI response. Please try again.';
  static const String errGenericError =
      'Something went wrong. Please try again.';

  static AppStringsLocalization localized(BuildContext context) =>
      AppStringsLocalization(AppLocalizations.of(context));
}

class AppStringsLocalization {
  const AppStringsLocalization(this._localizations);

  final AppLocalizations _localizations;

  String get appTagline => _localizations.appTagline;
  String get onboardingDisclaimer => _localizations.onboardingDisclaimer;
  String get resultDisclaimer => _localizations.resultDisclaimer;
  String get documentDisclaimer => _localizations.documentDisclaimer;
  String get errorProblemEmpty => _localizations.problemSummaryEmpty;
  String get errServiceUnavailable => _localizations.serviceTemporarilyUnavailable;
  String get errNoInternet => _localizations.noInternetConnection;
  String get errTooManyRequests => _localizations.tooManyRequests;
  String get errConfigError => _localizations.configurationError;
  String get errParseError => _localizations.unableToProcessResponse;
}
