import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/auth_service.dart';

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

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

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
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      onError(e.toString());
    }
  }

  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await ref.read(authServiceProvider).verifyOTP(verificationId, otp);
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
      final credential = await ref.read(authServiceProvider).signInWithEmail(email, password);
      state = state.copyWith(user: credential.user, isLoading: false);
      return credential;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<UserCredential> registerWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await ref.read(authServiceProvider).registerWithEmail(email, password);
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
