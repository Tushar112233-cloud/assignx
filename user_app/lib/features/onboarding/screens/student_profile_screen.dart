import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dropdown.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/phone_input.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';

/// Student profile completion screen — 3-step form matching web flow.
///
/// Step 1: Personal Information (Full Name)
/// Step 2: Academic Details (University, Course, Semester)
/// Step 3: Contact & Confirm (Phone, Terms)
class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  final _pageController = PageController();

  int _currentStep = 0; // 0-indexed to match page controller
  bool _isLoading = false;

  // Step 1: Personal
  final _nameController = TextEditingController();

  // Step 2: Academic
  String? _selectedUniversityId;
  String? _selectedCourseId;
  int? _selectedSemester;

  // Step 3: Contact
  final _phoneController = TextEditingController();
  bool _acceptedTerms = false;

  static const _totalSteps = 3;

  static const _stepConfig = [
    {
      'icon': Icons.person_outline_rounded,
      'title': 'Personal Information',
      'subtitle': 'Enter your basic details',
    },
    {
      'icon': Icons.school_outlined,
      'title': 'Academic Details',
      'subtitle': 'Tell us about your studies',
    },
    {
      'icon': Icons.phone_outlined,
      'title': 'Contact & Confirm',
      'subtitle': 'Final step to complete your profile',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(currentProfileProvider);
      final fullName = profile?.fullName ?? '';
      if (fullName.isNotEmpty) {
        _nameController.text = fullName;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.tr(context)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  void _nextStep() {
    // Validate current step
    if (_currentStep == 0) {
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your full name');
        return;
      }
      if (_nameController.text.trim().length < 2) {
        _showError('Name must be at least 2 characters');
        return;
      }
    }

    if (_currentStep == 2) {
      _submitForm();
      return;
    }

    setState(() => _currentStep++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.trim();
      final body = <String, dynamic>{
        'fullName': _nameController.text.trim(),
        'userType': 'student',
        'onboardingStep': 5,
        'onboardingCompleted': true,
      };
      if (phone.isNotEmpty) body['phone'] = phone;
      if (_selectedUniversityId != null) {
        body['universityId'] = _selectedUniversityId;
      }
      if (_selectedCourseId != null) body['courseId'] = _selectedCourseId;
      if (_selectedSemester != null) body['semester'] = _selectedSemester;

      await ApiClient.put('/users/me', body);
      await ref.read(authStateProvider.notifier).refreshProfile();

      if (mounted) context.go(RouteNames.signupSuccess);
    } catch (e) {
      _showError('Failed to save profile. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _totalSteps;

    return SubtleGradientScaffold.standard(
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: _isLoading,
          message: 'Saving profile...'.tr(context),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                // Header bar
                _buildTopBar(),

                const SizedBox(height: 12),

                // Progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildProgressBar(progress),
                ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

                const SizedBox(height: 20),

                // Step header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStepHeader(),
                ),

                const SizedBox(height: 16),

                // Form pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1Personal(),
                      _buildStep2Academic(),
                      _buildStep3Contact(),
                    ],
                  ),
                ),

                // Bottom button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: AppButton(
                    label: _currentStep == 2
                        ? 'Complete Registration'.tr(context)
                        : 'Continue'.tr(context),
                    onPressed: _isLoading ? null : _nextStep,
                    icon: _currentStep == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            onPressed: _previousStep,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Complete Profile'.tr(context),
            style: AppTextStyles.headingSmall.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Balance spacer
          const SizedBox(width: 40),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      children: [
        // Segmented progress bar
        Row(
          children: List.generate(_totalSteps, (i) {
            final isCompleted = i < _currentStep;
            final isCurrent = i == _currentStep;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isCompleted
                      ? AppColors.primary
                      : isCurrent
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.border,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${'Step'.tr(context)} ${_currentStep + 1} ${'of'.tr(context)} $_totalSteps',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepHeader() {
    final config = _stepConfig[_currentStep];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Row(
        key: ValueKey(_currentStep),
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              config['icon'] as IconData,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (config['title'] as String).tr(context),
                  style: AppTextStyles.headingSmall.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (config['subtitle'] as String).tr(context),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
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
  // Step 1: Personal Information
  // ---------------------------------------------------------------------------

  Widget _buildStep1Personal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Full Name'.tr(context),
              hint: 'Enter your full name'.tr(context),
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              validator: Validators.name,
              autofocus: true,
            ),
            const SizedBox(height: 6),
            Text(
              'Required'.tr(context),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2: Academic Details
  // ---------------------------------------------------------------------------

  Widget _buildStep2Academic() {
    final universities = ref.watch(universitiesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _FormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University
            universities.when(
              data: (unis) => AppDropdown<Map<String, dynamic>>(
                label: 'University'.tr(context),
                hint: 'Select your university'.tr(context),
                value: unis
                    .where((u) => u['id'] == _selectedUniversityId)
                    .firstOrNull,
                items: unis,
                itemLabel: (item) => item['name'] as String,
                searchable: true,
                onChanged: (value) {
                  setState(() {
                    _selectedUniversityId = value?['id'] as String?;
                    _selectedCourseId = null;
                  });
                },
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (_, __) => Text(
                'Failed to load universities'.tr(context),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.error),
              ),
            ),

            const SizedBox(height: 16),

            // Course (only when university selected)
            if (_selectedUniversityId != null) ...[
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
                        setState(
                            () => _selectedCourseId = value?['id'] as String?);
                      },
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    error: (_, __) => Text(
                      'Failed to load courses'.tr(context),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.error),
                    ),
                  ),
              const SizedBox(height: 16),
            ],

            // Semester
            AppDropdown<int>(
              label: 'Semester'.tr(context),
              hint: 'Select your current semester'.tr(context),
              value: _selectedSemester,
              items: List.generate(12, (i) => i + 1),
              itemLabel: (item) => '${'Semester'.tr(context)} $item',
              onChanged: (value) {
                setState(() => _selectedSemester = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3: Contact & Confirm
  // ---------------------------------------------------------------------------

  Widget _buildStep3Contact() {
    final user = ref.watch(currentUserProvider);
    final email = user?.email ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Account email display
          if (email.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Email'.tr(context),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 14),

          _FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhoneInput(
                  controller: _phoneController,
                  label: 'Phone Number (Optional)'.tr(context),
                  hint: 'Enter your phone number'.tr(context),
                ),
                const SizedBox(height: 6),
                Text(
                  'We may use this to contact you about your projects.'.tr(context),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 20),

                // Terms checkbox
                GestureDetector(
                  onTap: () =>
                      setState(() => _acceptedTerms = !_acceptedTerms),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _acceptedTerms,
                          onChanged: (v) =>
                              setState(() => _acceptedTerms = v ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'I agree to the Terms of Service and Privacy Policy'
                              .tr(context),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Info note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Text(
                'You can update these details later in Settings.'.tr(context),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Consistent white card wrapper for form sections.
class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    ).animate().fadeIn(duration: 400.ms).slideY(
          begin: 0.05,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
