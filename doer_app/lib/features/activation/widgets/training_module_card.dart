/// Training module card widgets for activation training.
///
/// This file provides card components for displaying training modules
/// during the doer activation process, with progress tracking and
/// completion status.
///
/// ## Widgets
/// - [TrainingModuleCard] - Individual training module card
/// - [TrainingModuleList] - List of training module cards
///
/// ## Features
/// - Module type icons (Video, PDF, Article)
/// - Duration display
/// - Progress bar for partially completed modules
/// - Completion badge and styling
/// - Type-specific color coding
///
/// ## Module Types
/// - **Video** (purple): Video training content
/// - **PDF** (red): Downloadable PDF documents
/// - **Article** (orange): Text-based articles
///
/// ## Example
/// ```dart
/// TrainingModuleCard(
///   module: trainingModule,
///   progress: moduleProgress,
///   onTap: () => openModule(module),
///   onMarkComplete: () => markComplete(module),
/// )
///
/// TrainingModuleList(
///   modules: allModules,
///   progress: progressMap,
///   onModuleTap: openModule,
/// )
/// ```
///
/// See also:
/// - [TrainingScreen] for usage context
/// - [TrainingModule] for module data model
/// - [TrainingProgress] for progress tracking
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/training_model.dart';

/// Card widget for displaying a single training module.
///
/// Shows module title, description, duration, type badge, and
/// optional progress indicator. Completed modules display a
/// success border and badge.
///
/// ## Props
/// - [module]: The [TrainingModule] to display
/// - [progress]: Optional [TrainingProgress] for this module
/// - [onTap]: Callback when card is tapped
/// - [onMarkComplete]: Callback to mark module complete
class TrainingModuleCard extends StatelessWidget {
  final TrainingModule module;
  final TrainingProgress? progress;
  final VoidCallback? onTap;
  final VoidCallback? onMarkComplete;

  const TrainingModuleCard({
    super.key,
    required this.module,
    this.progress,
    this.onTap,
    this.onMarkComplete,
  });

  bool get isCompleted => progress?.isCompleted ?? false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: BorderSide(
          color: isCompleted ? AppColors.success : Colors.transparent,
          width: isCompleted ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              // Module type icon
              _buildTypeIcon(),

              const SizedBox(width: AppSpacing.md),

              // Module info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            module.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
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
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      module.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Duration and type
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${module.durationMinutes} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _buildTypeBadge(),
                      ],
                    ),

                    // Progress bar if in progress
                    if (!isCompleted && (progress?.progressPercent ?? 0) > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: AppSpacing.borderRadiusSm,
                              child: LinearProgressIndicator(
                                value: (progress?.progressPercent ?? 0) / 100,
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
                            '${progress?.progressPercent ?? 0}%',
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

              const SizedBox(width: AppSpacing.sm),

              // Action button
              if (!isCompleted)
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

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (module.type) {
      case TrainingModuleType.video:
        icon = Icons.play_circle_filled;
        color = AppColors.accent;
        break;
      case TrainingModuleType.pdf:
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case TrainingModuleType.article:
        icon = Icons.article;
        color = Colors.orange;
        break;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Icon(
        icon,
        size: 32,
        color: color,
      ),
    );
  }

  Widget _buildTypeBadge() {
    String label;
    Color color;

    switch (module.type) {
      case TrainingModuleType.video:
        label = 'Video';
        color = AppColors.accent;
        break;
      case TrainingModuleType.pdf:
        label = 'PDF';
        color = Colors.red;
        break;
      case TrainingModuleType.article:
        label = 'Article';
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

/// List widget for displaying multiple training modules.
///
/// Renders a non-scrolling list of [TrainingModuleCard] widgets
/// with consistent spacing. Suitable for use inside scroll views.
///
/// ## Props
/// - [modules]: List of [TrainingModule] objects
/// - [progress]: Map of module IDs to [TrainingProgress]
/// - [onModuleTap]: Callback when a module card is tapped
/// - [onMarkComplete]: Callback to mark a module complete
class TrainingModuleList extends StatelessWidget {
  final List<TrainingModule> modules;
  final Map<String, TrainingProgress> progress;
  final Function(TrainingModule)? onModuleTap;
  final Function(TrainingModule)? onMarkComplete;

  const TrainingModuleList({
    super.key,
    required this.modules,
    required this.progress,
    this.onModuleTap,
    this.onMarkComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final module = modules[index];
        return TrainingModuleCard(
          module: module,
          progress: progress[module.id],
          onTap: () => onModuleTap?.call(module),
          onMarkComplete: () => onMarkComplete?.call(module),
        );
      },
    );
  }
}
