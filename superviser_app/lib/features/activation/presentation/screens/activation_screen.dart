import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/training_module.dart';
import '../providers/activation_provider.dart';
import '../widgets/training_module_card.dart';

/// Activation Lock Screen (S12)
///
/// Full-screen overlay showing training progress and modules.
class ActivationScreen extends ConsumerWidget {
  const ActivationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activationProvider);

    return Scaffold(
      body: SafeArea(
        child: state.isLoading && state.modules.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header
                  _buildHeader(context, state),

                  // Progress
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TrainingProgressBar(
                      completed: state.completedCount,
                      total: state.totalCount,
                    ),
                  ),

                  // Modules list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.modules.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final module = state.modules[index];
                        return TrainingModuleCard(
                          module: module,
                          index: index,
                          isActive: index == state.currentModuleIndex,
                          onTap: () => _openModule(context, ref, module, index),
                        );
                      },
                    ),
                  ),

                  // Bottom actions
                  if (state.isAllComplete)
                    _buildCompleteActions(context, ref, state),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ActivationState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Complete Your Training',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete all training modules to unlock your supervisor dashboard.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteActions(
    BuildContext context,
    WidgetRef ref,
    ActivationState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All training modules completed!',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.go('/activation/complete'),
              child: const Text('Continue to Dashboard'),
            ),
          ),
        ],
      ),
    );
  }

  void _openModule(
    BuildContext context,
    WidgetRef ref,
    TrainingModule module,
    int index,
  ) {
    ref.read(activationProvider.notifier).goToModule(index);

    switch (module.type) {
      case ModuleType.video:
        context.push('/activation/video/${module.id}');
        break;
      case ModuleType.pdf:
        context.push('/activation/document/${module.id}');
        break;
      case ModuleType.quiz:
        context.push('/activation/quiz/${module.contentUrl}');
        break;
    }
  }
}
