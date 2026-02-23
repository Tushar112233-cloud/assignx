import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/dialogs/confirm_dialog.dart';
import '../providers/registration_provider.dart';
import '../widgets/step_progress_indicator.dart';
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
        appBar: AppBar(
          title: const Text('Supervisor Application'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldLeave = await ConfirmDialog.showDiscardChanges(context);
              if (shouldLeave && mounted) {
                context.go('/login');
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Step progress indicator
              Padding(
                padding: const EdgeInsets.all(16),
                child: StepProgressIndicator(
                  currentStep: state.currentStep,
                  totalSteps: RegistrationState.totalSteps,
                  stepTitles: RegistrationState.stepTitles,
                  onStepTapped: _goToStep,
                ),
              ),

              // Error message
              if (state.error != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: AppTypography.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          ref.read(registrationProvider.notifier).clearError();
                        },
                      ),
                    ],
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
    );
  }
}
