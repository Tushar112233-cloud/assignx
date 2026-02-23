/// Razorpay configuration for payment processing.
///
/// Contains API keys and checkout configuration.
/// SECURITY: API keys MUST be provided via --dart-define at build time.
/// NEVER hardcode credentials in source code.
///
/// ## Build Configuration
///
/// Required settings must be provided at build time:
/// ```bash
/// flutter build apk \
///   --dart-define=RAZORPAY_KEY_ID=rzp_live_xxxxx \
///   --dart-define=RAZORPAY_TEST_MODE=false
/// ```
///
/// For development with test mode:
/// ```bash
/// flutter run \
///   --dart-define=RAZORPAY_KEY_ID=rzp_test_xxxxx \
///   --dart-define=RAZORPAY_TEST_MODE=true
/// ```
class RazorpayConfig {
  RazorpayConfig._();

  /// Razorpay API Key ID.
  ///
  /// SECURITY: Must be provided via --dart-define=RAZORPAY_KEY_ID=...
  /// This is the publishable key (safe for client-side).
  /// The secret key should NEVER be in the mobile app.
  static const String apiKey = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '', // No default - must be configured
  );

  /// Whether to use test mode.
  ///
  /// When true, uses Razorpay test environment.
  /// IMPORTANT: Set to false for production builds.
  static const bool isTestMode = bool.fromEnvironment(
    'RAZORPAY_TEST_MODE',
    defaultValue: true, // Default to test mode for safety
  );

  /// Validates that required environment variables are configured.
  ///
  /// Call this during app initialization to get clear error messages.
  static void validateConfiguration() {
    if (apiKey.isEmpty) {
      throw StateError(
        'RAZORPAY_KEY_ID not configured. '
        'Build with: --dart-define=RAZORPAY_KEY_ID=rzp_xxxxx',
      );
    }
  }

  /// Razorpay company name displayed during checkout.
  static const String companyName = 'AssignX';

  /// Razorpay company description.
  static const String description = 'Academic Support Platform';

  /// Company logo URL for checkout.
  static const String logoUrl = 'https://assignx.in/logo.png';

  /// Theme color for Razorpay checkout (hex without #).
  static const String themeColor = '6366F1';

  /// Prefill customer details for checkout.
  ///
  /// @param name Customer's full name.
  /// @param email Customer's email address.
  /// @param phone Customer's phone number.
  /// @returns Map of prefill data for Razorpay checkout.
  static Map<String, String> getPrefillData({
    String? name,
    String? email,
    String? phone,
  }) {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'contact': phone,
    };
  }

  /// Create checkout options for Razorpay.
  ///
  /// @param amountInPaise Payment amount in paise (1 INR = 100 paise).
  /// @param orderId Server-generated Razorpay order ID.
  /// @param name Customer's full name.
  /// @param email Customer's email address.
  /// @param phone Customer's phone number.
  /// @param description Payment description shown to user.
  /// @returns Map of options for Razorpay checkout.
  static Map<String, dynamic> createCheckoutOptions({
    required int amountInPaise,
    required String orderId,
    String? name,
    String? email,
    String? phone,
    String? description,
  }) {
    return {
      'key': apiKey,
      'amount': amountInPaise,
      'name': companyName,
      'description': description ?? RazorpayConfig.description,
      'order_id': orderId,
      'prefill': getPrefillData(name: name, email: email, phone: phone),
      'theme': {
        'color': '#$themeColor',
      },
    };
  }
}
