/// Application-wide configuration values.
///
/// Contains configurable settings that can be overridden via environment
/// variables at build time using --dart-define.
///
/// ## Build Configuration
///
/// Optional settings can be provided at build time:
/// ```bash
/// flutter build apk \
///   --dart-define=SUPPORT_PHONE=+911234567890 \
///   --dart-define=SUPPORT_EMAIL=support@assignx.in
/// ```
class AppConfig {
  AppConfig._();

  /// Application name.
  static const String appName = 'AssignX';

  /// Application tagline.
  static const String appTagline = 'Get your assignments done by experts';

  /// Support phone number for WhatsApp (with country code).
  ///
  /// Can be overridden via --dart-define=SUPPORT_PHONE=...
  /// Defaults to the configured support number.
  static const String supportPhone = String.fromEnvironment(
    'SUPPORT_PHONE',
    defaultValue: '+919876543210',
  );

  /// Support email address.
  ///
  /// Can be overridden via --dart-define=SUPPORT_EMAIL=...
  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'support@assignx.in',
  );

  /// Default support message for WhatsApp.
  static const String defaultSupportMessage =
      'Hi, I need help with the AssignX app.';

  /// Referral bonus amount (in INR).
  static const double referralBonusAmount = 200.0;

  /// Minimum wallet top-up amount (in INR).
  static const double minTopUpAmount = 100.0;

  /// Maximum wallet top-up amount (in INR).
  static const double maxTopUpAmount = 50000.0;

  /// Default currency code.
  static const String defaultCurrency = 'INR';

  /// Default country code.
  static const String defaultCountry = 'IN';

  /// App Store ID for iOS.
  static const String appStoreId = String.fromEnvironment(
    'APP_STORE_ID',
    defaultValue: '',
  );

  /// Play Store package name.
  static const String playStorePackage = String.fromEnvironment(
    'PLAY_STORE_PACKAGE',
    defaultValue: 'com.assignx.userapp',
  );

  /// Privacy policy URL.
  static const String privacyPolicyUrl =
      'https://assignx.in/privacy-policy';

  /// Terms of service URL.
  static const String termsOfServiceUrl =
      'https://assignx.in/terms-of-service';

  /// Help center URL.
  static const String helpCenterUrl = 'https://help.assignx.in';

  /// Social media links.
  static const String instagramUrl = 'https://instagram.com/assignx';
  static const String twitterUrl = 'https://twitter.com/assignx';
  static const String linkedInUrl = 'https://linkedin.com/company/assignx';

  /// Feature flags.
  static const bool enableMarketplace = true;
  static const bool enableReferrals = true;
  static const bool enableChat = true;

  /// Development/Debug flags.
  static const bool isProduction = bool.fromEnvironment(
    'dart.vm.product',
    defaultValue: false,
  );
}
