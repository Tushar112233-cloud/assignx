import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/resources_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../dashboard/widgets/app_header.dart';

/// Training center screen with modules and progress tracking.
///
/// Displays all training modules organized by category with progress
/// indicators and completion tracking. Modules can be required or
/// optional for platform activation.
///
/// ## Navigation
/// - Entry: From [ResourcesHubScreen] or [ActivationGateScreen]
/// - Back: Returns to previous screen
/// - Tap module: Opens [_ModuleDetailSheet] for full content
///
/// ## Features
/// - Overall progress card with completion percentage
/// - Required modules indicator
/// - Category-based organization
/// - Module cards with status (not started/in progress/completed)
/// - Duration estimates
/// - Video content indicators
///
/// ## Module Categories
/// - Onboarding: Getting started basics
/// - Writing Skills: Academic writing techniques
/// - Ethics: Plagiarism and integrity
/// - Research: Research methodology
/// - Productivity: Time management
///
/// ## Module Status
/// - Not started: Gray play icon
/// - In progress: Circular progress indicator
/// - Completed: Green checkmark
///
/// ## State Management
/// Uses [ResourcesProvider] for module data and completion tracking.
///
/// See also:
/// - [ResourcesProvider] for training state
/// - [TrainingModule] for module model
/// - [_ModuleDetailSheet] for module content view
class TrainingCenterScreen extends ConsumerWidget {
  const TrainingCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesState = ref.watch(resourcesProvider);
    final modulesByCategory = resourcesState.modulesByCategory;
    final progress = resourcesState.trainingProgress;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingOverlay(
        isLoading: resourcesState.isLoading,
        child: Column(
          children: [
            InnerHeader(
              title: 'Training Center',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress overview
                    _buildProgressCard(context, progress, resourcesState),

                    const SizedBox(height: AppSpacing.lg),

                    // Modules by category
                    ...modulesByCategory.entries.map((entry) {
                      return _buildCategorySection(
                        context,
                        ref,
                        entry.key,
                        entry.value,
                      );
                    }),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    double progress,
    ResourcesState state,
  ) {
    final completedCount = state.trainingModules.where((m) => m.isCompleted).length;
    final totalCount = state.trainingModules.length;
    final requiredCompleted = state.trainingModules
        .where((m) => m.isRequired && m.isCompleted)
        .length;
    final totalRequired = state.trainingModules.where((m) => m.isRequired).length;

    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusMd,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$completedCount of $totalCount modules completed',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (requiredCompleted < totalRequired)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$requiredCompleted/$totalRequired required modules completed',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'All required modules completed!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    WidgetRef ref,
    String category,
    List<TrainingModule> modules,
  ) {
    final completedInCategory = modules.where((m) => m.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$completedInCategory/${modules.length}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ...modules.map((module) => _buildModuleCard(context, ref, module)),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'onboarding':
        return Icons.rocket_launch;
      case 'writing skills':
        return Icons.edit_note;
      case 'ethics':
        return Icons.balance;
      case 'research':
        return Icons.search;
      case 'productivity':
        return Icons.timer;
      default:
        return Icons.school;
    }
  }

  Widget _buildModuleCard(
    BuildContext context,
    WidgetRef ref,
    TrainingModule module,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: InkWell(
        onTap: () => _openModuleDetail(context, ref, module),
        borderRadius: AppSpacing.borderRadiusSm,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: module.isCompleted
                      ? AppColors.success.withValues(alpha: 0.1)
                      : module.progress != null && module.progress! > 0
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: module.isCompleted
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 24,
                      )
                    : module.progress != null && module.progress! > 0
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  value: module.progress,
                                  strokeWidth: 3,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                              Text(
                                '${(module.progress! * 100).round()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          )
                        : const Icon(
                            Icons.play_circle_outline,
                            color: AppColors.textTertiary,
                            size: 24,
                          ),
              ),
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
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: module.isCompleted
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (module.isRequired)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Required',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          module.formattedDuration,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        if (module.videoUrl != null) ...[
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.play_circle_filled,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Video',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
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

  void _openModuleDetail(
    BuildContext context,
    WidgetRef ref,
    TrainingModule module,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModuleDetailSheet(module: module),
    );
  }
}

/// Module detail bottom sheet for viewing full training content.
///
/// Displays complete module information including video placeholder,
/// description, learning objectives, and content. Provides action
/// button to mark module as complete or review completed modules.
///
/// ## Features
/// - Module header with title and metadata chips
/// - Video placeholder (for video-based modules)
/// - Detailed description section
/// - Learning objectives list
/// - Markdown content display
/// - Complete/Review action button
///
/// ## State
/// - [_isCompleting]: Loading state during completion action
class _ModuleDetailSheet extends ConsumerStatefulWidget {
  final TrainingModule module;

  const _ModuleDetailSheet({required this.module});

  @override
  ConsumerState<_ModuleDetailSheet> createState() => _ModuleDetailSheetState();
}

class _ModuleDetailSheetState extends ConsumerState<_ModuleDetailSheet> {
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.module.isRequired)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Required Module',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            Text(
                              widget.module.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildInfoChip(
                                  Icons.category,
                                  widget.module.category,
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  Icons.schedule,
                                  widget.module.formattedDuration,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (widget.module.isCompleted)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 32,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Video placeholder
                  if (widget.module.videoUrl != null)
                    Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppSpacing.borderRadiusMd,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Video content',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.lg),

                  // Description
                  const Text(
                    'About this module',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.module.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Learning objectives
                  _buildSection(
                    'Learning Objectives',
                    Icons.flag,
                    [
                      'Understand core concepts and principles',
                      'Apply knowledge to real-world scenarios',
                      'Complete practical exercises',
                      'Pass the module assessment',
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Content preview
                  if (widget.module.contentMarkdown != null) ...[
                    const Text(
                      'Module Content',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Text(
                        widget.module.contentMarkdown!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // Bottom action bar
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: widget.module.isCompleted
                  ? AppButton(
                      text: 'Review Module',
                      onPressed: () => Navigator.pop(context),
                      isFullWidth: true,
                      variant: AppButtonVariant.secondary,
                      icon: Icons.refresh,
                    )
                  : AppButton(
                      text: _isCompleting ? 'Completing...' : 'Mark as Complete',
                      onPressed: _isCompleting ? null : _completeModule,
                      isFullWidth: true,
                      isLoading: _isCompleting,
                      icon: Icons.check,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Future<void> _completeModule() async {
    setState(() => _isCompleting = true);

    await ref
        .read(resourcesProvider.notifier)
        .completeModule(widget.module.id);

    if (mounted) {
      setState(() => _isCompleting = false);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('${widget.module.title} completed!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
