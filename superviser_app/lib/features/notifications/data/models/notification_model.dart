import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Notification type enum.
enum NotificationType {
  projectAssigned,
  projectUpdate,
  quoteAccepted,
  quoteRejected,
  paymentReceived,
  deliveryDue,
  revisionRequested,
  chatMessage,
  systemAlert,
  doerUpdate,
  review,
  support,
}

/// Extension for notification type properties.
extension NotificationTypeExtension on NotificationType {
  /// Get display name.
  String get displayName {
    switch (this) {
      case NotificationType.projectAssigned:
        return 'New Project';
      case NotificationType.projectUpdate:
        return 'Project Update';
      case NotificationType.quoteAccepted:
        return 'Quote Accepted';
      case NotificationType.quoteRejected:
        return 'Quote Rejected';
      case NotificationType.paymentReceived:
        return 'Payment Received';
      case NotificationType.deliveryDue:
        return 'Delivery Due';
      case NotificationType.revisionRequested:
        return 'Revision Requested';
      case NotificationType.chatMessage:
        return 'New Message';
      case NotificationType.systemAlert:
        return 'System Alert';
      case NotificationType.doerUpdate:
        return 'Doer Update';
      case NotificationType.review:
        return 'New Review';
      case NotificationType.support:
        return 'Support';
    }
  }

  /// Get icon.
  IconData get icon {
    switch (this) {
      case NotificationType.projectAssigned:
        return Icons.assignment;
      case NotificationType.projectUpdate:
        return Icons.update;
      case NotificationType.quoteAccepted:
        return Icons.check_circle;
      case NotificationType.quoteRejected:
        return Icons.cancel;
      case NotificationType.paymentReceived:
        return Icons.payment;
      case NotificationType.deliveryDue:
        return Icons.schedule;
      case NotificationType.revisionRequested:
        return Icons.edit_note;
      case NotificationType.chatMessage:
        return Icons.chat_bubble;
      case NotificationType.systemAlert:
        return Icons.warning_amber;
      case NotificationType.doerUpdate:
        return Icons.person;
      case NotificationType.review:
        return Icons.star;
      case NotificationType.support:
        return Icons.support_agent;
    }
  }

  /// Get color.
  Color get color {
    switch (this) {
      case NotificationType.projectAssigned:
        return AppColors.primary;
      case NotificationType.projectUpdate:
        return AppColors.info;
      case NotificationType.quoteAccepted:
        return AppColors.success;
      case NotificationType.quoteRejected:
        return AppColors.error;
      case NotificationType.paymentReceived:
        return AppColors.success;
      case NotificationType.deliveryDue:
        return AppColors.warning;
      case NotificationType.revisionRequested:
        return AppColors.warning;
      case NotificationType.chatMessage:
        return AppColors.primary;
      case NotificationType.systemAlert:
        return AppColors.error;
      case NotificationType.doerUpdate:
        return AppColors.secondary;
      case NotificationType.review:
        return Colors.amber;
      case NotificationType.support:
        return AppColors.info;
    }
  }
}

/// Notification model.
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.data,
    this.imageUrl,
    this.isRead = false,
    this.readAt,
    this.actionUrl,
  });

  /// Unique notification ID.
  final String id;

  /// User ID this notification belongs to.
  final String userId;

  /// Type of notification.
  final NotificationType type;

  /// Notification title.
  final String title;

  /// Notification body/message.
  final String body;

  /// When notification was created.
  final DateTime createdAt;

  /// Additional data payload.
  final Map<String, dynamic>? data;

  /// Optional image URL.
  final String? imageUrl;

  /// Whether notification has been read.
  final bool isRead;

  /// When notification was read.
  final DateTime? readAt;

  /// URL to navigate to when tapped.
  final String? actionUrl;

  /// Time ago string.
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years${years == 1 ? 'y' : 'y'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months${months == 1 ? 'mo' : 'mo'} ago';
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

  /// Project ID if notification is project-related.
  String? get projectId => data?['project_id'] as String?;

  /// Chat room ID if notification is chat-related.
  String? get chatRoomId => data?['chat_room_id'] as String?;

  /// Ticket ID if notification is support-related.
  String? get ticketId => data?['ticket_id'] as String?;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Build data map from reference fields if direct data not available
    Map<String, dynamic>? data = json['data'] as Map<String, dynamic>?;
    if (data == null && json['reference_id'] != null) {
      data = {
        'reference_type': json['reference_type'],
        'reference_id': json['reference_id'],
      };
    }

    return NotificationModel(
      id: json['id'] as String,
      userId: json['profile_id'] as String? ?? json['user_id'] as String? ?? '',
      type: _parseType(
          json['notification_type'] as String? ?? json['type'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      data: data,
      imageUrl: json['image_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      actionUrl: json['action_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'data': data,
      'image_url': imageUrl,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'action_url': actionUrl,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    Map<String, dynamic>? data,
    String? imageUrl,
    bool? isRead,
    DateTime? readAt,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'project_assigned':
      case 'task_assigned':
        return NotificationType.projectAssigned;
      case 'project_update':
      case 'work_submitted':
        return NotificationType.projectUpdate;
      case 'quote_accepted':
      case 'quote_ready':
        return NotificationType.quoteAccepted;
      case 'quote_rejected':
        return NotificationType.quoteRejected;
      case 'payment_received':
      case 'payout_processed':
        return NotificationType.paymentReceived;
      case 'delivery_due':
        return NotificationType.deliveryDue;
      case 'revision_requested':
        return NotificationType.revisionRequested;
      case 'chat_message':
      case 'new_message':
        return NotificationType.chatMessage;
      case 'system_alert':
        return NotificationType.systemAlert;
      case 'doer_update':
        return NotificationType.doerUpdate;
      case 'review':
        return NotificationType.review;
      case 'support':
        return NotificationType.support;
      case 'project_delivered':
      case 'project_completed':
        return NotificationType.projectUpdate;
      default:
        return NotificationType.systemAlert;
    }
  }
}

/// Notification settings model.
class NotificationSettings {
  const NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.projectUpdates = true,
    this.chatMessages = true,
    this.paymentAlerts = true,
    this.systemAlerts = true,
    this.marketingEmails = false,
    this.quietHoursEnabled = false,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool projectUpdates;
  final bool chatMessages;
  final bool paymentAlerts;
  final bool systemAlerts;
  final bool marketingEmails;
  final bool quietHoursEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['push_enabled'] as bool? ?? true,
      emailEnabled: json['email_enabled'] as bool? ?? true,
      projectUpdates: json['project_updates'] as bool? ?? true,
      chatMessages: json['chat_messages'] as bool? ?? true,
      paymentAlerts: json['payment_alerts'] as bool? ?? true,
      systemAlerts: json['system_alerts'] as bool? ?? true,
      marketingEmails: json['marketing_emails'] as bool? ?? false,
      quietHoursEnabled: json['quiet_hours_enabled'] as bool? ?? false,
      quietHoursStart: json['quiet_hours_start'] as String?,
      quietHoursEnd: json['quiet_hours_end'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'project_updates': projectUpdates,
      'chat_messages': chatMessages,
      'payment_alerts': paymentAlerts,
      'system_alerts': systemAlerts,
      'marketing_emails': marketingEmails,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
    };
  }

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? projectUpdates,
    bool? chatMessages,
    bool? paymentAlerts,
    bool? systemAlerts,
    bool? marketingEmails,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      projectUpdates: projectUpdates ?? this.projectUpdates,
      chatMessages: chatMessages ?? this.chatMessages,
      paymentAlerts: paymentAlerts ?? this.paymentAlerts,
      systemAlerts: systemAlerts ?? this.systemAlerts,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}
