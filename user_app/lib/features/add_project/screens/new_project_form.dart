import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/project_provider.dart';
import '../widgets/budget_display.dart';
import '../widgets/deadline_picker.dart';
import '../widgets/file_attachment.dart';
import '../widgets/reference_style_dropdown.dart';
import '../widgets/subject_dropdown.dart';
import '../widgets/success_popup.dart';
import '../widgets/word_count_input.dart';

/// Multi-step form for creating new project with beautiful gradient design.
class NewProjectForm extends ConsumerStatefulWidget {
  const NewProjectForm({super.key});

  @override
  ConsumerState<NewProjectForm> createState() => _NewProjectFormState();
}

class _NewProjectFormState extends ConsumerState<NewProjectForm> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Form data
  ProjectSubject? _subject;
  DateTime? _deadline;
  int? _wordCount;
  ReferenceStyle? _referenceStyle;
  List<AttachmentFile> _attachments = [];

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  /// Submits the project and shows success popup.
  Future<void> _submitProject() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    try {
      final project = await ref.read(projectNotifierProvider.notifier).createProject(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        serviceType: ServiceType.newProject,
        subjectId: _subject?.id,
        deadline: _deadline ?? DateTime.now().add(const Duration(days: 7)),
        wordCount: _wordCount,
        referenceStyleId: _referenceStyle?.id,
        specificInstructions: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (!mounted) return;

      final projectId = project?.id ?? '';

      await SuccessPopup.show(
        context,
        title: 'Project Submitted!',
        message: 'Your project has been submitted successfully. We\'ll match you with an expert soon.',
        projectId: projectId,
        onViewProject: () {
          context.go('/projects/$projectId');
        },
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'New Project',
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                  Colors.purple.shade400,
                ],
              ),
            ),
          ),

          // Content with glass morphism
          SafeArea(
            child: Column(
              children: [
                // Progress indicator
                _StepIndicator(
                  currentStep: _currentStep,
                  totalSteps: 3,
                  labels: const ['Details', 'Requirements', 'Review'],
                ),

                // Form content with glass morphism
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Form(
                        key: _formKey,
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildStep1(),
                            _buildStep2(),
                            _buildStep3(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom buttons
                _buildBottomButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Project Details', style: AppTextStyles.headingSmall),
                  Text(
                    'Tell us about your project',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Title
          _buildLabel('Project Title', Icons.title),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _titleController,
            hint: 'e.g., Research Paper on Climate Change',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a project title';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Subject
          _buildLabel('Subject Area', Icons.school_outlined),
          const SizedBox(height: 8),
          SubjectDropdown(
            value: _subject,
            onChanged: (value) => setState(() => _subject = value),
            errorText: null,
          ),
          const SizedBox(height: 20),

          // Description
          _buildLabel('Project Description', Icons.notes),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _descriptionController,
            hint: 'Describe your project requirements in detail...',
            maxLines: 5,
            validator: (value) {
              if (value == null || value.length < 20) {
                return 'Please provide more details (min 20 characters)';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Deadline
          _buildLabel('Deadline', Icons.calendar_today),
          const SizedBox(height: 8),
          DeadlinePicker(
            value: _deadline,
            onChanged: (value) => setState(() => _deadline = value),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Requirements', style: AppTextStyles.headingSmall),
                  Text(
                    'Specify your project requirements',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Word count
          _buildLabel('Word Count', Icons.format_size),
          const SizedBox(height: 8),
          WordCountInput(
            value: _wordCount,
            onChanged: (value) => setState(() => _wordCount = value),
          ),
          const SizedBox(height: 24),

          // Reference style
          _buildLabel('Reference Style', Icons.format_quote),
          const SizedBox(height: 8),
          ReferenceStyleDropdown(
            value: _referenceStyle,
            onChanged: (value) => setState(() => _referenceStyle = value),
          ),
          const SizedBox(height: 24),

          // Attachments
          _buildLabel('Reference Materials', Icons.attach_file),
          const SizedBox(height: 8),
          FileAttachment(
            files: _attachments,
            onChanged: (files) => setState(() => _attachments = files),
            label: 'Reference Materials',
            hint: 'Upload any reference documents, guidelines, or examples',
            maxFiles: 5,
            maxSizeMB: 10,
          ),
          const SizedBox(height: 24),

          // Additional notes
          _buildLabel('Additional Notes', Icons.notes),
          const SizedBox(height: 4),
          Text(
            'Any specific instructions or preferences',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _notesController,
            hint: 'e.g., Prefer formal tone, avoid certain topics...',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final basePrice = _calculateBasePrice();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Review & Submit', style: AppTextStyles.headingSmall),
                  Text(
                    'Review your project details',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Project summary
          _SummaryCard(
            title: 'Project Details',
            icon: Icons.description_outlined,
            items: [
              _SummaryItem('Title', _titleController.text),
              _SummaryItem('Subject', _subject?.displayName ?? 'Not selected'),
              _SummaryItem(
                'Deadline',
                _deadline != null
                    ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                    : 'Not set',
              ),
            ],
          ),
          const SizedBox(height: 16),

          _SummaryCard(
            title: 'Requirements',
            icon: Icons.checklist_outlined,
            items: [
              _SummaryItem(
                'Word Count',
                _wordCount != null ? '$_wordCount words' : 'Not specified',
              ),
              _SummaryItem(
                'Reference Style',
                _referenceStyle?.displayName ?? 'Not selected',
              ),
              _SummaryItem('Attachments', '${_attachments.length} file(s)'),
            ],
          ),
          const SizedBox(height: 24),

          // Budget display
          BudgetDisplay(
            basePrice: basePrice,
            urgencyTier: _getUrgencyTier(),
            wordCount: _wordCount,
          ),
          const SizedBox(height: 24),

          // Terms
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.info.withValues(alpha: 0.1),
                  AppColors.info.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.info,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'By submitting, you agree to our Terms of Service and Privacy Policy.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Colors.purple.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : _currentStep < 2
                        ? _nextStep
                        : _submitProject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _currentStep < 2 ? 'Continue' : 'Submit Project',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.labelMedium),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  double? _calculateBasePrice() {
    if (_wordCount == null) return null;
    return _wordCount! * 0.5;
  }

  UrgencyTier _getUrgencyTier() {
    if (_deadline == null) return UrgencyTier.standard;
    final daysUntil = _deadline!.difference(DateTime.now()).inDays;
    if (daysUntil < 1) return UrgencyTier.urgent;
    if (daysUntil <= 3) return UrgencyTier.express;
    if (daysUntil <= 7) return UrgencyTier.standard;
    return UrgencyTier.relaxed;
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (index > 0)
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: isCompleted || isCurrent
                                      ? LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.white.withValues(alpha: 0.5),
                                          ],
                                        )
                                      : null,
                                  color: isCompleted || isCurrent
                                      ? null
                                      : Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted || isCurrent
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              boxShadow: isCompleted || isCurrent
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: isCompleted
                                  ? Icon(
                                      Icons.check,
                                      size: 18,
                                      color: AppColors.primary,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: isCurrent
                                            ? AppColors.primary
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          if (index < totalSteps - 1)
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: isCompleted
                                      ? LinearGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.5),
                                            Colors.white.withValues(alpha: 0.3),
                                          ],
                                        )
                                      : null,
                                  color: isCompleted
                                      ? null
                                      : Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labels[index],
                        style: AppTextStyles.caption.copyWith(
                          color: isCurrent || isCompleted
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_SummaryItem> items;

  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceVariant.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      item.value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;

  const _SummaryItem(this.label, this.value);
}
