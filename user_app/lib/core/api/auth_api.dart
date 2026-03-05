import 'api_client.dart';
import '../storage/token_storage.dart';

class AuthApi {
  /// Check if an account exists for the given email.
  static Future<bool> checkAccount(String email) async {
    final response = await ApiClient.post('/auth/check-account', {'email': email});
    final data = response as Map<String, dynamic>;
    return data['exists'] == true;
  }

  /// Send OTP to the given email.
  static Future<void> sendOTP(String email, String purpose, {String? role}) async {
    await ApiClient.post('/auth/send-otp', {
      'email': email,
      'purpose': purpose,
      if (role != null) 'role': role,
    });
  }

  /// Verify the OTP code.
  /// Saves tokens on success and returns the user data.
  static Future<Map<String, dynamic>> verifyOTP(
    String email,
    String otp,
    String purpose, {
    String? role,
  }) async {
    final response = await ApiClient.post('/auth/verify', {
      'email': email,
      'otp': otp,
      'purpose': purpose,
      if (role != null) 'role': role,
    });
    final data = response as Map<String, dynamic>;

    if (data['accessToken'] != null && data['refreshToken'] != null) {
      await TokenStorage.saveTokens(
        data['accessToken'] as String,
        data['refreshToken'] as String,
      );
    }

    return data;
  }

  /// Log out the current user and clear tokens.
  static Future<void> logout() async {
    try {
      await ApiClient.post('/auth/logout');
    } catch (_) {}
    await TokenStorage.clearTokens();
  }

  /// Get the currently authenticated user.
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await ApiClient.get('/auth/me');
      return response as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
