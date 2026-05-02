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

/// Training Document Screen (S13)
///
/// Displays training PDF document with completion tracking.
class TrainingDocumentScreen extends ConsumerWidget {
  const TrainingDocumentScreen({
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
        position: MeshPosition.topRight,
        colors: MeshColors.warmColors,
        opacity: 0.35,
        child: SafeArea(
          child: GlassContainer(
            margin: const EdgeInsets.all(0),
            borderRadius: BorderRadius.zero,
            opacity: 0.7,
            child: PDFDocumentViewer(
              pdfUrl: module.contentUrl,
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
            Text('Document marked as complete!'.tr(context)),
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
