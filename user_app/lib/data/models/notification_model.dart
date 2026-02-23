/// Notification types matching Supabase notifications table enum.
enum NotificationType {
  projectSubmitted,
  quoteReady,
  paymentReceived,
  projectAssigned,
  taskAvailable,
  taskAssigned,
  workSubmitted,
  qcApproved,
  qcRejected,
  revisionRequested,
  projectDelivered,
  projectCompleted,
  newMessage,
  payoutProcessed,
  systemAlert,
  promotional,
}

/// Notification model matching Supabase notifications table schema.
class AppNotification {
  /// Unique identifier (UUID).
  final String id;

  /// Profile ID of the user (FK to profiles table).
  final String profileId;

  /// Type of notification.
  final NotificationType notificationType;

  /// Notification title (max 255 chars).
  final String title;

  /// Notification body text.
  final String body;

  /// Reference type (e.g., project, chat, payout).
  final String? referenceType;

  /// Reference ID (UUID of the referenced entity).
  final String? referenceId;

  /// Action URL for deep linking.
  final String? actionUrl;

  /// Whether push notification was sent.
  final bool pushSent;

  /// Timestamp when push notification was sent.
  final DateTime? pushSentAt;

  /// Whether WhatsApp notification was sent.
  final bool whatsappSent;

  /// Timestamp when WhatsApp notification was sent.
  final DateTime? whatsappSentAt;

  /// Whether email notification was sent.
  final bool emailSent;

  /// Timestamp when email notification was sent.
  final DateTime? emailSentAt;

  /// Whether notification has been read.
  final bool isRead;

  /// Timestamp when notification was read.
  final DateTime? readAt;

  /// Timestamp when notification was created.
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.profileId,
    required this.notificationType,
    required this.title,
    required this.body,
    this.referenceType,
    this.referenceId,
    this.actionUrl,
    this.pushSent = false,
    this.pushSentAt,
    this.whatsappSent = false,
    this.whatsappSentAt,
    this.emailSent = false,
    this.emailSentAt,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  /// Creates an [AppNotification] from a JSON map (Supabase row).
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      notificationType: _parseNotificationType(json['notification_type'] as String?),
      title: json['title'] as String,
      body: json['body'] as String,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      actionUrl: json['action_url'] as String?,
      pushSent: json['push_sent'] as bool? ?? false,
      pushSentAt: json['push_sent_at'] != null
          ? DateTime.parse(json['push_sent_at'] as String)
          : null,
      whatsappSent: json['whatsapp_sent'] as bool? ?? false,
      whatsappSentAt: json['whatsapp_sent_at'] != null
          ? DateTime.parse(json['whatsapp_sent_at'] as String)
          : null,
      emailSent: json['email_sent'] as bool? ?? false,
      emailSentAt: json['email_sent_at'] != null
          ? DateTime.parse(json['email_sent_at'] as String)
          : null,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this [AppNotification] to a JSON map for Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'notification_type': _notificationTypeToString(notificationType),
      'title': title,
      'body': body,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'action_url': actionUrl,
      'push_sent': pushSent,
      'push_sent_at': pushSentAt?.toIso8601String(),
      'whatsapp_sent': whatsappSent,
      'whatsapp_sent_at': whatsappSentAt?.toIso8601String(),
      'email_sent': emailSent,
      'email_sent_at': emailSentAt?.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Parses a notification type string from Supabase to [NotificationType].
  static NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'project_submitted':
        return NotificationType.projectSubmitted;
      case 'quote_ready':
        return NotificationType.quoteReady;
      case 'payment_received':
        return NotificationType.paymentReceived;
      case 'project_assigned':
        return NotificationType.projectAssigned;
      case 'task_available':
        return NotificationType.taskAvailable;
      case 'task_assigned':
        return NotificationType.taskAssigned;
      case 'work_submitted':
        return NotificationType.workSubmitted;
      case 'qc_approved':
        return NotificationType.qcApproved;
      case 'qc_rejected':
        return NotificationType.qcRejected;
      case 'revision_requested':
        return NotificationType.revisionRequested;
      case 'project_delivered':
        return NotificationType.projectDelivered;
      case 'project_completed':
        return NotificationType.projectCompleted;
      case 'new_message':
        return NotificationType.newMessage;
      case 'payout_processed':
        return NotificationType.payoutProcessed;
      case 'system_alert':
        return NotificationType.systemAlert;
      case 'promotional':
        return NotificationType.promotional;
      default:
        return NotificationType.systemAlert;
    }
  }

  /// Converts a [NotificationType] to its Supabase string representation.
  static String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.projectSubmitted:
        return 'project_submitted';
      case NotificationType.quoteReady:
        return 'quote_ready';
      case NotificationType.paymentReceived:
        return 'payment_received';
      case NotificationType.projectAssigned:
        return 'project_assigned';
      case NotificationType.taskAvailable:
        return 'task_available';
      case NotificationType.taskAssigned:
        return 'task_assigned';
      case NotificationType.workSubmitted:
        return 'work_submitted';
      case NotificationType.qcApproved:
        return 'qc_approved';
      case NotificationType.qcRejected:
        return 'qc_rejected';
      case NotificationType.revisionRequested:
        return 'revision_requested';
      case NotificationType.projectDelivered:
        return 'project_delivered';
      case NotificationType.projectCompleted:
        return 'project_completed';
      case NotificationType.newMessage:
        return 'new_message';
      case NotificationType.payoutProcessed:
        return 'payout_processed';
      case NotificationType.systemAlert:
        return 'system_alert';
      case NotificationType.promotional:
        return 'promotional';
    }
  }

  /// Creates a copy of this notification with the given fields replaced.
  AppNotification copyWith({
    String? id,
    String? profileId,
    NotificationType? notificationType,
    String? title,
    String? body,
    String? referenceType,
    String? referenceId,
    String? actionUrl,
    bool? pushSent,
    DateTime? pushSentAt,
    bool? whatsappSent,
    DateTime? whatsappSentAt,
    bool? emailSent,
    DateTime? emailSentAt,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      body: body ?? this.body,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      actionUrl: actionUrl ?? this.actionUrl,
      pushSent: pushSent ?? this.pushSent,
      pushSentAt: pushSentAt ?? this.pushSentAt,
      whatsappSent: whatsappSent ?? this.whatsappSent,
      whatsappSentAt: whatsappSentAt ?? this.whatsappSentAt,
      emailSent: emailSent ?? this.emailSent,
      emailSentAt: emailSentAt ?? this.emailSentAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, profileId: $profileId, notificationType: $notificationType, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
