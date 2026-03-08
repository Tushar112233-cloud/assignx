import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
import '../providers/activation_provider.dart';
import '../widgets/video_player_widget.dart';

/// Training Video Screen (S13)
///
/// Displays training video with completion tracking.
class TrainingVideoScreen extends ConsumerWidget {
  const TrainingVideoScreen({
    super.key,
    required this.moduleId,
  });

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activationProvider);
    final module = state.modules.firstWhere(
      (m) => m.id == moduleId,
      orElse: () => state.modules.first,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(module.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (module.isCompleted)
            GlassContainer(
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              borderRadius: BorderRadius.circular(16),
              backgroundColor: AppColors.success,
              opacity: 0.15,
              borderColor: AppColors.success.withValues(alpha: 0.3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Completed'.tr(context),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: MeshGradientBackground(
        position: MeshPosition.bottomRight,
        colors: MeshColors.warmColors,
        opacity: 0.35,
        child: SafeArea(
          child: Column(
            children: [
              // Video player
              Expanded(
                child: TrainingVideoPlayer(
                  videoUrl: module.contentUrl,
                  title: module.title,
                  onComplete: () async {
                    await ref
                        .read(activationProvider.notifier)
                        .markCurrentModuleComplete();
                    if (context.mounted) {
                      _showCompletionSnackbar(context);
                    }
                  },
                ),
              ),

              // Module info in glass container with orange accent progress
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                opacity: 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      module.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${module.durationMinutes} ${'minutes'.tr(context)}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const Spacer(),
                        if (!module.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'In Progress'.tr(context),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
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

  void _showCompletionSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('Module marked as complete!'.tr(context)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
