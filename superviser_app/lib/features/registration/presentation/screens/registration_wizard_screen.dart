import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/dialogs/confirm_dialog.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
import '../providers/registration_provider.dart';
import 'steps/personal_info_step.dart';
import 'steps/experience_step.dart';
import 'steps/banking_step.dart';
import 'steps/review_step.dart';

/// Multi-step registration wizard screen.
///
/// Guides supervisors through the application process.
class RegistrationWizardScreen extends ConsumerStatefulWidget {
  const RegistrationWizardScreen({super.key});

  @override
  ConsumerState<RegistrationWizardScreen> createState() =>
      _RegistrationWizardScreenState();
}

class _RegistrationWizardScreenState
    extends ConsumerState<RegistrationWizardScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final state = ref.read(registrationProvider);
    if (state.currentStep > 0) {
      // Go back a step instead of leaving
      _goToPreviousStep();
      return false;
    }

    // Confirm leaving wizard
    final shouldLeave = await ConfirmDialog.showDiscardChanges(context);
    return shouldLeave;
  }

  void _goToNextStep() {
    final notifier = ref.read(registrationProvider.notifier);
    final state = ref.read(registrationProvider);

    if (state.currentStep < RegistrationState.totalSteps - 1) {
      notifier.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep() {
    final notifier = ref.read(registrationProvider.notifier);
    final state = ref.read(registrationProvider);

    if (state.currentStep > 0) {
      notifier.previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int step) {
    final notifier = ref.read(registrationProvider.notifier);
    notifier.goToStep(step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitApplication() async {
    final notifier = ref.read(registrationProvider.notifier);
    final success = await notifier.submitApplication();

    if (!mounted) return;

    if (success) {
      context.go('/registration/pending');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Supervisor Application'.tr(context)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldLeave =
                  await ConfirmDialog.showDiscardChanges(context);
              if (shouldLeave && mounted) {
                context.go('/login');
              }
            },
          ),
        ),
        body: MeshGradientBackground(
          position: MeshPosition.topRight,
          colors: MeshColors.warmColors,
          opacity: 0.5,
          child: SafeArea(
            child: Column(
              children: [
                // Step dots indicator
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: _buildStepDots(state),
                ),

                // Error message
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GlassContainer(
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.all(12),
                      backgroundColor: AppColors.error,
                      opacity: 0.12,
                      borderColor: AppColors.error.withValues(alpha: 0.3),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              ref
                                  .read(registrationProvider.notifier)
                                  .clearError();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                // Step content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      PersonalInfoStep(
                        onNext: _goToNextStep,
                      ),
                      ExperienceStep(
                        onNext: _goToNextStep,
                        onBack: _goToPreviousStep,
                      ),
                      BankingStep(
                        onNext: _goToNextStep,
                        onBack: _goToPreviousStep,
                      ),
                      ReviewStep(
                        onSubmit: _submitApplication,
                        onBack: _goToPreviousStep,
                        onEditStep: _goToStep,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds horizontal step dots with orange fill for active/completed steps.
  Widget _buildStepDots(RegistrationState state) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: Column(
        children: [
          // Step dots row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(RegistrationState.totalSteps, (index) {
              final isCompleted = index < state.currentStep;
              final isCurrent = index == state.currentStep;

              return GestureDetector(
                onTap: isCompleted ? () => _goToStep(index) : null,
                child: Row(
                  children: [
                    // Dot
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isCurrent ? 32 : 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? AppColors.accent
                            : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                    // Spacer between dots
                    if (index < RegistrationState.totalSteps - 1)
                      const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          // Current step label
          Text(
            RegistrationState.stepTitles[state.currentStep],
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
