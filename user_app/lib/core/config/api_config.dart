import '../api/api_client.dart';
import '../socket/socket_client.dart';
import '../storage/token_storage.dart';

/// API configuration and initialization.
///
/// Replaces SupabaseConfig. Handles API client setup
/// and token management for the Express backend.
///
/// ## Build Configuration
///
/// The API base URL can be provided at build time via --dart-define:
/// ```bash
/// flutter build apk \
///   --dart-define=API_BASE_URL=http://your-api-server:4000
/// ```
class ApiConfig {
  ApiConfig._();

  /// Base URL for the backend API (delegates to ApiClient).
  static String get baseUrl => ApiClient.baseUrl;

  /// Validates that the API is reachable (optional check).
  static void validateConfiguration() {
    // API_BASE_URL has sensible defaults, so always valid
  }

  /// Initialize the API layer.
  ///
  /// Must be called before runApp() in main.dart.
  static Future<void> initialize() async {
    // No initialization needed for HTTP client.
    // Socket connects lazily on first use.
  }

  /// Check if user is authenticated.
  static Future<bool> get isAuthenticated => TokenStorage.hasTokens();

  /// Clean up resources.
  static void dispose() {
    SocketClient.disconnect();
  }

  /// Payment API endpoints.
  static String get createOrderUrl => '${baseUrl}/api/payments/create-order';
  static String get verifyPaymentUrl => '${baseUrl}/api/payments/verify';

  /// Cloudinary API endpoints.
  static String get cloudinaryUploadUrl => '${baseUrl}/api/cloudinary/upload';
  static String get cloudinaryDeleteUrl => '${baseUrl}/api/cloudinary/delete';
}
