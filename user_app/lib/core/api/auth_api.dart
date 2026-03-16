import 'api_client.dart';
import '../storage/token_storage.dart';

class AuthApi {
  /// Check if an account exists for the given email.
  ///
  /// API expects `{ email, role }` and returns `{ exists: bool }`.
  static Future<bool> checkAccount(String email, {String role = 'user'}) async {
    final response = await ApiClient.post('/auth/check-account', {
      'email': email,
      'role': role,
    });
    final data = response as Map<String, dynamic>;
    return data['exists'] == true;
  }

  /// Send OTP to the given email.
  ///
  /// API requires all three fields: `{ email, purpose, role }`.
  static Future<void> sendOTP(String email, String purpose, {String role = 'user'}) async {
    await ApiClient.post('/auth/send-otp', {
      'email': email,
      'purpose': purpose,
      'role': role,
    });
  }

  /// Verify the OTP code.
  ///
  /// API requires `{ email, otp, purpose, role }`.
  /// Saves tokens on success and returns the full response including
  /// `{ accessToken, refreshToken, user, profile }`.
  static Future<Map<String, dynamic>> verifyOTP(
    String email,
    String otp,
    String purpose, {
    String role = 'user',
  }) async {
    final response = await ApiClient.post('/auth/verify', {
      'email': email,
      'otp': otp,
      'purpose': purpose,
      'role': role,
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

  /// Get the currently authenticated user from `/users/me`.
  ///
  /// Returns the user object with fields like `id`, `email`, `fullName`,
  /// `avatarUrl`, `userType`, plus snake_case aliases.
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await ApiClient.get('/users/me');
      return response as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
