import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// PREFERENCES STATE MODEL
// ============================================================

/// State class for user preferences.
/// Contains all toggleable preferences that persist across sessions.
class PreferencesState {
  /// Whether push notifications are enabled.
  final bool pushNotifications;

  /// Whether email notifications are enabled.
  final bool emailNotifications;

  /// Whether project update notifications are enabled.
  final bool projectUpdates;

  /// Whether promotional messages are enabled.
  final bool promotionalMessages;

  /// Whether preferences are currently loading.
  final bool isLoading;

  const PreferencesState({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.projectUpdates = true,
    this.promotionalMessages = false,
    this.isLoading = false,
  });

  /// Create a copy with modified fields.
  PreferencesState copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? projectUpdates,
    bool? promotionalMessages,
    bool? isLoading,
  }) {
    return PreferencesState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      projectUpdates: projectUpdates ?? this.projectUpdates,
      promotionalMessages: promotionalMessages ?? this.promotionalMessages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ============================================================
// PREFERENCES NOTIFIER
// ============================================================

/// StateNotifier for managing user preferences.
/// Handles loading from and persisting to SharedPreferences.
class PreferencesNotifier extends StateNotifier<PreferencesState> {
  PreferencesNotifier() : super(const PreferencesState(isLoading: true)) {
    _loadPreferences();
  }

  // SharedPreferences keys
  static const String _keyPushNotifications = 'pref_push_notifications';
  static const String _keyEmailNotifications = 'pref_email_notifications';
  static const String _keyProjectUpdates = 'pref_project_updates';
  static const String _keyPromotionalMessages = 'pref_promotional_messages';

  /// Load preferences from SharedPreferences.
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      state = PreferencesState(
        pushNotifications: prefs.getBool(_keyPushNotifications) ?? true,
        emailNotifications: prefs.getBool(_keyEmailNotifications) ?? true,
        projectUpdates: prefs.getBool(_keyProjectUpdates) ?? true,
        promotionalMessages: prefs.getBool(_keyPromotionalMessages) ?? false,
        isLoading: false,
      );
    } catch (e) {
      // On error, use defaults
      state = const PreferencesState(isLoading: false);
    }
  }

  /// Toggle push notifications preference.
  Future<void> togglePushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPushNotifications, value);
    state = state.copyWith(pushNotifications: value);
  }

  /// Toggle email notifications preference.
  Future<void> toggleEmailNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEmailNotifications, value);
    state = state.copyWith(emailNotifications: value);
  }

  /// Toggle project updates preference.
  Future<void> toggleProjectUpdates(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyProjectUpdates, value);
    state = state.copyWith(projectUpdates: value);
  }

  /// Toggle promotional messages preference.
  Future<void> togglePromotionalMessages(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPromotionalMessages, value);
    state = state.copyWith(promotionalMessages: value);
  }

  /// Reset all preferences to defaults.
  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPushNotifications);
    await prefs.remove(_keyEmailNotifications);
    await prefs.remove(_keyProjectUpdates);
    await prefs.remove(_keyPromotionalMessages);

    state = const PreferencesState(isLoading: false);
  }

  /// Refresh preferences from storage.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadPreferences();
  }
}

// ============================================================
// PROVIDERS
// ============================================================

/// Provider for preferences notifier.
/// Manages user preferences state and persistence.
final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesState>((ref) {
  return PreferencesNotifier();
});

/// Provider for loading initial preferences.
/// Use this to await initial preferences load.
final preferencesLoadedProvider = FutureProvider<PreferencesState>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  return PreferencesState(
    pushNotifications: prefs.getBool('pref_push_notifications') ?? true,
    emailNotifications: prefs.getBool('pref_email_notifications') ?? true,
    projectUpdates: prefs.getBool('pref_project_updates') ?? true,
    promotionalMessages: prefs.getBool('pref_promotional_messages') ?? false,
    isLoading: false,
  );
});
