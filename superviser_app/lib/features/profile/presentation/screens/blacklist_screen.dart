import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
import '../../data/models/profile_model.dart';
import '../providers/profile_provider.dart';

/// Screen for managing doer blacklist.
class BlacklistScreen extends ConsumerWidget {
  const BlacklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blacklistState = ref.watch(blacklistProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Doer Blacklist'.tr(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: MeshGradientBackground(
        position: MeshPosition.topLeft,
        colors: MeshColors.warmColors,
        opacity: 0.4,
        child: SafeArea(
          child: blacklistState.isLoading && blacklistState.blacklistedDoers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(blacklistProvider.notifier).loadBlacklist(),
              child: blacklistState.blacklistedDoers.isEmpty
                  ? const _EmptyBlacklist()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: blacklistState.blacklistedDoers.length,
                      itemBuilder: (context, index) {
                        final doer = blacklistState.blacklistedDoers[index];
                        return _BlacklistCard(
                          doer: doer,
                          onRemove: () => _showRemoveDialog(context, ref, doer),
                        );
                      },
                    ),
            ),
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, WidgetRef ref, DoerInfo doer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove from Blacklist'.tr(context)),
        content: Text(
          '${'Are you sure you want to remove'.tr(context)} ${doer.name} ${'from your blacklist?'.tr(context)} '
          '${'This will allow them to be assigned to your projects again.'.tr(context)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(context)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(blacklistProvider.notifier)
                  .unblacklistDoer(doer.id);

              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${doer.name} ${'removed from blacklist'.tr(context)}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Remove'.tr(context)),
          ),
        ],
      ),
    );
  }
}

/// Blacklist card for a single doer.
class _BlacklistCard extends StatelessWidget {
  const _BlacklistCard({
    required this.doer,
    this.onRemove,
  });

  final DoerInfo doer;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      blur: 12,
      opacity: 0.75,
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      borderColor: AppColors.error.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.error.withValues(alpha: 0.1),
                  child: Text(
                    doer.name.isNotEmpty ? doer.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name and info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doer.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (doer.rating ?? 0).toStringAsFixed(1),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.folder_outlined,
                            size: 14,
                            color: AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${doer.completedProjects} ${'projects'.tr(context)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Remove button
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.error,
                  tooltip: 'Remove from blacklist'.tr(context),
                ),
              ],
            ),

            // Reason
            if (doer.blacklistReason != null &&
                doer.blacklistReason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reason for blacklisting'.tr(context),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doer.blacklistReason!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Date
            if (doer.blacklistedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${'Blacklisted on'.tr(context)} ${_formatDate(doer.blacklistedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Empty blacklist state.
class _EmptyBlacklist extends StatelessWidget {
  const _EmptyBlacklist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block_outlined,
              size: 64,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No blacklisted doers'.tr(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Doers you flag will appear here\nYou can blacklist doers from project details'.tr(context),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
