import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../data/models/activation_model.dart';
import '../../../providers/activation_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../widgets/activation_stepper.dart';

/// Activation gate screen - locks dashboard until all steps are complete.
///
/// Presents a 3-step activation process that users must complete before
/// accessing the main dashboard. Each step must be completed in order.
///
/// ## Navigation
/// - Entry: From [SplashScreen] or [ProfileSetupScreen] (authenticated, has profile)
/// - Fully Activated: Auto-redirects to [DashboardScreen]
/// - Step 1: Navigates to [TrainingScreen]
/// - Step 2: Navigates to [QuizScreen]
/// - Step 3: Navigates to [BankDetailsScreen]
/// - Sign Out: Returns to [OnboardingScreen]
///
/// ## Features
/// - Visual step progress with [ActivationStepper]
/// - Step cards showing completion status and progress
/// - Locked steps until prerequisites are completed
/// - Training progress percentage display
/// - Info section explaining activation importance
/// - Context-aware continue button text
/// - Sign out option
///
/// ## Activation Steps
/// 1. **Training**: Complete all training modules (shows progress %)
/// 2. **Quiz**: Pass the assessment quiz (locked until training done)
/// 3. **Bank Details**: Add payment information (locked until quiz passed)
///
/// ## State Management
/// Uses [ActivationProvider] to track and persist activation progress.
///
/// See also:
/// - [ActivationProvider] for activation state management
/// - [ActivationStepper] for the visual step indicator
/// - [TrainingScreen], [QuizScreen], [BankDetailsScreen] for individual steps
class ActivationGateScreen extends ConsumerStatefulWidget {
  const ActivationGateScreen({super.key});

  @override
  ConsumerState<ActivationGateScreen> createState() => _ActivationGateScreenState();
}

/// State class for [ActivationGateScreen].
///
/// Handles auto-redirect on full activation and step navigation.
class _ActivationGateScreenState extends ConsumerState<ActivationGateScreen> {
  /// Refreshes activation data on screen initialization.
  @override
  void initState() {
    super.initState();
    // Refresh activation data when screen loads
    Future.microtask(() {
      ref.read(activationProvider.notifier).refresh();
    });
  }

  /// Navigates to the appropriate screen for the given step.
  void _navigateToStep(ActivationStep step) {
    switch (step) {
      case ActivationStep.training:
        context.go(RouteNames.training);
        break;
      case ActivationStep.quiz:
        context.go(RouteNames.quiz);
        break;
      case ActivationStep.bankDetails:
        context.go(RouteNames.bankDetails);
        break;
    }
  }

  /// Builds the activation gate screen UI.
  ///
  /// Automatically redirects to dashboard if fully activated.
  /// Otherwise, displays the step progress and individual step cards.
  @override
  Widget build(BuildContext context) {
    final activationState = ref.watch(activationProvider);
    final user = ref.watch(currentUserProvider);
    final status = activationState.status;

    // Check if fully activated - show loading and redirect
    if (status.isFullyActivated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(RouteNames.dashboard);
        }
      });
      // Return loading screen while redirecting to prevent flash
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: activationState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // Lock icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_open,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Header
                    const Text(
                      'Unlock Your Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      'Hello, ${user?.fullName.split(' ').first ?? 'there'}! Complete these 3 steps to start earning.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Activation stepper
                    ActivationStepper(
                      status: status,
                      onStepTapped: _navigateToStep,
                      currentStep: _getCurrentStep(status),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Step cards
                    _buildStepCard(
                      step: ActivationStep.training,
                      isCompleted: status.trainingCompleted,
                      isLocked: false,
                      icon: Icons.school,
                      subtitle: 'Learn about DOER platform and guidelines',
                      progress: activationState.trainingProgressPercent,
                      onTap: () => _navigateToStep(ActivationStep.training),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _buildStepCard(
                      step: ActivationStep.quiz,
                      isCompleted: status.quizPassed,
                      isLocked: !status.trainingCompleted,
                      icon: Icons.quiz,
                      subtitle: 'Answer questions based on training',
                      lastAttempt: activationState.lastQuizAttempt,
                      onTap: status.trainingCompleted
                          ? () => _navigateToStep(ActivationStep.quiz)
                          : null,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _buildStepCard(
                      step: ActivationStep.bankDetails,
                      isCompleted: status.bankDetailsAdded,
                      isLocked: !status.quizPassed,
                      icon: Icons.account_balance,
                      subtitle: 'Add your bank account for payments',
                      onTap: status.quizPassed
                          ? () => _navigateToStep(ActivationStep.bankDetails)
                          : null,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Why this matters section
                    Container(
                      padding: AppSpacing.paddingLg,
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: AppSpacing.borderRadiusLg,
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.info,
                                size: 24,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                'Why is this important?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            '• Training ensures you understand our quality standards\n'
                            '• Quiz verifies your readiness to handle projects\n'
                            '• Bank details enable us to pay you on time',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Continue button
                    if (!status.isFullyActivated)
                      AppButton(
                        text: _getButtonText(status),
                        onPressed: () => _navigateToStep(_getCurrentStep(status)),
                        isFullWidth: true,
                        size: AppButtonSize.large,
                      ),

                    const SizedBox(height: AppSpacing.md),

                    // Logout option
                    TextButton(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).signOut();
                        if (mounted) {
                          context.go(RouteNames.onboarding);
                        }
                      },
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
      ),
    );
  }

  /// Builds an individual activation step card.
  ///
  /// Displays step information with appropriate visual state:
  /// - Completed: Green border and checkmark icon
  /// - Current: Blue highlight with step icon
  /// - Locked: Grey with lock icon
  ///
  /// Shows progress bar for training step when in progress.
  Widget _buildStepCard({
    required ActivationStep step,
    required bool isCompleted,
    required bool isLocked,
    required IconData icon,
    required String subtitle,
    double? progress,
    dynamic lastAttempt,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: BorderSide(
          color: isCompleted
              ? AppColors.success
              : isLocked
                  ? Colors.transparent
                  : AppColors.primary.withValues(alpha: 0.3),
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              // Step icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.1)
                      : isLocked
                          ? AppColors.border.withValues(alpha: 0.5)
                          : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : isLocked
                          ? Icons.lock
                          : icon,
                  color: isCompleted
                      ? AppColors.success
                      : isLocked
                          ? AppColors.textTertiary
                          : AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${step.number}: ${step.title}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isLocked
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isLocked
                            ? AppColors.textTertiary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (progress != null && progress > 0 && !isCompleted) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: AppSpacing.borderRadiusSm,
                              child: LinearProgressIndicator(
                                value: progress / 100,
                                backgroundColor: AppColors.border,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accent,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${progress.toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Status indicator
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
                )
              else if (!isLocked)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Determines the current activation step based on completion status.
  ActivationStep _getCurrentStep(ActivationStatus status) {
    if (!status.trainingCompleted) return ActivationStep.training;
    if (!status.quizPassed) return ActivationStep.quiz;
    return ActivationStep.bankDetails;
  }

  /// Returns appropriate button text based on current step.
  String _getButtonText(ActivationStatus status) {
    if (!status.trainingCompleted) return 'Start Training';
    if (!status.quizPassed) return 'Take Quiz';
    return 'Add Bank Details';
  }
}
