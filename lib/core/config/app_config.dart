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
import 'package:google_fonts/google_fonts.dart';

import '../../models/document_category_model.dart';
import '../../models/document_type_model.dart';
import '../../models/form_field_model.dart';
import '../../models/form_template_model.dart';

part 'app_config.templates.dart';
part 'app_config.theme.dart';
part 'app_config.animations.dart';

// ============================== API / WORKER =================================

// ignore: constant_identifier_names
const String WORKER_BASE_URL = String.fromEnvironment(
  'JUSLEGAL_AI_PROXY_BASE_URL',
  defaultValue: 'https://juslegal-ai-proxy.juslegal-ai.workers.dev',
);

// ignore: constant_identifier_names
const String OPENROUTER_MODEL = 'openrouter/auto';

// Keep this as a build-time setting so it can be changed when a Groq model is
// retired, without putting provider credentials in the app.
// ignore: constant_identifier_names
const String GROQ_MODEL = String.fromEnvironment(
  'GROQ_MODEL',
  defaultValue: 'openai/gpt-oss-20b',
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

/// Backward-compatible aliases for legacy callers.
/// New service code reads the shared API constants directly.
class AIConstants {
  static const String openRouterModel = OPENROUTER_MODEL;
  static const String groqModel = GROQ_MODEL;
  static const int maxTokens = ApiConstants.maxTokens;
  static const double temperature = ApiConstants.temperature;
}

const String jusLegalChatSystemPrompt =
    '''You are JusLegal, an AI legal assistant for Indian consumers.
Your role is to provide clear, practical legal guidance on consumer rights, complaints, and remedies under Indian law (Consumer Protection Act 2019, etc.).
Be friendly, professional, and concise. Always disclaim that you are not a substitute for a real lawyer.
If the user describes a legal issue, analyze it and suggest next steps, relevant authorities, and documents needed.''';

String chatSystemPromptForLanguage(String languageCode) {
  final base = jusLegalChatSystemPrompt;
  if (languageCode.toLowerCase() == 'hi') {
    return '$base\n'
        'Respond in Hindi (Devanagari script). '
        'Keep legal terms like RTI, PIL, FIR, IPC, CPC, CrPC, and act names in English where appropriate, '
        'but write all other content in Hindi.';
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

  static Future<void> initialize() async {}

  static bool get isAiAvailable => true;

  /// Image generation has not yet been moved behind the Worker. Returning an
  /// empty value prevents a provider key from being embedded in the app.
  @Deprecated('Move SiliconFlow calls behind the Worker before enabling them.')
  static String get siliconflowApiKey => '';

  static void printConfig() {
    if (kDebugMode) {
      debugPrint(
          '[EnvConfig] AI requests use the Cloudflare Worker proxy with Firebase auth.');
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
  static String get privacyPolicyUrl => 'https://juslegal-2196.web.app/privacy';
  static String get termsOfServiceUrl => 'https://juslegal-2196.web.app/terms';
  static String get websiteUrl => 'https://juslegal-2196.web.app';

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
}
