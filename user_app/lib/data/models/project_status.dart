import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Project status enum matching database project_status enum.
/// DB values: draft, submitted, analyzing, quoted, payment_pending, paid,
/// assigning, assigned, in_progress, submitted_for_qc, qc_in_progress,
/// qc_approved, qc_rejected, delivered, revision_requested, in_revision,
/// completed, auto_approved, cancelled, refunded
enum ProjectStatus {
  /// Initial draft state.
  draft,

  /// Project submitted by user.
  submitted,

  /// Project is being analyzed for quote.
  analyzing,

  /// Quote has been provided.
  quoted,

  /// Waiting for payment.
  paymentPending,

  /// Payment received.
  paid,

  /// Finding an expert to assign.
  assigning,

  /// Expert has been assigned.
  assigned,

  /// Expert is working on the project.
  inProgress,

  /// Work submitted for quality check.
  submittedForQc,

  /// Quality check in progress.
  qcInProgress,

  /// Quality check approved.
  qcApproved,

  /// Quality check rejected.
  qcRejected,

  /// Project delivered to user.
  delivered,

  /// User requested revisions.
  revisionRequested,

  /// Expert is working on revisions.
  inRevision,

  /// Project successfully completed.
  completed,

  /// Auto-approved after timeout.
  autoApproved,

  /// Project was cancelled.
  cancelled,

  /// Project was refunded.
  refunded,
}

/// Extension to add display properties and DB conversion to ProjectStatus.
extension ProjectStatusX on ProjectStatus {
  /// Mapping from DB string to enum for efficient lookup.
  static const _fromDbMap = {
    'draft': ProjectStatus.draft,
    'submitted': ProjectStatus.submitted,
    'analyzing': ProjectStatus.analyzing,
    'quoted': ProjectStatus.quoted,
    'payment_pending': ProjectStatus.paymentPending,
    'paid': ProjectStatus.paid,
    'assigning': ProjectStatus.assigning,
    'assigned': ProjectStatus.assigned,
    'in_progress': ProjectStatus.inProgress,
    'submitted_for_qc': ProjectStatus.submittedForQc,
    'qc_in_progress': ProjectStatus.qcInProgress,
    'qc_approved': ProjectStatus.qcApproved,
    'qc_rejected': ProjectStatus.qcRejected,
    'delivered': ProjectStatus.delivered,
    'revision_requested': ProjectStatus.revisionRequested,
    'in_revision': ProjectStatus.inRevision,
    'completed': ProjectStatus.completed,
    'auto_approved': ProjectStatus.autoApproved,
    'cancelled': ProjectStatus.cancelled,
    'refunded': ProjectStatus.refunded,
  };

  /// Mapping from enum to DB string.
  static const _toDbMap = {
    ProjectStatus.draft: 'draft',
    ProjectStatus.submitted: 'submitted',
    ProjectStatus.analyzing: 'analyzing',
    ProjectStatus.quoted: 'quoted',
    ProjectStatus.paymentPending: 'payment_pending',
    ProjectStatus.paid: 'paid',
    ProjectStatus.assigning: 'assigning',
    ProjectStatus.assigned: 'assigned',
    ProjectStatus.inProgress: 'in_progress',
    ProjectStatus.submittedForQc: 'submitted_for_qc',
    ProjectStatus.qcInProgress: 'qc_in_progress',
    ProjectStatus.qcApproved: 'qc_approved',
    ProjectStatus.qcRejected: 'qc_rejected',
    ProjectStatus.delivered: 'delivered',
    ProjectStatus.revisionRequested: 'revision_requested',
    ProjectStatus.inRevision: 'in_revision',
    ProjectStatus.completed: 'completed',
    ProjectStatus.autoApproved: 'auto_approved',
    ProjectStatus.cancelled: 'cancelled',
    ProjectStatus.refunded: 'refunded',
  };

  /// Display names for each status.
  static const _displayNames = {
    ProjectStatus.draft: 'Draft',
    ProjectStatus.submitted: 'Submitted',
    ProjectStatus.analyzing: 'Analyzing',
    ProjectStatus.quoted: 'Quoted',
    ProjectStatus.paymentPending: 'Payment Pending',
    ProjectStatus.paid: 'Paid',
    ProjectStatus.assigning: 'Assigning',
    ProjectStatus.assigned: 'Assigned',
    ProjectStatus.inProgress: 'In Progress',
    ProjectStatus.submittedForQc: 'Submitted for QC',
    ProjectStatus.qcInProgress: 'QC In Progress',
    ProjectStatus.qcApproved: 'QC Approved',
    ProjectStatus.qcRejected: 'QC Rejected',
    ProjectStatus.delivered: 'Delivered',
    ProjectStatus.revisionRequested: 'Revision Requested',
    ProjectStatus.inRevision: 'In Revision',
    ProjectStatus.completed: 'Completed',
    ProjectStatus.autoApproved: 'Auto Approved',
    ProjectStatus.cancelled: 'Cancelled',
    ProjectStatus.refunded: 'Refunded',
  };

  /// Descriptions for each status.
  static const _descriptions = {
    ProjectStatus.draft: 'Project saved as draft',
    ProjectStatus.submitted: 'Project submitted for review',
    ProjectStatus.analyzing: 'Analyzing Requirements...',
    ProjectStatus.quoted: 'Quote ready for review',
    ProjectStatus.paymentPending: 'Payment pending',
    ProjectStatus.paid: 'Payment received',
    ProjectStatus.assigning: 'Finding an expert...',
    ProjectStatus.assigned: 'Expert assigned',
    ProjectStatus.inProgress: 'Expert Working',
    ProjectStatus.submittedForQc: 'Submitted for quality check',
    ProjectStatus.qcInProgress: 'Quality check in progress',
    ProjectStatus.qcApproved: 'Quality check passed',
    ProjectStatus.qcRejected: 'Quality check failed',
    ProjectStatus.delivered: 'Files Uploaded - Action Required',
    ProjectStatus.revisionRequested: 'Changes Requested',
    ProjectStatus.inRevision: 'Working on revisions',
    ProjectStatus.completed: 'Successfully Completed',
    ProjectStatus.autoApproved: 'Auto-approved',
    ProjectStatus.cancelled: 'Project Cancelled',
    ProjectStatus.refunded: 'Payment Refunded',
  };

  /// Convert from database snake_case string to enum.
  static ProjectStatus fromString(String value) {
    return _fromDbMap[value] ?? ProjectStatus.draft;
  }

  /// Convert enum to database snake_case string.
  String toDbString() => _toDbMap[this]!;

  /// Display name for the status.
  String get displayName => _displayNames[this]!;

  /// Status description text.
  String get description => _descriptions[this]!;

  /// Color for the status badge.
  Color get color {
    switch (this) {
      case ProjectStatus.draft:
        return AppColors.textTertiary;
      case ProjectStatus.submitted:
      case ProjectStatus.quoted:
      case ProjectStatus.submittedForQc:
        return AppColors.info;
      case ProjectStatus.analyzing:
      case ProjectStatus.assigning:
      case ProjectStatus.qcInProgress:
      case ProjectStatus.inRevision:
        return AppColors.warning;
      case ProjectStatus.paymentPending:
        return const Color(0xFFEA580C);
      case ProjectStatus.paid:
      case ProjectStatus.qcApproved:
      case ProjectStatus.delivered:
      case ProjectStatus.completed:
      case ProjectStatus.autoApproved:
        return AppColors.success;
      case ProjectStatus.assigned:
      case ProjectStatus.inProgress:
        return AppColors.primary;
      case ProjectStatus.qcRejected:
      case ProjectStatus.revisionRequested:
        return AppColors.error;
      case ProjectStatus.cancelled:
      case ProjectStatus.refunded:
        return AppColors.textTertiary;
    }
  }

  /// Icon for the status.
  IconData get icon {
    switch (this) {
      case ProjectStatus.draft:
        return Icons.edit_outlined;
      case ProjectStatus.submitted:
        return Icons.send_outlined;
      case ProjectStatus.analyzing:
        return Icons.hourglass_empty;
      case ProjectStatus.quoted:
        return Icons.request_quote_outlined;
      case ProjectStatus.paymentPending:
        return Icons.payment_outlined;
      case ProjectStatus.paid:
        return Icons.paid_outlined;
      case ProjectStatus.assigning:
        return Icons.person_search_outlined;
      case ProjectStatus.assigned:
        return Icons.person_outlined;
      case ProjectStatus.inProgress:
        return Icons.engineering_outlined;
      case ProjectStatus.submittedForQc:
        return Icons.fact_check_outlined;
      case ProjectStatus.qcInProgress:
        return Icons.pending_outlined;
      case ProjectStatus.qcApproved:
        return Icons.verified_outlined;
      case ProjectStatus.qcRejected:
      case ProjectStatus.cancelled:
        return Icons.cancel_outlined;
      case ProjectStatus.delivered:
        return Icons.rate_review_outlined;
      case ProjectStatus.revisionRequested:
        return Icons.edit_note_outlined;
      case ProjectStatus.inRevision:
        return Icons.build_outlined;
      case ProjectStatus.completed:
        return Icons.check_circle_outline;
      case ProjectStatus.autoApproved:
        return Icons.auto_awesome_outlined;
      case ProjectStatus.refunded:
        return Icons.money_off_outlined;
    }
  }

  /// Which tab this status belongs to (for UI filtering).
  int get tabIndex {
    switch (this) {
      case ProjectStatus.draft:
      case ProjectStatus.submitted:
      case ProjectStatus.analyzing:
      case ProjectStatus.quoted:
      case ProjectStatus.paymentPending:
        return 0; // In Review / Pending
      case ProjectStatus.paid:
      case ProjectStatus.assigning:
      case ProjectStatus.assigned:
      case ProjectStatus.inProgress:
      case ProjectStatus.submittedForQc:
      case ProjectStatus.qcInProgress:
      case ProjectStatus.qcApproved:
      case ProjectStatus.qcRejected:
      case ProjectStatus.revisionRequested:
      case ProjectStatus.inRevision:
        return 1; // In Progress
      case ProjectStatus.delivered:
        return 2; // For Review
      case ProjectStatus.completed:
      case ProjectStatus.autoApproved:
      case ProjectStatus.cancelled:
      case ProjectStatus.refunded:
        return 3; // History
    }
  }

  /// Whether the project is in an active state (not completed/cancelled).
  bool get isActive {
    return this != ProjectStatus.completed &&
        this != ProjectStatus.autoApproved &&
        this != ProjectStatus.cancelled &&
        this != ProjectStatus.refunded;
  }

  /// Whether the project requires user action.
  bool get requiresUserAction {
    return this == ProjectStatus.quoted ||
        this == ProjectStatus.paymentPending ||
        this == ProjectStatus.delivered;
  }
}
