import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    try {
      debugPrint('Google Sign-In: opening account picker');
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Google Sign-In cancelled by user');
        throw AuthCancelledException('Google sign-in was cancelled');
      }

      debugPrint('Google Sign-In: fetching Google auth tokens');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('Google Sign-In: signing in with Firebase credential');
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      debugPrint(
        'Google Sign-In: success for uid ${userCredential.user?.uid ?? 'unknown'}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('Google Sign-In Firebase Error [${e.code}]: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);
      throw AuthFailureException(_firebaseMessage(e));
    } on AuthCancelledException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw AuthFailureException(
        'Google sign-in failed. Check Play Services and Firebase SHA-1 setup.',
      );
    }
  }

  Future<void> verifyPhone(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onError,
    Function(UserCredential)? onAutoVerified,
  ) async {
    final normalizedPhoneNumber = _normalizeIndianPhoneNumber(phoneNumber);
    debugPrint('OTP: starting verification for $normalizedPhoneNumber');

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: normalizedPhoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        try {
          debugPrint('OTP: automatic verification completed');
          final userCredential =
              await _firebaseAuth.signInWithCredential(credential);
          debugPrint(
            'OTP: automatic sign-in success for uid ${userCredential.user?.uid ?? 'unknown'}',
          );
          onAutoVerified?.call(userCredential);
        } on FirebaseAuthException catch (e, stackTrace) {
          debugPrint('OTP Auto Sign-In Error [${e.code}]: ${e.message}');
          debugPrintStack(stackTrace: stackTrace);
          onError(_firebaseMessage(e));
        } catch (e, stackTrace) {
          debugPrint('OTP Auto Sign-In Error: $e');
          debugPrintStack(stackTrace: stackTrace);
          onError('Automatic OTP verification failed. Please enter the OTP.');
        }
      },
      verificationFailed: (e) {
        debugPrint('OTP Error [${e.code}]: ${e.message}');
        onError(_firebaseMessage(e));
      },
      codeSent: (verificationId, resendToken) {
        debugPrint('OTP: code sent. resendToken=$resendToken');
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        debugPrint('OTP: auto retrieval timed out for verificationId');
      },
    );
  }

  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    try {
      debugPrint('OTP: verifying manual SMS code');
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      debugPrint(
        'OTP: manual sign-in success for uid ${userCredential.user?.uid ?? 'unknown'}',
      );
      return userCredential;
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint('OTP Verify Error [${e.code}]: ${e.message}');
      debugPrintStack(stackTrace: stackTrace);
      throw AuthFailureException(_firebaseMessage(e));
    } catch (e, stackTrace) {
      debugPrint('OTP Verify Error: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw AuthFailureException('OTP verification failed. Please try again.');
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail(
      String email, String password) async {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  User? get currentUser => _firebaseAuth.currentUser;

  String _normalizeIndianPhoneNumber(String phoneNumber) {
    final compact = phoneNumber.replaceAll(RegExp(r'\s+|-'), '');
    if (compact.startsWith('+')) return compact;

    final digitsOnly = compact.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.startsWith('91') && digitsOnly.length == 12) {
      return '+$digitsOnly';
    }
    return '+91$digitsOnly';
  }

  String _firebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
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
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}

class AuthFailureException implements Exception {
  final String message;

  const AuthFailureException(this.message);

  @override
  String toString() => message;
}

class AuthCancelledException implements Exception {
  final String message;

  const AuthCancelledException(this.message);

  @override
  String toString() => message;
}



class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
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
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      state = state.copyWith(user: user);
    });
    ref.onDispose(() {
      _authSub.cancel();
    });
    return AuthState(user: authService.currentUser);
  }

  Future<UserCredential> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await ref.read(authServiceProvider).signInWithGoogle();
      state = state.copyWith(user: credential.user, isLoading: false);
      return credential;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verifyPhone(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onError,
    Function(UserCredential)? onAutoVerified,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authServiceProvider).verifyPhone(
        phoneNumber,
        (verificationId) {
          state = state.copyWith(isLoading: false);
          onCodeSent(verificationId);
        },
        (message) {
          state = state.copyWith(isLoading: false, error: message);
          onError(message);
        },
        (credential) {
          state = state.copyWith(user: credential.user, isLoading: false);
          onAutoVerified?.call(credential);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      onError(e.toString());
    }
  }

  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential =
          await ref.read(authServiceProvider).verifyOTP(verificationId, otp);
      state = state.copyWith(user: credential.user, isLoading: false);
      return credential;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential =
          await ref.read(authServiceProvider).signInWithEmail(email, password);
      state = state.copyWith(user: credential.user, isLoading: false);
      return credential;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<UserCredential> registerWithEmail(
      String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await ref
          .read(authServiceProvider)
          .registerWithEmail(email, password);
      state = state.copyWith(user: credential.user, isLoading: false);
      return credential;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authServiceProvider).resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authServiceProvider).signOut();
      state = state.copyWith(user: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}


