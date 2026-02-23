import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../widgets/step_progress_bar.dart';
import '../widgets/chip_selector.dart';
import '../widgets/experience_slider.dart';

/// Profile setup screen with multi-step form.
///
/// Guides new users through a 3-step onboarding wizard to collect
/// their professional profile information needed for task matching.
///
/// ## Navigation
/// - Entry: From [RegisterScreen] or [SplashScreen] (authenticated, no profile)
/// - Success: Navigates to [ActivationGateScreen]
/// - Back: Returns to previous step (or no action on first step)
///
/// ## Features
/// - 3-step wizard with animated page transitions
/// - Visual progress bar with step labels and percentage
/// - Form validation per step
/// - Profile summary review before submission
/// - Loading state during profile creation
/// - Error feedback via SnackBar
///
/// ## Steps
/// 1. **Education**: Qualification level and university/institution
/// 2. **Skills**: Subject areas (max 5) and skills (max 8) selection
/// 3. **Experience**: Experience level slider with profile summary
///
/// ## Data Collected
/// - Qualification (dropdown selection)
/// - University/Institution name (optional text)
/// - Subject areas of interest (multi-select chips)
/// - Skills (multi-select chips with icons)
/// - Experience level (Beginner/Intermediate/Pro)
///
/// See also:
/// - [AuthProvider.setupDoerProfile] for profile creation
/// - [ActivationGateScreen] for post-setup activation flow
/// - [StepProgressBar] for progress visualization
/// - [ChipSelector] for multi-select options
/// - [ExperienceSlider] for experience level selection
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

/// State class for [ProfileSetupScreen].
///
/// Manages multi-step form state, page navigation, and profile submission.
class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  /// Controller for the step page view.
  final PageController _pageController = PageController();

  /// Current step index (1-based: 1, 2, or 3).
  int _currentStep = 1;

  /// Total number of steps in the wizard.
  final int _totalSteps = 3;

  /// Whether profile submission is in progress.
  bool _isLoading = false;

  // ===== Step 1: Qualification =====

  /// Selected qualification from dropdown.
  String? _selectedQualification;

  /// Controller for university/institution text input.
  final _universityController = TextEditingController();

  // ===== Step 2: Skills =====

  /// Selected subject area IDs (max 5).
  final List<String> _selectedSubjects = [];

  /// Selected skill IDs (max 8).
  final List<String> _selectedSkills = [];

  // ===== Step 3: Experience =====

  /// Selected experience level.
  ExperienceLevel _experienceLevel = ExperienceLevel.beginner;

  // Available options
  final List<String> _qualifications = [
    'High School',
    'Diploma',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Other',
  ];

  final List<ChipOption<String>> _subjectOptions = [
    const ChipOption(value: 'engineering', label: 'Engineering'),
    const ChipOption(value: 'business', label: 'Business'),
    const ChipOption(value: 'science', label: 'Science'),
    const ChipOption(value: 'arts', label: 'Arts'),
    const ChipOption(value: 'law', label: 'Law'),
    const ChipOption(value: 'medicine', label: 'Medicine'),
    const ChipOption(value: 'technology', label: 'Technology'),
    const ChipOption(value: 'design', label: 'Design'),
    const ChipOption(value: 'marketing', label: 'Marketing'),
    const ChipOption(value: 'finance', label: 'Finance'),
  ];

  final List<ChipOption<String>> _skillOptions = [
    const ChipOption(value: 'writing', label: 'Academic Writing', icon: Icons.edit),
    const ChipOption(value: 'research', label: 'Research', icon: Icons.search),
    const ChipOption(value: 'data_analysis', label: 'Data Analysis', icon: Icons.analytics),
    const ChipOption(value: 'programming', label: 'Programming', icon: Icons.code),
    const ChipOption(value: 'presentation', label: 'Presentations', icon: Icons.slideshow),
    const ChipOption(value: 'excel', label: 'Excel/Spreadsheets', icon: Icons.table_chart),
    const ChipOption(value: 'statistics', label: 'Statistics', icon: Icons.bar_chart),
    const ChipOption(value: 'editing', label: 'Proofreading', icon: Icons.spellcheck),
    const ChipOption(value: 'tutoring', label: 'Tutoring', icon: Icons.school),
    const ChipOption(value: 'translation', label: 'Translation', icon: Icons.translate),
  ];

  /// Disposes controllers to prevent memory leaks.
  @override
  void dispose() {
    _pageController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  /// Advances to the next step or submits the profile.
  ///
  /// If not on the last step, animates to the next page.
  /// If on the last step, calls [_submitProfile].
  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitProfile();
    }
  }

  /// Returns to the previous step.
  ///
  /// Only available when [_currentStep] is greater than 1.
  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Determines if the user can proceed to the next step.
  ///
  /// Validation rules per step:
  /// - Step 1: Qualification must be selected
  /// - Step 2: At least one subject AND one skill must be selected
  /// - Step 3: Always allowed (experience has default value)
  bool _canProceed() {
    switch (_currentStep) {
      case 1:
        return _selectedQualification != null;
      case 2:
        return _selectedSubjects.isNotEmpty && _selectedSkills.isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  /// Submits the completed profile to the backend.
  ///
  /// Collects all form data and calls [AuthProvider.setupDoerProfile].
  /// On success, navigates to [ActivationGateScreen].
  /// On failure, displays error via SnackBar.
  Future<void> _submitProfile() async {
    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).setupDoerProfile(
        ProfileSetupData(
          qualification: _selectedQualification!,
          universityName: _universityController.text.trim().isNotEmpty
              ? _universityController.text.trim()
              : null,
          experienceLevel: _getExperienceLevelString(_experienceLevel),
          yearsOfExperience: _getYearsFromLevel(_experienceLevel),
          skillIds: _selectedSkills.toList(),
          subjectIds: _selectedSubjects.toList(),
          primarySubjectId: _selectedSubjects.isNotEmpty ? _selectedSubjects.first : null,
        ),
      );

      if (!mounted) return;

      if (success) {
        context.go(RouteNames.activationGate);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Converts [ExperienceLevel] enum to API string value.
  String _getExperienceLevelString(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 'beginner';
      case ExperienceLevel.intermediate:
        return 'intermediate';
      case ExperienceLevel.pro:
        return 'expert';
    }
  }

  /// Estimates years of experience from [ExperienceLevel].
  ///
  /// Returns approximate years for backend storage:
  /// - Beginner: 1 year
  /// - Intermediate: 3 years
  /// - Pro: 5 years
  int _getYearsFromLevel(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 1;
      case ExperienceLevel.intermediate:
        return 3;
      case ExperienceLevel.pro:
        return 5;
    }
  }

  /// Builds the profile setup wizard UI.
  ///
  /// Layout structure:
  /// - AppBar with back button (visible after step 1)
  /// - Progress bar with step labels
  /// - Page view with 3 step screens (non-swipeable)
  /// - Continue/Complete button with validation
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
        title: const Text('Complete Your Profile'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: AppSpacing.paddingHorizontalMd,
              child: StepProgressBar(
                totalSteps: _totalSteps,
                currentStep: _currentStep,
                labels: const ['Education', 'Skills', 'Experience'],
                showPercentage: true,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildQualificationStep(),
                  _buildSkillsStep(),
                  _buildExperienceStep(),
                ],
              ),
            ),

            // Bottom button
            Padding(
              padding: AppSpacing.paddingLg,
              child: AppButton(
                text: _currentStep == _totalSteps ? 'Complete Setup' : 'Continue',
                onPressed: _canProceed() ? _nextStep : null,
                isLoading: _isLoading,
                isFullWidth: true,
                size: AppButtonSize.large,
                suffixIcon: _currentStep == _totalSteps ? Icons.check : Icons.arrow_forward,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds Step 1: Education/Qualification selection.
  ///
  /// Contains:
  /// - Qualification dropdown with 6 options
  /// - University/Institution text field (optional)
  /// - Info box about editing later
  Widget _buildQualificationStep() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your highest qualification?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'This helps us match you with relevant opportunities',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Qualification dropdown
          DropdownButtonFormField<String>(
            value: _selectedQualification,
            decoration: const InputDecoration(
              labelText: 'Qualification',
              hintText: 'Select your qualification',
              prefixIcon: Icon(Icons.school_outlined),
            ),
            items: _qualifications.map((q) {
              return DropdownMenuItem(value: q, child: Text(q));
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedQualification = value);
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // University field
          AppTextField(
            label: 'University/Institution',
            hint: 'Enter your university name',
            controller: _universityController,
            prefixIcon: Icons.apartment,
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Info box
          Container(
            padding: AppSpacing.paddingMd,
            decoration: const BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.info),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'You can update this information later from your profile settings.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
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

  /// Builds Step 2: Skills and subjects selection.
  ///
  /// Contains:
  /// - Subject areas chip selector (max 5 selections)
  /// - Skills chip selector with icons (max 8 selections)
  Widget _buildSkillsStep() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are you good at?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Select your areas of interest and skills',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Subject areas
          ChipSelector<String>(
            label: 'Areas of Interest',
            helperText: 'Select up to 5 subject areas',
            options: _subjectOptions,
            selectedValues: _selectedSubjects,
            maxSelections: 5,
            onChanged: (values) {
              setState(() => _selectedSubjects
                ..clear()
                ..addAll(values));
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // Skills
          ChipSelector<String>(
            label: 'Your Skills',
            helperText: 'Select up to 8 skills',
            options: _skillOptions,
            selectedValues: _selectedSkills,
            maxSelections: 8,
            onChanged: (values) {
              setState(() => _selectedSkills
                ..clear()
                ..addAll(values));
            },
          ),
        ],
      ),
    );
  }

  /// Builds Step 3: Experience level selection.
  ///
  /// Contains:
  /// - Experience level slider (Beginner/Intermediate/Pro)
  /// - Profile summary card showing all collected data
  Widget _buildExperienceStep() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your experience level?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'This helps us assign appropriate tasks to you',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Experience selector
          ExperienceSlider(
            value: _experienceLevel,
            onChanged: (level) {
              setState(() => _experienceLevel = level);
            },
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Summary card
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildSummaryItem('Qualification', _selectedQualification ?? '-'),
                _buildSummaryItem('University', _universityController.text.isEmpty ? '-' : _universityController.text),
                _buildSummaryItem('Subjects', _selectedSubjects.isEmpty ? '-' : '${_selectedSubjects.length} selected'),
                _buildSummaryItem('Skills', _selectedSkills.isEmpty ? '-' : '${_selectedSkills.length} selected'),
                _buildSummaryItem('Experience', _getLevelLabel(_experienceLevel)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single row in the profile summary card.
  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns display label for [ExperienceLevel].
  String _getLevelLabel(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.beginner:
        return 'Beginner';
      case ExperienceLevel.intermediate:
        return 'Intermediate';
      case ExperienceLevel.pro:
        return 'Pro';
    }
  }
}
