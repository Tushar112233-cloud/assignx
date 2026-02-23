import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Notification types matching web implementation
enum NotificationType {
  quoteReady,
  paymentReceived,
  projectStarted,
  projectDelivered,
  revisionRequested,
  projectCompleted,
  autoApprovalReminder,
  newMessage,
}

/// Notification payload
class NotificationPayload {
  final NotificationType type;
  final String title;
  final String body;
  final String? projectId;
  final String? projectNumber;
  final Map<String, String>? data;

  NotificationPayload({
    required this.type,
    required this.title,
    required this.body,
    this.projectId,
    this.projectNumber,
    this.data,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      type: _parseNotificationType(json['type'] ?? ''),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      projectId: json['project_id'],
      projectNumber: json['project_number'],
      data: json['data']?.cast<String, String>(),
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'quote_ready':
        return NotificationType.quoteReady;
      case 'payment_received':
        return NotificationType.paymentReceived;
      case 'project_started':
        return NotificationType.projectStarted;
      case 'project_delivered':
        return NotificationType.projectDelivered;
      case 'revision_requested':
        return NotificationType.revisionRequested;
      case 'project_completed':
        return NotificationType.projectCompleted;
      case 'auto_approval_reminder':
        return NotificationType.autoApprovalReminder;
      case 'new_message':
        return NotificationType.newMessage;
      default:
        return NotificationType.newMessage;
    }
  }
}

/// Notification Service
/// Handles push notifications for mobile
/// Implements U39 from feature spec
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  StreamController<NotificationPayload>? _notificationStreamController;
  Stream<NotificationPayload> get notificationStream =>
      _notificationStreamController?.stream ?? const Stream.empty();

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _notificationStreamController = StreamController<NotificationPayload>.broadcast();

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Setup FCM handlers
    _setupFcmHandlers();

    _isInitialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Request notification permissions
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }

    // Android 13+ requires runtime permission
    if (Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  /// Set notifications enabled/disabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (enabled) {
      await _registerFcmToken();
    } else {
      await _unregisterFcmToken();
    }
  }

  /// Get FCM token
  Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Register FCM token with server
  Future<void> _registerFcmToken() async {
    try {
      final token = await getFcmToken();
      if (token == null) return;

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Store token in database
      await supabase.from('push_subscriptions').upsert({
        'profile_id': user.id,
        'endpoint': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'endpoint');

      debugPrint('FCM token registered');
    } catch (e) {
      debugPrint('Error registering FCM token: $e');
    }
  }

  /// Unregister FCM token
  Future<void> _unregisterFcmToken() async {
    try {
      final token = await getFcmToken();
      if (token == null) return;

      final supabase = Supabase.instance.client;

      await supabase
          .from('push_subscriptions')
          .update({'is_active': false})
          .eq('endpoint', token);

      debugPrint('FCM token unregistered');
    } catch (e) {
      debugPrint('Error unregistering FCM token: $e');
    }
  }

  /// Setup FCM handlers
  void _setupFcmHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Token refresh
    _messaging.onTokenRefresh.listen((token) {
      _registerFcmToken();
    });
  }

  /// Handle foreground message
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message: ${message.data}');

    final notification = message.notification;
    if (notification != null) {
      await showLocalNotification(
        title: notification.title ?? 'AssignX',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
      );
    }

    // Emit to stream
    final payload = NotificationPayload.fromJson(message.data);
    _notificationStreamController?.add(payload);
  }

  /// Handle message opened app
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.data}');
    final payload = NotificationPayload.fromJson(message.data);
    _notificationStreamController?.add(payload);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final payload = NotificationPayload.fromJson(data);
        _notificationStreamController?.add(payload);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Show local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    final enabled = await areNotificationsEnabled();
    if (!enabled) return;

    const androidDetails = AndroidNotificationDetails(
      'assignx_notifications',
      'AssignX Notifications',
      channelDescription: 'Notifications from AssignX',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Dispose
  void dispose() {
    _notificationStreamController?.close();
  }
}

/// Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.data}');
  // Handle background message here if needed
}

/// Notification templates
class NotificationTemplates {
  static NotificationPayload getTemplate(
    NotificationType type,
    Map<String, String> data,
  ) {
    switch (type) {
      case NotificationType.quoteReady:
        return NotificationPayload(
          type: type,
          title: 'Quote Ready!',
          body: 'Your project ${data['projectNumber']} has been quoted at \u20B9${data['amount']}. Pay now to start work.',
          projectId: data['projectId'],
          projectNumber: data['projectNumber'],
        );
      case NotificationType.paymentReceived:
        return NotificationPayload(
          type: type,
          title: 'Payment Confirmed',
          body: 'Payment received for ${data['projectNumber']}. Our expert will start working immediately.',
          projectId: data['projectId'],
          projectNumber: data['projectNumber'],
        );
      case NotificationType.projectStarted:
        return NotificationPayload(
          type: type,
          title: 'Work Started',
          body: 'An expert has started working on ${data['projectNumber']}. Track progress in the app.',
          projectId: data['projectId'],
          projectNumber: data['projectNumber'],
        );
      case NotificationType.projectDelivered:
        return NotificationPayload(
          type: type,
          title: 'Project Delivered!',
          body: '${data['projectNumber']} is ready for review. Please check and approve within 48 hours.',
          projectId: data['projectId'],
          projectNumber: data['projectNumber'],
        );
      case NotificationType.revisionRequested:
        return NotificationPayload(
          type: type,
          title: 'Revision in Progress',
          body: 'Your revision request for ${data['projectNumber']} has been received. We\'re working on it.',
          projectId: data['projectId'],
          projectNumber: data['projectNumber'],
        );
      case NotificationType.projectCompleted:
        return NotificationPayload(
          type: type,
          title: 'Project Completed!',
          body: '${data['projectNumber']} has been marked as complete. Thank you for using AssignX!',
          projectId: data['projectId'],
          projectNumber: data['projectNumber'],
        );
      case NotificationType.autoApprovalReminder:
        return NotificationPayload(
          type: type,
          title: 'Review Reminder',
          body: '${data['projectNumber']} will auto-approve in ${data['timeLeft']}. Review it now!',
          projectId: data['projectId'],
          projectNumber: data['projectNumber'],
        );
      case NotificationType.newMessage:
        return NotificationPayload(
          type: type,
          title: 'New Message',
          body: 'You have a new message regarding ${data['projectNumber']}.',
          projectId: data['projectId'],
          projectNumber: data['projectNumber'],
        );
    }
  }
}
