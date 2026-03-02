import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/translation/translation_extensions.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import '../../providers/registration_provider.dart';

/// Step 4: Review & Submit
///
/// Shows summary of all entered information before submission.
class ReviewStep extends ConsumerWidget {
  const ReviewStep({
    super.key,
    required this.onSubmit,
    required this.onBack,
    required this.onEditStep,
  });

  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final void Function(int step) onEditStep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationProvider);
    final data = state.data;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Application'.tr(context),
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review all information before submitting'.tr(context),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),

          // Personal Information Section
          _buildSection(
            context: context,
            title: 'Personal Information'.tr(context),
            stepIndex: 0,
            onEdit: () => onEditStep(0),
            items: [
              _ReviewItem('Phone'.tr(context), data.phone ?? 'Not provided'.tr(context)),
              _ReviewItem(
                'Date of Birth'.tr(context),
                data.dateOfBirth != null
                    ? '${data.dateOfBirth!.day}/${data.dateOfBirth!.month}/${data.dateOfBirth!.year}'
                    : 'Not provided'.tr(context),
              ),
              _ReviewItem('Gender'.tr(context), data.gender ?? 'Not provided'.tr(context)),
              _ReviewItem(
                'Location'.tr(context),
                [data.city, data.state, data.country]
                    .where((s) => s != null && s.isNotEmpty)
                    .join(', '),
              ),
              if (data.linkedInUrl != null && data.linkedInUrl!.isNotEmpty)
                _ReviewItem('LinkedIn'.tr(context), data.linkedInUrl!),
            ],
          ),
          const SizedBox(height: 16),

          // Education & Experience Section
          _buildSection(
            context: context,
            title: 'Education & Experience'.tr(context),
            stepIndex: 1,
            onEdit: () => onEditStep(1),
            items: [
              _ReviewItem(
                  'Education'.tr(context), data.highestEducation ?? 'Not provided'.tr(context)),
              _ReviewItem(
                  'Field of Study'.tr(context), data.fieldOfStudy ?? 'Not provided'.tr(context)),
              _ReviewItem(
                'Experience'.tr(context),
                data.yearsOfExperience != null
                    ? '${data.yearsOfExperience} ${'years'.tr(context)}'
                    : 'Not provided'.tr(context),
              ),
              _ReviewItem(
                'Expertise'.tr(context),
                data.expertiseAreas.isNotEmpty
                    ? data.expertiseAreas.join(', ')
                    : 'Not selected'.tr(context),
              ),
              _ReviewItem(
                'CV'.tr(context),
                data.cvUrl != null ? 'Uploaded'.tr(context) : 'Not uploaded'.tr(context),
                isHighlighted: data.cvUrl != null,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Banking Details Section
          _buildSection(
            context: context,
            title: 'Banking Details'.tr(context),
            stepIndex: 2,
            onEdit: () => onEditStep(2),
            items: [
              _ReviewItem(
                  'Account Holder'.tr(context), data.accountHolderName ?? 'Not provided'.tr(context)),
              _ReviewItem(
                'Account Number'.tr(context),
                data.accountNumber != null
                    ? _maskAccountNumber(data.accountNumber!)
                    : 'Not provided'.tr(context),
              ),
              _ReviewItem('Bank Name'.tr(context), data.bankName ?? 'Not provided'.tr(context)),
              _ReviewItem('IFSC Code'.tr(context), data.ifscCode ?? 'Not provided'.tr(context)),
              if (data.panNumber != null && data.panNumber!.isNotEmpty)
                _ReviewItem('PAN'.tr(context), _maskPan(data.panNumber!)),
            ],
          ),
          const SizedBox(height: 24),

          // Completion Status
          _buildCompletionStatus(context, data.isComplete),
          const SizedBox(height: 24),

          // Terms Agreement
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondaryLight,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'By submitting this application, you agree to our Terms of Service and Privacy Policy. Your information will be reviewed by our team.'.tr(context),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Back'.tr(context),
                  onPressed: onBack,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  text: 'Submit Application'.tr(context),
                  onPressed: data.isComplete ? onSubmit : null,
                  isLoading: state.isLoading,
                  icon: Icons.send_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required int stepIndex,
    required VoidCallback onEdit,
    required List<_ReviewItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text('Edit'.tr(context)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          item.label,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value,
                          style: AppTypography.bodySmall.copyWith(
                            color: item.isHighlighted
                                ? AppColors.success
                                : AppColors.textPrimaryLight,
                            fontWeight: item.isHighlighted
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStatus(BuildContext context, bool isComplete) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isComplete ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete
                      ? 'Application Complete'.tr(context)
                      : 'Application Incomplete'.tr(context),
                  style: AppTypography.titleSmall.copyWith(
                    color: isComplete ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isComplete
                      ? 'All required fields have been filled. You can now submit your application.'.tr(context)
                      : 'Please complete all required fields before submitting.'.tr(context),
                  style: AppTypography.bodySmall.copyWith(
                    color: isComplete
                        ? AppColors.success.withValues(alpha: 0.8)
                        : AppColors.warning.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    return '${'*' * (accountNumber.length - 4)}${accountNumber.substring(accountNumber.length - 4)}';
  }

  String _maskPan(String pan) {
    if (pan.length != 10) return pan;
    return '${pan.substring(0, 2)}****${pan.substring(6)}';
  }
}

/// Helper class for review items
class _ReviewItem {
  const _ReviewItem(this.label, this.value, {this.isHighlighted = false});

  final String label;
  final String value;
  final bool isHighlighted;
}
