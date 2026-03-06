import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_text_styles.dart';
import 'live_stats_badge.dart';

/// Enhanced hero section for Campus Connect matching the web platform.
///
/// Features:
/// - "Campus Connect" badge at top
/// - "Your Campus is BUZZING" animated text with shimmer effect
/// - LiveStatsBadge row with real-time community stats
/// - Description text about the platform
/// - "Verify College to Post" CTA button
/// - Vibrant warm orange-to-red gradient background with decorative elements
class CampusConnectHero extends StatelessWidget {
  /// Callback when the verify college CTA is tapped.
  final VoidCallback? onVerifyCollege;

  const CampusConnectHero({
    super.key,
    this.onVerifyCollege,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withAlpha(30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background gradient
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF6B35), // Vibrant orange
                  Color(0xFFFF4444), // Warm red
                  Color(0xFFE91E63), // Pink-red
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Decorative circle elements for depth
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // "Campus Connect" badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4ADE80),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.hub_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Campus Connect',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 100.ms)
                    .slideY(begin: -0.3, end: 0),
                const SizedBox(height: 20),

                // Animated "Your Campus is BUZZING" text
                Column(
                  children: [
                    Text(
                      'Your Campus is',
                      style: AppTextStyles.displaySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                      effects: [
                        ShimmerEffect(
                          duration: 2500.ms,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ],
                      child: Text(
                        'BUZZING',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 36,
                          height: 1.1,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 20),

                // Live stats badges
                const LiveStatsBadge()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms),
                const SizedBox(height: 16),

                // Description text
                Text(
                  'Join conversations, discover opportunities, and connect with students across 500+ colleges',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.6,
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 500.ms),
                const SizedBox(height: 20),

                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: onVerifyCollege,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFF4444),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4444)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              size: 18,
                              color: Color(0xFFFF4444),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Verify College to Post',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: const Color(0xFFFF4444),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 600.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header bar for Campus Connect - DEPRECATED, use DashboardAppBar instead.
/// Kept for backward compatibility but should not be used.
class CampusConnectHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final double walletBalance;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onWalletTap;

  const CampusConnectHeader({
    super.key,
    this.walletBalance = 10100,
    this.onNotificationTap,
    this.onWalletTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    // Return empty container - use DashboardAppBar instead
    return const SizedBox.shrink();
  }
}
