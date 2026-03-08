import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/resources_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../dashboard/widgets/app_header.dart';
import '../../../core/translation/translation_extensions.dart';

/// Resources hub screen - central navigation for all resource tools.
///
/// Serves as the main entry point for all writing tools, learning
/// resources, and additional documentation for doers.
///
/// ## Navigation
/// - Entry: From bottom nav or dashboard
/// - AI Checker: Opens [AICheckerScreen]
/// - Citation Builder: Opens [CitationBuilderScreen]
/// - Training Center: Opens [TrainingCenterScreen]
/// - Back: Returns to previous screen
///
/// ## Sections
/// 1. **Quick Stats**: Training progress, AI checks count, citations count
/// 2. **Writing Tools**: AI Content Checker, Citation Builder
/// 3. **Learning & Development**: Training Center with progress bar
/// 4. **Additional Resources**: Writing guidelines, citation guides, FAQ
///
/// ## Features
/// - Tool cards with usage badges (e.g., "12 checks")
/// - Progress indicator for training completion
/// - Quick access to all resource tools
/// - External resource links
///
/// ## State Management
/// Uses [ResourcesProvider] for tool usage statistics.
///
/// See also:
/// - [ResourcesProvider] for resources state
/// - [AICheckerScreen] for AI content checking
/// - [CitationBuilderScreen] for citation generation
/// - [TrainingCenterScreen] for training modules
class ResourcesHubScreen extends ConsumerWidget {
  const ResourcesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesState = ref.watch(resourcesProvider);
    final trainingProgress = resourcesState.trainingProgress;
    final citationCount = resourcesState.citationHistory.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          InnerHeader(
            title: 'Resources & Tools',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar in glass container
                  _buildSearchBar(context),

                  const SizedBox(height: AppSpacing.lg),

                  // Quick stats
                  _buildQuickStats(trainingProgress, citationCount),

                  const SizedBox(height: AppSpacing.lg),

                  // Main tools section
                  Text(
                    'Writing Tools'.tr(context),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Bento grid layout for writing tools
                  _buildToolsGrid(context, citationCount),

                  const SizedBox(height: AppSpacing.lg),

                  // Learning section
                  Text(
                    'Learning & Development'.tr(context),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildTrainingCard(context, trainingProgress),

                  const SizedBox(height: AppSpacing.lg),

                  // Additional resources
                  Text(
                    'Additional Resources'.tr(context),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildResourceLinks(context),

                  // Bottom padding for floating nav bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a glass search bar at the top of the hub.
  Widget _buildSearchBar(BuildContext context) {
    return GlassContainer(
      blur: 12,
      opacity: 0.7,
      borderRadius: AppSpacing.borderRadiusLg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppColors.accent,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search resources & tools...'.tr(context),
                hintStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the quick stats row with glass containers.
  Widget _buildQuickStats(double trainingProgress, int citations) {
    return GlassCard(
      blur: 12,
      opacity: 0.75,
      padding: AppSpacing.paddingMd,
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Training',
              '${(trainingProgress * 100).round()}%',
              Icons.school,
              AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border.withValues(alpha: 0.5),
          ),
          Expanded(
            child: _buildStatItem(
              'Citations',
              '$citations',
              Icons.format_quote,
              AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds a bento-style grid of tool cards using GlassContainer.
  Widget _buildToolsGrid(BuildContext context, int citationCount) {
    return Row(
      children: [
        // Citation Builder - taller card
        Expanded(
          child: _buildBentoToolCard(
            context,
            title: 'Citation Builder',
            description: 'APA, MLA, Harvard & more',
            icon: Icons.format_quote,
            color: AppColors.accent,
            badge: citationCount > 0 ? '$citationCount' : null,
            onTap: () => context.push('/resources/citation-builder'),
            height: 170,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Format Templates
        Expanded(
          child: _buildBentoToolCard(
            context,
            title: 'Format Templates',
            description: 'Word, PPT & Excel',
            icon: Icons.description,
            color: const Color(0xFF2B579A),
            badge: 'New',
            onTap: () => context.push('/resources/templates'),
            height: 170,
          ),
        ),
      ],
    );
  }

  /// Builds a single bento-style tool card with glass effect.
  Widget _buildBentoToolCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    String? badge,
    required VoidCallback onTap,
    required double height,
  }) {
    return GlassCard(
      onTap: onTap,
      opacity: 0.75,
      blur: 12,
      height: height,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Builds the training center card with progress bar.
  Widget _buildTrainingCard(BuildContext context, double trainingProgress) {
    return GlassCard(
      onTap: () => context.push('/resources/training'),
      opacity: 0.75,
      blur: 12,
      padding: AppSpacing.paddingMd,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.accent,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.school,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Training Center',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Complete modules to improve skills',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: trainingProgress,
                          backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(trainingProgress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right,
              color: AppColors.accent,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the additional resource links section with glass styling.
  Widget _buildResourceLinks(BuildContext context) {
    return GlassCard(
      blur: 10,
      opacity: 0.7,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildLinkItem(
            context,
            'Writing Guidelines',
            'Best practices for academic writing',
            Icons.menu_book,
            AppColors.primary,
          ),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
          _buildLinkItem(
            context,
            'Citation Guides',
            'Detailed guides for all citation styles',
            Icons.article,
            AppColors.accent,
          ),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
          _buildLinkItem(
            context,
            'Plagiarism Policy',
            'Understand our plagiarism guidelines',
            Icons.policy,
            AppColors.warning,
          ),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
          _buildLinkItem(
            context,
            'FAQ & Support',
            'Get help with common questions',
            Icons.help_outline,
            AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to respective help page
      },
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              size: 18,
              color: color.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
