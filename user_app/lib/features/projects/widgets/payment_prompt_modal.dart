import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';

/// Bottom sheet modal for pending payment prompt.
class PaymentPromptModal extends StatelessWidget {
  final Project project;
  final VoidCallback onPayNow;
  final VoidCallback onRemindLater;

  const PaymentPromptModal({
    super.key,
    required this.project,
    required this.onPayNow,
    required this.onRemindLater,
  });

  /// Shows the payment prompt modal.
  static void show(
    BuildContext context, {
    required Project project,
    required VoidCallback onPayNow,
    required VoidCallback onRemindLater,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => PaymentPromptModal(
        project: project,
        onPayNow: onPayNow,
        onRemindLater: onRemindLater,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.payment,
                    size: 32,
                    color: AppColors.warning,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  'Payment Required',
                  style: AppTextStyles.headingSmall,
                ),

                const SizedBox(height: 8),

                // Project name
                Text(
                  project.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Amount card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Amount Due',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\u20B9',
                            style: AppTextStyles.headingMedium.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                          Text(
                            project.userQuote?.toStringAsFixed(0) ?? '0',
                            style: AppTextStyles.displayLarge.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Pay Now button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onPayNow();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payment, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Pay Now',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Remind Later button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onRemindLater();
                  },
                  child: Text(
                    'Remind me later',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
