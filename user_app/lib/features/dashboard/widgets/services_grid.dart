import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Services grid component matching web dashboard.
///
/// Displays 2x2 grid of service cards:
/// - Project Support (primary)
/// - AI/Plag Report (accent)
/// - Expert Sessions (amber) - Coming Soon
/// - Ref. Generator (warm brown) - Free external link
///
/// Example:
/// ```dart
/// ServicesGrid(
///   onNewProject: () => context.push('/new-project'),
///   onAiPlagReport: () => context.push('/report-request'),
///   onExpertSessions: () => context.push('/expert-opinion'),
///   onRefGenerator: () => launchUrl(...),
/// )
/// ```
class ServicesGrid extends StatelessWidget {
  /// Callback when New Project card is tapped.
  final VoidCallback? onNewProject;

  /// Callback when AI/Plag Report card is tapped.
  final VoidCallback? onAiPlagReport;

  /// Callback when Expert Sessions card is tapped.
  final VoidCallback? onExpertSessions;

  /// Callback when Reference Generator card is tapped.
  final VoidCallback? onRefGenerator;

  const ServicesGrid({
    super.key,
    this.onNewProject,
    this.onAiPlagReport,
    this.onExpertSessions,
    this.onRefGenerator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Choose what you need help with',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2x2 Grid
          Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  icon: Icons.description_outlined,
                  title: 'Project Support',
                  subtitle: 'Get expert help with your projects',
                  color: AppColors.primary,
                  onTap: onNewProject,
                  animationDelay: 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ServiceCard(
                  icon: Icons.search_outlined,
                  title: 'AI/Plag Report',
                  subtitle: 'Check originality & AI detection',
                  color: AppColors.accent,
                  onTap: onAiPlagReport,
                  animationDelay: 50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  icon: Icons.medical_services_outlined,
                  title: 'Consult Doctor',
                  subtitle: 'Medical consultation service',
                  color: const Color(0xFF16A34A), // Emerald
                  badge: 'Coming Soon',
                  isDisabled: true,
                  onTap: null,
                  animationDelay: 100,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ServiceCard(
                  icon: Icons.menu_book_outlined,
                  title: 'Ref. Generator',
                  subtitle: 'Generate citations for free',
                  color: const Color(0xFFB45309), // Amber-800
                  badge: 'Free',
                  onTap: onRefGenerator,
                  animationDelay: 150,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual service card with premium styling.
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final bool isDisabled;
  final VoidCallback? onTap;
  final int animationDelay;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.badge,
    this.isDisabled = false,
    this.onTap,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + animationDelay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 0,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: isDisabled ? null : onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon and badge row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            size: 20,
                            color: color,
                          ),
                        ),
                        const Spacer(),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDisabled
                                  ? AppColors.textTertiary.withValues(alpha: 0.1)
                                  : color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge!,
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isDisabled
                                    ? AppColors.textTertiary
                                    : color,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Subtitle
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Arrow indicator (only for enabled cards)
                    if (!isDisabled) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton loader for services grid.
class ServicesGridSkeleton extends StatelessWidget {
  const ServicesGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              SkeletonLoader(width: 36, height: 36, borderRadius: 10),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 100, height: 16, borderRadius: 4),
                  const SizedBox(height: 4),
                  SkeletonLoader(width: 160, height: 12, borderRadius: 4),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Grid skeleton
          Row(
            children: [
              Expanded(
                child: CardSkeleton(
                  height: 140,
                  borderRadius: 16,
                  showImage: false,
                  textLines: 2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CardSkeleton(
                  height: 140,
                  borderRadius: 16,
                  showImage: false,
                  textLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CardSkeleton(
                  height: 140,
                  borderRadius: 16,
                  showImage: false,
                  textLines: 2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CardSkeleton(
                  height: 140,
                  borderRadius: 16,
                  showImage: false,
                  textLines: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
