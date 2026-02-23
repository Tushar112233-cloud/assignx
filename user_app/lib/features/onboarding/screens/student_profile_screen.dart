import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dropdown.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../widgets/step_progress_bar.dart';

/// Student profile completion screen.
///
/// Redesigned with gradient background, glass morphism form,
/// and smooth animations to match Dashboard aesthetic.
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

  @override
  void initState() {
    super.initState();
    // Auto-fill name from Google account
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      final user = authState.valueOrNull?.user;
      if (user != null) {
        // Try to get name from user metadata (from Google)
        final fullName = user.userMetadata?['full_name'] as String? ??
            user.userMetadata?['name'] as String? ??
            '';
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
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      // Validate step 1
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your full name');
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
        content: Text(message),
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

      // Update profile with basic info - using UserType.student
      await authNotifier.updateProfile(
        fullName: _nameController.text.trim(),
        userType: UserType.student,
        onboardingStep: OnboardingStep.complete,
        onboardingCompleted: true,
      );

      // Save student-specific data to students table
      await authNotifier.saveStudentData(
        universityId: _selectedUniversityId,
        courseId: _selectedCourseId,
        semester: _selectedSemester,
        yearOfStudy: _selectedYearOfStudy,
        studentIdNumber: _studentIdController.text.trim().isNotEmpty
            ? _studentIdController.text.trim()
            : null,
      );

      if (mounted) {
        context.go(RouteNames.signupSuccess);
      }
    } catch (e) {
      _showError('Failed to save profile. Please try again.');
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
      body: MeshGradientBackground(
        position: MeshPosition.bottomRight,
        colors: [
          AppColors.meshPink,
          AppColors.meshPeach,
          AppColors.meshOrange,
        ],
        opacity: 0.4,
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: _isLoading,
            message: 'Saving profile...',
            child: Column(
              children: [
                // App bar with glass effect
                GlassContainer(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _previousStep,
                      ),
                      Expanded(
                        child: Text(
                          'Complete Profile',
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
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: StepProgressBar(
                      currentStep: _currentStep,
                      totalSteps: 2,
                      labels: const ['Basic Info', 'Education'],
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

                // Continue button with glass effect
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(4),
                    child: AppButton(
                      label: _currentStep == 2 ? 'Complete' : 'Continue',
                      onPressed: _nextStep,
                      icon: _currentStep == 2 ? Icons.check : Icons.arrow_forward,
                    ),
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 16),
              ],
            ),
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
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
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
                            'Basic Information',
                            style: AppTextStyles.headingMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Let's start with your basic details",
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
                  label: 'Full Name',
                  hint: 'Enter your full name',
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
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
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
                            'Education Details',
                            style: AppTextStyles.headingMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tell us about your academic background',
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
                    label: 'University',
                    hint: 'Select your university',
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
                    'Failed to load universities',
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
                          label: 'Course',
                          hint: 'Select your course',
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
                          'Failed to load courses',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),

                if (_selectedUniversityId != null) const SizedBox(height: 16),

                // Year of Study
                AppDropdown<int>(
                  label: 'Year of Study',
                  hint: 'Select your current year',
                  value: _selectedYearOfStudy,
                  items: List.generate(5, (i) => i + 1),
                  itemLabel: (item) => 'Year $item',
                  onChanged: (value) {
                    setState(() => _selectedYearOfStudy = value);
                  },
                ),

                const SizedBox(height: 16),

                // Semester
                AppDropdown<int>(
                  label: 'Semester (Optional)',
                  hint: 'Select your current semester',
                  value: _selectedSemester,
                  items: List.generate(8, (i) => i + 1),
                  itemLabel: (item) => 'Semester $item',
                  onChanged: (value) {
                    setState(() => _selectedSemester = value);
                  },
                ),

                const SizedBox(height: 16),

                // Student ID (optional)
                AppTextField(
                  controller: _studentIdController,
                  label: 'Student ID (Optional)',
                  hint: 'Enter your student ID number',
                  prefixIcon: Icons.badge_outlined,
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
