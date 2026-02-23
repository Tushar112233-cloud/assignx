import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Support ticket status enum.
enum TicketStatus {
  open('open', 'Open', AppColors.info, AppColors.infoLight),
  pending('pending', 'Pending', AppColors.warning, AppColors.warningLight),
  resolved('resolved', 'Resolved', AppColors.success, AppColors.successLight),
  closed('closed', 'Closed', AppColors.archived, Color(0xFFF3F4F6));

  final String dbValue;
  final String label;
  final Color color;
  final Color backgroundColor;

  const TicketStatus(this.dbValue, this.label, this.color, this.backgroundColor);

  /// Create from database string value.
  static TicketStatus fromDbValue(String? value) {
    switch (value?.toLowerCase()) {
      case 'open':
        return TicketStatus.open;
      case 'pending':
      case 'in_progress':
        return TicketStatus.pending;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }
}

/// Support ticket category enum.
enum TicketCategory {
  paymentIssue('payment_issue', 'Payment Issue'),
  projectRelated('project_related', 'Project Related'),
  technicalProblem('technical_problem', 'Technical Problem'),
  accountIssue('account_issue', 'Account Issue'),
  refundRequest('refund_request', 'Refund Request'),
  other('other', 'Other');

  final String dbValue;
  final String label;

  const TicketCategory(this.dbValue, this.label);

  /// Create from database string value.
  static TicketCategory fromDbValue(String? value) {
    switch (value?.toLowerCase()) {
      case 'payment_issue':
      case 'payment issue':
        return TicketCategory.paymentIssue;
      case 'project_related':
      case 'project related':
        return TicketCategory.projectRelated;
      case 'technical_problem':
      case 'technical problem':
        return TicketCategory.technicalProblem;
      case 'account_issue':
      case 'account issue':
        return TicketCategory.accountIssue;
      case 'refund_request':
      case 'refund request':
        return TicketCategory.refundRequest;
      default:
        return TicketCategory.other;
    }
  }
}

/// Support ticket response model.
class TicketResponse {
  final String id;
  final String ticketId;
  final String? responderId;
  final String message;
  final bool isStaffResponse;
  final DateTime createdAt;

  const TicketResponse({
    required this.id,
    required this.ticketId,
    this.responderId,
    required this.message,
    this.isStaffResponse = false,
    required this.createdAt,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      responderId: json['responder_id'] as String?,
      message: json['message'] as String? ?? '',
      isStaffResponse: json['is_staff_response'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'responder_id': responderId,
      'message': message,
      'is_staff_response': isStaffResponse,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Support ticket model.
class SupportTicket {
  final String id;
  final String userId;
  final String subject;
  final String description;
  final TicketCategory category;
  final TicketStatus status;
  final List<TicketResponse> responses;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.category,
    this.status = TicketStatus.open,
    this.responses = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get truncated ticket ID for display.
  String get displayId => id.length > 8 ? '#${id.substring(0, 8).toUpperCase()}' : '#$id';

  /// Get formatted created date string.
  String get createdDateString {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Get formatted updated date string.
  String get updatedDateString {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
    }
  }

  /// Check if ticket can accept new responses.
  bool get isActive => status == TicketStatus.open || status == TicketStatus.pending;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    // Parse responses if available
    List<TicketResponse> responses = [];
    if (json['responses'] != null && json['responses'] is List) {
      responses = (json['responses'] as List)
          .map((r) => TicketResponse.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return SupportTicket(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: TicketCategory.fromDbValue(json['category'] as String?),
      status: TicketStatus.fromDbValue(json['status'] as String?),
      responses: responses,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject': subject,
      'description': description,
      'category': category.dbValue,
      'status': status.dbValue,
      'responses': responses.map((r) => r.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SupportTicket copyWith({
    String? id,
    String? userId,
    String? subject,
    String? description,
    TicketCategory? category,
    TicketStatus? status,
    List<TicketResponse>? responses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      responses: responses ?? this.responses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
