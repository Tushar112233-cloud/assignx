import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Support ticket status.
enum TicketStatus {
  open,
  inProgress,
  waitingForReply,
  resolved,
  closed,
}

/// Extension for ticket status properties.
extension TicketStatusExtension on TicketStatus {
  String get displayName {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.waitingForReply:
        return 'Waiting for Reply';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.open:
        return AppColors.warning;
      case TicketStatus.inProgress:
        return AppColors.info;
      case TicketStatus.waitingForReply:
        return AppColors.secondary;
      case TicketStatus.resolved:
        return AppColors.success;
      case TicketStatus.closed:
        return AppColors.textSecondaryLight;
    }
  }

  IconData get icon {
    switch (this) {
      case TicketStatus.open:
        return Icons.fiber_new;
      case TicketStatus.inProgress:
        return Icons.pending;
      case TicketStatus.waitingForReply:
        return Icons.hourglass_empty;
      case TicketStatus.resolved:
        return Icons.check_circle;
      case TicketStatus.closed:
        return Icons.archive;
    }
  }
}

/// Support ticket category.
enum TicketCategory {
  general,
  technical,
  payment,
  project,
  account,
  feedback,
  other,
}

/// Extension for ticket category properties.
extension TicketCategoryExtension on TicketCategory {
  String get displayName {
    switch (this) {
      case TicketCategory.general:
        return 'General Inquiry';
      case TicketCategory.technical:
        return 'Technical Issue';
      case TicketCategory.payment:
        return 'Payment & Billing';
      case TicketCategory.project:
        return 'Project Related';
      case TicketCategory.account:
        return 'Account & Profile';
      case TicketCategory.feedback:
        return 'Feedback & Suggestions';
      case TicketCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TicketCategory.general:
        return Icons.help_outline;
      case TicketCategory.technical:
        return Icons.bug_report;
      case TicketCategory.payment:
        return Icons.payment;
      case TicketCategory.project:
        return Icons.assignment;
      case TicketCategory.account:
        return Icons.person;
      case TicketCategory.feedback:
        return Icons.feedback;
      case TicketCategory.other:
        return Icons.more_horiz;
    }
  }
}

/// Support ticket priority.
enum TicketPriority {
  low,
  normal,
  high,
  urgent,
}

/// Extension for ticket priority properties.
extension TicketPriorityExtension on TicketPriority {
  String get displayName {
    switch (this) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.normal:
        return 'Normal';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case TicketPriority.low:
        return AppColors.textSecondaryLight;
      case TicketPriority.normal:
        return AppColors.info;
      case TicketPriority.high:
        return AppColors.warning;
      case TicketPriority.urgent:
        return AppColors.error;
    }
  }
}

/// Support ticket model.
class TicketModel {
  const TicketModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.category,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.ticketNumber,
    this.description,
    this.attachments = const [],
    this.assignedTo,
    this.lastMessageAt,
    this.resolvedAt,
    this.closedAt,
    this.rating,
    this.feedback,
  });

  /// Unique ticket ID.
  final String id;

  /// Ticket number for reference.
  final String? ticketNumber;

  /// User ID who created the ticket.
  final String userId;

  /// Ticket subject.
  final String subject;

  /// Ticket description/message.
  final String? description;

  /// Ticket category.
  final TicketCategory category;

  /// Ticket status.
  final TicketStatus status;

  /// Ticket priority.
  final TicketPriority priority;

  /// Attachment URLs.
  final List<String> attachments;

  /// Assigned support agent ID.
  final String? assignedTo;

  /// When ticket was created.
  final DateTime createdAt;

  /// When last message was sent.
  final DateTime? lastMessageAt;

  /// When ticket was resolved.
  final DateTime? resolvedAt;

  /// When ticket was closed.
  final DateTime? closedAt;

  /// User rating (1-5).
  final int? rating;

  /// User feedback after resolution.
  final String? feedback;

  /// Formatted created date.
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  /// Time ago string.
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Whether ticket is active (not closed/resolved).
  bool get isActive =>
      status != TicketStatus.closed && status != TicketStatus.resolved;

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      ticketNumber: json['ticket_number'] as String?,
      userId: json['requester_id'] as String? ?? json['user_id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String?,
      category: _parseCategory(json['category'] as String?),
      status: _parseStatus(json['status'] as String?),
      priority: _parsePriority(json['priority'] as String?),
      attachments: (json['attachments'] as List?)?.cast<String>() ?? [],
      assignedTo: json['assigned_to'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      rating: json['satisfaction_rating'] as int? ?? json['rating'] as int?,
      feedback: json['satisfaction_feedback'] as String? ?? json['feedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'user_id': userId,
      'subject': subject,
      'description': description,
      'category': category.name,
      'status': _statusToString(status),
      'priority': priority.name,
      'attachments': attachments,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'rating': rating,
      'feedback': feedback,
    };
  }

  TicketModel copyWith({
    String? id,
    String? ticketNumber,
    String? userId,
    String? subject,
    String? description,
    TicketCategory? category,
    TicketStatus? status,
    TicketPriority? priority,
    List<String>? attachments,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    DateTime? resolvedAt,
    DateTime? closedAt,
    int? rating,
    String? feedback,
  }) {
    return TicketModel(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      attachments: attachments ?? this.attachments,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      closedAt: closedAt ?? this.closedAt,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
    );
  }

  static TicketCategory _parseCategory(String? category) {
    switch (category) {
      case 'general':
        return TicketCategory.general;
      case 'technical':
        return TicketCategory.technical;
      case 'payment':
        return TicketCategory.payment;
      case 'project':
        return TicketCategory.project;
      case 'account':
        return TicketCategory.account;
      case 'feedback':
        return TicketCategory.feedback;
      default:
        return TicketCategory.other;
    }
  }

  static TicketStatus _parseStatus(String? status) {
    switch (status) {
      case 'open':
        return TicketStatus.open;
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'waiting_for_reply':
        return TicketStatus.waitingForReply;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  static TicketPriority _parsePriority(String? priority) {
    switch (priority) {
      case 'low':
        return TicketPriority.low;
      case 'normal':
      case 'medium':
        return TicketPriority.normal;
      case 'high':
        return TicketPriority.high;
      case 'urgent':
        return TicketPriority.urgent;
      default:
        return TicketPriority.normal;
    }
  }

  static String _statusToString(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return 'open';
      case TicketStatus.inProgress:
        return 'in_progress';
      case TicketStatus.waitingForReply:
        return 'waiting_for_reply';
      case TicketStatus.resolved:
        return 'resolved';
      case TicketStatus.closed:
        return 'closed';
    }
  }
}

/// Ticket message model.
class TicketMessage {
  const TicketMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
    this.isSupport = false,
    this.attachments = const [],
  });

  final String id;
  final String ticketId;
  final String senderId;
  final String message;
  final DateTime createdAt;
  final String? senderName;
  final String? senderAvatar;
  final bool isSupport;
  final List<String> attachments;

  /// Time string.
  String get timeString {
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      senderName: json['sender_name'] as String?,
      senderAvatar: json['sender_avatar'] as String?,
      isSupport: json['is_support'] as bool? ?? false,
      attachments: (json['attachments'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'sender_id': senderId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'is_support': isSupport,
      'attachments': attachments,
    };
  }
}

/// FAQ item model.
class FAQItem {
  const FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    this.order = 0,
    this.isExpanded = false,
  });

  final String id;
  final String question;
  final String answer;
  final String? category;
  final int order;
  final bool isExpanded;

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      id: json['id'] as String,
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      category: json['category'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'order': order,
    };
  }

  FAQItem copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    int? order,
    bool? isExpanded,
  }) {
    return FAQItem(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      order: order ?? this.order,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// FAQ category model.
class FAQCategory {
  const FAQCategory({
    required this.id,
    required this.name,
    this.icon,
    this.items = const [],
  });

  final String id;
  final String name;
  final IconData? icon;
  final List<FAQItem> items;

  factory FAQCategory.fromJson(Map<String, dynamic> json) {
    return FAQCategory(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      items: (json['items'] as List?)
              ?.map((e) => FAQItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
