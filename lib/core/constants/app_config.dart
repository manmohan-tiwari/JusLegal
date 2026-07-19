class AppConfig {
  static Future<void> initialize() async {
    // No longer needs to load environment variables
    // All configuration is now hardcoded or handled by Firebase
  }

  // App Information
  static String get appName => 'JusLegal';
  static String get appLogoAsset => 'assets/icon/juslegal icon.png';
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
