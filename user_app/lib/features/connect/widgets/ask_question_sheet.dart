import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../shared/widgets/glass_container.dart';

/// Bottom sheet form for asking a new Q&A question.
///
/// Presents a modal bottom sheet with fields for subject (dropdown),
/// title, and body text. On submit, inserts the question into the
/// `connect_questions` Supabase table and calls [onQuestionPosted].
///
/// Usage:
/// ```dart
/// AskQuestionSheet.show(
///   context: context,
///   onQuestionPosted: () => ref.invalidate(connectQuestionsProvider),
/// );
/// ```
class AskQuestionSheet extends ConsumerStatefulWidget {
  /// Callback invoked after a question is successfully posted.
  final VoidCallback? onQuestionPosted;

  const AskQuestionSheet({
    super.key,
    this.onQuestionPosted,
  });

  /// Convenience method to display the sheet as a modal bottom sheet.
  static void show({
    required BuildContext context,
    VoidCallback? onQuestionPosted,
  }) {
    showModalBottomSheet(
      useSafeArea: false,
      context: context,
      useRootNavigator: true,

      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AskQuestionSheet(
        onQuestionPosted: onQuestionPosted,
      ),
    );
  }

  @override
  ConsumerState<AskQuestionSheet> createState() => _AskQuestionSheetState();
}

class _AskQuestionSheetState extends ConsumerState<AskQuestionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  String? _selectedSubject;
  bool _isSubmitting = false;

  /// Available subjects matching the connect module's subject list.
  static const List<String> _subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Computer Science',
    'Data Structures',
    'Machine Learning',
    'Economics',
    'Statistics',
    'English',
    'Biology',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  /// Submit the question to the API.
  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate() || _selectedSubject == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiClient.post('/connect/questions', {
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'subject': _selectedSubject,
      });

      if (mounted) {
        widget.onQuestionPosted?.call();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Question posted successfully!'.tr(context)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'Failed to post question'.tr(context)}: ${e.toString()}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(bottom: bottomInsets),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ask a Question'.tr(context),
                  style: AppTextStyles.headingSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: AppColors.textSecondary,
                  iconSize: 22,
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject dropdown
                    Text(
                      'Subject'.tr(context),
                      style: AppTextStyles.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildSubjectDropdown(context),

                    const SizedBox(height: AppSpacing.lg),

                    // Title field
                    Text(
                      'Title'.tr(context),
                      style: AppTextStyles.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: AppTextStyles.bodyMedium,
                      maxLength: 150,
                      decoration: InputDecoration(
                        hintText:
                            'e.g. How to solve differential equations?'
                                .tr(context),
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        counterStyle: AppTextStyles.caption,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title'.tr(context);
                        }
                        if (value.trim().length < 10) {
                          return 'Title must be at least 10 characters'
                              .tr(context);
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Body text area
                    Text(
                      'Details'.tr(context),
                      style: AppTextStyles.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bodyController,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 6,
                      maxLength: 2000,
                      decoration: InputDecoration(
                        hintText: 'Describe your question in detail...'
                            .tr(context),
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.error,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        counterStyle: AppTextStyles.caption,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please describe your question'.tr(context);
                        }
                        if (value.trim().length < 20) {
                          return 'Details must be at least 20 characters'
                              .tr(context);
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Guidelines callout
                    GlassContainer(
                      blur: 8,
                      opacity: 0.5,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 18,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Be specific and include relevant details to get better answers.'
                                  .tr(context),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Submit button
                    GlassButton(
                      label: 'Post Question'.tr(context),
                      icon: Icons.send_rounded,
                      onPressed: _isSubmitting ? null : _submitQuestion,
                      isLoading: _isSubmitting,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      borderColor: AppColors.primaryDark,
                    ),

                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the subject selection dropdown styled as a tappable field.
  Widget _buildSubjectDropdown(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSubjectPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: _selectedSubject == null && _formSubmitted
                ? AppColors.error
                : AppColors.border.withAlpha(0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.category_outlined,
              size: 20,
              color: _selectedSubject != null
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedSubject ?? 'Select a subject'.tr(context),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _selectedSubject != null
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  /// Whether the form has been submitted at least once (for inline validation).
  bool get _formSubmitted => _isSubmitting;

  /// Shows a modal bottom sheet to pick a subject.
  void _showSubjectPicker(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: false,
      context: context,
      useRootNavigator: true,

      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Select Subject'.tr(context),
                style: AppTextStyles.headingSmall,
              ),
            ),

            // Subject list
            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  final isSelected = _selectedSubject == subject;

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withAlpha(20)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getSubjectIcon(subject),
                        size: 20,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      subject.tr(context),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 22,
                          )
                        : null,
                    onTap: () {
                      setState(() => _selectedSubject = subject);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Map subject name to a representative icon.
  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'Mathematics':
        return Icons.calculate_outlined;
      case 'Physics':
        return Icons.science_outlined;
      case 'Chemistry':
        return Icons.biotech_outlined;
      case 'Computer Science':
        return Icons.computer_outlined;
      case 'Data Structures':
        return Icons.account_tree_outlined;
      case 'Machine Learning':
        return Icons.psychology_outlined;
      case 'Economics':
        return Icons.trending_up_outlined;
      case 'Statistics':
        return Icons.bar_chart_outlined;
      case 'English':
        return Icons.menu_book_outlined;
      case 'Biology':
        return Icons.eco_outlined;
      default:
        return Icons.school_outlined;
    }
  }
}
