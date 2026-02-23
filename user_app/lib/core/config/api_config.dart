/// API configuration for backend communication.
///
/// Contains configurable settings for the backend API endpoints.
/// All values should be provided via --dart-define at build time.
///
/// ## Build Configuration
///
/// Required settings must be provided at build time:
/// ```bash
/// flutter build apk \
///   --dart-define=API_BASE_URL=https://your-web-app.vercel.app
/// ```
class ApiConfig {
  ApiConfig._();

  /// Base URL for the backend API.
  ///
  /// Must be provided via --dart-define=API_BASE_URL=...
  /// This should point to the user-web deployment (e.g., Vercel).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '', // No default - must be configured
  );

  /// Validates that required environment variables are configured.
  ///
  /// Call this during app initialization to get clear error messages.
  static void validateConfiguration() {
    if (baseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL not configured. '
        'Build with: --dart-define=API_BASE_URL=https://your-web-app.vercel.app',
      );
    }
  }

  /// Payment API endpoints.
  static String get createOrderUrl => '$baseUrl/api/payments/create-order';
  static String get verifyPaymentUrl => '$baseUrl/api/payments/verify';

  /// Cloudinary API endpoints.
  static String get cloudinaryUploadUrl => '$baseUrl/api/cloudinary/upload';
  static String get cloudinaryDeleteUrl => '$baseUrl/api/cloudinary/delete';
}
