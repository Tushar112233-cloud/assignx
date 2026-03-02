import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/project_provider.dart';
import '../widgets/budget_display.dart';
import '../widgets/deadline_picker.dart';
import '../widgets/file_attachment.dart';
import '../widgets/project_type_selector.dart';
import '../widgets/reference_style_dropdown.dart';
import '../widgets/subject_dropdown.dart';
import '../widgets/success_popup.dart';
import '../../../core/translation/translation_extensions.dart';
import '../widgets/word_count_input.dart';

/// Multi-step wizard form for creating new projects.
///
/// 4-step flow:
/// 1. Type     - Select project type (Assignment, Document, Website, App, Consultancy, Turnitin)
/// 2. Details  - Title, subject, description, deadline
/// 3. Requirements - Dynamic fields based on selected project type
/// 4. Review   - Summary, pricing, terms, submit
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

  // Step 1: Project type
  ProjectType? _projectType;

  // Step 2: Project details
  ProjectSubject? _subject;
  DateTime? _deadline;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Step 3: Requirements (shared)
  int? _wordCount;
  ReferenceStyle? _referenceStyle;
  List<AttachmentFile> _attachments = [];
  final _notesController = TextEditingController();

  // Step 3: Website-specific
  final _pageCountController = TextEditingController();
  final _techStackController = TextEditingController();
  final _keyFeaturesController = TextEditingController();
  final _designRefController = TextEditingController();

  // Step 3: App-specific
  final Set<String> _selectedPlatforms = {};

  // Step 3: Consultancy-specific
  final _durationController = TextEditingController();
  final _questionSummaryController = TextEditingController();
  DateTime? _preferredDateTime;

  // Step 3: Turnitin-specific
  String? _turnitinReportType;

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _pageCountController.dispose();
    _techStackController.dispose();
    _keyFeaturesController.dispose();
    _designRefController.dispose();
    _durationController.dispose();
    _questionSummaryController.dispose();
    super.dispose();
  }

  /// Navigate to the next step. On Step 0 (type selection),
  /// validates that a project type is selected.
  void _nextStep() {
    if (_currentStep == 0 && _projectType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a project type'.tr(context)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

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

  /// Maps the selected ProjectType to a ServiceType for the database.
  ServiceType _mapServiceType() {
    switch (_projectType) {
      case ProjectType.consultancy:
        return ServiceType.expertOpinion;
      case ProjectType.turnitinCheck:
        return ServiceType.plagiarismCheck;
      default:
        return ServiceType.newProject;
    }
  }

  /// Builds the specific instructions string from type-specific fields.
  String _buildSpecificInstructions() {
    final parts = <String>[];

    if (_projectType != null) {
      parts.add('Project Type: ${_projectType!.displayName}');
    }

    switch (_projectType) {
      case ProjectType.website:
        if (_pageCountController.text.isNotEmpty) {
          parts.add('Number of Pages: ${_pageCountController.text}');
        }
        if (_techStackController.text.isNotEmpty) {
          parts.add('Tech Stack: ${_techStackController.text}');
        }
        if (_keyFeaturesController.text.isNotEmpty) {
          parts.add('Key Features: ${_keyFeaturesController.text}');
        }
        if (_designRefController.text.isNotEmpty) {
          parts.add('Design Reference: ${_designRefController.text}');
        }
        break;

      case ProjectType.app:
        if (_selectedPlatforms.isNotEmpty) {
          parts.add('Platforms: ${_selectedPlatforms.join(', ')}');
        }
        if (_keyFeaturesController.text.isNotEmpty) {
          parts.add('Key Features: ${_keyFeaturesController.text}');
        }
        if (_designRefController.text.isNotEmpty) {
          parts.add('Design Reference: ${_designRefController.text}');
        }
        break;

      case ProjectType.consultancy:
        if (_durationController.text.isNotEmpty) {
          parts.add('Duration: ${_durationController.text}');
        }
        if (_questionSummaryController.text.isNotEmpty) {
          parts.add('Question: ${_questionSummaryController.text}');
        }
        if (_preferredDateTime != null) {
          parts.add(
            'Preferred Date/Time: ${_preferredDateTime!.day}/${_preferredDateTime!.month}/${_preferredDateTime!.year} '
            '${_preferredDateTime!.hour}:${_preferredDateTime!.minute.toString().padLeft(2, '0')}',
          );
        }
        break;

      case ProjectType.turnitinCheck:
        if (_turnitinReportType != null) {
          parts.add('Report Type: $_turnitinReportType');
        }
        break;

      default:
        break;
    }

    if (_notesController.text.trim().isNotEmpty) {
      parts.add('Additional Notes: ${_notesController.text.trim()}');
    }

    return parts.join('\n');
  }

  /// Submits the project and shows success popup.
  Future<void> _submitProject() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    try {
      final specificInstructions = _buildSpecificInstructions();

      final project = await ref.read(projectNotifierProvider.notifier).createProject(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        serviceType: _mapServiceType(),
        subjectId: _subject?.name,
        deadline: _deadline ?? DateTime.now().add(const Duration(days: 7)),
        wordCount: _wordCount,
        pageCount: int.tryParse(_pageCountController.text),
        referenceStyleId: _referenceStyle?.name,
        specificInstructions: specificInstructions.isNotEmpty ? specificInstructions : null,
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

  /// Returns a contextual placeholder for the title field based on project type.
  String _getTitlePlaceholder() {
    switch (_projectType) {
      case ProjectType.assignment:
        return 'e.g., Research Paper on Climate Change';
      case ProjectType.document:
        return 'e.g., Annual Financial Report 2026';
      case ProjectType.website:
        return 'e.g., E-commerce Website for Boutique';
      case ProjectType.app:
        return 'e.g., Fitness Tracking Mobile App';
      case ProjectType.consultancy:
        return 'e.g., Thesis Topic Selection Guidance';
      case ProjectType.turnitinCheck:
        return 'e.g., Thesis AI & Plagiarism Check';
      default:
        return 'e.g., My New Project';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'New Project'.tr(context),
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
                // Progress indicator - 4 steps
                _StepIndicator(
                  currentStep: _currentStep,
                  totalSteps: 4,
                  labels: [
                    'Type'.tr(context),
                    'Details'.tr(context),
                    'Requirements'.tr(context),
                    'Review'.tr(context),
                  ],
                ),

                // Form content with glass morphism card
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
                            _buildStep1TypeSelection(),
                            _buildStep2Details(),
                            _buildStep3Requirements(),
                            _buildStep4Review(),
                          ],
                        ),
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

  // ---------------------------------------------------------------------------
  // STEP 1: Project Type Selection
  // ---------------------------------------------------------------------------

  Widget _buildStep1TypeSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header
          _buildStepHeader(
            icon: Icons.category_outlined,
            title: 'Project Type'.tr(context),
            subtitle: 'What kind of project do you need help with?'.tr(context),
          ),
          const SizedBox(height: 28),

          // Project type grid
          ProjectTypeSelector(
            selected: _projectType,
            onSelected: (type) => setState(() => _projectType = type),
          ),

          const SizedBox(height: 20),

          // Info hint
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.info.withValues(alpha: 0.08),
                  AppColors.info.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 18, color: AppColors.info),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Choose the type that best matches your project for optimal expert matching.'.tr(context),
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

  // ---------------------------------------------------------------------------
  // STEP 2: Project Details
  // ---------------------------------------------------------------------------

  Widget _buildStep2Details() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header
          _buildStepHeader(
            icon: Icons.description_outlined,
            title: 'Project Details'.tr(context),
            subtitle: 'Tell us about your project'.tr(context),
          ),
          const SizedBox(height: 28),

          // Title
          _buildLabel('Project Title'.tr(context), Icons.title),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _titleController,
            hint: _getTitlePlaceholder().tr(context),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a project title'.tr(context);
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Subject
          _buildLabel('Subject Area'.tr(context), Icons.school_outlined),
          const SizedBox(height: 8),
          SubjectDropdown(
            value: _subject,
            onChanged: (value) => setState(() => _subject = value),
            errorText: null,
          ),
          const SizedBox(height: 20),

          // Description
          _buildLabel('Project Description'.tr(context), Icons.notes),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _descriptionController,
            hint: 'Describe your project requirements in detail...'.tr(context),
            maxLines: 5,
            validator: (value) {
              if (value == null || value.length < 20) {
                return 'Please provide more details (min 20 characters)'.tr(context);
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Deadline
          _buildLabel('Deadline'.tr(context), Icons.calendar_today),
          const SizedBox(height: 8),
          DeadlinePicker(
            value: _deadline,
            onChanged: (value) => setState(() => _deadline = value),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3: Requirements (dynamic based on project type)
  // ---------------------------------------------------------------------------

  Widget _buildStep3Requirements() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header
          _buildStepHeader(
            icon: Icons.settings_outlined,
            title: 'Requirements'.tr(context),
            subtitle: 'Specify your project requirements'.tr(context),
          ),
          const SizedBox(height: 28),

          // Dynamic content based on project type
          ..._buildTypeSpecificFields(),
        ],
      ),
    );
  }

  /// Returns the list of form widgets appropriate for the selected project type.
  List<Widget> _buildTypeSpecificFields() {
    switch (_projectType) {
      case ProjectType.assignment:
      case ProjectType.document:
        return _buildAssignmentDocumentFields();
      case ProjectType.website:
        return _buildWebsiteFields();
      case ProjectType.app:
        return _buildAppFields();
      case ProjectType.consultancy:
        return _buildConsultancyFields();
      case ProjectType.turnitinCheck:
        return _buildTurnitinFields();
      default:
        return _buildAssignmentDocumentFields();
    }
  }

  /// Fields for Assignment / Document types:
  /// Word count, reference style, file attachments, additional notes.
  List<Widget> _buildAssignmentDocumentFields() {
    return [
      // Word count
      _buildLabel('Word Count'.tr(context), Icons.format_size),
      const SizedBox(height: 8),
      WordCountInput(
        value: _wordCount,
        onChanged: (value) => setState(() => _wordCount = value),
      ),
      const SizedBox(height: 24),

      // Reference style
      _buildLabel('Reference Style'.tr(context), Icons.format_quote),
      const SizedBox(height: 8),
      ReferenceStyleDropdown(
        value: _referenceStyle,
        onChanged: (value) => setState(() => _referenceStyle = value),
      ),
      const SizedBox(height: 24),

      // Attachments
      _buildLabel('Reference Materials'.tr(context), Icons.attach_file),
      const SizedBox(height: 8),
      FileAttachment(
        files: _attachments,
        onChanged: (files) => setState(() => _attachments = files),
        label: 'Reference Materials'.tr(context),
        hint: 'Upload any reference documents, guidelines, or examples'.tr(context),
        maxFiles: 5,
        maxSizeMB: 10,
      ),
      const SizedBox(height: 24),

      // Additional notes
      _buildLabel('Additional Notes'.tr(context), Icons.notes),
      const SizedBox(height: 4),
      Text(
        'Any specific instructions or preferences'.tr(context),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _notesController,
        hint: 'e.g., Prefer formal tone, avoid certain topics...'.tr(context),
        maxLines: 3,
      ),
    ];
  }

  /// Fields for Website type:
  /// Number of pages, tech stack, key features, design reference URL.
  List<Widget> _buildWebsiteFields() {
    return [
      // Number of pages
      _buildLabel('Number of Pages'.tr(context), Icons.web),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _pageCountController,
        hint: 'e.g., 5'.tr(context),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
      ),
      const SizedBox(height: 24),

      // Tech stack preference
      _buildLabel('Tech Stack Preference'.tr(context), Icons.code),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _techStackController,
        hint: 'e.g., React, Next.js, Tailwind CSS'.tr(context),
        maxLines: 2,
      ),
      const SizedBox(height: 24),

      // Key features
      _buildLabel('Key Features'.tr(context), Icons.star_outline),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _keyFeaturesController,
        hint: 'e.g., User auth, payment integration, dashboard...'.tr(context),
        maxLines: 3,
      ),
      const SizedBox(height: 24),

      // Design reference URL
      _buildLabel('Design Reference URL'.tr(context), Icons.link),
      const SizedBox(height: 4),
      Text(
        'Link to a design mockup or reference site (optional)'.tr(context),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _designRefController,
        hint: 'https://...'.tr(context),
      ),
      const SizedBox(height: 24),

      // Attachments
      _buildLabel('Reference Files'.tr(context), Icons.attach_file),
      const SizedBox(height: 8),
      FileAttachment(
        files: _attachments,
        onChanged: (files) => setState(() => _attachments = files),
        hint: 'Upload wireframes, mockups, or other reference files'.tr(context),
        maxFiles: 5,
        maxSizeMB: 10,
      ),
    ];
  }

  /// Fields for App type:
  /// Platform selection, key features, design reference URL.
  List<Widget> _buildAppFields() {
    return [
      // Platform selection
      _buildLabel('Target Platform(s)'.tr(context), Icons.devices),
      const SizedBox(height: 8),
      _PlatformSelector(
        selectedPlatforms: _selectedPlatforms,
        onChanged: (platforms) => setState(() {
          _selectedPlatforms.clear();
          _selectedPlatforms.addAll(platforms);
        }),
      ),
      const SizedBox(height: 24),

      // Key features
      _buildLabel('Key Features'.tr(context), Icons.star_outline),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _keyFeaturesController,
        hint: 'e.g., Push notifications, offline mode, social login...'.tr(context),
        maxLines: 3,
      ),
      const SizedBox(height: 24),

      // Design reference URL
      _buildLabel('Design Reference URL'.tr(context), Icons.link),
      const SizedBox(height: 4),
      Text(
        'Link to a design mockup or reference app (optional)'.tr(context),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _designRefController,
        hint: 'https://...'.tr(context),
      ),
      const SizedBox(height: 24),

      // Attachments
      _buildLabel('Reference Files'.tr(context), Icons.attach_file),
      const SizedBox(height: 8),
      FileAttachment(
        files: _attachments,
        onChanged: (files) => setState(() => _attachments = files),
        hint: 'Upload wireframes, mockups, or other reference files'.tr(context),
        maxFiles: 5,
        maxSizeMB: 10,
      ),
    ];
  }

  /// Fields for Consultancy type:
  /// Duration, question summary, preferred date/time.
  List<Widget> _buildConsultancyFields() {
    return [
      // Consultation duration
      _buildLabel('Consultation Duration'.tr(context), Icons.timer_outlined),
      const SizedBox(height: 8),
      _DurationSelector(
        value: _durationController.text,
        onChanged: (value) => setState(() => _durationController.text = value),
      ),
      const SizedBox(height: 24),

      // Question summary
      _buildLabel('Question / Topic Summary'.tr(context), Icons.help_outline),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _questionSummaryController,
        hint: 'Briefly describe what you need guidance on...'.tr(context),
        maxLines: 4,
        validator: (value) {
          if (value == null || value.length < 10) {
            return 'Please describe your question (min 10 characters)'.tr(context);
          }
          return null;
        },
      ),
      const SizedBox(height: 24),

      // Preferred date/time
      _buildLabel('Preferred Date & Time'.tr(context), Icons.calendar_today),
      const SizedBox(height: 4),
      Text(
        'When would you like the consultation? (optional)'.tr(context),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      const SizedBox(height: 8),
      DeadlinePicker(
        value: _preferredDateTime,
        onChanged: (value) => setState(() => _preferredDateTime = value),
      ),
      const SizedBox(height: 24),

      // Attachments
      _buildLabel('Supporting Documents'.tr(context), Icons.attach_file),
      const SizedBox(height: 8),
      FileAttachment(
        files: _attachments,
        onChanged: (files) => setState(() => _attachments = files),
        hint: 'Upload relevant documents for the expert to review'.tr(context),
        maxFiles: 3,
        maxSizeMB: 20,
      ),
    ];
  }

  /// Fields for Turnitin Check type:
  /// File upload, report type selection.
  List<Widget> _buildTurnitinFields() {
    return [
      // File upload (required)
      _buildLabel('Upload File(s)'.tr(context), Icons.upload_file),
      const SizedBox(height: 4),
      Text(
        'Upload the document(s) you want checked'.tr(context),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
      const SizedBox(height: 8),
      FileAttachment(
        files: _attachments,
        onChanged: (files) => setState(() => _attachments = files),
        hint: 'PDF, DOCX, or other document formats'.tr(context),
        maxFiles: 5,
        maxSizeMB: 20,
      ),
      const SizedBox(height: 24),

      // Report type selection
      _buildLabel('Report Type'.tr(context), Icons.assessment_outlined),
      const SizedBox(height: 12),
      _ReportTypeSelector(
        selected: _turnitinReportType,
        onSelected: (type) => setState(() => _turnitinReportType = type),
      ),
      const SizedBox(height: 24),

      // Additional notes
      _buildLabel('Additional Notes'.tr(context), Icons.notes),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _notesController,
        hint: 'Any specific requirements for the check...'.tr(context),
        maxLines: 3,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // STEP 4: Review & Pricing
  // ---------------------------------------------------------------------------

  Widget _buildStep4Review() {
    final basePrice = _calculateBasePrice();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header
          _buildStepHeader(
            icon: Icons.check_circle_outline,
            title: 'Review & Submit'.tr(context),
            subtitle: 'Review your project details'.tr(context),
          ),
          const SizedBox(height: 28),

          // Project type summary
          if (_projectType != null)
            _SummaryCard(
              title: 'Project Type'.tr(context),
              icon: Icons.category_outlined,
              items: [
                _SummaryItem('Type'.tr(context), _projectType!.displayName),
              ],
              accentColor: _projectType!.color,
            ),
          const SizedBox(height: 16),

          // Project details summary
          _SummaryCard(
            title: 'Project Details'.tr(context),
            icon: Icons.description_outlined,
            items: [
              _SummaryItem('Title'.tr(context), _titleController.text),
              _SummaryItem(
                'Subject'.tr(context),
                _subject?.displayName ?? 'Not selected'.tr(context),
              ),
              _SummaryItem(
                'Deadline'.tr(context),
                _deadline != null
                    ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                    : 'Not set'.tr(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Requirements summary
          _SummaryCard(
            title: 'Requirements'.tr(context),
            icon: Icons.checklist_outlined,
            items: _buildRequirementsSummaryItems(),
          ),
          const SizedBox(height: 24),

          // Budget display
          BudgetDisplay(
            basePrice: basePrice,
            urgencyTier: _getUrgencyTier(),
            wordCount: _wordCount,
          ),
          const SizedBox(height: 24),

          // Terms notice
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
                Icon(Icons.info_outline, size: 20, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'By submitting, you agree to our Terms of Service and Privacy Policy.'.tr(context),
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

  /// Builds the summary items for the requirements card depending on project type.
  List<_SummaryItem> _buildRequirementsSummaryItems() {
    final items = <_SummaryItem>[];

    switch (_projectType) {
      case ProjectType.assignment:
      case ProjectType.document:
        items.add(_SummaryItem(
          'Word Count'.tr(context),
          _wordCount != null ? '$_wordCount ${'words'.tr(context)}' : 'Not specified'.tr(context),
        ));
        items.add(_SummaryItem(
          'Reference Style'.tr(context),
          _referenceStyle?.displayName ?? 'Not selected'.tr(context),
        ));
        items.add(_SummaryItem(
          'Attachments'.tr(context),
          '${_attachments.length} ${'file(s)'.tr(context)}',
        ));
        break;

      case ProjectType.website:
        items.add(_SummaryItem(
          'Pages'.tr(context),
          _pageCountController.text.isNotEmpty ? _pageCountController.text : 'Not specified'.tr(context),
        ));
        items.add(_SummaryItem(
          'Tech Stack'.tr(context),
          _techStackController.text.isNotEmpty ? _techStackController.text : 'Not specified'.tr(context),
        ));
        items.add(_SummaryItem(
          'Key Features'.tr(context),
          _keyFeaturesController.text.isNotEmpty ? _keyFeaturesController.text : 'Not specified'.tr(context),
        ));
        break;

      case ProjectType.app:
        items.add(_SummaryItem(
          'Platforms'.tr(context),
          _selectedPlatforms.isNotEmpty ? _selectedPlatforms.join(', ') : 'Not selected'.tr(context),
        ));
        items.add(_SummaryItem(
          'Key Features'.tr(context),
          _keyFeaturesController.text.isNotEmpty ? _keyFeaturesController.text : 'Not specified'.tr(context),
        ));
        break;

      case ProjectType.consultancy:
        items.add(_SummaryItem(
          'Duration'.tr(context),
          _durationController.text.isNotEmpty ? _durationController.text : 'Not specified'.tr(context),
        ));
        items.add(_SummaryItem(
          'Question'.tr(context),
          _questionSummaryController.text.isNotEmpty
              ? (_questionSummaryController.text.length > 60
                  ? '${_questionSummaryController.text.substring(0, 60)}...'
                  : _questionSummaryController.text)
              : 'Not specified'.tr(context),
        ));
        break;

      case ProjectType.turnitinCheck:
        items.add(_SummaryItem(
          'Files'.tr(context),
          '${_attachments.length} ${'file(s)'.tr(context)}',
        ));
        items.add(_SummaryItem(
          'Report Type'.tr(context),
          _turnitinReportType ?? 'Not selected'.tr(context),
        ));
        break;

      default:
        items.add(_SummaryItem(
          'Attachments'.tr(context),
          '${_attachments.length} ${'file(s)'.tr(context)}',
        ));
        break;
    }

    return items;
  }

  // ---------------------------------------------------------------------------
  // Bottom navigation buttons
  // ---------------------------------------------------------------------------

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
                  'Back'.tr(context),
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
                    : _currentStep < 3
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
                        _currentStep < 3
                            ? 'Continue'.tr(context)
                            : 'Submit Project'.tr(context),
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

  // ---------------------------------------------------------------------------
  // Shared helper builders
  // ---------------------------------------------------------------------------

  /// Builds a step header row with gradient icon, title, and subtitle.
  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, Colors.purple.shade400],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headingSmall),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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
    switch (_projectType) {
      case ProjectType.turnitinCheck:
        if (_turnitinReportType == 'AI Detection') return 199;
        if (_turnitinReportType == 'Plagiarism Check') return 249;
        if (_turnitinReportType == 'Complete Report') return 399;
        return null;
      case ProjectType.consultancy:
        return 499;
      case ProjectType.website:
        final pages = int.tryParse(_pageCountController.text);
        if (pages != null) return pages * 500.0;
        return null;
      case ProjectType.app:
        return 2999;
      default:
        if (_wordCount == null) return null;
        return _wordCount! * 0.5;
    }
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

// =============================================================================
// PRIVATE HELPER WIDGETS
// =============================================================================

/// 4-step progress indicator displayed above the form card.
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
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
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

/// Summary card used in the review step.
class _SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_SummaryItem> items;
  final Color? accentColor;

  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.items,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

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
              Icon(icon, size: 18, color: color),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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

class _SummaryItem {
  final String label;
  final String value;

  const _SummaryItem(this.label, this.value);
}

/// Platform selection widget for App project type.
class _PlatformSelector extends StatelessWidget {
  final Set<String> selectedPlatforms;
  final ValueChanged<Set<String>> onChanged;

  const _PlatformSelector({
    required this.selectedPlatforms,
    required this.onChanged,
  });

  static const _platforms = [
    {'label': 'iOS', 'icon': Icons.apple},
    {'label': 'Android', 'icon': Icons.android},
    {'label': 'Web', 'icon': Icons.language},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _platforms.map((platform) {
        final label = platform['label'] as String;
        final icon = platform['icon'] as IconData;
        final isSelected = selectedPlatforms.contains(label);

        return Expanded(
          child: GestureDetector(
            onTap: () {
              final updated = Set<String>.from(selectedPlatforms);
              if (isSelected) {
                updated.remove(label);
              } else {
                updated.add(label);
              }
              onChanged(updated);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: label != 'Web' ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          Colors.white,
                        ],
                      )
                    : null,
                color: isSelected ? null : AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label.tr(context),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Consultation duration selector with preset options.
class _DurationSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _DurationSelector({
    required this.value,
    required this.onChanged,
  });

  static const _options = [
    '30 minutes',
    '1 hour',
    '2 hours',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((option) {
        final isSelected = value == option;
        return GestureDetector(
          onTap: () => onChanged(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              option.tr(context),
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Report type selector for Turnitin Check project type.
class _ReportTypeSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const _ReportTypeSelector({
    required this.selected,
    required this.onSelected,
  });

  static const _reportTypes = [
    {
      'label': 'AI Detection',
      'description': 'Check for AI-generated content',
      'icon': Icons.smart_toy_outlined,
      'price': 199,
    },
    {
      'label': 'Plagiarism Check',
      'description': 'Detect copied or paraphrased text',
      'icon': Icons.content_copy_outlined,
      'price': 249,
    },
    {
      'label': 'Complete Report',
      'description': 'AI detection + plagiarism check combined',
      'icon': Icons.verified_user_outlined,
      'price': 399,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _reportTypes.map((type) {
        final label = type['label'] as String;
        final description = type['description'] as String;
        final icon = type['icon'] as IconData;
        final price = type['price'] as int;
        final isSelected = selected == label;

        return GestureDetector(
          onTap: () => onSelected(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.08),
                        Colors.white,
                      ],
                    )
                  : null,
              color: isSelected ? null : AppColors.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),

                // Label + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.tr(context),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        description.tr(context),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                Text(
                  '\u20B9$price',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
