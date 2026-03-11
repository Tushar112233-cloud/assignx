import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../../core/translation/translation_extensions.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/// Qualification options matching the web registration form.
const List<_LabelValue> _qualificationOptions = [
  _LabelValue('High School', 'high_school'),
  _LabelValue('Undergraduate', 'undergraduate'),
  _LabelValue('Post Graduate', 'postgraduate'),
  _LabelValue('PhD', 'phd'),
];

/// Experience level options with descriptions.
const List<_ExperienceOption> _experienceLevels = [
  _ExperienceOption('Beginner', 'beginner', '0-1 years'),
  _ExperienceOption('Intermediate', 'intermediate', '1-3 years'),
  _ExperienceOption('Professional', 'pro', '3+ years'),
];

/// Skill areas available for selection.
const List<_LabelValue> _skillAreas = [
  _LabelValue('Engineering', 'engineering'),
  _LabelValue('Computer Science', 'computer_science'),
  _LabelValue('Mathematics', 'mathematics'),
  _LabelValue('Physics', 'physics'),
  _LabelValue('Chemistry', 'chemistry'),
  _LabelValue('Biology', 'biology'),
  _LabelValue('Business', 'business'),
  _LabelValue('Finance', 'finance'),
  _LabelValue('Economics', 'economics'),
  _LabelValue('Literature', 'literature'),
  _LabelValue('Arts & Design', 'arts'),
  _LabelValue('Education', 'education'),
  _LabelValue('Data Entry', 'data_entry'),
  _LabelValue('Research', 'research'),
  _LabelValue('Writing', 'writing'),
  _LabelValue('Translation', 'translation'),
];

/// Indian banks for the banking step dropdown.
const List<_LabelValue> _indianBanks = [
  _LabelValue('State Bank of India', 'sbi'),
  _LabelValue('HDFC Bank', 'hdfc'),
  _LabelValue('ICICI Bank', 'icici'),
  _LabelValue('Axis Bank', 'axis'),
  _LabelValue('Kotak Mahindra Bank', 'kotak'),
  _LabelValue('Punjab National Bank', 'pnb'),
  _LabelValue('Bank of Baroda', 'bob'),
  _LabelValue('Canara Bank', 'canara'),
  _LabelValue('Union Bank of India', 'union'),
  _LabelValue('IDBI Bank', 'idbi'),
  _LabelValue('IndusInd Bank', 'indusind'),
  _LabelValue('Yes Bank', 'yes'),
  _LabelValue('Other', 'other'),
];

/// Step metadata for the stepper indicator.
const List<_StepInfo> _steps = [
  _StepInfo('Email', Icons.email_outlined),
  _StepInfo('Profile', Icons.work_outline),
  _StepInfo('Banking', Icons.account_balance_outlined),
  _StepInfo('Review', Icons.check_circle_outline),
  _StepInfo('Verify', Icons.vpn_key_outlined),
];

// ---------------------------------------------------------------------------
// Helper classes
// ---------------------------------------------------------------------------

class _LabelValue {
  final String label;
  final String value;
  const _LabelValue(this.label, this.value);
}

class _ExperienceOption {
  final String label;
  final String value;
  final String description;
  const _ExperienceOption(this.label, this.value, this.description);
}

class _StepInfo {
  final String label;
  final IconData icon;
  const _StepInfo(this.label, this.icon);
}

// ---------------------------------------------------------------------------
// RegisterScreen
// ---------------------------------------------------------------------------

/// Multi-step registration screen for doer signup.
///
/// Provides a 5-step form matching the doer-web registration design:
/// 1. Email & Name
/// 2. Profile (qualification, experience, skills, bio)
/// 3. Banking details
/// 4. Review summary
/// 5. OTP verification
///
/// ## Navigation
/// - Entry: From [OnboardingScreen] or [LoginScreen]
/// - Success: Navigates to activation gate or pending screen
/// - Login: Navigates to [LoginScreen] via "Sign In" link
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Current step (1-5).
  int _step = 1;

  // Loading state for async operations.
  bool _isLoading = false;

  // Error message displayed below the form.
  String? _error;

  // Step 1 fields.
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();

  // Step 2 fields.
  String? _qualification;
  String? _experienceLevel;
  final Set<String> _selectedSkills = {};
  final _bioController = TextEditingController();

  // Step 3 fields.
  String? _bankName;
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _upiIdController = TextEditingController();

  // Step 5 OTP fields.
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _upiIdController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Cooldown timer
  // ---------------------------------------------------------------------------

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) timer.cancel();
      });
    });
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  /// Validates the current step and returns true if valid.
  bool _validateStep() {
    setState(() => _error = null);

    if (_step == 1) {
      final emailError = Validators.email(_emailController.text.trim());
      if (emailError != null) {
        setState(() => _error = emailError);
        return false;
      }
      final nameError = Validators.name(_fullNameController.text.trim());
      if (nameError != null) {
        setState(() => _error = nameError);
        return false;
      }
    } else if (_step == 2) {
      if (_qualification == null || _qualification!.isEmpty) {
        setState(() => _error = 'Please select your qualification');
        return false;
      }
      if (_experienceLevel == null || _experienceLevel!.isEmpty) {
        setState(() => _error = 'Please select your experience level');
        return false;
      }
      if (_selectedSkills.isEmpty) {
        setState(() => _error = 'Please select at least one skill area');
        return false;
      }
    } else if (_step == 3) {
      if (_bankName == null || _bankName!.isEmpty) {
        setState(() => _error = 'Please select your bank');
        return false;
      }
      final accError =
          Validators.bankAccountNumber(_accountNumberController.text.trim());
      if (accError != null) {
        setState(() => _error = accError);
        return false;
      }
      final ifscError =
          Validators.ifscCode(_ifscCodeController.text.trim());
      if (ifscError != null) {
        setState(() => _error = ifscError);
        return false;
      }
      final upiError = Validators.upiId(_upiIdController.text.trim());
      if (upiError != null) {
        setState(() => _error = upiError);
        return false;
      }
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Navigation handlers
  // ---------------------------------------------------------------------------

  /// Handles the "Continue" button press for steps 1-3.
  Future<void> _handleNext() async {
    if (!_validateStep()) return;

    // Step 1: Check if email already exists as an access request.
    if (_step == 1) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        final repository = ref.read(authRepositoryProvider);
        final status = await (repository as ApiAuthRepository)
            .checkAccessStatus(_emailController.text.trim().toLowerCase());
        if (!mounted) return;

        if (status != null) {
          if (status == 'approved') {
            setState(() {
              _error = 'This email is already approved. Please sign in instead.';
              _isLoading = false;
            });
            return;
          } else if (status == 'rejected') {
            setState(() {
              _error =
                  'This email was not approved. Please contact support.';
              _isLoading = false;
            });
            return;
          } else if (status == 'pending') {
            setState(() => _isLoading = false);
            _showSnackBar('Application already pending', AppColors.warning);
            return;
          }
        }
      } catch (_) {
        // 404 = no existing request, continue to next step.
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    setState(() => _step = _step + 1);
  }

  /// Handles the "Back" button press.
  void _handleBack() {
    setState(() {
      _error = null;
      if (_step == 5) {
        for (final c in _otpControllers) {
          c.clear();
        }
      }
      _step = _step - 1;
    });
  }

  // ---------------------------------------------------------------------------
  // OTP handlers
  // ---------------------------------------------------------------------------

  /// Sends the OTP to the user's email for signup verification.
  Future<void> _handleSendOtp() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.sendOtp(
        _emailController.text.trim().toLowerCase(),
        purpose: 'signup',
      );

      if (!mounted) return;
      setState(() {
        _step = 5;
        _isLoading = false;
      });
      _startCooldown();

      // Focus the first OTP input.
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _otpFocusNodes[0].requestFocus();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e is Exception
              ? e.toString().replaceFirst('Exception: ', '')
              : 'Failed to send verification code.';
        });
      }
    }
  }

  /// Resends the OTP code.
  Future<void> _handleResendOtp() async {
    if (_resendCooldown > 0) return;
    try {
      setState(() => _error = null);
      final repository = ref.read(authRepositoryProvider);
      await repository.sendOtp(
        _emailController.text.trim().toLowerCase(),
        purpose: 'signup',
      );
      if (!mounted) return;
      for (final c in _otpControllers) {
        c.clear();
      }
      _startCooldown();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Failed to resend. Please try again.');
      }
    }
  }

  /// Submits the OTP along with all form data for doer signup.
  Future<void> _handleOtpSubmit() async {
    final otpCode =
        _otpControllers.map((c) => c.text).join();
    if (otpCode.length != 6) {
      setState(() => _error = 'Please enter the 6-digit code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider) as ApiAuthRepository;
      final email = _emailController.text.trim().toLowerCase();
      final fullName = _fullNameController.text.trim();

      final metadata = {
        'qualification': _qualification,
        'experienceLevel': _experienceLevel,
        'skills': _selectedSkills.toList(),
        'bio': _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
        'bankName': _bankName,
        'accountNumber': _accountNumberController.text.trim(),
        'ifscCode': _ifscCodeController.text.trim().toUpperCase(),
        'upiId': _upiIdController.text.trim().isNotEmpty
            ? _upiIdController.text.trim()
            : null,
      };

      final result = await repository.doerSignup(
        email: email,
        otp: otpCode,
        fullName: fullName,
        metadata: metadata,
      );

      if (!mounted) return;

      if (result.hasSession) {
        // Signup + auth successful - navigate based on state.
        final userId =
            (result.user?['_id'] ?? result.user?['id'] ?? '').toString();
        if (userId.isNotEmpty) {
          // Refresh auth state so router can redirect properly.
          await ref.read(authProvider.notifier).refreshProfile();
        }
        if (!mounted) return;

        final authState = ref.read(authProvider);
        final user = authState.user;
        if (user != null && user.isActivated) {
          context.go(RouteNames.dashboard);
        } else {
          context.go(RouteNames.activationGate);
        }
      } else {
        // Likely pending approval - show message.
        if (!mounted) return;
        _showSnackBar(
          'Application submitted! You will be notified once approved.',
          AppColors.success,
        );
        context.go(RouteNames.login);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString().contains('Exception:')
              ? e.toString().replaceFirst(RegExp(r'.*Exception:\s*'), '')
              : 'Something went wrong. Please try again.';
        });
        // Reset OTP fields on error.
        for (final c in _otpControllers) {
          c.clear();
        }
        _otpFocusNodes[0].requestFocus();
      }
    }
  }

  /// Handles individual OTP digit input and auto-advance.
  void _handleOtpDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste into a single field.
      _otpControllers[index].text = value[value.length - 1];
    }
    setState(() => _error = null);
    if (value.isNotEmpty && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }

    // Auto-submit when all 6 digits are entered.
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length == 6) {
      _handleOtpSubmit();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  /// Finds a label from a list by its value.
  String _labelFor(List<_LabelValue> list, String? value) {
    if (value == null) return '';
    return list.firstWhere((e) => e.value == value, orElse: () => _LabelValue(value, value)).label;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.topRight,
        child: SafeArea(
          child: Column(
            children: [
              // Back button (to onboarding on step 1, otherwise step back).
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: _step > 1
                      ? _handleBack
                      : () => context.go(RouteNames.onboarding),
                ),
              ),

              // Scrollable content.
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Now accepting applications" badge.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(50),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Now accepting applications'.tr(context),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Title.
                      Text(
                        'Become a Dolancer'.tr(context),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Complete the form below to apply for access.'.tr(context),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Step indicator.
                      _buildStepIndicator(),

                      const SizedBox(height: AppSpacing.lg),

                      // Glass form container.
                      GlassContainer(
                        blur: 20,
                        opacity: 0.85,
                        borderRadius: BorderRadius.circular(20),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        enableHoverEffect: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step content.
                            if (_step == 1) _buildStep1Email(),
                            if (_step == 2) _buildStep2Profile(),
                            if (_step == 3) _buildStep3Banking(),
                            if (_step == 4) _buildStep4Review(),
                            if (_step == 5) _buildStep5Verify(),

                            // Error display.
                            if (_error != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.errorLight,
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusMd),
                                  border: Border.all(
                                    color: AppColors.error.withAlpha(50),
                                  ),
                                ),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: AppSpacing.lg),

                            // Action buttons.
                            _buildActionButtons(),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // "Already have an account? Sign in" link.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? '.tr(context),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go(RouteNames.login),
                            child: Text(
                              'Sign in'.tr(context),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step Indicator
  // ---------------------------------------------------------------------------

  /// Builds the horizontal step indicator with numbered circles and connecting lines.
  Widget _buildStepIndicator() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final circleSize = isSmall ? 26.0 : 32.0;
    final stepFontSize = isSmall ? 10.0 : 12.0;
    final labelFontSize = isSmall ? 9.0 : 10.0;
    final checkSize = isSmall ? 14.0 : 16.0;

    return Row(
      children: List.generate(_steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connecting line between circles.
          final stepBefore = (index ~/ 2) + 1;
          final isCompleted = stepBefore < _step;
          return Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.only(bottom: circleSize * 0.56),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }

        // Step circle.
        final stepIndex = index ~/ 2;
        final stepNum = stepIndex + 1;
        final info = _steps[stepIndex];
        final isActive = stepNum == _step;
        final isCompleted = stepNum < _step;

        return Column(
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isActive || isCompleted)
                    ? AppColors.primary
                    : Colors.transparent,
                border: (!isActive && !isCompleted)
                    ? Border.all(color: AppColors.border, width: 2)
                    : null,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(40),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check, size: checkSize, color: Colors.white)
                    : Text(
                        '$stepNum',
                        style: TextStyle(
                          fontSize: stepFontSize,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? Colors.white
                              : AppColors.textTertiary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              info.label,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w500,
                color: (isActive || isCompleted)
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
            ),
          ],
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1 - Email & Name
  // ---------------------------------------------------------------------------

  Widget _buildStep1Email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Email address',
          hint: 'you@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          validator: Validators.email,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Full name',
          hint: 'Your full name',
          controller: _fullNameController,
          keyboardType: TextInputType.name,
          prefixIcon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
          validator: Validators.name,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2 - Profile
  // ---------------------------------------------------------------------------

  Widget _buildStep2Profile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Qualification dropdown.
        _buildDropdownField(
          label: 'Qualification',
          value: _qualification,
          hint: 'Select your qualification',
          items: _qualificationOptions,
          onChanged: (v) => setState(() => _qualification = v),
        ),

        const SizedBox(height: AppSpacing.md),

        // Experience level buttons.
        const Text(
          'Experience level',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: _experienceLevels.map((level) {
            final isSelected = _experienceLevel == level.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: level.value != _experienceLevels.last.value
                      ? AppSpacing.sm
                      : 0,
                ),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _experienceLevel = level.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                      horizontal: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(20)
                          : AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          level.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          level.description,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.md),

        // Skills multi-select chips.
        Row(
          children: [
            const Text(
              'Skill areas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '(${_selectedSkills.length} selected)',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _skillAreas.map((skill) {
            final isSelected = _selectedSkills.contains(skill.value);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSkills.remove(skill.value);
                  } else {
                    _selectedSkills.add(skill.value);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                  border: isSelected
                      ? null
                      : Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skill.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.close, size: 14, color: Colors.white),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.md),

        // Bio (optional).
        const Row(
          children: [
            Text(
              'Bio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              '(optional)',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AppTextField(
          hint: 'Tell us about yourself...',
          controller: _bioController,
          maxLines: 3,
          maxLength: 500,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${_bioController.text.length}/500',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3 - Banking
  // ---------------------------------------------------------------------------

  Widget _buildStep3Banking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(
          label: 'Bank name',
          value: _bankName,
          hint: 'Select your bank',
          items: _indianBanks,
          onChanged: (v) => setState(() => _bankName = v),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Account number',
          hint: 'Enter account number',
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          maxLength: 18,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'IFSC code',
          hint: 'e.g. SBIN0001234',
          controller: _ifscCodeController,
          keyboardType: TextInputType.text,
          maxLength: 11,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: AppSpacing.md),
        const Row(
          children: [
            Text(
              'UPI ID',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              '(optional)',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AppTextField(
          hint: 'yourname@upi',
          controller: _upiIdController,
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 4 - Review
  // ---------------------------------------------------------------------------

  Widget _buildStep4Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Details section.
        _buildReviewSection(
          icon: Icons.email_outlined,
          title: 'Personal Details',
          rows: [
            _ReviewRow('Email', _emailController.text.trim()),
            _ReviewRow('Name', _fullNameController.text.trim()),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Professional Profile section.
        _buildReviewSection(
          icon: Icons.work_outline,
          title: 'Professional Profile',
          rows: [
            _ReviewRow(
              'Qualification',
              _labelFor(_qualificationOptions, _qualification),
            ),
            _ReviewRow(
              'Experience',
              _experienceLevels
                  .firstWhere(
                    (e) => e.value == _experienceLevel,
                    orElse: () =>
                        const _ExperienceOption('', '', ''),
                  )
                  .label,
            ),
          ],
          extraWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Skills',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: _selectedSkills.map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      _labelFor(_skillAreas, s),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_bioController.text.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Bio',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _bioController.text.trim(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Bank Details section.
        _buildReviewSection(
          icon: Icons.account_balance_outlined,
          title: 'Bank Details',
          rows: [
            _ReviewRow('Bank', _labelFor(_indianBanks, _bankName)),
            _ReviewRow(
              'Account',
              _maskAccountNumber(_accountNumberController.text.trim()),
            ),
            _ReviewRow('IFSC', _ifscCodeController.text.trim().toUpperCase()),
            if (_upiIdController.text.trim().isNotEmpty)
              _ReviewRow('UPI', _upiIdController.text.trim()),
          ],
        ),
      ],
    );
  }

  /// Masks the account number showing only last 4 digits.
  String _maskAccountNumber(String number) {
    if (number.length <= 4) return number;
    return '${'*' * (number.length - 4)}${number.substring(number.length - 4)}';
  }

  /// Builds a review section card with icon, title, and key-value rows.
  Widget _buildReviewSection({
    required IconData icon,
    required String title,
    required List<_ReviewRow> rows,
    Widget? extraWidget,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        row.value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          if (extraWidget != null) ...[
            const SizedBox(height: AppSpacing.xs),
            extraWidget,
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 5 - OTP Verification
  // ---------------------------------------------------------------------------

  Widget _buildStep5Verify() {
    return Column(
      children: [
        // Icon and title.
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.vpn_key_outlined,
              size: 24,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Verify your email',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'Enter the 6-digit code sent to '),
              TextSpan(
                text: _emailController.text.trim(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // OTP input boxes.
        Builder(builder: (context) {
          final sw = MediaQuery.of(context).size.width;
          final otpBoxWidth = (sw - AppSpacing.lg * 4 - 5 * AppSpacing.sm) / 6;
          final clampedOtpWidth = otpBoxWidth.clamp(40.0, 52.0);

          return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return SizedBox(
                width: clampedOtpWidth,
                height: clampedOtpWidth * 1.1,
                child: TextField(
                  controller: _otpControllers[i],
                  focusNode: _otpFocusNodes[i],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  enabled: !_isLoading,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide:
                          const BorderSide(color: AppColors.border, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide:
                          const BorderSide(color: AppColors.border, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  onChanged: (value) => _handleOtpDigitChanged(i, value),
                  onSubmitted: (_) {
                    if (i == 5) _handleOtpSubmit();
                  },
                ),
              );
          }),
        );
        }),

        const SizedBox(height: AppSpacing.md),

        // Resend row.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_resendCooldown > 0) ...[
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                '${_resendCooldown}s',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            GestureDetector(
              onTap: _resendCooldown > 0 ? null : _handleResendOtp,
              child: Text(
                'Resend code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _resendCooldown > 0
                      ? AppColors.textTertiary
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Action buttons
  // ---------------------------------------------------------------------------

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Back button (visible on steps 2+).
        if (_step > 1) ...[
          Expanded(
            flex: _step < 5 ? 0 : 0,
            child: AppButton(
              text: 'Back',
              variant: AppButtonVariant.outline,
              icon: Icons.arrow_back,
              onPressed: _isLoading ? null : _handleBack,
              size: AppButtonSize.large,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],

        // Main action button.
        Expanded(
          child: _step < 4
              ? AppButton(
                  text: _isLoading ? 'Checking...' : 'Continue',
                  suffixIcon: _isLoading ? null : Icons.arrow_forward,
                  onPressed: _isLoading ? null : _handleNext,
                  isLoading: _isLoading,
                  isFullWidth: true,
                  size: AppButtonSize.large,
                )
              : _step == 4
                  ? AppButton(
                      text: _isLoading ? 'Sending code...' : 'Submit & Verify',
                      suffixIcon: _isLoading ? null : Icons.arrow_forward,
                      onPressed: _isLoading ? null : _handleSendOtp,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                    )
                  : AppButton(
                      text: _isLoading ? 'Submitting...' : 'Verify & Submit',
                      suffixIcon: _isLoading ? null : Icons.arrow_forward,
                      onPressed: _isLoading ||
                              _otpControllers
                                      .map((c) => c.text)
                                      .join()
                                      .length !=
                                  6
                          ? null
                          : _handleOtpSubmit,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                    ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Dropdown field helper
  // ---------------------------------------------------------------------------

  /// Builds a labeled dropdown field matching the app design.
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required List<_LabelValue> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text(
            hint,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          dropdownColor: AppColors.surface,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item.value,
              child: Text(item.label),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Review row data class
// ---------------------------------------------------------------------------

class _ReviewRow {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);
}
