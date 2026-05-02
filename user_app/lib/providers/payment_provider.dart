import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/payment_service.dart';
import 'project_provider.dart';
import 'profile_provider.dart';

/// Payment state enum for tracking payment flow.
enum PaymentState {
  /// Initial state - no payment in progress.
  idle,

  /// Payment is being processed.
  processing,

  /// Payment completed successfully.
  success,

  /// Payment failed.
  failed,
}

/// Payment status model containing the current state and result.
class PaymentStatus {
  /// Current payment state.
  final PaymentState state;

  /// Payment result on success or failure.
  final PaymentResult? result;

  /// Error message on failure.
  final String? errorMessage;

  /// Project ID if this was a project payment.
  final String? projectId;

  /// Amount paid in rupees.
  final int? amountInRupees;

  const PaymentStatus({
    this.state = PaymentState.idle,
    this.result,
    this.errorMessage,
    this.projectId,
    this.amountInRupees,
  });

  /// Whether payment is currently processing.
  bool get isProcessing => state == PaymentState.processing;

  /// Whether payment was successful.
  bool get isSuccess => state == PaymentState.success;

  /// Whether payment failed.
  bool get isFailed => state == PaymentState.failed;

  /// Create a copy with modified fields.
  PaymentStatus copyWith({
    PaymentState? state,
    PaymentResult? result,
    String? errorMessage,
    String? projectId,
    int? amountInRupees,
  }) {
    return PaymentStatus(
      state: state ?? this.state,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      projectId: projectId ?? this.projectId,
      amountInRupees: amountInRupees ?? this.amountInRupees,
    );
  }

  /// Create an idle state.
  factory PaymentStatus.idle() => const PaymentStatus(state: PaymentState.idle);

  /// Create a processing state.
  factory PaymentStatus.processing({
    String? projectId,
    int? amountInRupees,
  }) =>
      PaymentStatus(
        state: PaymentState.processing,
        projectId: projectId,
        amountInRupees: amountInRupees,
      );

  /// Create a success state.
  factory PaymentStatus.success({
    required PaymentResult result,
    String? projectId,
    int? amountInRupees,
  }) =>
      PaymentStatus(
        state: PaymentState.success,
        result: result,
        projectId: projectId,
        amountInRupees: amountInRupees,
      );

  /// Create a failed state.
  factory PaymentStatus.failed({
    required String errorMessage,
    PaymentResult? result,
    String? projectId,
    int? amountInRupees,
  }) =>
      PaymentStatus(
        state: PaymentState.failed,
        errorMessage: errorMessage,
        result: result,
        projectId: projectId,
        amountInRupees: amountInRupees,
      );
}

/// StateNotifier for managing payment state.
///
/// Handles:
/// - Project payments via Razorpay
/// - Wallet top-ups via Razorpay
/// - Payment verification and status updates
class PaymentNotifier extends StateNotifier<PaymentStatus> {
  final Ref _ref;
  PaymentService? _paymentService;

  PaymentNotifier(this._ref) : super(PaymentStatus.idle());

  /// Initiates a project payment via Razorpay.
  ///
  /// @param projectId The project ID to pay for.
  /// @param amountInRupees Payment amount in Indian Rupees.
  /// @param projectTitle Project title for display.
  /// @param onComplete Optional callback when payment completes (success or failure).
  void initiateProjectPayment({
    required String projectId,
    required int amountInRupees,
    required String projectTitle,
    void Function(bool success, String? errorMessage)? onComplete,
  }) {
    // Clean up previous service if any
    _paymentService?.dispose();
    _paymentService = PaymentService();

    state = PaymentStatus.processing(
      projectId: projectId,
      amountInRupees: amountInRupees,
    );

    _paymentService!.payForProject(
      projectId: projectId,
      amountInRupees: amountInRupees,
      projectTitle: projectTitle,
      onSuccess: (result) {
        state = PaymentStatus.success(
          result: result,
          projectId: projectId,
          amountInRupees: amountInRupees,
        );

        // Record payment in project repository
        _ref.read(projectNotifierProvider.notifier).recordPayment(
          projectId,
          result.paymentId ?? '',
        );

        // Invalidate project providers to refresh data
        _ref.invalidate(projectProvider(projectId));
        _ref.invalidate(projectsProvider);
        _ref.invalidate(pendingPaymentProjectsProvider);
        _ref.invalidate(projectCountsProvider);

        onComplete?.call(true, null);
      },
      onError: (result) {
        final errorMessage = result.errorMessage ?? 'Payment failed';
        state = PaymentStatus.failed(
          errorMessage: errorMessage,
          result: result,
          projectId: projectId,
          amountInRupees: amountInRupees,
        );

        onComplete?.call(false, errorMessage);
      },
      onExternalWallet: () {
        // External wallet selected - payment will be processed externally
        // Keep processing state until we get success/error callback
      },
    );
  }

  /// Initiates a wallet top-up via Razorpay.
  ///
  /// @param amountInRupees Top-up amount in Indian Rupees.
  /// @param onComplete Optional callback when payment completes (success or failure).
  void initiateWalletTopUp({
    required int amountInRupees,
    void Function(bool success, String? errorMessage, double? newBalance)? onComplete,
  }) {
    // Clean up previous service if any
    _paymentService?.dispose();
    _paymentService = PaymentService();

    state = PaymentStatus.processing(amountInRupees: amountInRupees);

    _paymentService!.topUpWallet(
      amountInRupees: amountInRupees,
      onSuccess: (result) {
        state = PaymentStatus.success(
          result: result,
          amountInRupees: amountInRupees,
        );

        // Refresh wallet data
        _ref.invalidate(walletProvider);
        _ref.invalidate(walletTransactionsProvider);

        onComplete?.call(true, null, result.newBalance);
      },
      onError: (result) {
        final errorMessage = result.errorMessage ?? 'Payment failed';
        state = PaymentStatus.failed(
          errorMessage: errorMessage,
          result: result,
          amountInRupees: amountInRupees,
        );

        onComplete?.call(false, errorMessage, null);
      },
      onExternalWallet: () {
        // External wallet selected - payment will be processed externally
        // Keep processing state until we get success/error callback
      },
    );
  }

  /// Resets payment state to idle.
  void reset() {
    _paymentService?.dispose();
    _paymentService = null;
    state = PaymentStatus.idle();
  }

  @override
  void dispose() {
    _paymentService?.dispose();
    super.dispose();
  }
}

/// Provider for payment state and operations.
final paymentProvider = StateNotifierProvider.autoDispose<PaymentNotifier, PaymentStatus>(
  (ref) => PaymentNotifier(ref),
);

/// Provider for checking if a specific project has pending payment.
final projectHasPendingPaymentProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, projectId) async {
    final project = await ref.watch(projectProvider(projectId).future);
    return project?.isPendingPayment ?? false;
  },
);
