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

/// Professional profile completion screen.
///
/// Single-page form with smooth animations for collecting professional details.
class ProfessionalProfileScreen extends ConsumerStatefulWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  ConsumerState<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState
    extends ConsumerState<ProfessionalProfileScreen> {
  bool _isLoading = false;

  // Form controllers
  final _nameController = TextEditingController();
  ProfessionalType? _selectedProfessionalType;
  String? _selectedIndustryId;
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authNotifier = ref.read(authStateProvider.notifier);
      final authState = ref.read(authStateProvider);
      final user = authState.valueOrNull?.user;

      // Get the selected professional type if already set
      if (authNotifier.selectedProfessionalType != null) {
        setState(() {
          _selectedProfessionalType = authNotifier.selectedProfessionalType;
        });
      }

      // Auto-fill name from profile if available
      if (user != null) {
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
    _nameController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _linkedinController.dispose();
    _phoneController.dispose();
    super.dispose();
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
    // Validate
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your full name'); // Translated at display
      return;
    }

    if (_selectedProfessionalType == null) {
      _showError('Please select your professional type'); // Translated at display
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authStateProvider.notifier);

      // Send everything in one PUT /users/me call (matches web behavior)
      final phone = _phoneController.text.trim();
      final body = <String, dynamic>{
        'fullName': _nameController.text.trim(),
        'userType': 'professional',
        'professionalType': _selectedProfessionalType!.toDbString(),
        'onboardingStep': 'complete',
        'onboardingCompleted': true,
      };
      if (phone.isNotEmpty) body['phone'] = phone;
      if (_selectedIndustryId != null) body['industryId'] = _selectedIndustryId;
      if (_jobTitleController.text.trim().isNotEmpty) {
        body['jobTitle'] = _jobTitleController.text.trim();
      }
      if (_companyController.text.trim().isNotEmpty) {
        body['companyName'] = _companyController.text.trim();
      }
      if (_linkedinController.text.trim().isNotEmpty) {
        body['linkedinUrl'] = _linkedinController.text.trim();
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
    final industries = ref.watch(industriesProvider);

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
                      onPressed: () => context.pop(),
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

              const SizedBox(height: 8),

              // Main form
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.screenPadding,
                  child: Container(
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
                        // Header
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
                                Icons.work_outline,
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
                                    'Professional Details'.tr(context),
                                    style: AppTextStyles.headingMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tell us a bit about yourself'.tr(context),
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

                        const SizedBox(height: 16),

                        // Professional Type (required)
                        AppDropdown<ProfessionalType>(
                          label: 'Professional Type'.tr(context),
                          hint: 'Select your professional type'.tr(context),
                          value: _selectedProfessionalType,
                          items: ProfessionalType.values,
                          itemLabel: (item) => item.displayName,
                          onChanged: (value) {
                            setState(() => _selectedProfessionalType = value);
                          },
                        ),

                        const SizedBox(height: 16),

                        // Industry
                        industries.when(
                          data: (items) => AppDropdown<Map<String, dynamic>>(
                            label: 'Industry (Optional)'.tr(context),
                            hint: 'Select your industry'.tr(context),
                            value: items
                                .where((i) => i['id'] == _selectedIndustryId)
                                .firstOrNull,
                            items: items,
                            itemLabel: (item) => item['name'] as String,
                            searchable: true,
                            onChanged: (value) {
                              setState(() => _selectedIndustryId = value?['id'] as String?);
                            },
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                          error: (_, _) => Text(
                            'Failed to load industries'.tr(context),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Job Title (optional)
                        AppTextField(
                          controller: _jobTitleController,
                          label: _selectedProfessionalType == ProfessionalType.business
                              ? 'Your Role (Optional)'.tr(context)
                              : 'Job Title (Optional)'.tr(context),
                          hint: _selectedProfessionalType == ProfessionalType.business
                              ? 'e.g., Founder, CEO'.tr(context)
                              : 'e.g., Software Engineer'.tr(context),
                          prefixIcon: Icons.work_outline,
                          textCapitalization: TextCapitalization.words,
                        ),

                        const SizedBox(height: 16),

                        // Company (optional)
                        AppTextField(
                          controller: _companyController,
                          label: _selectedProfessionalType == ProfessionalType.business
                              ? 'Business Name (Optional)'.tr(context)
                              : 'Company (Optional)'.tr(context),
                          hint: _selectedProfessionalType == ProfessionalType.business
                              ? 'Enter your business name'.tr(context)
                              : 'Enter your company name'.tr(context),
                          prefixIcon: Icons.business_outlined,
                          textCapitalization: TextCapitalization.words,
                        ),

                        const SizedBox(height: 16),

                        // LinkedIn URL (optional)
                        AppTextField(
                          controller: _linkedinController,
                          label: 'LinkedIn Profile (Optional)'.tr(context),
                          hint: 'https://linkedin.com/in/yourprofile',
                          prefixIcon: Icons.link,
                          keyboardType: TextInputType.url,
                        ),

                        const SizedBox(height: 16),

                        // Phone Number (optional)
                        PhoneInput(
                          controller: _phoneController,
                          label: 'Phone Number (Optional)'.tr(context),
                          hint: 'Enter your phone number'.tr(context),
                          onSubmitted: _submitForm,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ),
              ),

              // Submit button
              Padding(
                padding: AppSpacing.screenPadding,
                child: AppButton(
                  label: 'Complete'.tr(context),
                  onPressed: _submitForm,
                  icon: Icons.check,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
