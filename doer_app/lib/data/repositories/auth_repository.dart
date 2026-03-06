import 'package:google_sign_in/google_sign_in.dart';

import '../../core/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/logger_service.dart';
import '../../core/storage/token_storage.dart';
import '../models/doer_model.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';

// Re-export models for convenience
export '../models/user_model.dart' show ProfileSetupData, BankDetailsFormData;

/// Auth response returned by the Express API.
class AuthResponse {
  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? user;

  AuthResponse({this.accessToken, this.refreshToken, this.user});

  bool get hasSession => accessToken != null && refreshToken != null;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] as Map<String, dynamic>?,
    );
  }
}

/// Abstract interface for authentication repository operations.
///
/// Defines the contract for authentication-related data operations including
/// user registration, login, session management, and profile operations.
abstract class AuthRepository {
  /// Gets the current authenticated user ID from stored tokens.
  Future<String?> getCurrentUserId();

  /// Signs up a new user with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });

  /// Signs in an existing user with email and password.
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Sends an OTP to the given email address.
  Future<void> sendOtp(String email, {String purpose = 'login'});

  /// Verifies the OTP for the given email address.
  Future<AuthResponse> verifyOtp(String email, String otp, {String purpose = 'login'});

  /// Fetches user profile from database.
  Future<UserModel?> fetchUserProfile(String userId);

  /// Creates initial profile in database.
  Future<void> createProfile({
    required String userId,
    required String email,
    required String fullName,
    required String phone,
  });

  /// Creates doer record for the user.
  Future<String> createDoerProfile({
    required String profileId,
    required ProfileSetupData data,
  });

  /// Updates doer profile.
  Future<void> updateDoerProfile(String doerId, ProfileSetupData data);

  /// Adds skills to doer.
  Future<void> addDoerSkills(String doerId, List<String> skillIds);

  /// Adds subjects to doer.
  Future<void> addDoerSubjects(String doerId, List<String> subjectIds, String? primarySubjectId);

  /// Updates bank details.
  Future<void> updateBankDetails(String doerId, BankDetailsFormData data);

  /// Signs in with Google OAuth.
  Future<bool> signInWithGoogle();

  /// Gets available skills.
  Future<List<SkillModel>> getAvailableSkills();

  /// Gets available subjects.
  Future<List<SubjectModel>> getAvailableSubjects();

  /// Signs in with magic link (passwordless email authentication).
  Future<bool> signInWithMagicLink({
    required String email,
    String? redirectTo,
  });

  /// Sends a password reset email.
  Future<void> resetPasswordForEmail(String email);
}

/// API implementation of [AuthRepository].
///
/// Provides concrete implementation of authentication operations using
/// the Express API backend.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository();

  @override
  Future<String?> getCurrentUserId() async {
    try {
      final response = await ApiClient.get('/auth/me');
      if (response is Map<String, dynamic>) {
        // API returns { profile: { _id: ... }, roleData: {...} }
        final profile = response['profile'] as Map<String, dynamic>?;
        if (profile != null) {
          return (profile['_id'] ?? profile['id'])?.toString();
        }
        return (response['_id'] ?? response['id'] ?? response['user']?['_id'] ?? response['user']?['id'])?.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    LoggerService.info('AuthRepository: Signing up user', data: {'email': email});

    final response = await ApiClient.post('/auth/signup', {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'userType': 'doer',
    });

    final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);
    if (authResponse.hasSession) {
      await TokenStorage.saveTokens(authResponse.accessToken!, authResponse.refreshToken!);
    }
    return authResponse;
  }

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    LoggerService.info('AuthRepository: Signing in user', data: {'email': email});

    final response = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);
    if (authResponse.hasSession) {
      await TokenStorage.saveTokens(authResponse.accessToken!, authResponse.refreshToken!);
    }
    return authResponse;
  }

  @override
  Future<void> signOut() async {
    LoggerService.info('AuthRepository: Signing out user');
    try {
      await ApiClient.post('/auth/logout');
    } catch (_) {
      // Ignore server errors on logout
    }
    await TokenStorage.clearTokens();
  }

  @override
  Future<void> sendOtp(String email, {String purpose = 'login'}) async {
    LoggerService.info('AuthRepository: Sending OTP', data: {'email': email, 'purpose': purpose});
    await ApiClient.post('/auth/send-otp', {
      'email': email.toLowerCase().trim(),
      'purpose': purpose,
      'role': 'doer',
    });
  }

  @override
  Future<AuthResponse> verifyOtp(String email, String otp, {String purpose = 'login'}) async {
    LoggerService.info('AuthRepository: Verifying OTP');

    final response = await ApiClient.post('/auth/verify', {
      'email': email.toLowerCase().trim(),
      'otp': otp,
      'purpose': purpose,
      'role': 'doer',
    });

    final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);
    if (authResponse.hasSession) {
      await TokenStorage.saveTokens(authResponse.accessToken!, authResponse.refreshToken!);
    }
    return authResponse;
  }

  @override
  Future<UserModel?> fetchUserProfile(String userId) async {
    LoggerService.info('AuthRepository: Fetching user profile', data: {'userId': userId});

    try {
      final response = await ApiClient.get('/doers/me');

      if (response == null) {
        LoggerService.warning('AuthRepository: Profile not found', data: {'userId': userId});
        return null;
      }

      // API returns doer data directly (no profile wrapper needed)
      final data = response is Map<String, dynamic>
          ? (response['doer'] as Map<String, dynamic>? ?? response)
          : response as Map<String, dynamic>;

      return UserModel.fromJson(data);
    } catch (e) {
      LoggerService.error('AuthRepository: Error fetching user profile', e);
      return null;
    }
  }

  @override
  Future<void> createProfile({
    required String userId,
    required String email,
    required String fullName,
    required String phone,
  }) async {
    LoggerService.info('AuthRepository: Creating doer', data: {'userId': userId});

    await ApiClient.post('/doers', {
      'id': userId,
      'email': email,
      'full_name': fullName,
      'phone': phone.startsWith('+') ? phone : '+91$phone',
      'user_type': 'doer',
    });
  }

  @override
  Future<String> createDoerProfile({
    required String profileId,
    required ProfileSetupData data,
  }) async {
    LoggerService.info('AuthRepository: Creating doer profile', data: {'doerId': profileId});

    final response = await ApiClient.post('/doers', {
      ...data.toDoerInsertData(profileId),
      'skillIds': data.skillIds,
      'subjectIds': data.subjectIds,
      'primarySubjectId': data.primarySubjectId,
    });

    final responseMap = response as Map<String, dynamic>;
    return (responseMap['_id'] ?? responseMap['id'] ?? '').toString();
  }

  @override
  Future<void> updateDoerProfile(String doerId, ProfileSetupData data) async {
    LoggerService.info('AuthRepository: Updating doer profile', data: {'doerId': doerId});

    await ApiClient.put('/doers/$doerId', {
      ...data.toDoerUpdateData(),
      'skillIds': data.skillIds,
      'subjectIds': data.subjectIds,
      'primarySubjectId': data.primarySubjectId,
    });
  }

  @override
  Future<void> addDoerSkills(String doerId, List<String> skillIds) async {
    LoggerService.info('AuthRepository: Adding doer skills', data: {'doerId': doerId, 'count': skillIds.length});

    await ApiClient.post('/doers/$doerId/skills', {
      'skillIds': skillIds,
    });
  }

  @override
  Future<void> addDoerSubjects(String doerId, List<String> subjectIds, String? primarySubjectId) async {
    LoggerService.info('AuthRepository: Adding doer subjects', data: {'doerId': doerId, 'count': subjectIds.length});

    await ApiClient.post('/doers/$doerId/subjects', {
      'subjectIds': subjectIds,
      'primarySubjectId': primarySubjectId,
    });
  }

  @override
  Future<void> updateBankDetails(String doerId, BankDetailsFormData data) async {
    LoggerService.info('AuthRepository: Updating bank details', data: {'doerId': doerId});

    await ApiClient.put('/doers/$doerId/bank-details', data.toDoerUpdateData());
  }

  @override
  Future<List<SkillModel>> getAvailableSkills() async {
    LoggerService.info('AuthRepository: Fetching available skills');

    final response = await ApiClient.get('/skills?active=true');
    final list = response is List ? response : (response as Map<String, dynamic>)['skills'] as List? ?? [];

    return list
        .map((json) => SkillModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SubjectModel>> getAvailableSubjects() async {
    LoggerService.info('AuthRepository: Fetching available subjects');

    final response = await ApiClient.get('/subjects?active=true');
    final list = response is List ? response : (response as Map<String, dynamic>)['subjects'] as List? ?? [];

    return list
        .map((json) => SubjectModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> signInWithGoogle() async {
    LoggerService.info('AuthRepository: Starting Google Sign In...');

    try {
      const webClientId = ApiConstants.googleWebClientId;

      if (webClientId.isEmpty) {
        LoggerService.error('AuthRepository: Google Web Client ID not configured', Exception('Missing GOOGLE_WEB_CLIENT_ID'));
        throw Exception('Google Web Client ID not configured. Pass GOOGLE_WEB_CLIENT_ID as --dart-define');
      }

      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        LoggerService.info('AuthRepository: User cancelled Google Sign In');
        return false;
      }

      LoggerService.info('AuthRepository: Google user selected: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        LoggerService.error('AuthRepository: Failed to get ID token from Google', Exception('Missing idToken'));
        throw Exception('Missing idToken from Google authentication');
      }

      // Exchange Google token with our API
      final response = await ApiClient.post('/auth/google', {
        'idToken': idToken,
        'accessToken': accessToken,
      });

      final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);
      if (authResponse.hasSession) {
        await TokenStorage.saveTokens(authResponse.accessToken!, authResponse.refreshToken!);
      }

      LoggerService.info('AuthRepository: Google sign in ${authResponse.hasSession ? 'successful' : 'failed'}');
      return authResponse.hasSession;
    } catch (e, stackTrace) {
      LoggerService.error('AuthRepository: Google sign-in failed', e);
      LoggerService.error('AuthRepository: Stack trace', stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> signInWithMagicLink({
    required String email,
    String? redirectTo,
  }) async {
    LoggerService.info('AuthRepository: Sending magic link...', data: {'email': email});

    try {
      await ApiClient.post('/auth/magic-link', {
        'email': email,
        'redirectTo': redirectTo,
      });

      LoggerService.info('AuthRepository: Magic link sent successfully to $email');
      return true;
    } catch (e, stackTrace) {
      LoggerService.error('AuthRepository: Magic link failed', e);
      LoggerService.error('AuthRepository: Stack trace', stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    LoggerService.info('AuthRepository: Sending password reset email...', data: {'email': email});

    try {
      await ApiClient.post('/auth/reset-password', {
        'email': email,
      });

      LoggerService.info('AuthRepository: Password reset email sent successfully to $email');
    } catch (e, stackTrace) {
      LoggerService.error('AuthRepository: Password reset failed', e);
      LoggerService.error('AuthRepository: Stack trace', stackTrace);
      rethrow;
    }
  }
}
