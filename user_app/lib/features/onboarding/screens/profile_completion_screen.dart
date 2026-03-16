import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';

/// Simple profile completion screen shown after signup OTP verification.
///
/// Collects the user's full name (required) and phone number (optional),
/// then marks onboarding as complete and navigates to the dashboard.
/// This mirrors the user website's post-signup onboarding flow.
class ProfileCompletionScreen extends ConsumerStatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  ConsumerState<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState
    extends ConsumerState<ProfileCompletionScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-fill name if already available from profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(currentProfileProvider);
      if (profile?.fullName != null && profile!.fullName!.isNotEmpty) {
        _nameController.text = profile.fullName!;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter your full name');
      _nameFocusNode.requestFocus();
      return;
    }

    if (name.length < 2) {
      _showError('Name must be at least 2 characters');
      _nameFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      final phone = _phoneController.text.trim();

      // Save full name, phone, and mark onboarding as complete
      await authNotifier.updateProfile(
        fullName: name,
        phone: phone.isNotEmpty ? phone : null,
        onboardingStep: OnboardingStep.complete,
        onboardingCompleted: true,
      );

      if (mounted) {
        context.go(RouteNames.signupSuccess);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to save profile. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final emailPrefix = user?.email?.split('@').first ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.topLeft,
        colors: [
          AppColors.meshPeach,
          AppColors.meshPink,
          AppColors.meshOrange,
        ],
        opacity: 0.4,
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: _isLoading,
            message: 'Saving profile...'.tr(context),
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Header
                  Padding(
                    padding: AppSpacing.screenPadding,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${'Hey'.tr(context)} $emailPrefix!',
                                      style:
                                          AppTextStyles.displaySmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Almost there! Tell us your name.'
                                          .tr(context),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(
                          begin: -0.1,
                          end: 0,
                          duration: 400.ms,
                        ),
                  ),

                  const SizedBox(height: 32),

                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppSpacing.screenPadding,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Error message
                            if (_errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.errorLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!.tr(context),
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Full Name field (required)
                            AppTextField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              label: 'Full Name'.tr(context),
                              hint: 'Enter your full name'.tr(context),
                              prefixIcon: Icons.person_outline,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              autofocus: true,
                              onChanged: (_) {
                                if (_errorMessage != null) {
                                  setState(() => _errorMessage = null);
                                }
                              },
                              onSubmitted: (_) {
                                _phoneFocusNode.requestFocus();
                              },
                            ),

                            const SizedBox(height: 8),

                            // Required label
                            Text(
                              'Required'.tr(context),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Phone Number field (optional)
                            AppTextField(
                              controller: _phoneController,
                              focusNode: _phoneFocusNode,
                              label: 'Phone Number (Optional)'.tr(context),
                              hint: 'Enter your phone number'.tr(context),
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9+\-\s]')),
                                LengthLimitingTextInputFormatter(15),
                              ],
                              onSubmitted: (_) => _submit(),
                            ),

                            const SizedBox(height: 8),

                            // Optional helper text
                            Text(
                              'We may use this to contact you about your projects.'
                                  .tr(context),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(
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
                    child: GlassContainer(
                      padding: const EdgeInsets.all(4),
                      child: AppButton(
                        label: 'Continue'.tr(context),
                        onPressed: _isLoading ? null : _submit,
                        icon: Icons.arrow_forward,
                        isLoading: _isLoading,
                      ),
                    ),
                  ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 400.ms,
                      ),

                  const SizedBox(height: 12),

                  // Skip option
                  Padding(
                    padding: AppSpacing.screenPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'You can update these details later in Settings.'
                              .tr(context),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 500.ms).fadeIn(duration: 300.ms),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
