import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/project_provider.dart';
import '../widgets/budget_display.dart';
import '../widgets/deadline_picker.dart';
import '../widgets/file_attachment.dart';
import '../widgets/focus_area_chips.dart';
import '../widgets/project_type_selector.dart';
import '../widgets/reference_style_dropdown.dart';
import '../widgets/subject_dropdown.dart';
import '../widgets/success_popup.dart';
import '../widgets/wizard_progress_header.dart';
import '../widgets/word_count_input.dart';

/// Multi-step project creation wizard with 4 steps.
///
/// Step 1: Project Type + Subject + Title
/// Step 2: Details + Requirements
/// Step 3: Files + Deadline
/// Step 4: Review + Submit
class ProjectWizardScreen extends ConsumerStatefulWidget {
  const ProjectWizardScreen({super.key});

  @override
  ConsumerState<ProjectWizardScreen> createState() =>
      _ProjectWizardScreenState();
}

class _ProjectWizardScreenState extends ConsumerState<ProjectWizardScreen> {
  final _pageController = PageController();
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1 data
  ProjectType? _projectType;
  ProjectSubject? _subject;
  final _titleController = TextEditingController();

  // Step 2 data
  final _descriptionController = TextEditingController();
  int? _wordCount;
  ReferenceStyle? _referenceStyle;
  Set<FocusArea> _focusAreas = {};

  // Step 3 data
  List<AttachmentFile> _attachments = [];
  DateTime? _deadline;

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Validates the current step and moves to the next.
  void _nextStep() {
    if (!_validateCurrentStep()) return;

    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  /// Moves to the previous step.
  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  /// Navigates to a specific step (used by review edit buttons).
  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = step);
  }

  /// Validates the current step's form fields.
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_projectType == null) {
          _showValidationError('Please select a project type');
          return false;
        }
        if (_titleController.text.trim().isEmpty) {
          _showValidationError('Please enter a project title');
          return false;
        }
        return true;
      case 1:
        if (_descriptionController.text.trim().length < 20) {
          _showValidationError(
            'Please provide more details (min 20 characters)',
          );
          return false;
        }
        return true;
      case 2:
        if (_deadline == null) {
          _showValidationError('Please select a deadline');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Maps ProjectType to ServiceType for the database.
  ServiceType _getServiceType() {
    switch (_projectType) {
      case ProjectType.assignment:
      case ProjectType.document:
      case ProjectType.website:
      case ProjectType.app:
        return ServiceType.newProject;
      case ProjectType.consultancy:
        return ServiceType.expertOpinion;
      case ProjectType.turnitinCheck:
        return ServiceType.plagiarismCheck;
      case null:
        return ServiceType.newProject;
    }
  }

  /// Submits the project and shows a success popup.
  Future<void> _submitProject() async {
    setState(() => _isSubmitting = true);

    try {
      final project =
          await ref.read(projectNotifierProvider.notifier).createProject(
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
                serviceType: _getServiceType(),
                subjectId: _subject?.toDbString(),
                deadline:
                    _deadline ?? DateTime.now().add(const Duration(days: 7)),
                wordCount: _wordCount,
                referenceStyleId: _referenceStyle?.name,
                focusAreas: _focusAreas.isNotEmpty
                    ? _focusAreas.map((a) => a.displayName).toList()
                    : null,
              );

      if (!mounted) return;

      final projectId = project?.id ?? '';

      await SuccessPopup.show(
        context,
        title: 'Project Submitted!',
        message:
            'Your project has been submitted successfully. We\'ll match you with an expert soon.',
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
          style: AppTextStyles.headingSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
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
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.85),
                  AppColors.primaryDark,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Wizard progress header
                WizardProgressHeader(
                  currentStep: _currentStep,
                  totalSteps: 4,
                ),

                // Form pages
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStep1(),
                          _buildStep2(),
                          _buildStep3(),
                          _buildStep4(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom navigation buttons
                _buildBottomButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Step 1: Project Type + Subject + Title.
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project type selector
            ProjectTypeSelector(
              selected: _projectType,
              onSelected: (type) => setState(() => _projectType = type),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Subject dropdown
            SubjectDropdown(
              value: _subject,
              onChanged: (value) => setState(() => _subject = value),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Title input
            Text(
              'Topic / Title',
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g., Research Paper on Climate Change',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(
                  Icons.title,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a project title';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Step 2: Details + Requirements.
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              'Project Description',
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Describe your project requirements in detail...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 20) {
                  return 'Please provide more details (min 20 characters)';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Word count
            WordCountInput(
              value: _wordCount,
              onChanged: (value) => setState(() => _wordCount = value),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Reference style
            ReferenceStyleDropdown(
              value: _referenceStyle,
              onChanged: (value) => setState(() => _referenceStyle = value),
              isRequired: false,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Focus area chips
            FocusAreaChips(
              selectedAreas: _focusAreas,
              onChanged: (areas) => setState(() => _focusAreas = areas),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 3: Files + Deadline.
  Widget _buildStep3() {
    final basePrice = _wordCount != null ? _wordCount! * 0.5 : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File attachment
            Row(
              children: [
                Icon(Icons.attach_file, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Reference Materials', style: AppTextStyles.labelMedium),
              ],
            ),
            const SizedBox(height: 8),
            FileAttachment(
              files: _attachments,
              onChanged: (files) => setState(() => _attachments = files),
              hint: 'Upload reference documents, guidelines, or examples',
              maxFiles: 5,
              maxSizeMB: 10,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Deadline picker
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text('Deadline', style: AppTextStyles.labelMedium),
              ],
            ),
            const SizedBox(height: 8),
            DeadlinePicker(
              value: _deadline,
              onChanged: (value) => setState(() => _deadline = value),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Budget display
            BudgetDisplay(
              basePrice: basePrice,
              urgencyTier: _getUrgencyTier(),
              wordCount: _wordCount,
            ),
          ],
        ),
      ),
    );
  }

  /// Step 4: Review + Submit.
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project type + subject summary
          _ReviewSection(
            title: 'Project Type & Subject',
            icon: Icons.category_outlined,
            onEdit: () => _goToStep(0),
            items: [
              _ReviewItem('Type', _projectType?.displayName ?? 'Not selected'),
              _ReviewItem(
                'Subject',
                _subject?.displayName ?? 'Not selected',
              ),
              _ReviewItem(
                'Title',
                _titleController.text.isNotEmpty
                    ? _titleController.text
                    : 'Not entered',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Details summary
          _ReviewSection(
            title: 'Details & Requirements',
            icon: Icons.checklist_outlined,
            onEdit: () => _goToStep(1),
            items: [
              _ReviewItem(
                'Description',
                _descriptionController.text.isNotEmpty
                    ? _descriptionController.text.length > 60
                        ? '${_descriptionController.text.substring(0, 60)}...'
                        : _descriptionController.text
                    : 'Not provided',
              ),
              _ReviewItem(
                'Word Count',
                _wordCount != null ? '$_wordCount words' : 'Not specified',
              ),
              _ReviewItem(
                'Reference Style',
                _referenceStyle?.displayName ?? 'Not selected',
              ),
              _ReviewItem(
                'Focus Areas',
                _focusAreas.isNotEmpty
                    ? _focusAreas.map((a) => a.displayName).join(', ')
                    : 'None selected',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Files + deadline summary
          _ReviewSection(
            title: 'Files & Deadline',
            icon: Icons.upload_file_outlined,
            onEdit: () => _goToStep(2),
            items: [
              _ReviewItem(
                'Attachments',
                '${_attachments.length} file(s)',
              ),
              _ReviewItem(
                'Deadline',
                _deadline != null
                    ? DateFormat('EEE, MMM d, y').format(_deadline!)
                    : 'Not set',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Budget card
          BudgetDisplay(
            basePrice: _wordCount != null ? _wordCount! * 0.5 : null,
            urgencyTier: _getUrgencyTier(),
            wordCount: _wordCount,
          ),

          const SizedBox(height: AppSpacing.md),

          // Terms notice
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.info.withValues(alpha: 0.1),
                  AppColors.info.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
              ),
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

  /// Bottom navigation buttons (Back / Continue / Submit).
  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
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
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.border),
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
                  colors: [AppColors.primary, AppColors.primaryDark],
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
                    : _currentStep < 3
                        ? _nextStep
                        : _submitProject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep < 3 ? 'Continue' : 'Submit Project',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentStep < 3
                                ? Icons.arrow_forward
                                : Icons.check_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
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

/// Summary section in the review step with an edit button.
class _ReviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onEdit;
  final List<_ReviewItem> items;

  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.onEdit,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      item.value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
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

class _ReviewItem {
  final String label;
  final String value;

  const _ReviewItem(this.label, this.value);
}
