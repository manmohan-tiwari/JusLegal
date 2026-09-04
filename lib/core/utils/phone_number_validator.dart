import '../config/app_config.dart';
import '../../services/auth_exceptions.dart';

class PhoneNumberValidator {
  PhoneNumberValidator._();

  static String normalize(String phoneNumber) {
    final compact = phoneNumber.trim().replaceAll(RegExp(r'[\s()-]'), '');
    final countryCode = AppConfig.defaultCountryCode.trim();
    final countryDigits = countryCode.replaceAll(RegExp(r'\D'), '');
    final digits = compact.replaceAll(RegExp(r'\D'), '');

    if (compact.startsWith('+')) {
      return '+$digits';
    }
    if (digits.startsWith(countryDigits) &&
        digits.length == countryDigits.length + 10) {
      return '+$digits';
    }
    if (digits.length == 10) {
      return '$countryCode$digits';
    }
    return '+$digits';
  }

  static bool isValid(String phoneNumber) {
    final normalized = normalize(phoneNumber);
    final countryDigits =
        AppConfig.defaultCountryCode.replaceAll(RegExp(r'\D'), '');
    final digits = normalized.replaceAll(RegExp(r'\D'), '');

    return normalized.startsWith('+$countryDigits') &&
        digits.length == countryDigits.length + 10 &&
        digits.substring(countryDigits.length).startsWith(RegExp(r'[6-9]'));
  }

  static String normalizeOrThrow(String phoneNumber) {
    if (!isValid(phoneNumber)) {
      throw const InvalidPhoneNumberException(
        'Enter a valid 10-digit Indian mobile number.',
      );
    }
    return normalize(phoneNumber);
  }
}
