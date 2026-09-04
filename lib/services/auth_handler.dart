import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:juslegal/core/utils/logger.dart';
import 'package:juslegal/core/utils/password_validator.dart';
import 'package:juslegal/core/utils/phone_number_validator.dart';
import 'package:juslegal/core/utils/rate_limiter.dart';

export 'auth_exceptions.dart';
import 'auth_exceptions.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final RateLimiter _otpRateLimiter;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    RateLimiter? otpRateLimiter,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _otpRateLimiter = otpRateLimiter ??
            RateLimiter(
              minInterval: const Duration(seconds: 30),
              maxCallsPerInterval: 1,
            );

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  Future<UserCredential> signInWithGoogle() async {
    try {
      logger.debug('Opening Google sign-in', tag: 'Auth');
      if (kIsWeb) {
        return await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthCancelledException('Google sign-in was cancelled');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _firebaseAuth.signInWithCredential(credential);
    } on AuthCancelledException {
      rethrow;
    } on FirebaseAuthException catch (error, stackTrace) {
      throw _failure(error, stackTrace, 'Google sign-in');
    } catch (error, stackTrace) {
      logger.error('Google sign-in failed',
          tag: 'Auth', error: error, stackTrace: stackTrace);
      throw const AuthFailureException(
          'Google sign-in failed. Please try again.');
    }
  }

  Future<void> verifyPhone(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onError,
    Function(UserCredential)? onAutoVerified,
  ) async {
    final normalizedPhoneNumber =
        PhoneNumberValidator.normalizeOrThrow(phoneNumber);
    if (!_otpRateLimiter.isCallAllowed()) {
      throw const AuthRateLimitException(
        'Too many OTP requests. Please wait 30 seconds and try again.',
      );
    }

    final completion = Completer<void>();
    var callbackCompleted = false;

    void completeWithError(
        String message, Object error, StackTrace stackTrace) {
      if (callbackCompleted) return;
      callbackCompleted = true;
      onError(message);
      if (!completion.isCompleted) completion.completeError(error, stackTrace);
    }

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: normalizedPhoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          if (callbackCompleted) return;
          try {
            final userCredential =
                await _firebaseAuth.signInWithCredential(credential);
            callbackCompleted = true;
            onAutoVerified?.call(userCredential);
            if (!completion.isCompleted) completion.complete();
          } on FirebaseAuthException catch (error, stackTrace) {
            final failure =
                _failure(error, stackTrace, 'Automatic OTP verification');
            completeWithError(failure.message, failure, stackTrace);
          } catch (error, stackTrace) {
            logger.error('Automatic OTP verification failed',
                tag: 'Auth', error: error, stackTrace: stackTrace);
            completeWithError(
              'Automatic OTP verification failed. Please enter the OTP.',
              error,
              stackTrace,
            );
          }
        },
        verificationFailed: (error) {
          final failure =
              _failure(error, StackTrace.current, 'OTP verification');
          completeWithError(failure.message, failure, StackTrace.current);
        },
        codeSent: (verificationId, _) {
          if (callbackCompleted) return;
          callbackCompleted = true;
          logger.info('OTP code sent', tag: 'Auth');
          onCodeSent(verificationId);
          if (!completion.isCompleted) completion.complete();
        },
        codeAutoRetrievalTimeout: (_) {},
      );
      await completion.future;
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (error, stackTrace) {
      throw _failure(error, stackTrace, 'OTP verification');
    } catch (error, stackTrace) {
      logger.error('OTP verification failed',
          tag: 'Auth', error: error, stackTrace: stackTrace);
      throw const AuthFailureException(
          'OTP verification failed. Please try again.');
    }
  }

  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    if (verificationId.trim().isEmpty ||
        !RegExp(r'^\d{6}$').hasMatch(otp.trim())) {
      throw const AuthValidationException('Enter the 6-digit OTP.');
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp.trim(),
      );
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error, stackTrace) {
      throw _failure(error, stackTrace, 'OTP verification');
    } catch (error, stackTrace) {
      logger.error('OTP verification failed',
          tag: 'Auth', error: error, stackTrace: stackTrace);
      throw const AuthFailureException(
          'OTP verification failed. Please try again.');
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    _validateEmail(email);
    _validatePassword(password, requireStrength: false);
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (!(credential.user?.emailVerified ?? false)) {
        throw const EmailVerificationRequiredException(
          'Please verify your email address before signing in.',
        );
      }
      return credential;
    } on FirebaseAuthException catch (error, stackTrace) {
      throw _failure(error, stackTrace, 'Email sign-in');
    } catch (error, stackTrace) {
      throw _unexpectedFailure(error, stackTrace, 'Email sign-in');
    }
  }

  Future<UserCredential> registerWithEmail(
      String email, String password) async {
    _validateEmail(email);
    _validatePassword(password, requireStrength: true);
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.sendEmailVerification();
      return credential;
    } on FirebaseAuthException catch (error, stackTrace) {
      throw _failure(error, stackTrace, 'Account registration');
    } catch (error, stackTrace) {
      throw _unexpectedFailure(error, stackTrace, 'Account registration');
    }
  }

  Future<void> resetPassword(String email) async {
    _validateEmail(email);
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error, stackTrace) {
      throw _failure(error, stackTrace, 'Password reset');
    } catch (error, stackTrace) {
      throw _unexpectedFailure(error, stackTrace, 'Password reset');
    }
  }

  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user == null) {
      throw const AuthFailureException('You must be signed in.');
    }
    if (user.emailVerified) return;
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (error, stackTrace) {
      throw _failure(error, stackTrace, 'Email verification');
    }
  }

  Future<bool> checkEmailVerification() async {
    final user = currentUser;
    if (user == null) return false;
    await user.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  Future<String?> refreshToken({bool forceRefresh = true}) async {
    final user = currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken(forceRefresh);
    } on FirebaseAuthException catch (error, stackTrace) {
      throw _failure(error, stackTrace, 'Token refresh');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (!kIsWeb) await _googleSignIn.signOut();
    } finally {
      _otpRateLimiter.reset();
    }
  }

  void _validateEmail(String email) {
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[A-Za-z]{2,}$').hasMatch(email.trim())) {
      throw const InvalidEmailException('Enter a valid email address.');
    }
  }

  void _validatePassword(String password, {required bool requireStrength}) {
    if (password.isEmpty) {
      throw const WeakPasswordException('Enter a password.');
    }
    if (requireStrength && !PasswordValidator.isStrong(password)) {
      throw const WeakPasswordException(
      'Password must be at least 8 characters and include uppercase, lowercase, a number, and a special character.',
      );
    }
  }

  AuthFailureException _failure(
    FirebaseAuthException error,
    StackTrace stackTrace,
    String operation,
  ) {
    logger.error('$operation failed',
        tag: 'Auth', error: error, stackTrace: stackTrace);
    return AuthFailureException(_firebaseMessage(error), code: error.code);
  }

  AuthFailureException _unexpectedFailure(
      Object error, StackTrace stackTrace, String operation) {
    logger.error('$operation failed',
        tag: 'Auth', error: error, stackTrace: stackTrace);
    return const AuthFailureException(
        'Authentication failed. Please try again.');
  }

  String _firebaseMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-phone-number':
        return 'Enter a valid phone number with country code.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again later.';
      case 'invalid-verification-code':
        return 'The OTP is incorrect. Please check the 6-digit code.';
      case 'session-expired':
        return 'This OTP has expired. Please request a new one.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'invalid-credential':
      case 'wrong-password':
        return 'The email or password is incorrect.';
      case 'user-not-found':
        return 'No account was found for this email address.';
      case 'weak-password':
        return 'Choose a stronger password with at least 8 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'popup-closed-by-user':
        return 'Google sign-in was cancelled.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  late final StreamSubscription<User?> _authSub;

  @override
  AuthState build() {
    final authService = ref.read(authServiceProvider);
    _authSub = authService.authStateChanges.listen((user) {
      state = state.copyWith(user: user, clearUser: user == null);
    });
    ref.onDispose(() {
      _authSub.cancel();
    });
    return AuthState(user: authService.currentUser);
  }

  Future<UserCredential> signInWithGoogle() => _runUserOperation(
        () => ref.read(authServiceProvider).signInWithGoogle(),
      );

  Future<UserCredential> verifyOTP(String verificationId, String otp) =>
      _runUserOperation(
        () => ref.read(authServiceProvider).verifyOTP(verificationId, otp),
      );

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _runUserOperation(
        () => ref.read(authServiceProvider).signInWithEmail(email, password),
      );

  Future<UserCredential> registerWithEmail(String email, String password) =>
      _runUserOperation(
        () => ref.read(authServiceProvider).registerWithEmail(email, password),
      );

  Future<void> resetPassword(String email) => _runOperation(
        () => ref.read(authServiceProvider).resetPassword(email),
      );

  Future<void> sendEmailVerification() => _runOperation(
        () => ref.read(authServiceProvider).sendEmailVerification(),
      );

  Future<void> verifyPhone(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onError,
    Function(UserCredential)? onAutoVerified,
  ) =>
      _runOperation(
        () => ref.read(authServiceProvider).verifyPhone(
          phoneNumber,
          (id) {
            state = state.copyWith(isLoading: false);
            onCodeSent(id);
          },
          (message) {
            state = state.copyWith(isLoading: false, error: message);
            onError(message);
          },
          (credential) {
            state = state.copyWith(user: credential.user, isLoading: false);
            onAutoVerified?.call(credential);
          },
        ),
      );

  Future<bool> checkEmailVerification() async {
    final verified =
        await ref.read(authServiceProvider).checkEmailVerification();
    state = state.copyWith(user: ref.read(authServiceProvider).currentUser);
    return verified;
  }

  Future<String?> refreshToken({bool forceRefresh = true}) =>
      ref.read(authServiceProvider).refreshToken(forceRefresh: forceRefresh);

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authServiceProvider).signOut();
      state = const AuthState();
    } catch (error, stackTrace) {
      logger.error('Sign-out failed',
          tag: 'Auth', error: error, stackTrace: stackTrace);
      state = AuthState(error: error.toString());
      rethrow;
    }
  }

  Future<UserCredential> _runUserOperation(
    Future<UserCredential> Function() operation,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await operation();
      state = state.copyWith(user: credential.user, isLoading: false);
      return credential;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      rethrow;
    }
  }

  Future<void> _runOperation(Future<void> Function() operation) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await operation();
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      rethrow;
    }
  }
}
