library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_text_styles.dart';

/// Hero section for Pro Network with a premium dark navy/deep purple design.
///
/// Features a sophisticated gradient, professional stats, and action chips.
/// Visually distinct from Campus Connect's warm orange theme.
class ProNetworkHero extends StatelessWidget {
  final bool showAnimation;

  const ProNetworkHero({
    super.key,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dark gradient background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A), // Deep navy
                  Color(0xFF1E1B4B), // Dark indigo
                  Color(0xFF312E81), // Deep purple
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Decorative elements
          Positioned(
            top: -25,
            right: -15,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: -5,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                ),
              ),
            ),
          ),

          // Subtle grid/dot pattern
          Positioned(
            top: 15,
            right: 50,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF818CF8).withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 25,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF818CF8).withValues(alpha: 0.3),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 90,
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA78BFA).withValues(alpha: 0.4),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Pro Network" badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF818CF8)
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF818CF8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF818CF8)
                                        .withValues(alpha: 0.6),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PRO',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: const Color(0xFFC4B5FD),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 100.ms)
                          .slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        'Pro Network',
                        style: AppTextStyles.displayMedium.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 200.ms)
                          .slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Discover gigs, showcase skills, connect with professionals',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFA5B4FC),
                          height: 1.5,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 300.ms),
                      const SizedBox(height: 16),

                      // Quick action chips
                      _QuickActionChips()
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 400.ms)
                          .slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),

                // Animation or fallback icon
                if (showAnimation) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Lottie.asset(
                      'assets/animations/computer.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF818CF8)
                                  .withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.hub_rounded,
                            size: 36,
                            color: Color(0xFF818CF8),
                          ),
                        );
                      },
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick action chips row (Post, Saved).
class _QuickActionChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ActionChip(
          icon: Icons.add_circle_outline,
          label: 'Post',
          onTap: () => context.push('/pro-network/create'),
        ),
        _ActionChip(
          icon: Icons.bookmark_outline,
          label: 'Saved',
          onTap: () => context.push('/pro-network/saved'),
        ),
      ],
    );
  }
}

/// Individual action chip with glass-morphism styling on dark background.
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: const Color(0xFFC4B5FD)),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC4B5FD),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
