import 'app_config.dart';

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
  static const String authNationalConsumerHelpline = 'National Consumer Helpline';
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
  static const String errServiceUnavailable = 'Service temporarily unavailable. Please try again in a few minutes.';
  static const String errNoInternet = 'No internet connection. Please check your network and try again.';
  static const String errTooManyRequests = 'Too many requests. Please wait a moment and try again.';
  static const String errConfigError = 'Service configuration error. Please try again later.';
  static const String errParseError = 'Unable to process AI response. Please try again.';
  static const String errGenericError = 'Something went wrong. Please try again.';
}
