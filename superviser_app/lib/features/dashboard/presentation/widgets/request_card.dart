/// Request card widgets for displaying project requests.
///
/// This file contains:
/// - [RequestCard]: Full-featured card for displaying request details
/// - [CompactRequestCard]: Simplified list tile version for compact displays
///
/// These widgets are used throughout the dashboard to display project
/// requests with varying levels of detail.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/request_model.dart';
import 'field_filter.dart';

/// A card widget for displaying project request details.
///
/// Shows comprehensive request information including:
/// - Subject tag
/// - Title and description
/// - Deadline with urgency indication
/// - Client name and requirements (word/page count)
/// - Price tag (if quoted)
/// - Optional action button
///
/// ## Usage
///
/// ```dart
/// RequestCard(
///   request: myRequest,
///   onTap: () => viewDetails(myRequest),
///   actionLabel: 'Quote',
///   onAction: () => showQuoteForm(myRequest),
/// )
/// ```
///
/// See also:
/// - [CompactRequestCard] for a simpler list tile version
/// - [RequestModel] for the data model
/// - [_DeadlineChip] for deadline display
class RequestCard extends StatelessWidget {
  /// Creates a new [RequestCard] instance.
  ///
  /// Required parameters:
  /// - [request]: The request data to display
  /// - [onTap]: Callback when the card is tapped
  ///
  /// Optional parameters:
  /// - [actionLabel]: Label for the action button (e.g., "Quote")
  /// - [onAction]: Callback when the action button is pressed
  const RequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.actionLabel,
    this.onAction,
  });

  /// The request data to display.
  final RequestModel request;

  /// Callback invoked when the card is tapped.
  ///
  /// Typically used to navigate to request details.
  final VoidCallback onTap;

  /// Label for the action button.
  ///
  /// If null, no action button is displayed.
  final String? actionLabel;

  /// Callback invoked when the action button is pressed.
  ///
  /// Only used if [actionLabel] is not null.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SubjectTag(subject: request.subject),
                        const SizedBox(height: 8),
                        Text(
                          request.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Deadline chip
                  _DeadlineChip(
                    deadline: request.formattedDeadline,
                    isUrgent: request.isUrgent,
                    isOverdue: request.isOverdue,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                request.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Footer row
              Row(
                children: [
                  // Client info
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request.clientName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                  // Word/Page count
                  if (request.wordCount != null || request.pageCount != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatRequirements(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                  const Spacer(),
                  // Quote/Price
                  if (request.userQuote != null)
                    _PriceTag(
                      price: request.userQuote!,
                      isPaid: request.isPaid,
                    ),
                ],
              ),
              // Action button
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(actionLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Formats the word/page count requirements as a string.
  ///
  /// Returns a string like "2000 words / 10 pages" or just one
  /// if only one is specified.
  String _formatRequirements() {
    final parts = <String>[];
    if (request.wordCount != null) {
      parts.add('${request.wordCount} words');
    }
    if (request.pageCount != null) {
      parts.add('${request.pageCount} pages');
    }
    return parts.join(' / ');
  }
}

/// Deadline chip widget with urgency indication.
///
/// Displays the formatted deadline with color-coded urgency:
/// - Red for overdue
/// - Orange for urgent (less than 24 hours)
/// - Gray for normal
class _DeadlineChip extends StatelessWidget {
  /// Creates a new [_DeadlineChip] instance.
  const _DeadlineChip({
    required this.deadline,
    required this.isUrgent,
    required this.isOverdue,
  });

  /// Formatted deadline string (e.g., "2d 5h").
  final String deadline;

  /// Whether the deadline is urgent (< 24 hours).
  final bool isUrgent;

  /// Whether the deadline has passed.
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final color = isOverdue
        ? AppColors.error
        : isUrgent
            ? Colors.orange
            : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            deadline,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Price tag widget for displaying quoted amounts.
///
/// Shows the price with different styling based on payment status:
/// - Green with checkmark if paid
/// - Primary color if quoted but unpaid
class _PriceTag extends StatelessWidget {
  /// Creates a new [_PriceTag] instance.
  const _PriceTag({
    required this.price,
    this.isPaid = false,
  });

  /// The price amount to display.
  final double price;

  /// Whether the price has been paid.
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPaid) ...[
            Icon(
              Icons.check_circle,
              size: 14,
              color: AppColors.success,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '₹${price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isPaid ? AppColors.success : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

/// Compact request card for list views.
///
/// A simplified version of [RequestCard] using [ListTile] for
/// more compact display in lists.
///
/// Shows:
/// - Status icon in a colored avatar
/// - Title
/// - Client name and deadline
/// - Status text
///
/// ## Usage
///
/// ```dart
/// CompactRequestCard(
///   request: myRequest,
///   onTap: () => viewDetails(myRequest),
/// )
/// ```
///
/// See also:
/// - [RequestCard] for full-featured display
class CompactRequestCard extends StatelessWidget {
  /// Creates a new [CompactRequestCard] instance.
  const CompactRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  /// The request data to display.
  final RequestModel request;

  /// Callback invoked when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _getStatusColor().withValues(alpha: 0.1),
        child: Icon(
          _getStatusIcon(),
          color: _getStatusColor(),
          size: 20,
        ),
      ),
      title: Text(
        request.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${request.clientName} • ${request.formattedDeadline}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
      ),
      trailing: Text(
        request.status.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  /// Returns the color associated with the current status.
  ///
  /// Color coding:
  /// - Blue: Draft, Submitted
  /// - Orange: Analyzing, Quoted, Payment Pending
  /// - Green: Paid, QC Approved, Delivered, Completed
  /// - Purple: Assigned
  /// - Teal: In Progress, In Revision
  /// - Amber: QC-related statuses
  /// - Red: Rejected, Cancelled, Refunded
  Color _getStatusColor() {
    switch (request.status) {
      case ProjectStatus.draft:
      case ProjectStatus.submitted:
        return Colors.blue;
      case ProjectStatus.analyzing:
      case ProjectStatus.quoted:
      case ProjectStatus.paymentPending:
        return Colors.orange;
      case ProjectStatus.paid:
      case ProjectStatus.assigning:
        return AppColors.success;
      case ProjectStatus.assigned:
        return Colors.purple;
      case ProjectStatus.inProgress:
      case ProjectStatus.inRevision:
        return Colors.teal;
      case ProjectStatus.submittedForQc:
      case ProjectStatus.qcInProgress:
      case ProjectStatus.revisionRequested:
        return Colors.amber;
      case ProjectStatus.qcApproved:
      case ProjectStatus.delivered:
      case ProjectStatus.completed:
      case ProjectStatus.autoApproved:
        return AppColors.success;
      case ProjectStatus.qcRejected:
      case ProjectStatus.cancelled:
      case ProjectStatus.refunded:
        return AppColors.error;
    }
  }

  /// Returns the icon associated with the current status.
  ///
  /// Each status has a unique icon representing its meaning.
  IconData _getStatusIcon() {
    switch (request.status) {
      case ProjectStatus.draft:
        return Icons.edit_note;
      case ProjectStatus.submitted:
        return Icons.fiber_new;
      case ProjectStatus.analyzing:
        return Icons.analytics;
      case ProjectStatus.quoted:
        return Icons.request_quote;
      case ProjectStatus.paymentPending:
        return Icons.hourglass_empty;
      case ProjectStatus.paid:
        return Icons.payment;
      case ProjectStatus.assigning:
        return Icons.person_search;
      case ProjectStatus.assigned:
        return Icons.person_add;
      case ProjectStatus.inProgress:
      case ProjectStatus.inRevision:
        return Icons.pending;
      case ProjectStatus.submittedForQc:
      case ProjectStatus.qcInProgress:
        return Icons.rate_review;
      case ProjectStatus.qcApproved:
        return Icons.verified;
      case ProjectStatus.qcRejected:
        return Icons.error_outline;
      case ProjectStatus.delivered:
        return Icons.local_shipping;
      case ProjectStatus.revisionRequested:
        return Icons.replay;
      case ProjectStatus.completed:
      case ProjectStatus.autoApproved:
        return Icons.check_circle;
      case ProjectStatus.cancelled:
      case ProjectStatus.refunded:
        return Icons.cancel;
    }
  }
}
