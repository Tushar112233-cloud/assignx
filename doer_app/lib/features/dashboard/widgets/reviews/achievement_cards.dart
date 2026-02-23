import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../data/models/project_model.dart';

/// Achievement milestone data model.
class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final int requiredCount;
  final Color color;
  final bool Function(List<ReviewModel> reviews, DoerStats stats) isUnlocked;
  final double Function(List<ReviewModel> reviews, DoerStats stats) progress;

  const _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredCount,
    required this.color,
    required this.isUnlocked,
    required this.progress,
  });
}

/// Grid of achievement milestone cards showing review-based accomplishments.
class AchievementCards extends StatelessWidget {
  final List<ReviewModel> reviews;
  final DoerStats stats;

  const AchievementCards({
    super.key,
    required this.reviews,
    required this.stats,
  });

  List<_Achievement> get _achievements => [
        _Achievement(
          title: 'First Review',
          description: 'Receive your first review',
          icon: Icons.emoji_events_rounded,
          requiredCount: 1,
          color: const Color(0xFFCD7F32), // Bronze
          isUnlocked: (r, _) => r.isNotEmpty,
          progress: (r, _) => (r.length / 1).clamp(0.0, 1.0),
        ),
        _Achievement(
          title: 'Rising Star',
          description: 'Receive 10 reviews',
          icon: Icons.star_rounded,
          requiredCount: 10,
          color: const Color(0xFFF59E0B),
          isUnlocked: (r, _) => r.length >= 10,
          progress: (r, _) => (r.length / 10).clamp(0.0, 1.0),
        ),
        _Achievement(
          title: 'Top Rated',
          description: 'Maintain 4.5+ average',
          icon: Icons.workspace_premium_rounded,
          requiredCount: 1,
          color: const Color(0xFF22C55E),
          isUnlocked: (r, s) => r.isNotEmpty && s.rating >= 4.5,
          progress: (r, s) =>
              r.isEmpty ? 0.0 : (s.rating / 4.5).clamp(0.0, 1.0),
        ),
        _Achievement(
          title: 'Review Champion',
          description: 'Receive 25+ reviews',
          icon: Icons.military_tech_rounded,
          requiredCount: 25,
          color: const Color(0xFF3B82F6),
          isUnlocked: (r, _) => r.length >= 25,
          progress: (r, _) => (r.length / 25).clamp(0.0, 1.0),
        ),
        _Achievement(
          title: 'Consistent',
          description: 'Receive 50+ reviews',
          icon: Icons.verified_rounded,
          requiredCount: 50,
          color: const Color(0xFF8B5CF6),
          isUnlocked: (r, _) => r.length >= 50,
          progress: (r, _) => (r.length / 50).clamp(0.0, 1.0),
        ),
        _Achievement(
          title: 'Legend',
          description: 'Receive 100+ reviews',
          icon: Icons.diamond_rounded,
          requiredCount: 100,
          color: const Color(0xFFEC4899),
          isUnlocked: (r, _) => r.length >= 100,
          progress: (r, _) => (r.length / 100).clamp(0.0, 1.0),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: const Icon(Icons.emoji_events_outlined,
                  size: 18, color: Color(0xFF8B5CF6)),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${_achievements.where((a) => a.isUnlocked(reviews, stats)).length}/${_achievements.length}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: AppSpacing.md),

        // Grid of achievements
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
          ),
          itemCount: _achievements.length,
          itemBuilder: (context, index) {
            final achievement = _achievements[index];
            return _AchievementCard(
              achievement: achievement,
              reviews: reviews,
              stats: stats,
              index: index,
            );
          },
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;
  final List<ReviewModel> reviews;
  final DoerStats stats;
  final int index;

  const _AchievementCard({
    required this.achievement,
    required this.reviews,
    required this.stats,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked(reviews, stats);
    final progress = achievement.progress(reviews, stats);

    return Container(
      decoration: BoxDecoration(
        color: unlocked
            ? achievement.color.withValues(alpha: 0.08)
            : AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: unlocked
              ? achievement.color.withValues(alpha: 0.3)
              : AppColors.border,
          width: unlocked ? 1.5 : 0.5,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with lock/unlock
          Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: unlocked
                      ? achievement.color.withValues(alpha: 0.15)
                      : AppColors.border,
                  valueColor: AlwaysStoppedAnimation(
                    unlocked
                        ? achievement.color
                        : AppColors.textTertiary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              Icon(
                unlocked ? achievement.icon : Icons.lock_rounded,
                size: 20,
                color: unlocked
                    ? achievement.color
                    : AppColors.textTertiary.withValues(alpha: 0.5),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Title
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: unlocked ? achievement.color : AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // Progress text
          Text(
            unlocked
                ? 'Unlocked!'
                : '${(progress * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              color: unlocked
                  ? achievement.color.withValues(alpha: 0.8)
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 80 * index),
          duration: 400.ms,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: Duration(milliseconds: 80 * index),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}
