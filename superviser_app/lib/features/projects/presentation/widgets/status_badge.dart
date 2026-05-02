import 'package:flutter/material.dart';
import '../../domain/entities/project_status.dart';

/// Badge widget for displaying project status.
///
/// Automatically colored based on status type.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
    this.showIcon = true,
  });

  /// The project status
  final ProjectStatus status;

  /// Whether to use compact layout
  final bool compact;

  /// Whether to show the status icon
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          status.displayName,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: status.color,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              status.icon,
              size: 14,
              color: status.color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            status.displayName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// A larger status indicator with description.
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({
    super.key,
    required this.status,
    this.description,
  });

  final ProjectStatus status;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              status.icon,
              color: status.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: status.color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: status.color.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Status progress timeline.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({
    super.key,
    required this.currentStatus,
    this.showAll = false,
  });

  final ProjectStatus currentStatus;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    final statuses = showAll
        ? ProjectStatus.values.where((s) => !s.isFinal).toList()
        : [
            ProjectStatus.submitted,
            ProjectStatus.quoted,
            ProjectStatus.paid,
            ProjectStatus.assigned,
            ProjectStatus.inProgress,
            ProjectStatus.forReview,
            ProjectStatus.completed,
          ];

    final currentIndex = statuses.indexOf(currentStatus);

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isCompleted = index < currentIndex;
          final isCurrent = index == currentIndex;

          return Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? status.color
                          : Colors.grey.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check
                          : isCurrent
                              ? status.icon
                              : Icons.circle_outlined,
                      color: isCompleted || isCurrent
                          ? Colors.white
                          : Colors.grey,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.displayName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isCurrent
                              ? status.color
                              : isCompleted
                                  ? Colors.grey
                                  : Colors.grey.withValues(alpha: 0.5),
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          fontSize: 10,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (index < statuses.length - 1)
                Container(
                  width: 24,
                  height: 2,
                  color: isCompleted
                      ? status.color
                      : Colors.grey.withValues(alpha: 0.2),
                ),
            ],
          );
        },
      ),
    );
  }
}
