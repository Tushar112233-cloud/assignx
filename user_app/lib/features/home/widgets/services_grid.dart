import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/service_model.dart';
import '../../../shared/animations/common_animations.dart';
import '../../../shared/decorations/app_gradients.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// 2x2 grid of services on home screen.
///
/// Uses the new UI polish system with:
/// - AppShadows for elevation and hover states
/// - TapScaleContainer for press animations
/// - Staggered animations for entrance
/// - AppGradients for subtle background overlays
class ServicesGrid extends StatelessWidget {
  /// Whether to show loading skeletons.
  final bool isLoading;

  const ServicesGrid({
    super.key,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final services = ServiceItem.homeServices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Services',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isLoading
              ? _buildSkeletonGrid()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return StaggeredAnimationBuilder(
                      index: index,
                      type: StaggeredAnimationType.fadeSlideUp,
                      staggerDelay: const Duration(milliseconds: 80),
                      child: _ServiceCard(service: services[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => const _ServiceCardSkeleton(),
    );
  }
}

/// Service card with hover effects and press animation.
class _ServiceCard extends StatefulWidget {
  final ServiceItem service;

  const _ServiceCard({required this.service});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return TapScaleContainer(
      onTap: service.isAvailable
          ? () => context.push(service.route)
          : null,
      pressedScale: 0.96,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.borderRadiusLg,
            border: Border.all(
              color: _isHovered && service.isAvailable
                  ? AppColors.primary.withAlpha(50)
                  : AppColors.border,
              width: _isHovered && service.isAvailable ? 1.5 : 1,
            ),
            boxShadow: _isHovered && service.isAvailable
                ? AppShadows.cardHover
                : AppShadows.md,
          ),
          child: Stack(
            children: [
              // Subtle gradient overlay when hovered
              if (_isHovered && service.isAvailable)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: AppSpacing.borderRadiusLg,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withAlpha(8),
                            AppColors.accent.withAlpha(5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon with animated container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: service.isAvailable
                          ? (_isHovered
                              ? AppColors.primary.withAlpha(40)
                              : AppColors.primary.withAlpha(25))
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _isHovered && service.isAvailable
                          ? AppShadows.xs
                          : null,
                    ),
                    child: Icon(
                      service.icon,
                      color: service.isAvailable
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      size: 24,
                    ),
                  ),

                  const Spacer(),

                  // Title
                  Text(
                    service.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: service.isAvailable
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Subtitle
                  Text(
                    service.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              // Badge with animation
              if (service.badge != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: service.badge == 'FREE'
                          ? AppGradients.success
                          : AppGradients.warning,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _isHovered ? AppShadows.sm : AppShadows.xs,
                    ),
                    child: Text(
                      service.badge!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Disabled overlay
              if (!service.isAvailable)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withAlpha(128),
                      borderRadius: AppSpacing.borderRadiusLg,
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Coming Soon',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton loader for service cards.
class _ServiceCardSkeleton extends StatelessWidget {
  const _ServiceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon skeleton
          const SkeletonLoader(
            width: 44,
            height: 44,
            borderRadius: 12,
          ),
          const Spacer(),
          // Title skeleton
          const SkeletonLoader(
            width: 80,
            height: 16,
          ),
          const SizedBox(height: 6),
          // Subtitle skeleton
          const SkeletonLoader(
            width: 100,
            height: 12,
          ),
        ],
      ),
    );
  }
}

/// Public skeleton widget for external use.
class ServicesGridSkeleton extends StatelessWidget {
  const ServicesGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServicesGrid(isLoading: true);
  }
}
