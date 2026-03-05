library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart' hide ApiException;
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository();

  Future<Map<String, dynamic>> checkSupervisorStatus(String email) async {
    try {
      final response = await ApiClient.get('/auth/supervisor-status', queryParams: {'email': email});
      if (response == null) return {'status': 'not_found'};
      return response as Map<String, dynamic>;
    } on ApiException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  Future<void> sendOTP({required String email, required String purpose, String role = 'supervisor'}) async {
    try {
      await ApiClient.post('/auth/send-otp', {
        'email': email,
        'purpose': purpose,
        'role': role,
      });
    } on ApiException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  Future<UserModel> verifyOTP({required String email, required String otp, required String purpose, String role = 'supervisor'}) async {
    try {
      final response = await ApiClient.post('/auth/verify', {
        'email': email,
        'otp': otp,
        'purpose': purpose,
        'role': role,
      });
      if (response == null) throw const AppAuthException('Verification failed');

      final accessToken = response['accessToken'] as String? ?? '';
      final refreshToken = response['refreshToken'] as String? ?? '';
      if (accessToken.isNotEmpty) {
        await TokenStorage.saveTokens(accessToken, refreshToken);
      }

      final userData = response['user'] as Map<String, dynamic>? ?? response['profile'] as Map<String, dynamic>?;
      if (userData == null) throw const AppAuthException('No user data returned');
      return UserModel.fromJson(userData);
    } on ApiException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  Future<void> supervisorSignup({
    required String email,
    required String otp,
    required String fullName,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      await ApiClient.post('/auth/supervisor-signup', {
        'email': email,
        'otp': otp,
        'fullName': fullName,
        'metadata': metadata,
      });
    } on ApiException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  Future<void> signOut() async {
    try {
      try {
        await ApiClient.post('/auth/logout');
      } catch (_) {}
      await TokenStorage.clearTokens();
    } catch (e) {
      await TokenStorage.clearTokens();
      if (e is AppAuthException) rethrow;
      throw AppAuthException('Failed to sign out: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final hasTokens = await TokenStorage.hasTokens();
      if (!hasTokens) return null;

      final response = await ApiClient.get('/auth/me');
      if (response == null) return null;

      final userData = response['user'] as Map<String, dynamic>?
          ?? response['profile'] as Map<String, dynamic>?
          ?? response;
      return UserModel.fromJson(userData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('getCurrentUser failed: $e');
      return null;
    }
  }

  Future<bool> hasSession() async {
    return TokenStorage.hasTokens();
  }

  Future<UserModel?> recoverSession() async {
    try {
      final hasTokens = await TokenStorage.hasTokens();
      if (!hasTokens) return null;
      return await getCurrentUser();
    } catch (e) {
      debugPrint('Session recovery failed: $e');
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    return TokenStorage.hasTokens();
  }

  Future<UserModel?> fetchUserProfile(String userId) async {
    try {
      final response = await ApiClient.get('/profiles/$userId');
      if (response == null) return null;

      final data = response is Map<String, dynamic>
          ? (response['profile'] as Map<String, dynamic>? ?? response)
          : response as Map<String, dynamic>;

      return UserModel.fromJson(data);
    } on ApiException catch (e) {
      throw ServerException(e.message, null);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ServerException('Failed to fetch profile: $e', null);
    }
  }

  Future<Map<String, dynamic>?> fetchSupervisorData(String userId) async {
    try {
      final response = await ApiClient.get('/supervisors/$userId');
      return response as Map<String, dynamic>?;
    } on ApiException catch (e) {
      throw ServerException(e.message, null);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ServerException('Failed to fetch supervisor data: $e', null);
    }
  }

  Future<bool> isActivatedSupervisor(String userId) async {
    try {
      final response = await ApiClient.get('/supervisors/$userId/activation-status');
      if (response == null) return false;
      return (response['isActivated'] ?? response['is_activated']) as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
