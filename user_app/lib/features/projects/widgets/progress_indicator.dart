import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Progress bar showing completion percentage.
class ProjectProgressIndicator extends StatelessWidget {
  final int percent;
  final double height;
  final bool showLabel;
  final Color? backgroundColor;
  final Color? progressColor;

  const ProjectProgressIndicator({
    super.key,
    required this.percent,
    this.height = 6,
    this.showLabel = true,
    this.backgroundColor,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percent.clamp(0, 100);
    final bgColor = backgroundColor ?? AppColors.surfaceVariant;
    final fgColor = progressColor ?? _getColorForPercent(clampedPercent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$clampedPercent%',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(
            children: [
              // Background
              Container(
                height: height,
                width: double.infinity,
                color: bgColor,
              ),
              // Progress
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: height,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: clampedPercent / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          fgColor,
                          fgColor.withAlpha(200),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorForPercent(int percent) {
    if (percent >= 75) return AppColors.success;
    if (percent >= 50) return AppColors.primary;
    if (percent >= 25) return AppColors.warning;
    return AppColors.textTertiary;
  }
}

/// Circular progress indicator with percentage.
class CircularProgressWithLabel extends StatelessWidget {
  final int percent;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;

  const CircularProgressWithLabel({
    super.key,
    required this.percent,
    this.size = 60,
    this.strokeWidth = 6,
    this.backgroundColor,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percent.clamp(0, 100);
    final bgColor = backgroundColor ?? AppColors.surfaceVariant;
    final fgColor = progressColor ?? AppColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              color: bgColor,
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clampedPercent / 100,
              strokeWidth: strokeWidth,
              color: fgColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Percentage text
          Text(
            '$clampedPercent%',
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: size * 0.22,
              fontWeight: FontWeight.bold,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}
