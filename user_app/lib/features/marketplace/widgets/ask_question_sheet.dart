import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_subject.dart';
import '../../../providers/marketplace_provider.dart';

/// Bottom sheet for asking a new question.
class AskQuestionSheet extends ConsumerStatefulWidget {
  /// Callback when question is successfully submitted.
  final VoidCallback? onSuccess;

  const AskQuestionSheet({
    super.key,
    this.onSuccess,
  });

  /// Show the ask question sheet.
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AskQuestionSheet(onSuccess: onSuccess),
    );
  }

  @override
  ConsumerState<AskQuestionSheet> createState() => _AskQuestionSheetState();
}

class _AskQuestionSheetState extends ConsumerState<AskQuestionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  ProjectSubject? _selectedSubject;
  final List<String> _tags = [];
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  /// Add a tag.
  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 5) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  /// Remove a tag.
  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  /// Submit the question.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a subject'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(submitQuestionProvider({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'subject': _selectedSubject!.toDbString(),
        'tags': _tags,
        'is_anonymous': _isAnonymous,
      }).future);

      if (mounted) {
        // Invalidate questions provider to refresh list
        ref.invalidate(questionsProvider);

        Navigator.pop(context);
        widget.onSuccess?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Question posted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post question: $e'),
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
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
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
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Ask a Question',
                        style: AppTextStyles.headingMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          Text(
                            'Get help from the community',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Question title
                          _buildLabel('Question Title', required: true),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            decoration: _inputDecoration(
                              hintText: "What's your question?",
                            ),
                            maxLines: 2,
                            maxLength: 200,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a question title';
                              }
                              if (value.trim().length < 10) {
                                return 'Title must be at least 10 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Details
                          _buildLabel('Details'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _contentController,
                            decoration: _inputDecoration(
                              hintText: 'Provide more context about your question...',
                            ),
                            maxLines: 5,
                            maxLength: 2000,
                            textInputAction: TextInputAction.newline,
                          ),
                          const SizedBox(height: 16),

                          // Subject dropdown
                          _buildLabel('Subject', required: true),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<ProjectSubject>(
                            initialValue: _selectedSubject,
                            decoration: _inputDecoration(
                              hintText: 'Select a subject',
                            ),
                            items: ProjectSubject.values.map((subject) {
                              return DropdownMenuItem(
                                value: subject,
                                child: Row(
                                  children: [
                                    Icon(
                                      subject.icon,
                                      size: 18,
                                      color: subject.color,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(subject.displayName),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedSubject = value);
                            },
                          ),
                          const SizedBox(height: 16),

                          // Tags
                          _buildLabel('Tags (optional)'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _tagController,
                                  decoration: _inputDecoration(
                                    hintText: 'Add a tag',
                                    suffixIcon: IconButton(
                                      onPressed: _tags.length < 5 ? _addTag : null,
                                      icon: const Icon(Icons.add),
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _addTag(),
                                ),
                              ),
                            ],
                          ),
                          if (_tags.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _tags.map((tag) {
                                return Chip(
                                  label: Text(
                                    tag,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  backgroundColor: AppColors.primaryLight.withAlpha(30),
                                  deleteIconColor: AppColors.primary,
                                  onDeleted: () => _removeTag(tag),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: AppColors.primary.withAlpha(50),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          Text(
                            '${_tags.length}/5 tags',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Anonymous toggle
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isAnonymous
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Post anonymously',
                                        style: AppTextStyles.labelMedium,
                                      ),
                                      Text(
                                        'Your name and profile will be hidden',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isAnonymous,
                                  onChanged: (value) {
                                    setState(() => _isAnonymous = value);
                                  },
                                  activeThumbColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80), // Space for button
                        ],
                      ),
                    ),
                  ),
                ),
                // Submit button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                'Post Question',
                                style: AppTextStyles.buttonMedium,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build a label widget.
  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.error,
            ),
          ),
      ],
    );
  }

  /// Build input decoration.
  InputDecoration _inputDecoration({
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      suffixIcon: suffixIcon,
    );
  }
}
