/// Profile state management provider for the Doer App.
///
/// This file manages the user's profile data, payment history, bank details,
/// notification preferences, and app notifications. It provides a comprehensive
/// view of the user's account and settings.
///
/// ## Architecture
///
/// The profile provider manages several related data domains:
/// - **User Profile**: Personal information and stats
/// - **Payment History**: Transaction records
/// - **Bank Details**: Payment account information
/// - **Notifications**: App notifications and preferences
///
/// ## Usage
///
/// ```dart
/// // Watch profile state in a widget
/// final profileState = ref.watch(profileProvider);
///
/// // Display user info
/// Text(profileState.profile?.fullName ?? 'User');
///
/// // Update profile
/// await ref.read(profileProvider.notifier).updateProfile(
///   fullName: 'New Name',
///   bio: 'Updated bio',
/// );
///
/// // Upload avatar
/// final imageFile = File('/path/to/image.jpg');
/// await ref.read(profileProvider.notifier).uploadAvatar(imageFile);
///
/// // Update notification preferences
/// await ref.read(profileProvider.notifier).updateNotificationPreferences(
///   newPreferences,
/// );
/// ```
///
/// ## State Flow
///
/// ```
/// initial -> loading profile data
///     |
///     v
/// [profile, payments, bank, notifications] -> ready
///     |
///     v
/// update profile/preferences -> saving -> ready
/// ```
///
/// ## Database Integration
///
/// The provider interacts with several Supabase tables:
/// - `profiles`: User profile information
/// - `payments`: Payment transaction history
/// - `bank_accounts`: Bank account details
/// - `notifications`: App notifications
/// - `notification_preferences`: User notification settings
///
/// See also:
/// - [AuthNotifier] for authentication state
/// - [UserProfile] for profile data structure
/// - [PaymentTransaction] for payment records
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../core/constants/api_constants.dart';
import '../shared/utils/masking_utils.dart';

/// User profile data model.
///
/// Contains the doer's personal information, statistics, and settings.
/// This is a comprehensive representation of the user's account.
///
/// ## Properties
///
/// - [id]: Unique user identifier
/// - [email]: User's email address
/// - [fullName]: Display name
/// - [avatarUrl]: Profile picture URL
/// - [phone]: Phone number
/// - [bio]: User's biography
/// - [education]: Educational background
/// - [skills]: List of skill names
/// - [rating]: Average rating (0-5)
/// - [completedProjects]: Number of completed projects
/// - [totalEarnings]: Total earnings in INR
/// - [joinedAt]: Account creation date
/// - [isVerified]: Whether the account is verified
/// - [isAvailable]: Availability status
///
/// ## Usage
///
/// ```dart
/// final profile = ref.watch(userProfileProvider);
///
/// if (profile != null) {
///   Text('Rating: ${profile.rating}');
///   Text('Completed: ${profile.completedProjects} projects');
/// }
/// ```
class UserProfile {
  /// Unique identifier for the user.
  final String id;

  /// User's email address.
  final String email;

  /// User's full display name.
  final String fullName;

  /// URL to the user's profile picture, if set.
  final String? avatarUrl;

  /// User's phone number, if provided.
  final String? phone;

  /// User's biography or description.
  final String? bio;

  /// User's educational background.
  final String? education;

  /// List of skill names the user possesses.
  final List<String> skills;

  /// User's average rating from completed projects (0-5 scale).
  final double rating;

  /// Total number of completed projects.
  final int completedProjects;

  /// Total earnings in INR.
  final int totalEarnings;

  /// Date when the user joined the platform.
  final DateTime joinedAt;

  /// Whether the user's account is verified.
  final bool isVerified;

  /// Whether the user is available for new projects.
  final bool isAvailable;

  /// Creates a new [UserProfile] instance.
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.phone,
    this.bio,
    this.education,
    this.skills = const [],
    this.rating = 0.0,
    this.completedProjects = 0,
    this.totalEarnings = 0,
    required this.joinedAt,
    this.isVerified = false,
    this.isAvailable = true,
  });

  /// Creates a [UserProfile] from a JSON map.
  ///
  /// ## Parameters
  ///
  /// - [json]: The JSON map from the database
  ///
  /// ## Returns
  ///
  /// A new [UserProfile] instance with parsed data.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'User',
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      education: json['education'] as String?,
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      completedProjects: json['completed_projects'] as int? ?? 0,
      totalEarnings: json['total_earnings'] as int? ?? 0,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
      isVerified: json['is_verified'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  /// Converts this profile to a JSON map for database storage.
  ///
  /// ## Returns
  ///
  /// A map with profile data suitable for database operations.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'bio': bio,
      'education': education,
      'skills': skills,
      'is_available': isAvailable,
    };
  }

  /// Creates a copy of this profile with the specified fields replaced.
  ///
  /// ## Parameters
  ///
  /// - [fullName]: Updated full name
  /// - [avatarUrl]: Updated avatar URL
  /// - [phone]: Updated phone number
  /// - [bio]: Updated biography
  /// - [education]: Updated education
  /// - [skills]: Updated skills list
  /// - [isAvailable]: Updated availability
  ///
  /// ## Returns
  ///
  /// A new [UserProfile] instance with the specified changes.
  UserProfile copyWith({
    String? fullName,
    String? avatarUrl,
    String? phone,
    String? bio,
    String? education,
    List<String>? skills,
    bool? isAvailable,
  }) {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      rating: rating,
      completedProjects: completedProjects,
      totalEarnings: totalEarnings,
      joinedAt: joinedAt,
      isVerified: isVerified,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  /// Returns a masked version of the phone number for display.
  ///
  /// Example: "+91 98765 43210" becomes "+91 987** ***10"
  String? get maskedPhone => phone != null ? MaskingUtils.maskPhone(phone!) : null;

  /// Returns a masked version of the email for display.
  ///
  /// Example: "user@example.com" becomes "u***@example.com"
  String get maskedEmail => MaskingUtils.maskEmail(email);
}

/// Payment transaction record model.
///
/// Represents a single payment transaction in the user's payment history.
///
/// ## Properties
///
/// - [id]: Unique transaction identifier
/// - [projectId]: Associated project ID
/// - [projectTitle]: Title of the project
/// - [amount]: Transaction amount
/// - [status]: Current payment status
/// - [type]: Type of payment
/// - [createdAt]: When the transaction was created
/// - [processedAt]: When the transaction was processed
/// - [transactionId]: External transaction reference
class PaymentTransaction {
  /// Unique identifier for the transaction.
  final String id;

  /// ID of the associated project.
  final String projectId;

  /// Title of the associated project.
  final String projectTitle;

  /// Transaction amount in INR.
  final double amount;

  /// Current status of the payment.
  final PaymentStatus status;

  /// Type of payment transaction.
  final PaymentType type;

  /// When the transaction was created.
  final DateTime createdAt;

  /// When the transaction was processed, if applicable.
  final DateTime? processedAt;

  /// External transaction reference ID.
  final String? transactionId;

  /// Creates a new [PaymentTransaction] instance.
  const PaymentTransaction({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.amount,
    required this.status,
    required this.type,
    required this.createdAt,
    this.processedAt,
    this.transactionId,
  });

  /// Creates a [PaymentTransaction] from a JSON map.
  ///
  /// ## Parameters
  ///
  /// - [json]: The JSON map from the database
  ///
  /// ## Returns
  ///
  /// A new [PaymentTransaction] instance with parsed data.
  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String,
      projectId: json['project_id'] as String? ?? '',
      projectTitle: json['project_title'] as String? ?? 'Unknown Project',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      type: PaymentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentType.projectPayment,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      transactionId: json['transaction_id'] as String?,
    );
  }
}

/// Enumeration of payment statuses.
///
/// Represents the current state of a payment transaction.
enum PaymentStatus {
  /// Payment is pending processing.
  pending('Pending'),

  /// Payment is currently being processed.
  processing('Processing'),

  /// Payment has been successfully completed.
  completed('Completed'),

  /// Payment processing failed.
  failed('Failed'),

  /// Payment has been refunded.
  refunded('Refunded');

  /// Human-readable display name for the status.
  final String displayName;

  const PaymentStatus(this.displayName);
}

/// Enumeration of payment types.
///
/// Categorizes different types of payment transactions.
enum PaymentType {
  /// Payment for completing a project.
  projectPayment('Project Payment'),

  /// Bonus payment for exceptional work.
  bonus('Bonus'),

  /// Referral bonus payment.
  referral('Referral Bonus'),

  /// Withdrawal to bank account.
  withdrawal('Withdrawal');

  /// Human-readable display name for the type.
  final String displayName;

  const PaymentType(this.displayName);
}

/// Bank account details model.
///
/// Contains the user's bank account information for payment processing.
///
/// ## Properties
///
/// - [id]: Unique identifier
/// - [accountName]: Account holder's name
/// - [accountNumber]: Bank account number
/// - [ifscCode]: IFSC code of the bank branch
/// - [bankName]: Name of the bank
/// - [isVerified]: Whether the account is verified
/// - [isPrimary]: Whether this is the primary account
class BankDetails {
  /// Unique identifier for the bank details record.
  final String id;

  /// Name of the account holder.
  final String accountName;

  /// Bank account number.
  final String accountNumber;

  /// IFSC code of the bank branch.
  final String ifscCode;

  /// Name of the bank.
  final String bankName;

  /// Whether the bank account has been verified.
  final bool isVerified;

  /// Whether this is the primary account for payments.
  final bool isPrimary;

  /// Creates a new [BankDetails] instance.
  const BankDetails({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    this.isVerified = false,
    this.isPrimary = true,
  });

  /// Creates a [BankDetails] from a JSON map.
  ///
  /// ## Parameters
  ///
  /// - [json]: The JSON map from the database
  ///
  /// ## Returns
  ///
  /// A new [BankDetails] instance with parsed data.
  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      id: json['id'] as String,
      accountName: json['account_name'] as String? ?? '',
      accountNumber: json['account_number'] as String? ?? '',
      ifscCode: json['ifsc_code'] as String? ?? '',
      bankName: json['bank_name'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      isPrimary: json['is_primary'] as bool? ?? true,
    );
  }

  /// Returns a masked version of the account number for display.
  ///
  /// Example: "1234567890" becomes "XXXX XXX890"
  String get maskedAccountNumber => MaskingUtils.maskAccountNumber(accountNumber);

  /// Returns a masked version of the IFSC code for display.
  ///
  /// Example: "SBIN0001234" becomes "SBIN***1234"
  String get maskedIfsc => MaskingUtils.maskIFSC(ifscCode);
}

/// Notification preferences model.
///
/// Contains user preferences for different types of notifications.
///
/// ## Properties
///
/// - [emailNotifications]: Enable email notifications
/// - [pushNotifications]: Enable push notifications
/// - [newProjectAlerts]: Alerts for new matching projects
/// - [deadlineReminders]: Reminders for upcoming deadlines
/// - [paymentUpdates]: Updates about payment status
/// - [marketingEmails]: Marketing and promotional emails
class NotificationPreferences {
  /// Whether email notifications are enabled.
  final bool emailNotifications;

  /// Whether push notifications are enabled.
  final bool pushNotifications;

  /// Whether to receive alerts for new matching projects.
  final bool newProjectAlerts;

  /// Whether to receive deadline reminder notifications.
  final bool deadlineReminders;

  /// Whether to receive payment status updates.
  final bool paymentUpdates;

  /// Whether to receive marketing and promotional emails.
  final bool marketingEmails;

  /// Creates a new [NotificationPreferences] instance.
  ///
  /// All notification types default to enabled except marketing emails.
  const NotificationPreferences({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.newProjectAlerts = true,
    this.deadlineReminders = true,
    this.paymentUpdates = true,
    this.marketingEmails = false,
  });

  /// Creates [NotificationPreferences] from a JSON map.
  ///
  /// ## Parameters
  ///
  /// - [json]: The JSON map from the database
  ///
  /// ## Returns
  ///
  /// A new [NotificationPreferences] instance with parsed data.
  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      emailNotifications: json['email_notifications'] as bool? ?? true,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      newProjectAlerts: json['new_project_alerts'] as bool? ?? true,
      deadlineReminders: json['deadline_reminders'] as bool? ?? true,
      paymentUpdates: json['payment_updates'] as bool? ?? true,
      marketingEmails: json['marketing_emails'] as bool? ?? false,
    );
  }

  /// Converts preferences to a JSON map for database storage.
  ///
  /// ## Returns
  ///
  /// A map with preference data suitable for database operations.
  Map<String, dynamic> toJson() {
    return {
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'new_project_alerts': newProjectAlerts,
      'deadline_reminders': deadlineReminders,
      'payment_updates': paymentUpdates,
      'marketing_emails': marketingEmails,
    };
  }

  /// Creates a copy with the specified fields replaced.
  ///
  /// ## Parameters
  ///
  /// All parameters are optional preference toggles.
  ///
  /// ## Returns
  ///
  /// A new [NotificationPreferences] instance with the specified changes.
  NotificationPreferences copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? newProjectAlerts,
    bool? deadlineReminders,
    bool? paymentUpdates,
    bool? marketingEmails,
  }) {
    return NotificationPreferences(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      newProjectAlerts: newProjectAlerts ?? this.newProjectAlerts,
      deadlineReminders: deadlineReminders ?? this.deadlineReminders,
      paymentUpdates: paymentUpdates ?? this.paymentUpdates,
      marketingEmails: marketingEmails ?? this.marketingEmails,
    );
  }
}

/// App notification model.
///
/// Represents a notification in the user's notification center.
///
/// ## Properties
///
/// - [id]: Unique notification identifier
/// - [title]: Notification title
/// - [message]: Notification body text
/// - [type]: Type of notification
/// - [createdAt]: When the notification was created
/// - [isRead]: Whether the notification has been read
/// - [actionUrl]: Deep link URL for the notification action
/// - [data]: Additional notification data
class AppNotification {
  /// Unique identifier for the notification.
  final String id;

  /// Title of the notification.
  final String title;

  /// Body message of the notification.
  final String message;

  /// Type categorizing the notification.
  final NotificationType type;

  /// When the notification was created.
  final DateTime createdAt;

  /// Whether the notification has been read.
  final bool isRead;

  /// Optional deep link URL for notification action.
  final String? actionUrl;

  /// Additional data associated with the notification.
  final Map<String, dynamic>? data;

  /// Creates a new [AppNotification] instance.
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
    this.data,
  });

  /// Creates an [AppNotification] from a JSON map.
  ///
  /// ## Parameters
  ///
  /// - [json]: The JSON map from the database
  ///
  /// ## Returns
  ///
  /// A new [AppNotification] instance with parsed data.
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
      actionUrl: json['action_url'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

/// Enumeration of notification types.
///
/// Categorizes notifications for filtering and display purposes.
enum NotificationType {
  /// General notifications.
  general('General', _NotificationIconCodes.notifications),

  /// Project-related notifications.
  project('Project', _NotificationIconCodes.assignment),

  /// Payment-related notifications.
  payment('Payment', _NotificationIconCodes.payment),

  /// Deadline reminder notifications.
  deadline('Deadline', _NotificationIconCodes.schedule),

  /// Review-related notifications.
  review('Review', _NotificationIconCodes.rateReview),

  /// System notifications.
  system('System', _NotificationIconCodes.info);

  /// Human-readable display name for the type.
  final String displayName;

  /// Material icon code for the type.
  final int iconCode;

  const NotificationType(this.displayName, this.iconCode);
}

/// Icon codes for notification types.
///
/// Uses Material icon code points to avoid Flutter dependency in provider.
class _NotificationIconCodes {
  static const int notifications = 0xe7f4;
  static const int assignment = 0xe85d;
  static const int payment = 0xe8a1;
  static const int schedule = 0xe8b5;
  static const int rateReview = 0xe8a9;
  static const int info = 0xe88e;
}

/// Immutable state class representing the profile data.
///
/// Contains all profile-related information including user data,
/// payments, notifications, and preferences.
///
/// ## Properties
///
/// - [profile]: The user's profile data
/// - [paymentHistory]: List of payment transactions
/// - [bankDetails]: User's bank account details
/// - [notificationPreferences]: Notification settings
/// - [notifications]: App notifications
/// - [isLoading]: Whether data is being loaded
/// - [isSaving]: Whether data is being saved
/// - [errorMessage]: Error message if operation failed
///
/// ## Usage
///
/// ```dart
/// final state = ref.watch(profileProvider);
///
/// if (state.isLoading) {
///   return LoadingIndicator();
/// }
///
/// return ProfileScreen(
///   profile: state.profile!,
///   notifications: state.notifications,
/// );
/// ```
class ProfileState {
  /// The user's profile data, null if not loaded.
  final UserProfile? profile;

  /// List of payment transactions.
  final List<PaymentTransaction> paymentHistory;

  /// User's bank account details, null if not set.
  final BankDetails? bankDetails;

  /// User's notification preferences.
  final NotificationPreferences notificationPreferences;

  /// List of app notifications.
  final List<AppNotification> notifications;

  /// Whether profile data is being loaded.
  final bool isLoading;

  /// Whether profile data is being saved.
  final bool isSaving;

  /// Error message from the last failed operation, null if no error.
  final String? errorMessage;

  /// Creates a new [ProfileState] instance.
  const ProfileState({
    this.profile,
    this.paymentHistory = const [],
    this.bankDetails,
    this.notificationPreferences = const NotificationPreferences(),
    this.notifications = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  /// Creates a copy of this state with the specified fields replaced.
  ///
  /// ## Parameters
  ///
  /// All parameters are optional state fields to update.
  ///
  /// ## Returns
  ///
  /// A new [ProfileState] instance with the specified changes.
  ProfileState copyWith({
    UserProfile? profile,
    List<PaymentTransaction>? paymentHistory,
    BankDetails? bankDetails,
    NotificationPreferences? notificationPreferences,
    List<AppNotification>? notifications,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      bankDetails: bankDetails ?? this.bankDetails,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }

  /// Returns the count of unread notifications.
  int get unreadNotificationCount => notifications.where((n) => !n.isRead).length;

  /// Calculates total earnings for the current month.
  ///
  /// ## Returns
  ///
  /// The sum of completed payments created this month.
  double get totalEarningsThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return paymentHistory
        .where((p) =>
            p.status == PaymentStatus.completed &&
            p.createdAt.isAfter(startOfMonth))
        .fold(0.0, (sum, p) => sum + p.amount);
  }
}

/// Notifier class that manages profile state and operations.
///
/// This class handles loading and managing profile data including:
/// - Fetching user profile information
/// - Loading payment history
/// - Managing bank details
/// - Handling notifications and preferences
///
/// ## Lifecycle
///
/// The notifier initializes by loading profile data from the database
/// when first accessed.
///
/// ## State Management
///
/// State updates are performed through [state] assignment, triggering
/// reactive updates in all watching widgets.
///
/// ## Usage
///
/// ```dart
/// // Access the notifier for operations
/// final notifier = ref.read(profileProvider.notifier);
///
/// // Update profile
/// await notifier.updateProfile(fullName: 'New Name');
///
/// // Mark notification as read
/// await notifier.markNotificationRead(notificationId);
///
/// // Update notification preferences
/// await notifier.updateNotificationPreferences(newPreferences);
/// ```
class ProfileNotifier extends Notifier<ProfileState> {
  /// Builds and initializes the profile state.
  ///
  /// This method is called when the provider is first read. It
  /// triggers loading of profile data and returns an initial loading state.
  ///
  /// ## Returns
  ///
  /// A [ProfileState] with isLoading set to true.
  @override
  ProfileState build() {
    _loadProfile();
    return const ProfileState(isLoading: true);
  }

  /// The Supabase client instance for database operations.
  SupabaseClient get _client => SupabaseConfig.client;

  /// Loads the user profile and related data.
  ///
  /// Fetches profile from database or falls back to mock data.
  /// Then loads related data in parallel.
  ///
  /// ## State Updates
  ///
  /// Sets [isLoading] to true during load, false on completion.
  /// Updates all profile-related state fields.
  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          profile: null,
          paymentHistory: [],
          bankDetails: null,
          notifications: [],
        );
        return;
      }

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      // Also fetch doer stats (rating, completed projects, earnings, availability)
      final doerResponse = await _client
          .from('doers')
          .select('id, average_rating, total_projects_completed, total_earnings, is_available')
          .eq('profile_id', user.id)
          .maybeSingle();

      // Merge doer stats into profile JSON before parsing
      final mergedJson = Map<String, dynamic>.from(response);
      if (doerResponse != null) {
        mergedJson['rating'] = doerResponse['average_rating'];
        mergedJson['completed_projects'] = doerResponse['total_projects_completed'];
        mergedJson['total_earnings'] = doerResponse['total_earnings'];
        mergedJson['is_available'] = doerResponse['is_available'];
      }

      final profile = UserProfile.fromJson(mergedJson);

      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );

      // Load related data in parallel
      await Future.wait([
        _loadPaymentHistory(),
        _loadBankDetails(),
        _loadNotifications(),
        _loadNotificationPreferences(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileNotifier._loadProfile error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        profile: null,
        paymentHistory: [],
        bankDetails: null,
        notifications: [],
        errorMessage: 'Failed to load profile',
      );
    }
  }

  /// Loads payment transaction history.
  ///
  /// Fetches all payment records ordered by date descending.
  ///
  /// ## State Updates
  ///
  /// Updates [ProfileState.paymentHistory] with loaded transactions.
  Future<void> _loadPaymentHistory() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      final response = await _client
          .from('payments')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final history = (response as List)
          .map((e) => PaymentTransaction.fromJson(e))
          .toList();

      state = state.copyWith(paymentHistory: history);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileNotifier._loadPaymentHistory error: $e');
      }
    }
  }

  /// Loads bank account details.
  ///
  /// Fetches the primary bank account for the user.
  ///
  /// ## State Updates
  ///
  /// Updates [ProfileState.bankDetails] with loaded bank details.
  Future<void> _loadBankDetails() async {
    try {
      final response = await _client
          .from('bank_accounts')
          .select()
          .eq('is_primary', true)
          .maybeSingle();

      if (response != null) {
        state = state.copyWith(bankDetails: BankDetails.fromJson(response));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileNotifier._loadBankDetails error: $e');
      }
    }
  }

  /// Loads app notifications.
  ///
  /// Fetches the 50 most recent notifications.
  ///
  /// ## State Updates
  ///
  /// Updates [ProfileState.notifications] with loaded notifications.
  Future<void> _loadNotifications() async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      final notifications = (response as List)
          .map((e) => AppNotification.fromJson(e))
          .toList();

      state = state.copyWith(notifications: notifications);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileNotifier._loadNotifications error: $e');
      }
    }
  }

  /// Loads notification preferences.
  ///
  /// Fetches the user's notification preference settings.
  ///
  /// ## State Updates
  ///
  /// Updates [ProfileState.notificationPreferences] with loaded preferences.
  Future<void> _loadNotificationPreferences() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      final response = await _client
          .from('notification_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        state = state.copyWith(
          notificationPreferences: NotificationPreferences.fromJson(response),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileNotifier._loadNotificationPreferences error: $e');
      }
    }
  }

  /// Updates the user's profile information.
  ///
  /// ## Parameters
  ///
  /// - [fullName]: Updated full name
  /// - [phone]: Updated phone number
  /// - [bio]: Updated biography
  /// - [education]: Updated education
  /// - [skills]: Updated skills list
  ///
  /// ## Returns
  ///
  /// `true` if update was successful, `false` otherwise.
  ///
  /// ## State Updates
  ///
  /// Sets [isSaving] to true during save, false on completion.
  /// Updates [ProfileState.profile] with new data.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final success = await ref.read(profileProvider.notifier).updateProfile(
  ///   fullName: 'John Doe',
  ///   bio: 'Expert in academic writing',
  /// );
  /// ```
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? bio,
    String? education,
    List<String>? skills,
  }) async {
    if (state.profile == null) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final updatedProfile = state.profile!.copyWith(
        fullName: fullName,
        phone: phone,
        bio: bio,
        education: education,
        skills: skills,
      );

      await _client
          .from('profiles')
          .update(updatedProfile.toJson())
          .eq('id', state.profile!.id);

      state = state.copyWith(
        profile: updatedProfile,
        isSaving: false,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileNotifier.updateProfile error: $e');
      }
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to update profile',
      );
      return false;
    }
  }

  /// Uploads a new avatar image and updates the profile.
  ///
  /// ## Parameters
  ///
  /// - [imageFile]: The image file to upload
  ///
  /// ## Returns
  ///
  /// `true` if upload was successful, `false` otherwise.
  ///
  /// ## State Updates
  ///
  /// Sets [isSaving] to true during upload, false on completion.
  /// Updates [UserProfile.avatarUrl] with the new image URL.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final imageFile = File('/path/to/image.jpg');
  /// final success = await ref.read(profileProvider.notifier).uploadAvatar(imageFile);
  /// if (success) {
  ///   // Show success message
  /// }
  /// ```
  Future<bool> uploadAvatar(File imageFile) async {
    if (state.profile == null) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'User not authenticated',
        );
        return false;
      }

      // Upload to Supabase storage
      final fileName = 'avatar_$userId.jpg';
      final path = 'avatars/$fileName';

      await _client.storage.from(ApiConstants.profileImagesBucket).upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      final avatarUrl = _client.storage
          .from(ApiConstants.profileImagesBucket)
          .getPublicUrl(path);

      // Update profile with new avatar URL
      await _client
          .from('profiles')
          .update({'avatar_url': avatarUrl})
          .eq('id', userId);

      // Update local state
      final updatedProfile = state.profile!.copyWith(avatarUrl: avatarUrl);
      state = state.copyWith(
        profile: updatedProfile,
        isSaving: false,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileNotifier.uploadAvatar error: $e');
      }
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to upload avatar: $e',
      );
      return false;
    }
  }

  /// Updates the user's availability status.
  ///
  /// ## Parameters
  ///
  /// - [isAvailable]: New availability status
  ///
  /// ## State Updates
  ///
  /// Updates [UserProfile.isAvailable] in the profile.
  Future<void> updateAvailability(bool isAvailable) async {
    if (state.profile == null) return;

    final updatedProfile = state.profile!.copyWith(isAvailable: isAvailable);
    state = state.copyWith(profile: updatedProfile);

    try {
      await _client
          .from('doers')
          .update({'is_available': isAvailable})
          .eq('profile_id', state.profile!.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileNotifier.updateAvailability error: $e');
      }
    }
  }

  /// Updates notification preferences.
  ///
  /// ## Parameters
  ///
  /// - [preferences]: New notification preferences
  ///
  /// ## State Updates
  ///
  /// Updates [ProfileState.notificationPreferences] with new preferences.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await ref.read(profileProvider.notifier).updateNotificationPreferences(
  ///   currentPreferences.copyWith(marketingEmails: false),
  /// );
  /// ```
  Future<void> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    state = state.copyWith(notificationPreferences: preferences);

    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      await _client.from('notification_preferences').upsert({
        'user_id': user.id,
        ...preferences.toJson(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileNotifier.updateNotificationPreferences error: $e');
      }
    }
  }

  /// Marks a single notification as read.
  ///
  /// ## Parameters
  ///
  /// - [notificationId]: ID of the notification to mark as read
  ///
  /// ## State Updates
  ///
  /// Updates the notification's [isRead] status to true.
  Future<void> markNotificationRead(String notificationId) async {
    final notifications = state.notifications.map((n) {
      if (n.id == notificationId) {
        return AppNotification(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          createdAt: n.createdAt,
          isRead: true,
          actionUrl: n.actionUrl,
          data: n.data,
        );
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: notifications);

    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileNotifier.markNotificationRead error: $e');
      }
    }
  }

  /// Marks all notifications as read.
  ///
  /// ## State Updates
  ///
  /// Updates all notifications' [isRead] status to true.
  Future<void> markAllNotificationsRead() async {
    final notifications = state.notifications.map((n) {
      return AppNotification(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        createdAt: n.createdAt,
        isRead: true,
        actionUrl: n.actionUrl,
        data: n.data,
      );
    }).toList();

    state = state.copyWith(notifications: notifications);

    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileNotifier.markAllNotificationsRead error: $e');
      }
    }
  }

  /// Refreshes all profile data from the database.
  ///
  /// Use this method to reload profile data after external changes
  /// or for pull-to-refresh functionality.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Pull-to-refresh in profile screen
  /// RefreshIndicator(
  ///   onRefresh: () => ref.read(profileProvider.notifier).refresh(),
  ///   child: ProfileContent(),
  /// );
  /// ```
  Future<void> refresh() async {
    await _loadProfile();
  }
}

/// The main profile provider.
///
/// Use this provider to access profile state and manage profile operations.
///
/// ## Watching State
///
/// ```dart
/// // In a widget
/// final profileState = ref.watch(profileProvider);
///
/// if (profileState.isLoading) {
///   return LoadingScreen();
/// }
///
/// return ProfileContent(
///   profile: profileState.profile!,
///   notifications: profileState.notifications,
/// );
/// ```
///
/// ## Performing Operations
///
/// ```dart
/// // Update profile
/// await ref.read(profileProvider.notifier).updateProfile(
///   fullName: 'New Name',
/// );
///
/// // Mark notification as read
/// await ref.read(profileProvider.notifier).markNotificationRead(id);
/// ```
final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

/// Convenience provider for accessing the user profile.
///
/// Returns the [UserProfile] if loaded, null otherwise.
///
/// ## Usage
///
/// ```dart
/// final profile = ref.watch(userProfileProvider);
///
/// if (profile != null) {
///   Text(profile.fullName);
/// }
/// ```
final userProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(profileProvider).profile;
});

/// Convenience provider for accessing payment history.
///
/// Returns the list of [PaymentTransaction] records.
///
/// ## Usage
///
/// ```dart
/// final payments = ref.watch(paymentHistoryProvider);
///
/// return PaymentHistoryList(payments: payments);
/// ```
final paymentHistoryProvider = Provider<List<PaymentTransaction>>((ref) {
  return ref.watch(profileProvider).paymentHistory;
});

/// Convenience provider for accessing notifications.
///
/// Returns the list of [AppNotification] objects.
///
/// ## Usage
///
/// ```dart
/// final notifications = ref.watch(notificationsProvider);
///
/// return NotificationsList(notifications: notifications);
/// ```
final notificationsProvider = Provider<List<AppNotification>>((ref) {
  return ref.watch(profileProvider).notifications;
});

/// Convenience provider for accessing unread notification count.
///
/// Returns the number of unread notifications.
///
/// ## Usage
///
/// ```dart
/// final unreadCount = ref.watch(unreadNotificationCountProvider);
///
/// if (unreadCount > 0) {
///   Badge(count: unreadCount);
/// }
/// ```
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(profileProvider).unreadNotificationCount;
});

/// Convenience provider for accessing profile loading state.
///
/// Returns `true` if profile data is being loaded.
///
/// ## Usage
///
/// ```dart
/// final isLoading = ref.watch(profileLoadingProvider);
///
/// if (isLoading) {
///   return CircularProgressIndicator();
/// }
/// ```
final profileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).isLoading;
});
