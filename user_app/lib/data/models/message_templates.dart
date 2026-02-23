import 'package:flutter/material.dart';

/// Action button configuration for unavailability templates.
class TemplateAction {
  /// Display text for the action button.
  final String text;

  /// Action identifier for handling the button click.
  final String action;

  /// Button style variant.
  final TemplateActionVariant variant;

  const TemplateAction({
    required this.text,
    required this.action,
    this.variant = TemplateActionVariant.primary,
  });

  /// Creates a TemplateAction from a JSON map.
  factory TemplateAction.fromJson(Map<String, dynamic> json) {
    return TemplateAction(
      text: json['text'] as String,
      action: json['action'] as String,
      variant: TemplateActionVariant.values.firstWhere(
        (v) => v.name == json['variant'],
        orElse: () => TemplateActionVariant.primary,
      ),
    );
  }

  /// Converts this TemplateAction to a JSON map.
  Map<String, dynamic> toJson() => {
    'text': text,
    'action': action,
    'variant': variant.name,
  };
}

/// Button style variants for template actions.
enum TemplateActionVariant {
  primary,
  secondary,
  outline,
}

/// Icon style variants for unavailability messages.
enum IconVariant {
  primary,
  warning,
  error,
  success,
  info,
}

/// Pre-drafted unavailability response template.
///
/// Provides consistent messaging when services, experts, or features
/// are temporarily unavailable.
///
/// Example:
/// ```dart
/// final template = UnavailabilityTemplate.expertUnavailable(
///   expertName: 'Dr. Sarah Johnson',
///   estimatedDate: 'February 1, 2026',
/// );
/// ```
class UnavailabilityTemplate {
  /// Unique template identifier.
  final String id;

  /// Title displayed at the top of the message.
  final String title;

  /// Main message body.
  final String message;

  /// Icon name for the template.
  final IconData iconData;

  /// Icon color variant.
  final IconVariant iconVariant;

  /// Optional single action button text.
  final String? actionText;

  /// Optional route for single action button.
  final String? actionRoute;

  /// Optional array of action buttons.
  final List<TemplateAction>? actions;

  /// Service hours display string.
  final String? serviceHours;

  /// Whether to show a countdown timer.
  final bool showCountdown;

  /// Whether to show an email input field.
  final bool showEmailInput;

  /// Optional estimated completion/availability time.
  final DateTime? estimatedTime;

  const UnavailabilityTemplate({
    required this.id,
    required this.title,
    required this.message,
    required this.iconData,
    this.iconVariant = IconVariant.primary,
    this.actionText,
    this.actionRoute,
    this.actions,
    this.serviceHours,
    this.showCountdown = false,
    this.showEmailInput = false,
    this.estimatedTime,
  });

  /// Template for when a service has reached its capacity limit.
  /// Suggests browsing alternative services.
  factory UnavailabilityTemplate.serviceAtCapacity() {
    return const UnavailabilityTemplate(
      id: 'service_at_capacity',
      title: 'Service at Capacity',
      message: '''Thank you for your interest! This service is currently at capacity and we're working hard to accommodate more requests.

We'll notify you as soon as it becomes available. In the meantime, you might be interested in our other services that can help with your project.''',
      iconData: Icons.schedule,
      iconVariant: IconVariant.warning,
      actionText: 'Browse Other Services',
      actionRoute: '/home',
    );
  }

  /// Template for when a specific expert is not available.
  /// Provides options to find similar experts or get notified.
  factory UnavailabilityTemplate.expertUnavailable({
    required String expertName,
    String? estimatedDate,
  }) {
    final estimatedText = estimatedDate ?? 'soon';
    return UnavailabilityTemplate(
      id: 'expert_unavailable',
      title: 'Expert Currently Unavailable',
      message: '''$expertName is currently not accepting new projects due to high demand.

You can:
- Wait for their availability (estimated: $estimatedText)
- Let us match you with another equally qualified expert
- Save their profile to be notified when available''',
      iconData: Icons.person_off_outlined,
      iconVariant: IconVariant.info,
      actions: const [
        TemplateAction(
          text: 'Find Similar Expert',
          action: 'find_similar',
          variant: TemplateActionVariant.primary,
        ),
        TemplateAction(
          text: 'Get Notified',
          action: 'notify_available',
          variant: TemplateActionVariant.outline,
        ),
      ],
    );
  }

  /// Template for outside of service hours.
  /// Shows countdown to when service resumes.
  factory UnavailabilityTemplate.outsideServiceHours() {
    return const UnavailabilityTemplate(
      id: 'outside_hours',
      title: 'Outside Service Hours',
      message: '''Our team is currently outside service hours (9 AM - 9 PM IST).

Your request has been saved and we'll respond first thing tomorrow. For urgent queries, please use our emergency support line.''',
      iconData: Icons.nightlight_outlined,
      iconVariant: IconVariant.primary,
      serviceHours: '9:00 AM - 9:00 PM IST',
      actionText: 'Emergency Support',
      showCountdown: true,
    );
  }

  /// Template for scheduled maintenance periods.
  /// Shows estimated completion time.
  factory UnavailabilityTemplate.maintenanceMode({
    required DateTime completionTime,
  }) {
    final formattedTime = _formatDateTime(completionTime);
    return UnavailabilityTemplate(
      id: 'maintenance',
      title: 'Scheduled Maintenance',
      message: '''We're currently performing scheduled maintenance to improve your experience.

Expected completion: $formattedTime

We apologize for any inconvenience.''',
      iconData: Icons.build_outlined,
      iconVariant: IconVariant.warning,
      showCountdown: true,
      estimatedTime: completionTime,
    );
  }

  /// Template for when a service is not available in user's region.
  /// Collects email for regional expansion notifications.
  factory UnavailabilityTemplate.regionNotSupported() {
    return const UnavailabilityTemplate(
      id: 'region_not_supported',
      title: 'Service Not Available in Your Region',
      message: '''We're sorry, but this service is not yet available in your region.

We're expanding rapidly and hope to serve your area soon. Please enter your email to be notified when we launch in your region.''',
      iconData: Icons.location_off_outlined,
      iconVariant: IconVariant.info,
      showEmailInput: true,
      actionText: 'Notify Me',
    );
  }

  /// Template for high demand periods with queue functionality.
  factory UnavailabilityTemplate.highDemand({
    required String waitTime,
  }) {
    return UnavailabilityTemplate(
      id: 'high_demand',
      title: 'High Demand Period',
      message: '''We're experiencing higher than usual demand right now.

Your request has been added to our priority queue. Expected wait time: $waitTime

You'll receive a notification when we're ready to assist you.''',
      iconData: Icons.warning_amber_outlined,
      iconVariant: IconVariant.warning,
      showCountdown: true,
      actions: const [
        TemplateAction(
          text: 'Stay in Queue',
          action: 'stay_in_queue',
          variant: TemplateActionVariant.primary,
        ),
        TemplateAction(
          text: 'Cancel Request',
          action: 'cancel_request',
          variant: TemplateActionVariant.outline,
        ),
      ],
    );
  }

  /// Template for server or connectivity issues.
  factory UnavailabilityTemplate.serverIssue() {
    return const UnavailabilityTemplate(
      id: 'server_issue',
      title: 'Connection Issue',
      message: '''We're having trouble connecting to our servers. This is usually temporary and resolves within a few minutes.

Please try again shortly. If the problem persists, our team has been notified and is working on it.''',
      iconData: Icons.cloud_off_outlined,
      iconVariant: IconVariant.error,
      actions: [
        TemplateAction(
          text: 'Retry Connection',
          action: 'retry',
          variant: TemplateActionVariant.primary,
        ),
        TemplateAction(
          text: 'Contact Support',
          action: 'contact_support',
          variant: TemplateActionVariant.outline,
        ),
      ],
    );
  }

  /// Template for booking/scheduling conflicts.
  factory UnavailabilityTemplate.slotUnavailable() {
    return const UnavailabilityTemplate(
      id: 'slot_unavailable',
      title: 'Time Slot No Longer Available',
      message: '''The time slot you selected has just been booked by another user.

Please choose a different time slot from the available options below.''',
      iconData: Icons.event_busy_outlined,
      iconVariant: IconVariant.warning,
      actionText: 'View Available Slots',
      actionRoute: '/schedule',
    );
  }

  /// Template for feature temporarily disabled.
  factory UnavailabilityTemplate.featureDisabled({
    DateTime? estimatedTime,
  }) {
    return UnavailabilityTemplate(
      id: 'feature_disabled',
      title: 'Feature Temporarily Unavailable',
      message: '''This feature is temporarily disabled while we make improvements.

We expect it to be back online soon. Thank you for your patience!''',
      iconData: Icons.handyman_outlined,
      iconVariant: IconVariant.info,
      showCountdown: estimatedTime != null,
      estimatedTime: estimatedTime,
    );
  }

  /// Helper to format DateTime.
  static String _formatDateTime(DateTime dateTime) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at $hour:$minute $period';
  }

  /// Get the icon color based on variant.
  Color getIconColor() {
    switch (iconVariant) {
      case IconVariant.warning:
        return const Color(0xFFF59E0B); // Amber
      case IconVariant.error:
        return const Color(0xFFDC352F); // Red
      case IconVariant.success:
        return const Color(0xFF259369); // Green
      case IconVariant.info:
        return const Color(0xFF2B93BE); // Blue
      case IconVariant.primary:
        return const Color(0xFF765341); // Coffee Bean
    }
  }

  /// Get the icon background color based on variant.
  Color getIconBackgroundColor() {
    switch (iconVariant) {
      case IconVariant.warning:
        return const Color(0xFFFEF3C7); // Amber light
      case IconVariant.error:
        return const Color(0xFFFEE2E2); // Red light
      case IconVariant.success:
        return const Color(0xFFD4F5E5); // Green light
      case IconVariant.info:
        return const Color(0xFFDBEAFE); // Blue light
      case IconVariant.primary:
        return const Color(0xFFF1EEEA); // Brown light
    }
  }

  /// Creates a copy of this template with optional overrides.
  UnavailabilityTemplate copyWith({
    String? id,
    String? title,
    String? message,
    IconData? iconData,
    IconVariant? iconVariant,
    String? actionText,
    String? actionRoute,
    List<TemplateAction>? actions,
    String? serviceHours,
    bool? showCountdown,
    bool? showEmailInput,
    DateTime? estimatedTime,
  }) {
    return UnavailabilityTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      iconData: iconData ?? this.iconData,
      iconVariant: iconVariant ?? this.iconVariant,
      actionText: actionText ?? this.actionText,
      actionRoute: actionRoute ?? this.actionRoute,
      actions: actions ?? this.actions,
      serviceHours: serviceHours ?? this.serviceHours,
      showCountdown: showCountdown ?? this.showCountdown,
      showEmailInput: showEmailInput ?? this.showEmailInput,
      estimatedTime: estimatedTime ?? this.estimatedTime,
    );
  }

  @override
  String toString() =>
      'UnavailabilityTemplate(id: $id, title: $title)';
}

/// Utility class for countdown calculations.
class CountdownUtils {
  CountdownUtils._();

  /// Calculate countdown time until a target date/time.
  static CountdownResult calculateCountdown(DateTime targetTime) {
    final now = DateTime.now();
    final diff = targetTime.difference(now);

    if (diff.isNegative) {
      return const CountdownResult(
        hours: 0,
        minutes: 0,
        seconds: 0,
        isExpired: true,
      );
    }

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    return CountdownResult(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      isExpired: false,
    );
  }

  /// Calculate time until next service hours start.
  /// Assumes service hours are 9 AM - 9 PM IST.
  static ServiceHoursResult getTimeToServiceStart() {
    final now = DateTime.now().toUtc();
    // Convert to IST (UTC+5:30)
    final istTime = now.add(const Duration(hours: 5, minutes: 30));
    final currentHour = istTime.hour;
    final currentMinute = istTime.minute;

    // Service hours: 9 AM - 9 PM IST
    const serviceStart = 9;
    const serviceEnd = 21;

    if (currentHour >= serviceStart && currentHour < serviceEnd) {
      return const ServiceHoursResult(
        hours: 0,
        minutes: 0,
        isWithinServiceHours: true,
      );
    }

    // Calculate hours until 9 AM
    int hoursUntilOpen;
    if (currentHour >= serviceEnd) {
      // After 9 PM, until midnight + until 9 AM
      hoursUntilOpen = (24 - currentHour) + serviceStart;
    } else {
      // Before 9 AM
      hoursUntilOpen = serviceStart - currentHour;
    }

    // Adjust for current minutes
    int minutesRemaining = 60 - currentMinute;
    if (minutesRemaining == 60) {
      minutesRemaining = 0;
    } else {
      hoursUntilOpen -= 1;
    }

    return ServiceHoursResult(
      hours: hoursUntilOpen,
      minutes: minutesRemaining,
      isWithinServiceHours: false,
    );
  }
}

/// Result of a countdown calculation.
class CountdownResult {
  final int hours;
  final int minutes;
  final int seconds;
  final bool isExpired;

  const CountdownResult({
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.isExpired,
  });

  /// Format as HH:MM:SS.
  String format() {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Format as HH:MM.
  String formatShort() {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';
  }
}

/// Result of service hours calculation.
class ServiceHoursResult {
  final int hours;
  final int minutes;
  final bool isWithinServiceHours;

  const ServiceHoursResult({
    required this.hours,
    required this.minutes,
    required this.isWithinServiceHours,
  });

  /// Format as "Xh Ym".
  String format() {
    if (isWithinServiceHours) {
      return 'Open now';
    }
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
