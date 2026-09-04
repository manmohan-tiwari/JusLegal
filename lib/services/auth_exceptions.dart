class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthFailureException extends AuthException {
  const AuthFailureException(super.message, {super.code});
}

class AuthCancelledException extends AuthException {
  const AuthCancelledException(super.message);
}

class AuthValidationException extends AuthException {
  const AuthValidationException(super.message);
}

class AuthRateLimitException extends AuthException {
  const AuthRateLimitException(super.message);
}

class InvalidPhoneNumberException extends AuthValidationException {
  const InvalidPhoneNumberException(super.message);
}

class InvalidEmailException extends AuthValidationException {
  const InvalidEmailException(super.message);
}

class WeakPasswordException extends AuthValidationException {
  const WeakPasswordException(super.message);
}

class EmailVerificationRequiredException extends AuthException {
  const EmailVerificationRequiredException(super.message);
}
