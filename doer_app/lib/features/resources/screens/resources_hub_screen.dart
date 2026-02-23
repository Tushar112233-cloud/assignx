import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/resources_provider.dart';
import '../../dashboard/widgets/app_header.dart';

/// Resources hub screen - central navigation for all resource tools.
///
/// Serves as the main entry point for all writing tools, learning
/// resources, and additional documentation for doers.
///
/// ## Navigation
/// - Entry: From [AppDrawer] or dashboard
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
    final aiCheckCount = resourcesState.aiCheckHistory.length;
    final citationCount = resourcesState.citationHistory.length;

    return Scaffold(
      backgroundColor: AppColors.background,
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
                  // Quick stats
                  _buildQuickStats(trainingProgress, aiCheckCount, citationCount),

                  const SizedBox(height: AppSpacing.lg),

                  // Main tools section
                  const Text(
                    'Writing Tools',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildToolCard(
                    context,
                    title: 'AI Content Checker',
                    description: 'Check your content for AI-generated patterns and ensure originality.',
                    icon: Icons.psychology,
                    color: AppColors.info,
                    badge: aiCheckCount > 0 ? '$aiCheckCount checks' : null,
                    onTap: () => context.push('/resources/ai-checker'),
                  ),

                  _buildToolCard(
                    context,
                    title: 'Citation Builder',
                    description: 'Generate properly formatted citations in APA, MLA, Harvard, and more.',
                    icon: Icons.format_quote,
                    color: AppColors.accent,
                    badge: citationCount > 0 ? '$citationCount citations' : null,
                    onTap: () => context.push('/resources/citation-builder'),
                  ),

                  _buildToolCard(
                    context,
                    title: 'Format Templates',
                    description: 'Download pre-formatted Word, PowerPoint, and Excel templates.',
                    icon: Icons.description,
                    color: const Color(0xFF2B579A),
                    badge: 'New',
                    onTap: () => context.push('/resources/templates'),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Learning section
                  const Text(
                    'Learning & Development',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildToolCard(
                    context,
                    title: 'Training Center',
                    description: 'Complete training modules to improve your skills and unlock features.',
                    icon: Icons.school,
                    color: AppColors.primary,
                    progress: trainingProgress,
                    onTap: () => context.push('/resources/training'),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Additional resources
                  const Text(
                    'Additional Resources',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildResourceLinks(),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(double trainingProgress, int aiChecks, int citations) {
    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Padding(
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
              color: AppColors.border,
            ),
            Expanded(
              child: _buildStatItem(
                'AI Checks',
                '$aiChecks',
                Icons.psychology,
                AppColors.info,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.border,
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
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
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

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    String? badge,
    double? progress,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: color.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),
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

  Widget _buildResourceLinks() {
    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        children: [
          _buildLinkItem(
            'Writing Guidelines',
            'Best practices for academic writing',
            Icons.menu_book,
          ),
          const Divider(height: 1),
          _buildLinkItem(
            'Citation Guides',
            'Detailed guides for all citation styles',
            Icons.article,
          ),
          const Divider(height: 1),
          _buildLinkItem(
            'Plagiarism Policy',
            'Understand our plagiarism guidelines',
            Icons.policy,
          ),
          const Divider(height: 1),
          _buildLinkItem(
            'FAQ & Support',
            'Get help with common questions',
            Icons.help_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(String title, String subtitle, IconData icon) {
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
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.textSecondary,
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
            const Icon(
              Icons.open_in_new,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
