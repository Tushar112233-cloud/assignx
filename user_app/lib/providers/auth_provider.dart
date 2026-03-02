import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../core/storage/token_storage.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

/// Auth repository provider.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Lightweight user info from JWT / API response.
class AuthUser {
  final String id;
  final String? email;

  const AuthUser({required this.id, this.email});
}

/// Current auth state.
class AuthStateData {
  final AuthUser? user;
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  const AuthStateData({
    this.user,
    this.profile,
    this.isLoading = false,
    this.error,
  });

  /// Check if user is authenticated.
  bool get isAuthenticated => user != null;

  /// Check if user has completed profile.
  bool get hasProfile => profile?.isComplete ?? false;

  /// Copy with updated fields.
  AuthStateData copyWith({
    AuthUser? user,
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return AuthStateData(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth state notifier.
class AuthStateNotifier extends AsyncNotifier<AuthStateData> {
  late AuthRepository _authRepository;

  @override
  Future<AuthStateData> build() async {
    _authRepository = ref.read(authRepositoryProvider);

    // Check if user has stored tokens
    final hasTokens = await TokenStorage.hasTokens();
    if (hasTokens) {
      try {
        final userData = await _authRepository.getCurrentUser();
        if (userData != null) {
          final userId = (userData['_id'] ?? userData['id'] ?? '') as String;
          final email = userData['email'] as String?;
          final user = AuthUser(id: userId, email: email);
          final profile = await _authRepository.getUserProfile(userId);
          return AuthStateData(user: user, profile: profile);
        }
      } catch (_) {
        // Token expired or invalid, clear it
        await TokenStorage.clearTokens();
      }
    }

    return const AuthStateData();
  }

  /// Sign out.
  Future<void> signOut() async {
    state = AsyncValue.data(
        state.valueOrNull?.copyWith(isLoading: true) ??
            const AuthStateData(isLoading: true));

    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(AuthStateData());
    } catch (e) {
      state = AsyncValue.data(
        state.valueOrNull?.copyWith(isLoading: false, error: e.toString()) ??
            AuthStateData(error: e.toString()),
      );
      rethrow;
    }
  }

  /// Update user profile.
  Future<void> updateProfile({
    String? fullName,
    UserType? userType,
    String? avatarUrl,
    String? phone,
    String? city,
    String? state,
    OnboardingStep? onboardingStep,
    bool? onboardingCompleted,
  }) async {
    final user = this.state.valueOrNull?.user;
    if (user == null) return;

    this.state = AsyncValue.data(
        this.state.valueOrNull?.copyWith(isLoading: true) ??
            const AuthStateData(isLoading: true));

    try {
      final profile = await _authRepository.upsertProfile(
        userId: user.id,
        email: user.email ?? '',
        fullName: fullName,
        userType: userType,
        avatarUrl: avatarUrl,
        phone: phone,
        city: city,
        state: state,
        onboardingStep: onboardingStep,
        onboardingCompleted: onboardingCompleted,
      );

      this.state = AsyncValue.data(AuthStateData(user: user, profile: profile));
    } catch (e) {
      this.state = AsyncValue.data(
        this.state.valueOrNull?.copyWith(isLoading: false, error: e.toString()) ??
            AuthStateData(error: e.toString()),
      );
      rethrow;
    }
  }

  /// Save student data to the students table.
  Future<StudentData> saveStudentData({
    String? universityId,
    String? courseId,
    int? semester,
    int? yearOfStudy,
    String? studentIdNumber,
    int? expectedGraduationYear,
    String? collegeEmail,
    List<String>? preferredSubjects,
  }) async {
    final user = state.valueOrNull?.user;
    if (user == null) {
      throw StateError('User must be authenticated to save student data');
    }

    return await _authRepository.saveStudentData(
      profileId: user.id,
      universityId: universityId,
      courseId: courseId,
      semester: semester,
      yearOfStudy: yearOfStudy,
      studentIdNumber: studentIdNumber,
      expectedGraduationYear: expectedGraduationYear,
      collegeEmail: collegeEmail,
      preferredSubjects: preferredSubjects,
    );
  }

  /// Save professional data to the professionals table.
  Future<ProfessionalData> saveProfessionalData({
    required ProfessionalType professionalType,
    String? industryId,
    String? jobTitle,
    String? companyName,
    String? linkedinUrl,
    String? businessType,
    String? gstNumber,
  }) async {
    final user = state.valueOrNull?.user;
    if (user == null) {
      throw StateError('User must be authenticated to save professional data');
    }

    return await _authRepository.saveProfessionalData(
      profileId: user.id,
      professionalType: professionalType,
      industryId: industryId,
      jobTitle: jobTitle,
      companyName: companyName,
      linkedinUrl: linkedinUrl,
      businessType: businessType,
      gstNumber: gstNumber,
    );
  }

  /// Get student data for the current user.
  Future<StudentData?> getStudentData() async {
    final user = state.valueOrNull?.user;
    if (user == null) return null;

    return await _authRepository.getStudentData(user.id);
  }

  /// Get professional data for the current user.
  Future<ProfessionalData?> getProfessionalData() async {
    final user = state.valueOrNull?.user;
    if (user == null) return null;

    return await _authRepository.getProfessionalData(user.id);
  }

  /// Set selected user type (before profile completion).
  UserType? get selectedUserType => ref.read(_persistedSelectedUserTypeProvider);

  void setSelectedUserType(UserType userType) {
    ref.read(_persistedSelectedUserTypeProvider.notifier).state = userType;
  }

  /// Store role selected before sign-in (survives OAuth redirect).
  UserType? get preSignInRole => ref.read(_persistedPreSignInRoleProvider);

  void setPreSignInRole(UserType? role) {
    ref.read(_persistedPreSignInRoleProvider.notifier).state = role;
    if (role != null) {
      ref.read(_persistedSelectedUserTypeProvider.notifier).state = role;
    }
  }

  /// Sign in with magic link (passwordless email authentication).
  Future<bool> signInWithMagicLink({
    required String email,
    UserType? userType,
  }) async {
    state = AsyncValue.data(state.valueOrNull?.copyWith(isLoading: true) ??
        const AuthStateData(isLoading: true));

    try {
      if (userType != null) {
        setPreSignInRole(userType);
      }

      final success = await _authRepository.signInWithMagicLink(
        email: email,
        userType: userType,
      );

      state = AsyncValue.data(
        state.valueOrNull?.copyWith(isLoading: false) ?? const AuthStateData(),
      );

      return success;
    } catch (e) {
      state = AsyncValue.data(
        state.valueOrNull?.copyWith(isLoading: false, error: e.toString()) ??
            AuthStateData(error: e.toString()),
      );
      rethrow;
    }
  }

  /// Verify OTP token from magic link.
  Future<bool> verifyOtp({
    required String email,
    required String token,
  }) async {
    state = AsyncValue.data(state.valueOrNull?.copyWith(isLoading: true) ??
        const AuthStateData(isLoading: true));

    try {
      final data = await _authRepository.verifyOtp(
        email: email,
        token: token,
      );

      if (data != null) {
        final userId = (data['user']?['_id'] ?? data['user']?['id'] ?? data['_id'] ?? data['id'] ?? '') as String;
        final userEmail = (data['user']?['email'] ?? data['email'] ?? email) as String;
        final user = AuthUser(id: userId, email: userEmail);
        final profile = await _authRepository.getUserProfile(userId);
        state = AsyncValue.data(AuthStateData(user: user, profile: profile));
        return true;
      } else {
        state = AsyncValue.data(
          state.valueOrNull?.copyWith(isLoading: false) ?? const AuthStateData(),
        );
        return false;
      }
    } catch (e) {
      state = AsyncValue.data(
        state.valueOrNull?.copyWith(isLoading: false, error: e.toString()) ??
            AuthStateData(error: e.toString()),
      );
      rethrow;
    }
  }

  /// Set selected professional type (for professionals).
  ProfessionalType? _selectedProfessionalType;
  ProfessionalType? get selectedProfessionalType => _selectedProfessionalType;

  void setSelectedProfessionalType(ProfessionalType professionalType) {
    _selectedProfessionalType = professionalType;
  }

  /// Refresh the current user profile.
  Future<void> refreshProfile() async {
    final user = state.valueOrNull?.user;
    if (user == null) return;

    final profile = await _authRepository.getUserProfile(user.id);
    state = AsyncValue.data(AuthStateData(user: user, profile: profile));
  }
}

/// Main auth state provider.
final authStateProvider =
    AsyncNotifierProvider<AuthStateNotifier, AuthStateData>(() {
  return AuthStateNotifier();
});

/// Persisted selected user type across notifier rebuilds.
final _persistedSelectedUserTypeProvider = StateProvider<UserType?>((ref) => null);

/// Persisted pre-sign-in role across notifier rebuilds.
final _persistedPreSignInRoleProvider = StateProvider<UserType?>((ref) => null);

/// Convenience provider for current user.
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.user;
});

/// Convenience provider for current profile.
final currentProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.profile;
});

/// Convenience provider for auth loading state.
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoading || (authState.valueOrNull?.isLoading ?? false);
});

/// Universities provider.
final universitiesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(authRepositoryProvider);
  return repository.getUniversities();
});

/// Courses provider for a specific university.
final coursesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, universityId) async {
  final repository = ref.read(authRepositoryProvider);
  return repository.getCourses(universityId);
});

/// Industries provider.
final industriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.read(authRepositoryProvider);
  return repository.getIndustries();
});
