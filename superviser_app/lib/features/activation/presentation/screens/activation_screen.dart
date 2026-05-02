import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Complete Your Training'.tr(context)),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MeshGradientBackground(
        position: MeshPosition.topRight,
        colors: MeshColors.warmColors,
        opacity: 0.5,
        child: SafeArea(
          child: state.isLoading && state.modules.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Header
                    _buildHeader(context, state),

                    // Progress in glass card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(16),
                        elevation: 1,
                        child: _buildProgressSection(context, state),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Modules list with glass step cards
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
                            onTap: () =>
                                _openModule(context, ref, module, index),
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
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.school_outlined,
              size: 32,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Complete all training modules to unlock your supervisor dashboard.'
                .tr(context),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the progress section with orange accent progress bar.
  Widget _buildProgressSection(BuildContext context, ActivationState state) {
    final progress =
        state.totalCount > 0 ? state.completedCount / state.totalCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Training Progress'.tr(context),
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              '${state.completedCount} ${'of'.tr(context)} ${state.totalCount} ${'completed'.tr(context)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? AppColors.success : AppColors.accent,
            ),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteActions(
    BuildContext context,
    WidgetRef ref,
    ActivationState state,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      opacity: 0.9,
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(12),
            borderColor: AppColors.success.withValues(alpha: 0.3),
            elevation: 1,
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All training modules completed!'.tr(context),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('Continue to Dashboard'.tr(context)),
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
