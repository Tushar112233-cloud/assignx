/// Moderation Dialog Widget
///
/// Shows a dialog when content moderation detects personal information
/// sharing attempts. Provides user-friendly feedback about violations
/// and allows them to dismiss or edit their message.
library;

import 'package:flutter/material.dart';
import '../../core/services/moderation_service.dart';
import '../../core/constants/app_colors.dart';
import 'glass_container.dart';

/// Dialog shown when content moderation blocks a message.
///
/// Displays violation details and provides options to dismiss
/// or edit the message.
class ModerationDialog extends StatelessWidget {
  /// The moderation result containing violation details.
  final ModerationResult result;

  /// Callback when user dismisses the dialog.
  final VoidCallback? onDismiss;

  /// Callback when user wants to edit their message.
  final VoidCallback? onEdit;

  /// Optional user violation summary for showing warning level.
  final UserViolationSummary? userSummary;

  const ModerationDialog({
    super.key,
    required this.result,
    this.onDismiss,
    this.onEdit,
    this.userSummary,
  });

  /// Show the moderation dialog.
  static Future<void> show(
    BuildContext context, {
    required ModerationResult result,
    VoidCallback? onDismiss,
    VoidCallback? onEdit,
    UserViolationSummary? userSummary,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ModerationDialog(
        result: result,
        onDismiss: onDismiss,
        onEdit: onEdit,
        userSummary: userSummary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              _buildWarningIcon(),
              const SizedBox(height: 20),

              // Title
              Text(
                _getTitle(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getSeverityColor(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                result.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Violations list
              if (result.violations.isNotEmpty) ...[
                _buildViolationsList(context),
                const SizedBox(height: 16),
              ],

              // Warning level indicator
              if (userSummary != null) ...[
                _buildWarningLevelIndicator(context),
                const SizedBox(height: 20),
              ],

              // Buttons
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningIcon() {
    IconData icon;
    Color color = _getSeverityColor();

    switch (result.severity) {
      case ModerationSeverity.high:
        icon = Icons.dangerous_outlined;
        break;
      case ModerationSeverity.medium:
        icon = Icons.warning_amber_rounded;
        break;
      case ModerationSeverity.low:
        icon = Icons.info_outline;
        break;
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 40, color: color),
    );
  }

  String _getTitle() {
    switch (result.severity) {
      case ModerationSeverity.high:
        return 'Message Blocked';
      case ModerationSeverity.medium:
        return 'Content Not Allowed';
      case ModerationSeverity.low:
        return 'Personal Info Detected';
    }
  }

  Color _getSeverityColor() {
    switch (result.severity) {
      case ModerationSeverity.high:
        return Colors.red;
      case ModerationSeverity.medium:
        return Colors.orange;
      case ModerationSeverity.low:
        return Colors.amber;
    }
  }

  Widget _buildViolationsList(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final violationTypes = result.violationTypes;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withAlpha(13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detected:',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? Colors.white54 : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: violationTypes.map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSeverityColor().withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getSeverityColor().withAlpha(77),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getViolationIcon(type),
                      size: 14,
                      color: _getSeverityColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getSeverityColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getViolationIcon(ViolationType type) {
    switch (type) {
      case ViolationType.phone:
        return Icons.phone_outlined;
      case ViolationType.email:
        return Icons.email_outlined;
      case ViolationType.socialMedia:
        return Icons.tag;
      case ViolationType.address:
        return Icons.location_on_outlined;
      case ViolationType.link:
        return Icons.link;
      case ViolationType.messagingApp:
        return Icons.chat_bubble_outline;
    }
  }

  Widget _buildWarningLevelIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final summary = userSummary!;

    String warningText;
    Color warningColor;

    switch (summary.warningLevel) {
      case WarningLevel.none:
      case WarningLevel.first:
        warningText = 'First Warning';
        warningColor = Colors.amber;
        break;
      case WarningLevel.second:
        warningText = 'Second Warning';
        warningColor = Colors.orange;
        break;
      case WarningLevel.final_:
        warningText = 'Final Warning';
        warningColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: warningColor.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: warningColor.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_rounded, size: 18, color: warningColor),
          const SizedBox(width: 8),
          Text(
            warningText,
            style: theme.textTheme.labelMedium?.copyWith(
              color: warningColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (summary.totalViolations > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: warningColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${summary.totalViolations}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onEdit?.call();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Edit Message'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('OK, Got it'),
          ),
        ),
      ],
    );
  }
}

/// Inline warning widget for showing moderation feedback while typing.
class ModerationWarningBanner extends StatelessWidget {
  /// The moderation result.
  final ModerationResult result;

  /// Whether to show in compact mode.
  final bool compact;

  const ModerationWarningBanner({
    super.key,
    required this.result,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (result.allowed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final color = _getSeverityColor();

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_rounded, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Contains ${result.violationTypes.map((t) => t.displayName).join(", ")}',
                style: theme.textTheme.labelSmall?.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Personal info detected',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  result.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.withAlpha(204),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor() {
    switch (result.severity) {
      case ModerationSeverity.high:
        return Colors.red;
      case ModerationSeverity.medium:
        return Colors.orange;
      case ModerationSeverity.low:
        return Colors.amber;
    }
  }
}

/// Rate limited overlay shown when user is blocked from sending.
class RateLimitedOverlay extends StatelessWidget {
  /// The user violation summary.
  final UserViolationSummary summary;

  /// Callback when user acknowledges.
  final VoidCallback? onAcknowledge;

  const RateLimitedOverlay({
    super.key,
    required this.summary,
    this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.black54,
      child: Center(
        child: GlassContainer(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Temporarily Restricted',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'You have been temporarily restricted from sending messages due to repeated policy violations.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again later or contact support if you believe this is an error.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      onAcknowledge?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('I Understand'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
