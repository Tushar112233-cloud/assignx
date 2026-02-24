/// Top subjects ranking widget.
///
/// Ranked list of top 5 subjects by project count
/// with earnings per subject displayed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../providers/statistics_provider.dart';
import '../../../../core/translation/translation_extensions.dart';

/// Ranked list of top subjects by project count.
class TopSubjectsRanking extends ConsumerWidget {
  const TopSubjectsRanking({super.key});

  static const _rankColors = [
    Color(0xFFFFD700), // Gold
    Color(0xFFC0C0C0), // Silver
    Color(0xFFCD7F32), // Bronze
    AppColors.textTertiary,
    AppColors.textTertiary,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    final subjects = stats.topSubjects;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, size: 18, color: Color(0xFFFFD700)),
              SizedBox(width: 8),
              Text(
                'Top Subjects'.tr(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (subjects.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Complete projects to see rankings'.tr(context),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...subjects.asMap().entries.map((entry) {
              final index = entry.key;
              final subject = entry.value;
              final maxCount = subjects.first.projectCount;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < subjects.length - 1 ? 12 : 0,
                ),
                child: _buildSubjectRow(
                  rank: index + 1,
                  subject: subject,
                  maxCount: maxCount,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSubjectRow({
    required int rank,
    required SubjectRanking subject,
    required int maxCount,
  }) {
    final rankColor = rank <= _rankColors.length
        ? _rankColors[rank - 1]
        : AppColors.textTertiary;
    final barWidth = maxCount > 0 ? subject.projectCount / maxCount : 0.0;

    return Row(
      children: [
        // Rank badge
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: rank <= 3
                ? rankColor.withValues(alpha: 0.15)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? rankColor : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Subject info with bar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subject.subject,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${subject.projectCount} projects',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: AppSpacing.borderRadiusXs,
                      child: LinearProgressIndicator(
                        value: barWidth,
                        backgroundColor: AppColors.border.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          rank <= 3 ? rankColor : AppColors.accent,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatCurrency(subject.totalEarnings),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
