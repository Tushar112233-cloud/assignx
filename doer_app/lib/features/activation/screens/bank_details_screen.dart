import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/activation_provider.dart';
import '../../../providers/auth_provider.dart' show BankDetailsFormData;
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../widgets/bank_verification_badge.dart';

/// Bank details screen for completing activation.
///
/// Collects and validates user's bank account information for payment
/// processing. This is the final step in the activation process.
///
/// ## Navigation
/// - Entry: From [ActivationGateScreen] (Step 3, requires quiz passed)
/// - Back: Returns to [ActivationGateScreen]
/// - Success: Shows completion dialog, then [DashboardScreen]
///
/// ## Features
/// - Account holder name input
/// - Account number input with confirmation
/// - IFSC code validation with bank lookup
/// - Optional UPI ID input
/// - Real-time IFSC validation (mock)
/// - Security encryption notice
/// - Accuracy warning notice
/// - Shows existing details if already submitted
///
/// ## Form Validation
/// - Account holder name: Required
/// - Account number: Required, 9-18 digits
/// - Confirm account number: Must match account number
/// - IFSC code: Required, 11 alphanumeric characters
/// - UPI ID: Optional, valid UPI format
///
/// ## IFSC Validation
/// Mock validation recognizes SBIN, HDFC, ICIC, AXIS prefixes
/// with appropriate bank names. TODO: Integrate real IFSC API.
///
/// See also:
/// - [ActivationProvider] for bank details submission
/// - [Validators] for form validation utilities
/// - [BankAccountCard] for displaying saved details
class BankDetailsScreen extends ConsumerStatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  ConsumerState<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

/// State class for [BankDetailsScreen].
///
/// Manages form state, IFSC validation, and submission.
class _BankDetailsScreenState extends ConsumerState<BankDetailsScreen> {
  /// Form key for validation.
  final _formKey = GlobalKey<FormState>();

  /// Controller for account holder name.
  final _accountHolderNameController = TextEditingController();

  /// Controller for account number.
  final _accountNumberController = TextEditingController();

  /// Controller for account number confirmation.
  final _confirmAccountNumberController = TextEditingController();

  /// Controller for IFSC code.
  final _ifscCodeController = TextEditingController();

  /// Controller for optional UPI ID.
  final _upiIdController = TextEditingController();

  /// Whether form submission is in progress.
  bool _isLoading = false;

  /// Whether IFSC validation is in progress.
  bool _isValidatingIfsc = false;

  /// Bank name resolved from IFSC lookup.
  String? _bankName;

  /// Branch name resolved from IFSC lookup.
  String? _branchName;

  /// Whether IFSC code passed validation.
  bool _ifscValid = false;

  /// Disposes all text controllers to prevent memory leaks.
  @override
  void dispose() {
    _accountHolderNameController.dispose();
    _accountNumberController.dispose();
    _confirmAccountNumberController.dispose();
    _ifscCodeController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  /// Validates IFSC code and fetches bank/branch information.
  ///
  /// Simulates API call to validate IFSC code. Recognizes common
  /// bank prefixes (SBIN, HDFC, ICIC, AXIS) and returns mock data.
  ///
  /// TODO: Replace with real IFSC validation API.
  Future<void> _validateIfscCode(String ifsc) async {
    if (ifsc.length != 11) {
      setState(() {
        _bankName = null;
        _branchName = null;
        _ifscValid = false;
      });
      return;
    }

    setState(() => _isValidatingIfsc = true);

    // Simulated IFSC validation - in production, use a real API
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isValidatingIfsc = false;
        // Mock validation result
        if (ifsc.startsWith('SBIN')) {
          _bankName = 'State Bank of India';
          _branchName = 'Main Branch';
          _ifscValid = true;
        } else if (ifsc.startsWith('HDFC')) {
          _bankName = 'HDFC Bank';
          _branchName = 'Main Branch';
          _ifscValid = true;
        } else if (ifsc.startsWith('ICIC')) {
          _bankName = 'ICICI Bank';
          _branchName = 'Main Branch';
          _ifscValid = true;
        } else if (ifsc.startsWith('AXIS')) {
          _bankName = 'Axis Bank';
          _branchName = 'Main Branch';
          _ifscValid = true;
        } else {
          // Accept any valid format for testing
          _bankName = 'Bank of India';
          _branchName = 'Branch';
          _ifscValid = true;
        }
      });
    }
  }

  /// Handles form submission.
  ///
  /// Validates form, checks account number match, creates form data,
  /// and submits to [ActivationProvider]. On success, shows
  /// completion dialog. On failure, shows error SnackBar.
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_accountNumberController.text != _confirmAccountNumberController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account numbers do not match'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final formData = BankDetailsFormData(
      accountHolderName: _accountHolderNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      confirmAccountNumber: _confirmAccountNumberController.text.trim(),
      ifscCode: _ifscCodeController.text.trim().toUpperCase(),
      upiId: _upiIdController.text.trim().isEmpty
          ? null
          : _upiIdController.text.trim(),
    );

    final success = await ref.read(activationProvider.notifier).submitBankDetails(formData);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save bank details. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Shows activation completion dialog.
  ///
  /// Displays congratulations message and navigates to dashboard.
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Activation Complete!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Congratulations! You can now access your dashboard and start accepting projects.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              text: 'Go to Dashboard',
              onPressed: () {
                Navigator.pop(context);
                context.go(RouteNames.dashboard);
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the bank details screen UI.
  ///
  /// Shows existing details view if already submitted,
  /// otherwise shows the input form with all fields.
  @override
  Widget build(BuildContext context) {
    final activationState = ref.watch(activationProvider);
    final existingDetails = activationState.bankDetails;

    // If bank details already exist, show them
    if (existingDetails != null && activationState.status.bankDetailsAdded) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(RouteNames.activationGate),
          ),
          title: const Text(
            'Bank Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Bank details submitted successfully!',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              BankAccountCard(
                accountHolderName: existingDetails.accountHolderName,
                maskedAccountNumber: existingDetails.maskedAccountNumber,
                bankName: existingDetails.bankName ?? 'Bank',
                ifscCode: existingDetails.ifscCode,
                isVerified: existingDetails.isVerified,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                text: 'Go to Dashboard',
                onPressed: () => context.go(RouteNames.dashboard),
                isFullWidth: true,
                size: AppButtonSize.large,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.activationGate),
        ),
        title: const Text(
          'Bank Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Add Bank Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Enter your bank details to receive payments for completed projects.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Security note
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: AppColors.info,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Your bank details are encrypted and securely stored.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Account Holder Name
              AppTextField(
                label: 'Account Holder Name',
                hint: 'Enter name as per bank records',
                controller: _accountHolderNameController,
                textCapitalization: TextCapitalization.words,
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    Validators.required(value, fieldName: 'Account holder name'),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Account Number
              AppTextField(
                label: 'Account Number',
                hint: 'Enter your account number',
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.account_balance_wallet_outlined,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(18),
                ],
                validator: Validators.bankAccount,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Confirm Account Number
              AppTextField(
                label: 'Confirm Account Number',
                hint: 'Re-enter your account number',
                controller: _confirmAccountNumberController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.account_balance_wallet_outlined,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(18),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your account number';
                  }
                  if (value != _accountNumberController.text) {
                    return 'Account numbers do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // IFSC Code
              AppTextField(
                label: 'IFSC Code',
                hint: 'e.g., SBIN0001234',
                controller: _ifscCodeController,
                textCapitalization: TextCapitalization.characters,
                prefixIcon: Icons.code,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(11),
                  UpperCaseTextFormatter(),
                ],
                validator: Validators.ifscCode,
                onChanged: (value) {
                  if (value.length == 11) {
                    _validateIfscCode(value);
                  } else {
                    setState(() {
                      _bankName = null;
                      _branchName = null;
                      _ifscValid = false;
                    });
                  }
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              // IFSC validation result
              IfscValidationResult(
                isLoading: _isValidatingIfsc,
                isValid: _ifscValid,
                bankName: _bankName,
                branchName: _branchName,
              ),

              const SizedBox(height: AppSpacing.lg),

              // UPI ID (Optional)
              AppTextField(
                label: 'UPI ID (Optional)',
                hint: 'e.g., yourname@upi',
                controller: _upiIdController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.phone_android,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return Validators.upi(value);
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Important note
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Please ensure all details are accurate. Incorrect information may delay your payments.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Submit button
              AppButton(
                text: 'Complete Activation',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
                isFullWidth: true,
                size: AppButtonSize.large,
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Text input formatter that converts input to uppercase.
///
/// Used for IFSC code input to ensure consistent formatting.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
