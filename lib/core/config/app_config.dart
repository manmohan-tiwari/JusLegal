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

// ============================== API CONSTANTS =================================

class ApiConstants {
  // Shared Settings
  static const double temperature = 0.2;
  static const int maxTokens = 1200;

  /// Normal chat is intentionally concise; analysis and document flows retain
  /// their existing limits.
  static const int chatMaxTokens = 400;
  static const int letterMaxTokens = 2400;
  static const int maxRetries = 2;
  static const int retryDelayMs = 1000;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

const String jusLegalChatSystemPrompt =
    '''You are JusLegal, a progressive Indian legal assistant. This is NORMAL CHAT, not a legal-analysis or document-writing task.

For each user message, read CURRENT CASE STATE, identify the next useful action, and respond progressively. Ask at most one high-value question when a material fact is missing; otherwise give the next practical action. Do not ask facts already in the case state. Do not give a full legal report, complete procedure, or unrelated legal detail unless the user asks for it. Keep law concise and relevant to the current stage; never invent laws, sections, authorities, deadlines, outcomes, or facts.

Return ONLY one JSON object. It must have exactly these keys and no others:
{
  "type": "question|information|action|warning|final",
  "message": "1-3 short user-facing sentences; no markdown, headings, numbered prefixes, or option labels",
  "question": null,
  "options": [],
  "steps": [],
  "legalContext": null,
  "nextAction": null,
  "caseUpdates": {}
}

type and message are required. Use question only when type is question, with one question and normally 2-4 short, mutually clear string options. Keep options as strings, never write them in message. Use steps only when useful (1-4 short strings). Use legalContext only when relevant. nextAction is optional. caseUpdates must contain only facts learned from this latest user message; never invent facts, repeat old facts, or overwrite known facts with null unless explicitly corrected. Flutter controls all UI formatting.''';

String chatSystemPromptForLanguage([String languageCode = 'en']) {
  return '$jusLegalChatSystemPrompt\nRespond in English.';
}

// ============================ RUNTIME / ENV ==================================

/// Compatibility shim for callers that log AI configuration.
class AiRuntimeConfig {
  AiRuntimeConfig._();

  static void logConfig() {
    if (kDebugMode) {
      debugPrint(
          '[AiRuntimeConfig] AI requests use Google Gemini direct integration.');
    }
  }
}

/// App-level configuration values.
class EnvConfig {
  EnvConfig._();

  static ConfigurationException? configurationError;

  static Future<void> initialize() async {
    configurationError = null;
    try {
      final envFile = _environmentFile.isNotEmpty ? _environmentFile : '.env';
      await dotenv.dotenv.load(
        fileName: envFile,
        isOptional: true,
      );
      _EnvironmentState.load(dotenv.dotenv.env);
      if (kDebugMode) {
        debugPrint(
            '[EnvConfig] Loaded ${dotenv.dotenv.env.length} keys from $envFile. Gemini key configured: ${EnvironmentState.geminiApiKey.isNotEmpty}');
      }
      if (!EnvironmentState.isValid) {
        throw const ConfigurationException(
          'Website URL and country code must be valid.',
        );
      }
    } catch (error, stackTrace) {
      _EnvironmentState.load(const <String, String>{});
      configurationError = error is ConfigurationException
          ? error
          : ConfigurationException(
              'Unable to load environment configuration: $error');
      if (kDebugMode) {
        debugPrint(
            '[EnvConfig] Optional environment file was not loaded: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  static bool get isAiAvailable => FeatureFlags.aiEnabled;

  static void printConfig() {
    if (kDebugMode) {
      debugPrint(
          '[EnvConfig] environment=${EnvironmentTypeConfig.current.name} '
          'geminiConfigured=${EnvironmentState.geminiApiKey.isNotEmpty} '
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
  static String get privacyPolicyUrl =>
      '${EnvironmentState.websiteUrl}/privacy';
  static String get termsOfServiceUrl => '${EnvironmentState.websiteUrl}/terms';
  static String get websiteUrl => EnvironmentState.websiteUrl;

  // Firebase identifiers are public configuration, but remain environment-aware.
  static String get firebaseProjectId => EnvironmentState.firebaseProjectId;
  static String get firebaseAuthDomain => EnvironmentState.firebaseAuthDomain;
  static String get firebaseStorageBucket =>
      EnvironmentState.firebaseStorageBucket;
  static String get firebaseMessagingSenderId =>
      EnvironmentState.firebaseMessagingSenderId;
  static String get firebaseMeasurementId =>
      EnvironmentState.firebaseMeasurementId;

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

  // API Keys
  static String? get apiKey =>
      EnvironmentState.geminiApiKey.isNotEmpty ? EnvironmentState.geminiApiKey : null;
  static String get geminiApiKey => EnvironmentState.geminiApiKey;
  static String get geminiModel => EnvironmentState.geminiModel;
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
  static const String authEducationRegulatory =
      'Education Regulatory Authority';
  static const String authAirlineGrievance = 'Airline Grievance Officer';
  static const String authConsumerCommission = 'Consumer Commission';

  // Action Labels
  static const String actionCallNow = 'Call Now';
  static const String actionFileOnline = 'File Online';
  static const String actionVisitWebsite = 'Visit Website';
  static const String actionFindNearest = 'Find nearest';
  static const String actionContactAirline = 'Contact airline';

  // Chat Error Messages
  static const Map<String, String> chatErrorMessages = {
    'serviceUnavailable': 'AI services are unavailable. Please try again shortly.',
    'network':
        'Could not reach the AI service. Check your connection and try again.',
    'generic': 'Could not get an AI response. Please try again.',
    'cancelled': 'Previous request cancelled. Sending your new message…',
  };

  static String chatErrorMessage(String key, [String languageCode = 'en']) {
    return chatErrorMessages[key] ?? '';
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
  String get errServiceUnavailable =>
      _localizations.serviceTemporarilyUnavailable;
  String get errNoInternet => _localizations.noInternetConnection;
  String get errTooManyRequests => _localizations.tooManyRequests;
  String get errConfigError => _localizations.configurationError;
  String get errParseError => _localizations.unableToProcessResponse;
}
