import 'package:logger/logger.dart';
import '../config/razorpay_config.dart';

/// Service to test Razorpay configuration
class RazorpayTestService {
  static final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  /// Test if Razorpay credentials are configured
  static Map<String, dynamic> testConfiguration() {
    final apiKey = RazorpayConfig.apiKey;
    final isTestMode = RazorpayConfig.isTestMode;

    final isConfigured = apiKey.isNotEmpty && apiKey != 'your_razorpay_key_id';
    final keyPrefix = apiKey.length >= 12 ? '${apiKey.substring(0, 12)}...' : apiKey;

    final result = {
      'configured': isConfigured,
      'credentials': {
        'RAZORPAY_KEY_ID': isConfigured ? keyPrefix : 'NOT SET',
        'isTestMode': isTestMode,
      },
      'companyName': RazorpayConfig.companyName,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _logger.i('Razorpay Configuration Test Results:\n${result.toString()}');

    return result;
  }

  /// Log configuration status
  static void logStatus() {
    final config = testConfiguration();
    final isConfigured = config['configured'] as bool;

    if (isConfigured) {
      _logger.i('✅ Razorpay is properly configured');
      _logger.i('   Key: ${config['credentials']['RAZORPAY_KEY_ID']}');
      _logger.i('   Test Mode: ${config['credentials']['isTestMode']}');
    } else {
      _logger.w('⚠️ Razorpay is NOT configured');
      _logger.w('   Make sure to run with --dart-define flags');
    }
  }
}
