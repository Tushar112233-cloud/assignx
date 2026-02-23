import 'package:flutter/material.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';

/// Thin colored status banner strip.
class StatusBanner extends StatelessWidget {
  final ProjectStatus status;
  final String? customText;

  const StatusBanner({
    super.key,
    required this.status,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: status.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            status.icon,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            customText ?? _getStatusText(),
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (status) {
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.submitted:
        return 'Submitted for Review';
      case ProjectStatus.analyzing:
        return 'Analyzing Requirements';
      case ProjectStatus.quoted:
        return 'Quote Ready';
      case ProjectStatus.paymentPending:
        return 'Payment Required';
      case ProjectStatus.paid:
        return 'Payment Received';
      case ProjectStatus.assigning:
        return 'Finding Expert';
      case ProjectStatus.assigned:
        return 'Expert Assigned';
      case ProjectStatus.inProgress:
        return 'In Progress - On Track';
      case ProjectStatus.submittedForQc:
        return 'Submitted for QC';
      case ProjectStatus.qcInProgress:
        return 'Quality Check in Progress';
      case ProjectStatus.qcApproved:
        return 'Quality Check Passed';
      case ProjectStatus.qcRejected:
        return 'Quality Check Failed';
      case ProjectStatus.delivered:
        return 'Ready for Review';
      case ProjectStatus.revisionRequested:
        return 'Revision Requested';
      case ProjectStatus.inRevision:
        return 'Making Revisions';
      case ProjectStatus.completed:
        return 'Successfully Completed';
      case ProjectStatus.autoApproved:
        return 'Auto-Approved';
      case ProjectStatus.cancelled:
        return 'Project Cancelled';
      case ProjectStatus.refunded:
        return 'Payment Refunded';
    }
  }
}
