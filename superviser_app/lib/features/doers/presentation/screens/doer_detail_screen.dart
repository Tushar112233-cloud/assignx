import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
import '../../../dashboard/data/models/doer_model.dart';
import '../providers/doers_provider.dart';

/// Detail screen for viewing a doer's full profile.
/// Standalone route — uses MeshGradientBackground.
class DoerDetailScreen extends ConsumerWidget {
  const DoerDetailScreen({super.key, required this.doerId});

  final String doerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doersState = ref.watch(doersProvider);
    final doer = doersState.doers.cast<DoerModel?>().firstWhere(
          (d) => d?.id == doerId,
          orElse: () => null,
        );

    if (doer == null) {
      return MeshGradientBackground(
        position: MeshPosition.bottomRight,
        opacity: 0.4,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Doer Profile'.tr(context)),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_off, size: 64, color: AppColors.textSecondaryLight),
                const SizedBox(height: 16),
                Text('Doer not found'.tr(context)),
              ],
            ),
          ),
        ),
      );
    }

    return MeshGradientBackground(
      position: MeshPosition.bottomRight,
      opacity: 0.4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Doer Profile'.tr(context),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {},
              tooltip: 'Message'.tr(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Glass hero card with avatar + info
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: GlassCard(
                  blur: 15,
                  opacity: 0.7,
                  borderRadius: BorderRadius.circular(20),
                  borderColor: Colors.white.withAlpha(60),
                  padding: const EdgeInsets.all(24),
                  elevation: 3,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                            backgroundImage: doer.avatarUrl != null
                                ? NetworkImage(doer.avatarUrl!)
                                : null,
                            child: doer.avatarUrl == null
                                ? Text(
                                    doer.initials,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 4,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: doer.isAvailable ? AppColors.success : AppColors.textSecondaryLight,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        doer.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doer.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          // Rating badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  doer.rating.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${doer.totalReviews} ${'reviews'.tr(context)})',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondaryLight,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: doer.isAvailable
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.textSecondaryLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              doer.isAvailable ? 'Available'.tr(context) : 'Busy'.tr(context),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: doer.isAvailable ? AppColors.success : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Glass stat cards (projects, rating, on-time)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _GlassStatCard(
                      icon: Icons.folder_copy,
                      label: 'Completed'.tr(context),
                      value: doer.completedProjects.toString(),
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _GlassStatCard(
                      icon: Icons.check_circle,
                      label: 'Success Rate'.tr(context),
                      value: '${doer.successRate.toStringAsFixed(0)}%',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    _GlassStatCard(
                      icon: Icons.timer,
                      label: 'On Time'.tr(context),
                      value: '${doer.onTimeDeliveryRate.toStringAsFixed(0)}%',
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),

              // Glass section card: About
              _GlassDetailSection(
                title: 'About'.tr(context),
                children: [
                  if (doer.bio != null && doer.bio!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        doer.bio!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ),
                  _DetailRow(label: 'Qualification'.tr(context), value: doer.qualificationDisplay),
                  _DetailRow(label: 'Experience'.tr(context), value: doer.experienceLevelDisplay),
                  _DetailRow(label: 'Years of Experience'.tr(context), value: '${doer.yearsOfExperience} ${'years'.tr(context)}'),
                ],
              ),

              // Glass section card: Expertise
              if (doer.expertise.isNotEmpty)
                _GlassDetailSection(
                  title: 'Expertise'.tr(context),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doer.expertise.map((exp) {
                        return Chip(
                          label: Text(exp),
                          labelStyle: const TextStyle(fontSize: 12),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.assignment_ind, size: 18),
                        label: Text('Assign to Project'.tr(context)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text('Send Message'.tr(context)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glass stat card for the detail screen.
class _GlassStatCard extends StatelessWidget {
  const _GlassStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        blur: 10,
        opacity: 0.65,
        borderRadius: BorderRadius.circular(14),
        borderColor: color.withAlpha(30),
        padding: const EdgeInsets.all(16),
        elevation: 1,
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontSize: 11,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass detail section card wrapper.
class _GlassDetailSection extends StatelessWidget {
  const _GlassDetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: GlassCard(
        blur: 10,
        opacity: 0.65,
        borderRadius: BorderRadius.circular(16),
        borderColor: Colors.white.withAlpha(50),
        padding: const EdgeInsets.all(16),
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
