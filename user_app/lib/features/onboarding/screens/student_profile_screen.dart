import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dropdown.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/phone_input.dart';
import '../widgets/step_progress_bar.dart';

/// Student profile completion screen.
///
/// Multi-step form with smooth animations for collecting student details.
class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  final _pageController = PageController();

  int _currentStep = 1;
  bool _isLoading = false;

  // Form controllers
  final _nameController = TextEditingController();
  String? _selectedUniversityId;
  String? _selectedCourseId;
  int? _selectedSemester;
  int? _selectedYearOfStudy;
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-fill name from Google account
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      final user = authState.valueOrNull?.user;
      if (user != null) {
        // Try to get name from profile
        final profile = ref.read(currentProfileProvider);
        final fullName = profile?.fullName ?? '';
        if (fullName.isNotEmpty) {
          _nameController.text = fullName;
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      // Validate step 1
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your full name'); // Translated at display
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.tr(context)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authStateProvider.notifier);

      // Send everything in one PUT /users/me call (matches web behavior)
      final phone = _phoneController.text.trim();
      final body = <String, dynamic>{
        'fullName': _nameController.text.trim(),
        'userType': 'student',
        'onboardingStep': 'complete',
        'onboardingCompleted': true,
      };
      if (phone.isNotEmpty) body['phone'] = phone;
      if (_selectedUniversityId != null) body['universityId'] = _selectedUniversityId;
      if (_selectedCourseId != null) body['courseId'] = _selectedCourseId;
      if (_selectedSemester != null) body['semester'] = _selectedSemester;
      if (_selectedYearOfStudy != null) body['yearOfStudy'] = _selectedYearOfStudy;
      if (_studentIdController.text.trim().isNotEmpty) {
        body['studentIdNumber'] = _studentIdController.text.trim();
      }

      await ApiClient.put('/users/me', body);

      // Refresh the auth state so router knows onboarding is done
      await authNotifier.refreshProfile();

      if (mounted) {
        context.go(RouteNames.signupSuccess);
      }
    } catch (e) {
      _showError('Failed to save profile. Please try again.'); // Translated at display
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: _isLoading,
          message: 'Saving profile...'.tr(context),
          child: Column(
            children: [
              // App bar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x0F000000),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _previousStep,
                    ),
                    Expanded(
                      child: Text(
                        'Complete Profile'.tr(context),
                        style: AppTextStyles.headingSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x0F000000),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: StepProgressBar(
                    currentStep: _currentStep,
                    totalSteps: 2,
                    labels: ['Basic Info'.tr(context), 'Education'.tr(context)],
                  ),
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // Form pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                  ],
                ),
              ),

              // Continue button
              Padding(
                padding: AppSpacing.screenPadding,
                child: AppButton(
                  label: _currentStep == 2 ? 'Complete'.tr(context) : 'Continue'.tr(context),
                  onPressed: _nextStep,
                  icon: _currentStep == 2 ? Icons.check : Icons.arrow_forward,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x0F000000),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Basic Information'.tr(context),
                            style: AppTextStyles.headingMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Let's start with your basic details".tr(context),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Full Name
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name'.tr(context),
                  hint: 'Enter your full name'.tr(context),
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.name,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(
                begin: 0.1,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final universities = ref.watch(universitiesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x0F000000),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Education Details'.tr(context),
                            style: AppTextStyles.headingMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tell us about your academic background'.tr(context),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // University
                universities.when(
                  data: (unis) => AppDropdown<Map<String, dynamic>>(
                    label: 'University'.tr(context),
                    hint: 'Select your university'.tr(context),
                    value: unis.where((u) => u['id'] == _selectedUniversityId).firstOrNull,
                    items: unis,
                    itemLabel: (item) => item['name'] as String,
                    searchable: true,
                    onChanged: (value) {
                      setState(() {
                        _selectedUniversityId = value?['id'] as String?;
                        _selectedCourseId = null; // Reset course
                      });
                    },
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  error: (_, _) => Text(
                    'Failed to load universities'.tr(context),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Course (only show if university selected)
                if (_selectedUniversityId != null)
                  ref.watch(coursesProvider(_selectedUniversityId!)).when(
                        data: (courses) => AppDropdown<Map<String, dynamic>>(
                          label: 'Course'.tr(context),
                          hint: 'Select your course'.tr(context),
                          value: courses
                              .where((c) => c['id'] == _selectedCourseId)
                              .firstOrNull,
                          items: courses,
                          itemLabel: (item) => item['name'] as String,
                          searchable: true,
                          onChanged: (value) {
                            setState(() {
                              _selectedCourseId = value?['id'] as String?;
                            });
                          },
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        error: (_, _) => Text(
                          'Failed to load courses'.tr(context),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),

                if (_selectedUniversityId != null) const SizedBox(height: 16),

                // Year of Study
                AppDropdown<int>(
                  label: 'Year of Study'.tr(context),
                  hint: 'Select your current year'.tr(context),
                  value: _selectedYearOfStudy,
                  items: List.generate(5, (i) => i + 1),
                  itemLabel: (item) => '${'Year'.tr(context)} $item',
                  onChanged: (value) {
                    setState(() => _selectedYearOfStudy = value);
                  },
                ),

                const SizedBox(height: 16),

                // Semester
                AppDropdown<int>(
                  label: 'Semester (Optional)'.tr(context),
                  hint: 'Select your current semester'.tr(context),
                  value: _selectedSemester,
                  items: List.generate(8, (i) => i + 1),
                  itemLabel: (item) => '${'Semester'.tr(context)} $item',
                  onChanged: (value) {
                    setState(() => _selectedSemester = value);
                  },
                ),

                const SizedBox(height: 16),

                // Student ID (optional)
                AppTextField(
                  controller: _studentIdController,
                  label: 'Student ID (Optional)'.tr(context),
                  hint: 'Enter your student ID number'.tr(context),
                  prefixIcon: Icons.badge_outlined,
                ),

                const SizedBox(height: 16),

                // Phone Number (optional)
                PhoneInput(
                  controller: _phoneController,
                  label: 'Phone Number (Optional)'.tr(context),
                  hint: 'Enter your phone number'.tr(context),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(
                begin: 0.1,
                end: 0,
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
