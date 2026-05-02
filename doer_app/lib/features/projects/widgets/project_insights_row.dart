/// Compact horizontal scrollable insights row for the My Projects screen.
///
/// Displays quick analytics cards: total projects, avg completion time,
/// total earnings, and current week velocity.
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../providers/projects_provider.dart';

/// A collapsible row of stat cards showing project analytics insights.
class ProjectInsightsRow extends StatefulWidget {
  final ProjectStats stats;

  const ProjectInsightsRow({
    super.key,
    required this.stats,
  });

  @override
  State<ProjectInsightsRow> createState() => _ProjectInsightsRowState();
}

class _ProjectInsightsRowState extends State<ProjectInsightsRow>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with toggle
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                const Icon(
                  Icons.insights_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  'Insights'.tr(context),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _isExpanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.expand_more_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Animated collapsible content
          AnimatedCrossFade(
            firstChild: _buildInsightsCards(),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCards() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: SizedBox(
        height: 80,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _InsightCard(
              icon: Icons.folder_rounded,
              label: 'Total Projects'.tr(context),
              value: widget.stats.totalCount.toString(),
              gradient: const [AppColors.accent, AppColors.accentLight],
            ),
            const SizedBox(width: AppSpacing.sm),
            _InsightCard(
              icon: Icons.timer_rounded,
              label: 'Avg Completion'.tr(context),
              value: widget.stats.avgCompletionDays > 0
                  ? '${widget.stats.avgCompletionDays.toStringAsFixed(1)}d'
                  : '--',
              gradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
            ),
            const SizedBox(width: AppSpacing.sm),
            _InsightCard(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Total Earned'.tr(context),
              value: _formatCurrency(widget.stats.totalEarnings),
              gradient: const [Color(0xFF059669), Color(0xFF34D399)],
            ),
            const SizedBox(width: AppSpacing.sm),
            _InsightCard(
              icon: Icons.speed_rounded,
              label: 'This Week'.tr(context),
              value: '${widget.stats.weekVelocity}',
              gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '\u20B9${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '\u20B9${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\u20B9${amount.toStringAsFixed(0)}';
  }
}

/// A single compact insight stat card with gradient background.
class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  const _InsightCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.9)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
