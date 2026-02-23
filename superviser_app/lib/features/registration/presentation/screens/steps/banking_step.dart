import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../shared/widgets/inputs/app_text_field.dart';
import '../../providers/registration_provider.dart';

/// Step 3: Banking Details
///
/// Collects payment information for supervisor payouts.
class BankingStep extends ConsumerStatefulWidget {
  const BankingStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  ConsumerState<BankingStep> createState() => _BankingStepState();
}

class _BankingStepState extends ConsumerState<BankingStep> {
  final _formKey = GlobalKey<FormState>();
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _ifscController = TextEditingController();
  final _panController = TextEditingController();

  bool _obscureAccount = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final data = ref.read(registrationProvider).data;
    _accountHolderController.text = data.accountHolderName ?? '';
    _accountNumberController.text = data.accountNumber ?? '';
    _confirmAccountController.text = data.accountNumber ?? '';
    _bankNameController.text = data.bankName ?? '';
    _ifscController.text = data.ifscCode ?? '';
    _panController.text = data.panNumber ?? '';
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _confirmAccountController.dispose();
    _bankNameController.dispose();
    _ifscController.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(registrationProvider.notifier);
      notifier.updateData((data) => data.copyWith(
            accountHolderName: _accountHolderController.text.trim(),
            accountNumber: _accountNumberController.text.trim(),
            bankName: _bankNameController.text.trim(),
            ifscCode: _ifscController.text.trim().toUpperCase(),
            panNumber: _panController.text.trim().toUpperCase(),
          ));
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Banking Details',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Required for receiving payments',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),

            // Security Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.security_outlined,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your banking information is encrypted and securely stored.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account Holder Name
            AppTextField(
              controller: _accountHolderController,
              label: 'Account Holder Name *',
              hint: 'As per bank records',
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Account holder name is required';
                }
                if (value.length < 3) {
                  return 'Enter a valid name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Account Number
            AppTextField(
              controller: _accountNumberController,
              label: 'Account Number *',
              hint: 'Enter your account number',
              prefixIcon: Icons.account_balance_outlined,
              keyboardType: TextInputType.number,
              obscureText: _obscureAccount,
              suffixIcon: _obscureAccount ? Icons.visibility_off : Icons.visibility,
              onSuffixTap: () {
                setState(() {
                  _obscureAccount = !_obscureAccount;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Account number is required';
                }
                if (value.length < 9 || value.length > 18) {
                  return 'Enter a valid account number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm Account Number
            AppTextField(
              controller: _confirmAccountController,
              label: 'Confirm Account Number *',
              hint: 'Re-enter your account number',
              prefixIcon: Icons.account_balance_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm account number';
                }
                if (value != _accountNumberController.text) {
                  return 'Account numbers do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Bank Name
            AppTextField(
              controller: _bankNameController,
              label: 'Bank Name *',
              hint: 'e.g., State Bank of India',
              prefixIcon: Icons.business_outlined,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bank name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // IFSC Code
            AppTextField(
              controller: _ifscController,
              label: 'IFSC Code *',
              hint: 'e.g., SBIN0001234',
              prefixIcon: Icons.code_outlined,
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'IFSC code is required';
                }
                // IFSC format: 4 letters + 0 + 6 characters
                final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
                if (!ifscRegex.hasMatch(value.toUpperCase())) {
                  return 'Enter a valid IFSC code';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // PAN Number
            AppTextField(
              controller: _panController,
              label: 'PAN Number (Optional)',
              hint: 'e.g., ABCDE1234F',
              prefixIcon: Icons.badge_outlined,
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  // PAN format: 5 letters + 4 digits + 1 letter
                  final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
                  if (!panRegex.hasMatch(value.toUpperCase())) {
                    return 'Enter a valid PAN number';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Back',
                    onPressed: widget.onBack,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    text: 'Continue',
                    onPressed: _saveAndContinue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
