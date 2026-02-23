import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

/// Bottom sheet for requesting revisions.
///
/// Allows supervisor to provide feedback and select issues.
class RevisionFeedbackForm extends StatefulWidget {
  const RevisionFeedbackForm({
    super.key,
    required this.projectTitle,
    required this.onSubmit,
  });

  /// Project title for display
  final String projectTitle;

  /// Called when revision request is submitted
  final Future<bool> Function({
    required String feedback,
    List<String>? issues,
  }) onSubmit;

  /// Shows the revision feedback form.
  static Future<bool?> show(
    BuildContext context, {
    required String projectTitle,
    required Future<bool> Function({
      required String feedback,
      List<String>? issues,
    }) onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RevisionFeedbackForm(
        projectTitle: projectTitle,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<RevisionFeedbackForm> createState() => _RevisionFeedbackFormState();
}

class _RevisionFeedbackFormState extends State<RevisionFeedbackForm> {
  final _feedbackController = TextEditingController();
  final _selectedIssues = <String>{};
  bool _isSubmitting = false;
  String? _error;

  static const _commonIssues = [
    'Quality concerns',
    'Missing requirements',
    'Formatting issues',
    'Incomplete content',
    'Grammar/spelling errors',
    'Citation problems',
    'Structure issues',
    'Incorrect data',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.replay,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request Revision',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            widget.projectTitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Common issues
                    Text(
                      'Select Issues (Optional)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _commonIssues.map((issue) {
                        final isSelected = _selectedIssues.contains(issue);
                        return FilterChip(
                          label: Text(issue),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedIssues.add(issue);
                              } else {
                                _selectedIssues.remove(issue);
                              }
                            });
                          },
                          selectedColor: Colors.orange.withValues(alpha: 0.2),
                          checkmarkColor: Colors.orange,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.orange
                                : AppColors.textSecondaryLight
                                    .withValues(alpha: 0.3),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.orange.shade800
                                : AppColors.textSecondaryLight,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Feedback text
                    Text(
                      'Detailed Feedback',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Provide specific feedback to help the doer understand what needs to be changed.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _feedbackController,
                      hint: 'Enter your feedback here...',
                      maxLines: 6,
                    ),
                    // Error message
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Tips
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tips for Good Feedback',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _TipItem(text: 'Be specific about what needs to change'),
                          _TipItem(text: 'Reference specific sections or pages'),
                          _TipItem(text: 'Explain why the change is needed'),
                          _TipItem(text: 'Provide examples when possible'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              // Submit button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: PrimaryButton(
                  text: 'Submit Revision Request',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    final feedback = _feedbackController.text.trim();

    if (feedback.isEmpty) {
      setState(() {
        _error = 'Please provide feedback for the revision request.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final success = await widget.onSubmit(
        feedback: feedback,
        issues: _selectedIssues.isNotEmpty ? _selectedIssues.toList() : null,
      );

      if (success && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        setState(() {
          _error = 'Failed to submit revision request. Please try again.';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'An error occurred. Please try again.';
          _isSubmitting = false;
        });
      }
    }
  }
}

/// Tip item widget.
class _TipItem extends StatelessWidget {
  const _TipItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
