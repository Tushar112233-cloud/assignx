library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isActivated = false,
  });

  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isActivated;

  bool get isAuthenticated => user != null;

  factory AuthState.initial() => const AuthState(isLoading: true);

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isActivated,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isActivated: isActivated ?? this.isActivated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(AuthState.initial()) {
    _init();
  }

  final AuthRepository _repository;

  Future<void> _init() async {
    try {
      final user = await _repository.recoverSession();
      if (user != null) {
        await _loadUserData(user);
      } else {
        state = const AuthState();
      }
    } catch (e) {
      debugPrint('Auth init failed: $e');
      state = const AuthState();
    }
  }

  Future<void> _loadUserData(UserModel user) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      bool isActivated = false;
      try {
        isActivated = await _repository.isActivatedSupervisor(user.id);
      } catch (e) {
        debugPrint('Activation check failed: $e');
      }

      UserModel? profile;
      try {
        profile = await _repository.fetchUserProfile();
      } catch (e) {
        debugPrint('Profile fetch failed: $e');
      }

      state = state.copyWith(
        user: profile ?? user,
        isActivated: isActivated,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('_loadUserData failed: $e');
      state = state.copyWith(
        user: user,
        isLoading: false,
        error: 'Failed to load user data',
      );
    }
  }

  Future<Map<String, dynamic>> checkSupervisorStatus(String email) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final result = await _repository.checkSupervisorStatus(email);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> sendOTP({required String email, required String purpose}) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _repository.sendOTP(email: email, purpose: purpose);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<bool> verifyOTP({required String email, required String otp, required String purpose}) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final user = await _repository.verifyOTP(email: email, otp: otp, purpose: purpose);
      await _loadUserData(user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> supervisorSignup({
    required String email,
    required String otp,
    required String fullName,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _repository.supervisorSignup(email: email, otp: otp, fullName: fullName, metadata: metadata);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _repository.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> refreshUser() async {
    final currentUser = await _repository.getCurrentUser();
    if (currentUser != null) {
      await _loadUserData(currentUser);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isActivatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isActivated;
});
