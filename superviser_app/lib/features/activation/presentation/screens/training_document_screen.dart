import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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
      appBar: AppBar(
        title: Text(module.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (module.isCompleted)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
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
                    'Completed',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: PDFDocumentViewer(
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
    );
  }

  void _showCompletionSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Document marked as complete!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
