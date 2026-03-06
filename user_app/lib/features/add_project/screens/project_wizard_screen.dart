import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
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
import '../widgets/word_count_input.dart';

class _StepContext {
  final IconData icon;
  final String heading;
  final String subtitle;
  const _StepContext(
      {required this.icon, required this.heading, required this.subtitle});
}

const _steps = [
  _StepContext(
    icon: Icons.lightbulb_outline,
    heading: 'What do you need?',
    subtitle: 'Select your project type, subject & topic',
  ),
  _StepContext(
    icon: Icons.edit_note,
    heading: 'Tell us more',
    subtitle: 'Add description, word count & preferences',
  ),
  _StepContext(
    icon: Icons.calendar_today_outlined,
    heading: 'Files & timeline',
    subtitle: 'Upload references and set your deadline',
  ),
  _StepContext(
    icon: Icons.check_circle_outline,
    heading: 'Review & submit',
    subtitle: 'Double-check everything before submitting',
  ),
];

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

  ProjectType? _projectType;
  ProjectSubject? _subject;
  final _titleController = TextEditingController();

  final _descriptionController = TextEditingController();
  int? _wordCount;
  ReferenceStyle? _referenceStyle;
  Set<FocusArea> _focusAreas = {};

  List<AttachmentFile> _attachments = [];
  DateTime? _deadline;

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  void _goToStep(int step) {
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep = step);
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_projectType == null) {
          _showError('Please select a project type');
          return false;
        }
        if (_titleController.text.trim().isEmpty) {
          _showError('Please enter a project title');
          return false;
        }
        return true;
      case 1:
        if (_descriptionController.text.trim().length < 20) {
          _showError('Please provide more details (min 20 characters)');
          return false;
        }
        return true;
      case 2:
        if (_deadline == null) {
          _showError('Please select a deadline');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

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
        onViewProject: () => context.go('/projects/$projectId'),
      );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// The inline CTA button that scrolls with content.
  Widget _buildInlineButton({bool isSubmit = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 24),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : isSubmit
                  ? _submitProject
                  : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF111827),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF111827).withAlpha(150),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSubmit ? 'Submit Project' : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSubmit ? Icons.check_circle : Icons.arrow_forward,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final progress = (_currentStep + 1) / 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed:
                        _currentStep > 0 ? _previousStep : () => context.pop(),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Step ${_currentStep + 1} of 4',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.close, size: 22, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // ── Progress bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),

            // ── Step heading ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withAlpha(25),
                          AppColors.primary.withAlpha(10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppColors.primary.withAlpha(30)),
                    ),
                    child: Icon(step.icon, size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.heading,
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Form content (scrollable with inline button) ──
            Expanded(
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
          ],
        ),
      ),
    );
  }

  // ── Step 1 ──
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProjectTypeSelector(
              selected: _projectType,
              onSelected: (type) => setState(() => _projectType = type),
            ),
            const SizedBox(height: 24),
            SubjectDropdown(
              value: _subject,
              onChanged: (value) => setState(() => _subject = value),
            ),
            const SizedBox(height: 24),
            _SectionLabel(label: 'Topic / Title'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hint: 'e.g., Research Paper on Climate Change',
              icon: Icons.edit_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter a project title';
                }
                return null;
              },
            ),
            _buildInlineButton(),
          ],
        ),
      ),
    );
  }

  // ── Step 2 ──
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: 'Project Description'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hint: 'Describe your project requirements in detail...',
              maxLines: 5,
              validator: (v) {
                if (v == null || v.trim().length < 20) {
                  return 'Min 20 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            WordCountInput(
              value: _wordCount,
              onChanged: (value) => setState(() => _wordCount = value),
            ),
            const SizedBox(height: 24),
            ReferenceStyleDropdown(
              value: _referenceStyle,
              onChanged: (value) => setState(() => _referenceStyle = value),
              isRequired: false,
            ),
            const SizedBox(height: 24),
            FocusAreaChips(
              selectedAreas: _focusAreas,
              onChanged: (areas) => setState(() => _focusAreas = areas),
            ),
            _buildInlineButton(),
          ],
        ),
      ),
    );
  }

  // ── Step 3 ──
  Widget _buildStep3() {
    final basePrice = _wordCount != null ? _wordCount! * 0.5 : null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: 'Reference Materials', icon: Icons.attach_file),
            const SizedBox(height: 8),
            FileAttachment(
              files: _attachments,
              onChanged: (files) => setState(() => _attachments = files),
              hint: 'Upload reference documents, guidelines, or examples',
              maxFiles: 5,
              maxSizeMB: 10,
            ),
            const SizedBox(height: 28),
            _SectionLabel(label: 'Deadline', icon: Icons.schedule),
            const SizedBox(height: 8),
            DeadlinePicker(
              value: _deadline,
              onChanged: (value) => setState(() => _deadline = value),
            ),
            const SizedBox(height: 28),
            BudgetDisplay(
              basePrice: basePrice,
              urgencyTier: _getUrgencyTier(),
              wordCount: _wordCount,
            ),
            _buildInlineButton(),
          ],
        ),
      ),
    );
  }

  // ── Step 4 ──
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewCard(
            title: 'Project Type & Subject',
            icon: Icons.category_outlined,
            onEdit: () => _goToStep(0),
            items: [
              _ReviewItem('Type', _projectType?.displayName ?? 'Not selected'),
              _ReviewItem('Subject', _subject?.displayName ?? 'Not selected'),
              _ReviewItem(
                'Title',
                _titleController.text.isNotEmpty
                    ? _titleController.text
                    : 'Not entered',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ReviewCard(
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
              _ReviewItem('Word Count',
                  _wordCount != null ? '$_wordCount words' : 'Not specified'),
              _ReviewItem('Reference Style',
                  _referenceStyle?.displayName ?? 'Not selected'),
              _ReviewItem(
                'Focus Areas',
                _focusAreas.isNotEmpty
                    ? _focusAreas.map((a) => a.displayName).join(', ')
                    : 'None selected',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ReviewCard(
            title: 'Files & Deadline',
            icon: Icons.upload_file_outlined,
            onEdit: () => _goToStep(2),
            items: [
              _ReviewItem('Attachments', '${_attachments.length} file(s)'),
              _ReviewItem(
                'Deadline',
                _deadline != null
                    ? DateFormat('EEE, MMM d, y').format(_deadline!)
                    : 'Not set',
              ),
            ],
          ),
          const SizedBox(height: 16),
          BudgetDisplay(
            basePrice: _wordCount != null ? _wordCount! * 0.5 : null,
            urgencyTier: _getUrgencyTier(),
            wordCount: _wordCount,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 18, color: Color(0xFF0284C7)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'By submitting, you agree to our Terms of Service and Privacy Policy.',
                    style: AppTextStyles.caption
                        .copyWith(color: const Color(0xFF0369A1), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          _buildInlineButton(isSubmit: true),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: icon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(icon, size: 20, color: Colors.grey[400]),
              )
            : null,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
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

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _SectionLabel({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onEdit;
  final List<_ReviewItem> items;

  const _ReviewCard({
    required this.title,
    required this.icon,
    required this.onEdit,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
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
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
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
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(item.label,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937)),
                      maxLines: 2,
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

class _ReviewItem {
  final String label;
  final String value;
  const _ReviewItem(this.label, this.value);
}
