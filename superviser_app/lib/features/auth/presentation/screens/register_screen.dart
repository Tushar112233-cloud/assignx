library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
import '../providers/auth_provider.dart';
import '../../../common/data/models/subject.dart' as subject_model;
import '../../../common/presentation/providers/subjects_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Email & Name
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // Step 2: Professional Profile
  final _yearsController = TextEditingController();
  final _bioController = TextEditingController();
  String _qualification = 'Masters';
  final List<String> _selectedSubjectIds = [];

  // Step 3: Bank Details
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiController = TextEditingController();

  // Step 4: OTP Verification
  final _otpController = TextEditingController();
  bool _otpSent = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  bool _agreedToTerms = false;

  static const _qualifications = ['PhD', 'Masters', 'Bachelors', 'Diploma', 'Other'];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _yearsController.dispose();
    _bioController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    _otpController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendCooldown = 0);
      } else {
        if (mounted) setState(() => _resendCooldown--);
      }
    });
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(step, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().isEmpty) {
          context.showErrorSnackBar('Please enter your full name'.tr(context));
          return false;
        }
        if (Validators.email(_emailController.text.trim()) != null) {
          context.showErrorSnackBar('Please enter a valid email'.tr(context));
          return false;
        }
        return true;
      case 1:
        if (_yearsController.text.trim().isEmpty) {
          context.showErrorSnackBar('Please enter years of experience'.tr(context));
          return false;
        }
        if (_selectedSubjectIds.isEmpty) {
          context.showErrorSnackBar('Please select at least one subject area'.tr(context));
          return false;
        }
        return true;
      case 2:
        if (_bankNameController.text.trim().isEmpty) {
          context.showErrorSnackBar('Please enter bank name'.tr(context));
          return false;
        }
        if (_accountNumberController.text.trim().isEmpty) {
          context.showErrorSnackBar('Please enter account number'.tr(context));
          return false;
        }
        if (_ifscController.text.trim().isEmpty) {
          context.showErrorSnackBar('Please enter IFSC code'.tr(context));
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  bool _isCheckingEmail = false;

  Future<void> _handleNext() async {
    context.unfocus();
    if (!_validateCurrentStep()) return;

    if (_currentStep == 0) {
      setState(() => _isCheckingEmail = true);
      try {
        final result = await ref.read(authProvider.notifier).checkEmailAvailability(
          _emailController.text.trim(),
        );
        if (!mounted) return;
        final available = result['available'] as bool? ?? !(result['exists'] as bool? ?? false);
        final conflictingRole = result['conflictingRole'] as String?;
        final pendingApproval = result['pendingApproval'] as bool? ?? false;
        if (!available) {
          if (pendingApproval) {
            context.showErrorSnackBar(
              'This email already has a pending application awaiting approval. Please wait for admin review or log in to check your status.',
            );
          } else if (conflictingRole != null) {
            context.showErrorSnackBar(
              'This email is already registered as a $conflictingRole. Please use a different email or log in.',
            );
          } else {
            context.showErrorSnackBar(
              'This email is already registered. Please log in instead.',
            );
          }
          setState(() => _isCheckingEmail = false);
          return;
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isCheckingEmail = false);
        context.showErrorSnackBar('Failed to verify email. Please try again.');
        return;
      }
      setState(() => _isCheckingEmail = false);
    }

    if (_currentStep == 2 && !_agreedToTerms) {
      context.showErrorSnackBar('Please agree to the Terms of Service'.tr(context));
      return;
    }

    _goToStep(_currentStep + 1);
  }

  Future<void> _handleSendOTP() async {
    ref.read(authProvider.notifier).clearError();
    try {
      await ref.read(authProvider.notifier).sendOTP(
        email: _emailController.text.trim(),
        purpose: 'signup',
      );
      if (!mounted) return;
      setState(() => _otpSent = true);
      _startCooldown();
      context.showSuccessSnackBar('Verification code sent to ${_emailController.text.trim()}'.tr(context));
    } catch (e) {
      if (!mounted) return;
      final error = ref.read(authProvider).error;
      if (error != null) context.showErrorSnackBar(error);
    }
  }

  Future<void> _handleResendOTP() async {
    if (_resendCooldown > 0) return;
    ref.read(authProvider.notifier).clearError();
    try {
      await ref.read(authProvider.notifier).sendOTP(
        email: _emailController.text.trim(),
        purpose: 'signup',
      );
      if (!mounted) return;
      _startCooldown();
      context.showSuccessSnackBar('Verification code resent'.tr(context));
    } catch (e) {
      if (!mounted) return;
      final error = ref.read(authProvider).error;
      if (error != null) context.showErrorSnackBar(error);
    }
  }

  Future<void> _handleVerifyAndSubmit() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      context.showErrorSnackBar('Please enter a 6-digit code'.tr(context));
      return;
    }
    context.unfocus();
    ref.read(authProvider.notifier).clearError();

    final metadata = <String, dynamic>{
      'qualification': _qualification,
      'yearsOfExperience': int.tryParse(_yearsController.text.trim()) ?? 0,
      'expertiseAreas': _selectedSubjectIds,
      'bio': _bioController.text.trim(),
      'bankName': _bankNameController.text.trim(),
      'accountNumber': _accountNumberController.text.trim(),
      'ifscCode': _ifscController.text.trim(),
      'upiId': _upiController.text.trim(),
    };

    final success = await ref.read(authProvider.notifier).supervisorSignup(
      email: _emailController.text.trim(),
      otp: otp,
      fullName: _nameController.text.trim(),
      metadata: metadata,
    );

    if (!mounted) return;

    if (success) {
      context.showSuccessSnackBar('Registration submitted successfully!'.tr(context));
      context.go('/registration/pending');
    } else {
      final error = ref.read(authProvider).error;
      if (error != null) context.showErrorSnackBar(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'.tr(context)),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _goToStep(_currentStep - 1),
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: MeshGradientBackground(
        position: MeshPosition.topRight,
        colors: const [
          AppColors.meshAmber,
          AppColors.meshOrange,
          AppColors.meshPeach,
          AppColors.meshGold,
        ],
        opacity: 0.6,
        child: SafeArea(
          child: Column(
            children: [
              // Step indicator
              _buildStepIndicator(),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Become a Supervisor'.tr(context),
                    style: AppTypography.headlineLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildStep4(isLoading),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : AppColors.textSecondaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: GlassContainer(
        blur: 15,
        opacity: 0.85,
        borderRadius: BorderRadius.circular(20),
        borderColor: Colors.white.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Personal Information'.tr(context),
              style: AppTypography.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your name and email to get started'.tr(context),
              style: AppTypography.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            AppTextField(
              controller: _nameController,
              label: 'Full Name'.tr(context),
              hint: 'Enter your full name'.tr(context),
              prefixIcon: Icons.person_outlined,
              validator: Validators.name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            EmailTextField(
              controller: _emailController,
              validator: Validators.email,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleNext(),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Next'.tr(context),
              onPressed: _handleNext,
              isLoading: _isCheckingEmail,
            ),
            const SizedBox(height: 24),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: GlassContainer(
        blur: 15,
        opacity: 0.85,
        borderRadius: BorderRadius.circular(20),
        borderColor: Colors.white.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Professional Profile'.tr(context),
              style: AppTypography.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us about your qualifications and expertise'.tr(context),
              style: AppTypography.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Qualification dropdown
            DropdownButtonFormField<String>(
              value: _qualification,
              decoration: InputDecoration(
                labelText: 'Qualification'.tr(context),
                prefixIcon: const Icon(Icons.school_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _qualifications.map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
              onChanged: (v) => setState(() => _qualification = v ?? 'Masters'),
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _yearsController,
              label: 'Years of Experience'.tr(context),
              hint: 'e.g. 5'.tr(context),
              prefixIcon: Icons.work_outline,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Subject areas multi-select
            Text(
              'Subject Areas'.tr(context),
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ref.watch(subjectsProvider).when(
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )),
              error: (err, _) => GestureDetector(
                onTap: () => ref.invalidate(subjectsProvider),
                child: Text(
                  'Failed to load subjects. Tap to retry.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                ),
              ),
              data: (subjects) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subjects.map((subject) {
                  final isSelected = _selectedSubjectIds.contains(subject.id);
                  return FilterChip(
                    label: Text(subject.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSubjectIds.add(subject.id);
                        } else {
                          _selectedSubjectIds.remove(subject.id);
                        }
                      });
                    },
                    selectedColor: AppColors.accent.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.accent,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _bioController,
              label: '${'Bio'.tr(context)} (${'optional'.tr(context)})',
              hint: 'Brief professional summary'.tr(context),
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              text: 'Next'.tr(context),
              onPressed: _handleNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: GlassContainer(
        blur: 15,
        opacity: 0.85,
        borderRadius: BorderRadius.circular(20),
        borderColor: Colors.white.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bank Details'.tr(context),
              style: AppTypography.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Required for payment processing'.tr(context),
              style: AppTypography.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            AppTextField(
              controller: _bankNameController,
              label: 'Bank Name'.tr(context),
              hint: 'Enter your bank name'.tr(context),
              prefixIcon: Icons.account_balance_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _accountNumberController,
              label: 'Account Number'.tr(context),
              hint: 'Enter your account number'.tr(context),
              prefixIcon: Icons.numbers_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _ifscController,
              label: 'IFSC Code'.tr(context),
              hint: 'e.g. SBIN0001234'.tr(context),
              prefixIcon: Icons.code_outlined,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _upiController,
              label: '${'UPI ID'.tr(context)} (${'optional'.tr(context)})',
              hint: 'e.g. name@upi'.tr(context),
              prefixIcon: Icons.payment_outlined,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),

            _buildTermsCheckbox(),
            const SizedBox(height: 24),

            PrimaryButton(
              text: 'Next'.tr(context),
              onPressed: _handleNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: GlassContainer(
        blur: 15,
        opacity: 0.85,
        borderRadius: BorderRadius.circular(20),
        borderColor: Colors.white.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verify Email'.tr(context),
              style: AppTypography.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We need to verify your email before submitting'.tr(context),
              style: AppTypography.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Email display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.email_outlined, color: AppColors.accent, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _emailController.text.trim(),
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!_otpSent) ...[
              PrimaryButton(
                text: 'Send Verification Code'.tr(context),
                onPressed: _handleSendOTP,
                isLoading: isLoading,
              ),
            ] else ...[
              Text(
                'Enter the 6-digit code sent to your email'.tr(context),
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _otpController,
                label: 'Verification Code'.tr(context),
                hint: '000000',
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleVerifyAndSubmit(),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ".tr(context),
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_resendCooldown > 0)
                    Text(
                      'Resend in ${_resendCooldown}s',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    )
                  else
                    TertiaryButton(
                      text: 'Resend'.tr(context),
                      onPressed: _handleResendOTP,
                    ),
                ],
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: 'Verify & Submit'.tr(context),
                onPressed: _handleVerifyAndSubmit,
                isLoading: isLoading,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() => _agreedToTerms = value ?? false);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the '.tr(context),
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service'.tr(context),
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: ' ${'and'.tr(context)} '),
                  TextSpan(
                    text: 'Privacy Policy'.tr(context),
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? '.tr(context),
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TertiaryButton(
          text: 'Log In'.tr(context),
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}
