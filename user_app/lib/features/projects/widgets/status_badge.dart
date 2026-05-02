import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';

/// Color-coded status badge pill.
class StatusBadge extends StatelessWidget {
  final ProjectStatus status;
  final bool showIcon;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: ${status.displayName}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: status.color.withAlpha(25),
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          border: Border.all(
            color: status.color.withAlpha(50),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                status.icon,
                size: compact ? 12 : 14,
                color: status.color,
                semanticLabel: null, // Label handled by parent Semantics
              ),
              SizedBox(width: compact ? 4 : 6),
            ],
            Text(
              status.displayName,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: status.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Larger status badge with description.
class StatusBadgeLarge extends StatelessWidget {
  final ProjectStatus status;
  final String? customDescription;

  const StatusBadgeLarge({
    super.key,
    required this.status,
    this.customDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: ${status.displayName}, ${customDescription ?? status.description}',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: status.color.withAlpha(20),
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: status.color.withAlpha(50),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: status.color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                status.icon,
                size: 20,
                color: status.color,
                semanticLabel: null, // Label handled by parent Semantics
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.displayName,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: status.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customDescription ?? status.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: status.color.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
