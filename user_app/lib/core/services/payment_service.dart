import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../config/api_config.dart';
import '../config/razorpay_config.dart';
import '../config/supabase_config.dart';

/// Payment result model containing payment response data.
class PaymentResult {
  /// Whether the payment was successful.
  final bool success;

  /// Razorpay payment ID (on success).
  final String? paymentId;

  /// Razorpay order ID.
  final String? orderId;

  /// Razorpay signature for verification.
  final String? signature;

  /// Error code (on failure).
  final String? errorCode;

  /// Error message (on failure).
  final String? errorMessage;

  /// Transaction ID from server (on verified success).
  final String? transactionId;

  /// New wallet balance (for top-ups).
  final double? newBalance;

  const PaymentResult({
    required this.success,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorCode,
    this.errorMessage,
    this.transactionId,
    this.newBalance,
  });
}

/// Server order creation response.
class _OrderResponse {
  final String id;
  final int amount;
  final String currency;

  _OrderResponse({
    required this.id,
    required this.amount,
    required this.currency,
  });

  factory _OrderResponse.fromJson(Map<String, dynamic> json) {
    return _OrderResponse(
      id: json['id'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
    );
  }
}

/// Server payment verification response.
class _VerifyResponse {
  final bool success;
  final String? transactionId;
  final double? newBalance;
  final String? message;
  final String? error;

  _VerifyResponse({
    required this.success,
    this.transactionId,
    this.newBalance,
    this.message,
    this.error,
  });

  factory _VerifyResponse.fromJson(Map<String, dynamic> json) {
    return _VerifyResponse(
      success: json['success'] as bool? ?? false,
      transactionId: json['transaction_id'] as String?,
      newBalance: (json['new_balance'] as num?)?.toDouble(),
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }
}

/// Callback types for payment events.
typedef PaymentSuccessCallback = void Function(PaymentResult result);
typedef PaymentErrorCallback = void Function(PaymentResult result);

/// Payment service for handling Razorpay transactions.
///
/// This service handles the complete payment flow:
/// 1. Creates order on server (secure)
/// 2. Opens Razorpay checkout
/// 3. Verifies payment signature on server (secure)
/// 4. Updates wallet/project atomically on server
///
/// SECURITY: All sensitive operations are performed server-side.
/// The mobile app only handles the UI flow.
class PaymentService {
  late Razorpay _razorpay;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  PaymentSuccessCallback? _onSuccess;
  PaymentErrorCallback? _onError;
  VoidCallback? _onExternalWallet;

  // Store payment context for verification
  int? _currentAmountInRupees;
  String? _currentProjectId;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Get authorization headers with Supabase access token.
  ///
  /// @returns Map of headers including Authorization bearer token.
  /// @throws Exception if user is not authenticated.
  Future<Map<String, String>> _getAuthHeaders() async {
    final session = SupabaseConfig.currentSession;
    if (session == null) {
      throw Exception('User not authenticated');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  /// Creates a Razorpay order on the server.
  ///
  /// @param amountInRupees Payment amount in Indian Rupees.
  /// @param type Payment type (wallet_topup or project_payment).
  /// @param projectId Optional project ID for project payments.
  /// @returns Order response with Razorpay order ID.
  /// @throws Exception on network or server errors.
  Future<_OrderResponse> _createServerOrder({
    required int amountInRupees,
    required String type,
    String? projectId,
  }) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final headers = await _getAuthHeaders();
    final amountInPaise = amountInRupees * 100;

    final body = {
      'amount': amountInPaise,
      'currency': 'INR',
      'receipt': '${type}_${DateTime.now().millisecondsSinceEpoch}',
      'notes': {
        'type': type,
        'profile_id': userId,
        if (projectId != null) 'project_id': projectId,
      },
    };

    _logger.i('[PaymentService] Creating server order: $body');

    final response = await http.post(
      Uri.parse(ApiConfig.createOrderUrl),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      final errorMessage = errorBody['error'] ?? 'Failed to create order';
      _logger.e('[PaymentService] Order creation failed: $errorMessage');
      throw Exception(errorMessage);
    }

    final data = jsonDecode(response.body);
    _logger.i('[PaymentService] Order created: ${data['id']}');
    return _OrderResponse.fromJson(data);
  }

  /// Verifies payment on the server and updates wallet/project.
  ///
  /// @param orderId Razorpay order ID.
  /// @param paymentId Razorpay payment ID.
  /// @param signature Razorpay signature for verification.
  /// @param amountInRupees Payment amount in rupees.
  /// @param projectId Optional project ID for project payments.
  /// @returns Verification response with transaction details.
  /// @throws Exception on verification failure.
  Future<_VerifyResponse> _verifyServerPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required int amountInRupees,
    String? projectId,
  }) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final headers = await _getAuthHeaders();

    final body = {
      'razorpay_order_id': orderId,
      'razorpay_payment_id': paymentId,
      'razorpay_signature': signature,
      'profile_id': userId,
      'amount': amountInRupees,
      if (projectId != null) 'project_id': projectId,
    };

    _logger.i('[PaymentService] Verifying payment: $orderId');

    final response = await http.post(
      Uri.parse(ApiConfig.verifyPaymentUrl),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      final errorMessage = data['error'] ?? 'Payment verification failed';
      _logger.e('[PaymentService] Verification failed: $errorMessage');
      throw Exception(errorMessage);
    }

    _logger.i('[PaymentService] Payment verified successfully');
    return _VerifyResponse.fromJson(data);
  }

  /// Opens Razorpay checkout for a project payment.
  ///
  /// Flow:
  /// 1. Creates order on server
  /// 2. Opens Razorpay checkout
  /// 3. On success, verifies payment on server
  /// 4. Calls onSuccess only after server verification
  ///
  /// @param projectId Project ID being paid for.
  /// @param amountInRupees Payment amount in Indian Rupees.
  /// @param projectTitle Project title for display.
  /// @param onSuccess Callback for successful verified payment.
  /// @param onError Callback for payment errors.
  /// @param onExternalWallet Callback for external wallet selection.
  Future<void> payForProject({
    required String projectId,
    required int amountInRupees,
    required String projectTitle,
    PaymentSuccessCallback? onSuccess,
    PaymentErrorCallback? onError,
    VoidCallback? onExternalWallet,
  }) async {
    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;
    _currentAmountInRupees = amountInRupees;
    _currentProjectId = projectId;

    try {
      // Step 1: Create order on server
      final order = await _createServerOrder(
        amountInRupees: amountInRupees,
        type: 'project_payment',
        projectId: projectId,
      );

      // Get user details for prefill
      final user = SupabaseConfig.currentUser;
      String? userName;
      if (user != null) {
        final profile = await SupabaseConfig.client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        userName = profile?['full_name'] as String?;
      }

      // Step 2: Open Razorpay checkout with server order ID
      final options = RazorpayConfig.createCheckoutOptions(
        amountInPaise: order.amount,
        orderId: order.id,
        name: userName,
        email: user?.email,
        phone: user?.phone,
        description: 'Payment for: $projectTitle',
      );

      _razorpay.open(options);
    } catch (e) {
      _logger.e('[PaymentService] Error initiating payment: $e');
      _onError?.call(PaymentResult(
        success: false,
        errorCode: 'INIT_ERROR',
        errorMessage: e.toString(),
      ));
    }
  }

  /// Opens Razorpay checkout for wallet top-up.
  ///
  /// Flow:
  /// 1. Creates order on server
  /// 2. Opens Razorpay checkout
  /// 3. On success, verifies payment on server
  /// 4. Wallet is updated atomically on server
  /// 5. Calls onSuccess only after server verification
  ///
  /// @param amountInRupees Top-up amount in Indian Rupees.
  /// @param onSuccess Callback for successful verified payment.
  /// @param onError Callback for payment errors.
  /// @param onExternalWallet Callback for external wallet selection.
  Future<void> topUpWallet({
    required int amountInRupees,
    PaymentSuccessCallback? onSuccess,
    PaymentErrorCallback? onError,
    VoidCallback? onExternalWallet,
  }) async {
    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;
    _currentAmountInRupees = amountInRupees;
    _currentProjectId = null;

    try {
      // Step 1: Create order on server
      final order = await _createServerOrder(
        amountInRupees: amountInRupees,
        type: 'wallet_topup',
      );

      // Get user details for prefill
      final user = SupabaseConfig.currentUser;
      String? userName;
      if (user != null) {
        final profile = await SupabaseConfig.client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        userName = profile?['full_name'] as String?;
      }

      // Step 2: Open Razorpay checkout with server order ID
      final options = RazorpayConfig.createCheckoutOptions(
        amountInPaise: order.amount,
        orderId: order.id,
        name: userName,
        email: user?.email,
        phone: user?.phone,
        description: 'Wallet Top-up: \u20B9$amountInRupees',
      );

      _razorpay.open(options);
    } catch (e) {
      _logger.e('[PaymentService] Error initiating top-up: $e');
      _onError?.call(PaymentResult(
        success: false,
        errorCode: 'INIT_ERROR',
        errorMessage: e.toString(),
      ));
    }
  }

  /// Handles successful payment from Razorpay.
  ///
  /// IMPORTANT: This does NOT mean the payment is verified.
  /// We must verify the signature on the server before confirming.
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _logger.i('[PaymentService] Razorpay success - verifying on server...');

    try {
      // Step 3: Verify payment on server
      final verification = await _verifyServerPayment(
        orderId: response.orderId ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
        amountInRupees: _currentAmountInRupees ?? 0,
        projectId: _currentProjectId,
      );

      if (verification.success) {
        _logger.i('[PaymentService] Payment verified and processed');
        _onSuccess?.call(PaymentResult(
          success: true,
          paymentId: response.paymentId,
          orderId: response.orderId,
          signature: response.signature,
          transactionId: verification.transactionId,
          newBalance: verification.newBalance,
        ));
      } else {
        _logger.e('[PaymentService] Server verification failed');
        _onError?.call(PaymentResult(
          success: false,
          paymentId: response.paymentId,
          orderId: response.orderId,
          errorCode: 'VERIFICATION_FAILED',
          errorMessage: verification.error ?? 'Payment verification failed',
        ));
      }
    } catch (e) {
      _logger.e('[PaymentService] Verification error: $e');
      _onError?.call(PaymentResult(
        success: false,
        paymentId: response.paymentId,
        orderId: response.orderId,
        errorCode: 'VERIFICATION_ERROR',
        errorMessage: 'Payment made but verification failed. Contact support with ID: ${response.paymentId}',
      ));
    }
  }

  /// Handles payment error from Razorpay.
  void _handlePaymentError(PaymentFailureResponse response) {
    _logger.e('[PaymentService] Payment failed: ${response.message}');
    _onError?.call(PaymentResult(
      success: false,
      errorCode: response.code.toString(),
      errorMessage: response.message,
    ));
  }

  /// Handles external wallet selection from Razorpay.
  void _handleExternalWallet(ExternalWalletResponse response) {
    _logger.i('[PaymentService] External wallet: ${response.walletName}');
    _onExternalWallet?.call();
  }

  /// Dispose of Razorpay instance.
  ///
  /// Call this when the payment service is no longer needed
  /// to prevent memory leaks.
  void dispose() {
    _razorpay.clear();
  }
}
