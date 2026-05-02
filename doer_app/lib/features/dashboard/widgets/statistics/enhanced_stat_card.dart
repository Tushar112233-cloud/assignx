/// Enhanced stat card widget for statistics screen.
///
/// Card with icon, title, value, subtitle, and optional trend indicator.
/// Supports four color variants: teal, blue, purple, orange.
library;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Color variant for the enhanced stat card.
enum StatCardVariant { teal, blue, purple, orange }

/// Enhanced stat card with glassmorphism effect and trend indicator.
class EnhancedStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final double? trend;
  final StatCardVariant variant;

  const EnhancedStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.variant = StatCardVariant.blue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _variantColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: colors.main.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: colors.main.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.main.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(icon, size: 18, color: colors.main),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: trend! >= 0
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusXs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend! >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 10,
                        color: trend! >= 0 ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${trend!.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: trend! >= 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colors.main,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  ({Color main, Color light}) get _variantColors {
    switch (variant) {
      case StatCardVariant.teal:
        return (main: const Color(0xFF14B8A6), light: const Color(0xFFCCFBF1));
      case StatCardVariant.blue:
        return (main: AppColors.accent, light: AppColors.infoLight);
      case StatCardVariant.purple:
        return (main: const Color(0xFF8B5CF6), light: const Color(0xFFEDE9FE));
      case StatCardVariant.orange:
        return (main: const Color(0xFFF97316), light: const Color(0xFFFFF7ED));
    }
  }
}
