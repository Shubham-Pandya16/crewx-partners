import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';

class AuthState {
  final bool isLoading;
  final String? verificationId;
  final String? error;
  final User? user;

  AuthState({
    this.isLoading = false,
    this.verificationId,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? verificationId,
    String? error,
    User? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      verificationId: verificationId ?? this.verificationId,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState(user: _authService.currentUser));

  Future<void> sendOtp({
    required String phone,
    required Function(String vId) onCodeSent,
    required Function(String error) onFailed,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    await _authService.sendOtp(
      phone: phone,
      verificationCompleted: (cred) async {
        try {
          final res = await FirebaseAuth.instance.signInWithCredential(cred);
          state = state.copyWith(isLoading: false, user: res.user);
        } catch (e) {
          state = state.copyWith(isLoading: false, error: e.toString());
        }
      },
      verificationFailed: (e) {
        state = state.copyWith(isLoading: false, error: e.message);
        onFailed(e.message ?? 'Verification failed');
      },
      codeSent: (vId, token) {
        state = state.copyWith(isLoading: false, verificationId: vId);
        onCodeSent(vId);
      },
      codeAutoRetrievalTimeout: (vId) {
        state = state.copyWith(verificationId: vId);
      },
    );
  }

  Future<UserCredential?> verifyOtp(String vId, String smsCode) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cred = await _authService.verifyOtp(vId, smsCode);
      state = state.copyWith(isLoading: false, user: cred.user);
      return cred;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = AuthState();
  }
}

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
