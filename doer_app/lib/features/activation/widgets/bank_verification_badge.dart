/// Bank verification and account display widgets.
///
/// This file provides widgets for displaying bank account verification
/// status and account details during the activation process.
///
/// ## Widgets
/// - [BankVerificationBadge] - Status badge (verified/pending)
/// - [BankAccountCard] - Full account details card
/// - [IfscValidationResult] - IFSC code validation feedback
///
/// ## Features
/// - Verified/pending status badges
/// - Bank account card with masked details
/// - IFSC code validation with bank/branch lookup
/// - Edit button for account modifications
///
/// ## Verification States
/// - **Verified** (green): Bank account confirmed
/// - **Pending** (yellow): Awaiting verification
///
/// ## Example
/// ```dart
/// // Simple status badge
/// BankVerificationBadge(isVerified: account.verified)
///
/// // Full account card
/// BankAccountCard(
///   accountHolderName: 'John Doe',
///   maskedAccountNumber: '****1234',
///   bankName: 'State Bank',
///   ifscCode: 'SBIN0001234',
///   isVerified: true,
///   onEdit: () => editAccount(),
/// )
///
/// // IFSC validation result
/// IfscValidationResult(
///   bankName: 'State Bank of India',
///   branchName: 'Main Branch',
///   isValid: true,
/// )
/// ```
///
/// See also:
/// - [BankDetailsScreen] for usage context
/// - [BankDetails] for account data model
/// - [AppTextField] for input fields
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Bank account verification status badge.
///
/// Displays a compact badge indicating whether a bank account
/// is verified or pending verification.
///
/// ## Props
/// - [isVerified]: Current verification status
/// - [showLabel]: Whether to show text label (default: true)
class BankVerificationBadge extends StatelessWidget {
  final bool isVerified;
  final bool showLabel;

  const BankVerificationBadge({
    super.key,
    required this.isVerified,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isVerified
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(
          color: isVerified
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending,
            size: 14,
            color: isVerified ? AppColors.success : AppColors.warning,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              isVerified ? 'Verified' : 'Pending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isVerified ? AppColors.success : AppColors.warning,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bank account details card widget.
///
/// Displays complete bank account information in a card format,
/// including account holder name, masked account number, bank name,
/// IFSC code, and verification status.
///
/// ## Props
/// - [accountHolderName]: Name on the account
/// - [maskedAccountNumber]: Masked account number (e.g., ****1234)
/// - [bankName]: Name of the bank
/// - [ifscCode]: IFSC code for the branch
/// - [isVerified]: Whether account is verified
/// - [onEdit]: Optional callback for edit button
class BankAccountCard extends StatelessWidget {
  final String accountHolderName;
  final String maskedAccountNumber;
  final String bankName;
  final String ifscCode;
  final bool isVerified;
  final VoidCallback? onEdit;

  const BankAccountCard({
    super.key,
    required this.accountHolderName,
    required this.maskedAccountNumber,
    required this.bankName,
    required this.ifscCode,
    this.isVerified = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: isVerified ? AppColors.success : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bankName.isNotEmpty ? bankName : 'Bank Account',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      maskedAccountNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              BankVerificationBadge(isVerified: isVerified),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Account holder name
          _buildInfoRow('Account Holder', accountHolderName),
          const SizedBox(height: AppSpacing.sm),

          // IFSC Code
          _buildInfoRow('IFSC Code', ifscCode),

          if (onEdit != null) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit Details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// IFSC code validation result display.
///
/// Shows the result of IFSC code validation, including loading state,
/// error message, or validated bank/branch details.
///
/// ## States
/// - **Loading**: Shows spinner with "Verifying..." text
/// - **Error**: Shows error icon with message
/// - **Valid**: Shows green success card with bank/branch
///
/// ## Props
/// - [bankName]: Validated bank name (when valid)
/// - [branchName]: Validated branch name (optional)
/// - [isLoading]: Show loading state
/// - [isValid]: Whether IFSC is valid
/// - [errorMessage]: Error message to display
class IfscValidationResult extends StatelessWidget {
  final String? bankName;
  final String? branchName;
  final bool isLoading;
  final bool isValid;
  final String? errorMessage;

  const IfscValidationResult({
    super.key,
    this.bankName,
    this.branchName,
    this.isLoading = false,
    this.isValid = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Verifying IFSC code...',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    if (errorMessage != null) {
      return Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Text(
            errorMessage!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.error,
            ),
          ),
        ],
      );
    }

    if (isValid && bankName != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              size: 16,
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bankName!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (branchName != null)
                    Text(
                      branchName!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
