import 'api_client.dart';
import '../storage/token_storage.dart';

/// API wrapper for authentication endpoints.
class AuthApi {
  /// Send a magic link to the given email.
  static Future<void> sendMagicLink(String email) async {
    await ApiClient.post('/auth/magic-link', {'email': email});
  }

  /// Verify the OTP code sent via magic link.
  /// Saves tokens on success and returns the user data.
  static Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    final response = await ApiClient.post('/auth/verify', {
      'email': email,
      'otp': otp,
    });
    final data = response as Map<String, dynamic>;

    // Save JWT tokens
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
    } catch (_) {
      // Ignore errors on logout - clear tokens regardless
    }
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
