import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';

/// Widget with approve and request changes buttons.
class ReviewActions extends StatelessWidget {
  final Project project;
  final VoidCallback onApprove;
  final VoidCallback onRequestChanges;
  final bool isLoading;

  const ReviewActions({
    super.key,
    required this.project,
    required this.onApprove,
    required this.onRequestChanges,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.success.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 20,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                'Review Delivery',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Please review the delivered files and approve or request changes.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          // Auto-approval timer
          if (project.autoApproveAt != null) ...[
            const SizedBox(height: 12),
            _AutoApprovalInfo(deadline: project.autoApproveAt!),
          ],

          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              // Request Changes
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onRequestChanges,
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Request Changes'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Approve
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onApprove,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AutoApprovalInfo extends StatefulWidget {
  final DateTime deadline;

  const _AutoApprovalInfo({required this.deadline});

  @override
  State<_AutoApprovalInfo> createState() => _AutoApprovalInfoState();
}

class _AutoApprovalInfoState extends State<_AutoApprovalInfo> {
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.deadline.difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (!mounted) return;
      setState(() {
        _remaining = widget.deadline.difference(DateTime.now());
      });
      if (_remaining.isNegative) return;
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return const SizedBox.shrink();
    }

    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Auto-approves in ${hours}h ${minutes}m if no action taken',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal for entering feedback when requesting changes.
class FeedbackInputModal extends StatefulWidget {
  final Function(String feedback) onSubmit;

  const FeedbackInputModal({
    super.key,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(String feedback) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FeedbackInputModal(onSubmit: onSubmit),
    );
  }

  @override
  State<FeedbackInputModal> createState() => _FeedbackInputModalState();
}

class _FeedbackInputModalState extends State<FeedbackInputModal> {
  final _controller = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isValid = _controller.text.trim().length >= 10;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Request Changes',
                    style: AppTextStyles.headingSmall,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Please describe what changes you need. Be specific to help the expert understand your requirements.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Text field
                  TextField(
                    controller: _controller,
                    maxLines: 5,
                    minLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter your feedback here...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Minimum 10 characters',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isValid
                          ? () {
                              Navigator.pop(context);
                              widget.onSubmit(_controller.text.trim());
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: AppColors.surfaceVariant,
                      ),
                      child: const Text('Submit Feedback'),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
