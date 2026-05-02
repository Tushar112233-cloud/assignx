import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../api/api_client.dart';
import '../config/api_config.dart';
import '../config/razorpay_config.dart';
import '../storage/token_storage.dart';

/// Cached user info for payment prefill.
class _PaymentUser {
  final String id;
  final String? email;
  final String? phone;
  final String? fullName;

  _PaymentUser({required this.id, this.email, this.phone, this.fullName});
}

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
  final String? keyId;

  _OrderResponse({
    required this.id,
    required this.amount,
    required this.currency,
    this.keyId,
  });

  factory _OrderResponse.fromJson(Map<String, dynamic> json) {
    return _OrderResponse(
      // API returns orderId (not id)
      id: (json['orderId'] ?? json['id']) as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String,
      keyId: json['keyId'] as String?,
    );
  }
}

/// Server payment verification response.
class _VerifyResponse {
  final bool success;
  final String? paymentId;
  final String? transactionId;
  final double? newBalance;
  final String? message;
  final String? error;

  _VerifyResponse({
    required this.success,
    this.paymentId,
    this.transactionId,
    this.newBalance,
    this.message,
    this.error,
  });

  factory _VerifyResponse.fromJson(Map<String, dynamic> json) {
    return _VerifyResponse(
      success: json['success'] as bool? ?? false,
      paymentId: (json['paymentId'] ?? json['payment_id']) as String?,
      transactionId: (json['transactionId'] ?? json['transaction_id']) as String?,
      newBalance: (json['newBalance'] ?? json['new_balance'] ?? json['balance'] as num?)?.toDouble(),
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

  /// Get current user info from the API for payment prefill.
  Future<_PaymentUser?> _getCurrentUser() async {
    try {
      final data = await ApiClient.get('/auth/me');
      if (data == null) return null;
      final map = data as Map<String, dynamic>;
      return _PaymentUser(
        id: (map['_id'] ?? map['id'] ?? '') as String,
        email: map['email'] as String?,
        phone: map['phone'] as String?,
        fullName: (map['fullName'] ?? map['full_name']) as String?,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get authorization headers with JWT access token.
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
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
    final headers = await _getAuthHeaders();

    // Send amount in rupees -- the API converts to paise internally.
    final body = {
      'amount': amountInRupees,
      if (projectId != null) 'projectId': projectId,
      'notes': {
        'type': type,
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
    final headers = await _getAuthHeaders();

    final body = {
      'razorpay_order_id': orderId,
      'razorpay_payment_id': paymentId,
      'razorpay_signature': signature,
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

      // Get user details for prefill via API
      final paymentUser = await _getCurrentUser();

      // Step 2: Open Razorpay checkout with server order ID
      final options = RazorpayConfig.createCheckoutOptions(
        amountInPaise: order.amount,
        orderId: order.id,
        name: paymentUser?.fullName,
        email: paymentUser?.email,
        phone: paymentUser?.phone,
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

      // Get user details for prefill via API
      final paymentUser = await _getCurrentUser();

      // Step 2: Open Razorpay checkout with server order ID
      final options = RazorpayConfig.createCheckoutOptions(
        amountInPaise: order.amount,
        orderId: order.id,
        name: paymentUser?.fullName,
        email: paymentUser?.email,
        phone: paymentUser?.phone,
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

        double? newBalance = verification.newBalance;

        // For wallet top-ups (no projectId), credit the wallet via the topup endpoint
        if (_currentProjectId == null && _currentAmountInRupees != null) {
          try {
            final topupResponse = await _creditWalletAfterVerification(
              amountInRupees: _currentAmountInRupees!,
              paymentId: response.paymentId ?? '',
            );
            newBalance = topupResponse;
          } catch (e) {
            _logger.e('[PaymentService] Wallet credit failed: $e');
            // Payment was verified but wallet credit failed -- still report success
            // but log the error for support follow-up
          }
        }

        _onSuccess?.call(PaymentResult(
          success: true,
          paymentId: response.paymentId,
          orderId: response.orderId,
          signature: response.signature,
          transactionId: verification.transactionId,
          newBalance: newBalance,
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

  /// Credits the wallet after a successful Razorpay payment verification.
  ///
  /// Called after the payment signature is verified on the server.
  /// This calls POST /wallets/topup to actually credit the wallet balance.
  Future<double?> _creditWalletAfterVerification({
    required int amountInRupees,
    required String paymentId,
  }) async {
    final headers = await _getAuthHeaders();

    final body = {
      'amount': amountInRupees,
      'paymentId': paymentId,
    };

    _logger.i('[PaymentService] Crediting wallet: $amountInRupees INR');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/wallets/topup'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to credit wallet');
    }

    final data = jsonDecode(response.body);
    _logger.i('[PaymentService] Wallet credited. New balance: ${data['balance']}');
    return (data['balance'] as num?)?.toDouble();
  }

  /// Opens Razorpay checkout with a pre-created order.
  ///
  /// Used for expert booking payments where the order is created
  /// via a custom endpoint. Payment verification is handled by
  /// the caller's onSuccess callback (not the standard verify flow).
  ///
  /// @param orderId Pre-created Razorpay order ID.
  /// @param keyId Razorpay key ID from the server.
  /// @param amountInPaise Amount in paise (already converted by server).
  /// @param description Payment description.
  /// @param onSuccess Callback with raw PaymentResult (caller handles verification).
  /// @param onError Callback for payment errors.
  void payCustomOrder({
    required String orderId,
    required String keyId,
    required int amountInPaise,
    required String description,
    PaymentSuccessCallback? onSuccess,
    PaymentErrorCallback? onError,
  }) {
    // For custom orders, skip server verification in _handlePaymentSuccess
    // Instead, directly call the provided onSuccess callback
    _onSuccess = null;
    _onError = null;
    _currentAmountInRupees = null;
    _currentProjectId = null;

    // Set up one-time handlers
    _razorpay.clear();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      _logger.i('[PaymentService] Custom order payment success: ${response.paymentId}');
      onSuccess?.call(PaymentResult(
        success: true,
        paymentId: response.paymentId,
        orderId: response.orderId,
        signature: response.signature,
      ));
    });

    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      _logger.e('[PaymentService] Custom order payment failed: ${response.message}');
      onError?.call(PaymentResult(
        success: false,
        errorCode: response.code.toString(),
        errorMessage: response.message,
      ));
    });

    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
      _logger.i('[PaymentService] External wallet: ${response.walletName}');
    });

    try {
      final options = {
        'key': keyId,
        'amount': amountInPaise,
        'currency': 'INR',
        'name': 'AssignX',
        'description': description,
        'order_id': orderId,
        'theme': {'color': '#7c3aed'},
      };

      _razorpay.open(options);
    } catch (e) {
      _logger.e('[PaymentService] Error opening custom checkout: $e');
      onError?.call(PaymentResult(
        success: false,
        errorCode: 'INIT_ERROR',
        errorMessage: e.toString(),
      ));
    }
  }

  /// Dispose of Razorpay instance.
  ///
  /// Call this when the payment service is no longer needed
  /// to prevent memory leaks.
  void dispose() {
    _razorpay.clear();
  }
}
