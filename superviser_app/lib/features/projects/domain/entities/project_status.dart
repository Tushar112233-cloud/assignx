import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Enum representing all possible project statuses.
///
/// Follows the 20-state project lifecycle defined in the system.
enum ProjectStatus {
  /// Initial submission by client
  submitted('submitted', 'Submitted', Icons.inbox),

  /// Supervisor analyzing requirements
  analyzing('analyzing', 'Analyzing', Icons.analytics),

  /// Quote sent to client
  quoted('quoted', 'Quoted', Icons.request_quote),

  /// Client accepted quote
  accepted('accepted', 'Accepted', Icons.thumb_up),

  /// Awaiting payment
  paymentPending('payment_pending', 'Payment Pending', Icons.payment),

  /// Payment received
  paid('paid', 'Paid', Icons.check_circle),

  /// Ready for doer assignment
  readyToAssign('ready_to_assign', 'Ready to Assign', Icons.assignment_ind),

  /// Doer assigned
  assigned('assigned', 'Assigned', Icons.person_add),

  /// Work in progress
  inProgress('in_progress', 'In Progress', Icons.pending),

  /// Work delivered by doer
  delivered('delivered', 'Delivered', Icons.send),

  /// Under QC review by supervisor
  forReview('for_review', 'For Review', Icons.rate_review),

  /// Revision requested
  revisionRequested('revision_requested', 'Revision Requested', Icons.replay),

  /// Doer working on revision
  inRevision('in_revision', 'In Revision', Icons.edit_note),

  /// Approved by supervisor
  approved('approved', 'Approved', Icons.verified),

  /// Delivered to client
  deliveredToClient('delivered_to_client', 'Delivered', Icons.local_shipping),

  /// Client reviewing
  clientReview('client_review', 'Client Review', Icons.preview),

  /// Client requested changes
  clientRevision('client_revision', 'Client Revision', Icons.refresh),

  /// Project completed
  completed('completed', 'Completed', Icons.check_circle_outline),

  /// Project cancelled
  cancelled('cancelled', 'Cancelled', Icons.cancel),

  /// Project refunded
  refunded('refunded', 'Refunded', Icons.money_off);

  const ProjectStatus(this.value, this.displayName, this.icon);

  /// Database value
  final String value;

  /// Human-readable name
  final String displayName;

  /// Associated icon
  final IconData icon;

  /// Creates status from string value.
  static ProjectStatus fromString(String? value) {
    if (value == null) return ProjectStatus.submitted;
    return ProjectStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ProjectStatus.submitted,
    );
  }

  /// Gets the color associated with this status.
  Color get color {
    switch (this) {
      case ProjectStatus.submitted:
      case ProjectStatus.analyzing:
        return Colors.amber;
      case ProjectStatus.quoted:
      case ProjectStatus.accepted:
      case ProjectStatus.paymentPending:
        return Colors.orange;
      case ProjectStatus.paid:
      case ProjectStatus.readyToAssign:
        return AppColors.success;
      case ProjectStatus.assigned:
      case ProjectStatus.inProgress:
        return Colors.blue;
      case ProjectStatus.delivered:
      case ProjectStatus.forReview:
        return Colors.teal;
      case ProjectStatus.revisionRequested:
      case ProjectStatus.inRevision:
      case ProjectStatus.clientRevision:
        return Colors.deepOrange;
      case ProjectStatus.approved:
      case ProjectStatus.deliveredToClient:
      case ProjectStatus.clientReview:
        return Colors.purple;
      case ProjectStatus.completed:
        return AppColors.success;
      case ProjectStatus.cancelled:
      case ProjectStatus.refunded:
        return AppColors.error;
    }
  }

  /// Whether this status represents an active project.
  bool get isActive {
    return [
      ProjectStatus.assigned,
      ProjectStatus.inProgress,
      ProjectStatus.delivered,
      ProjectStatus.inRevision,
    ].contains(this);
  }

  /// Whether this status requires supervisor action.
  bool get requiresAction {
    return [
      ProjectStatus.submitted,
      ProjectStatus.forReview,
      ProjectStatus.delivered,
    ].contains(this);
  }

  /// Whether this status is a review status.
  bool get isForReview {
    return [
      ProjectStatus.delivered,
      ProjectStatus.forReview,
    ].contains(this);
  }

  /// Whether this status is final.
  bool get isFinal {
    return [
      ProjectStatus.completed,
      ProjectStatus.cancelled,
      ProjectStatus.refunded,
    ].contains(this);
  }
}
