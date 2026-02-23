import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// All user-configurable settings persisted via SharedPreferences.
class SettingsState {
  const SettingsState({
    // Notifications
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 7, minute: 0),
    // Appearance
    this.themeMode = ThemeMode.system,
    // Privacy
    this.profileVisible = true,
    this.twoFactorEnabled = false,
    // Language
    this.displayLanguage = 'English',
    this.timezone = 'UTC',
  });

  final bool emailNotifications;
  final bool pushNotifications;
  final bool quietHoursEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  final ThemeMode themeMode;

  final bool profileVisible;
  final bool twoFactorEnabled;

  final String displayLanguage;
  final String timezone;

  SettingsState copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? quietHoursEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    ThemeMode? themeMode,
    bool? profileVisible,
    bool? twoFactorEnabled,
    String? displayLanguage,
    String? timezone,
  }) {
    return SettingsState(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      themeMode: themeMode ?? this.themeMode,
      profileVisible: profileVisible ?? this.profileVisible,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      displayLanguage: displayLanguage ?? this.displayLanguage,
      timezone: timezone ?? this.timezone,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  static const _prefix = 'settings_';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      state = SettingsState(
        emailNotifications: prefs.getBool('${_prefix}email_notifications') ?? true,
        pushNotifications: prefs.getBool('${_prefix}push_notifications') ?? true,
        quietHoursEnabled: prefs.getBool('${_prefix}quiet_hours_enabled') ?? false,
        quietHoursStart: _timeFromMinutes(
          prefs.getInt('${_prefix}quiet_hours_start') ?? 22 * 60,
        ),
        quietHoursEnd: _timeFromMinutes(
          prefs.getInt('${_prefix}quiet_hours_end') ?? 7 * 60,
        ),
        themeMode: ThemeMode.values[prefs.getInt('${_prefix}theme_mode') ?? 0],
        profileVisible: prefs.getBool('${_prefix}profile_visible') ?? true,
        twoFactorEnabled: prefs.getBool('${_prefix}two_factor_enabled') ?? false,
        displayLanguage: prefs.getString('${_prefix}display_language') ?? 'English',
        timezone: prefs.getString('${_prefix}timezone') ?? 'UTC',
      );
    } catch (_) {
      // Keep defaults on failure
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool('${_prefix}email_notifications', state.emailNotifications),
        prefs.setBool('${_prefix}push_notifications', state.pushNotifications),
        prefs.setBool('${_prefix}quiet_hours_enabled', state.quietHoursEnabled),
        prefs.setInt('${_prefix}quiet_hours_start', _timeToMinutes(state.quietHoursStart)),
        prefs.setInt('${_prefix}quiet_hours_end', _timeToMinutes(state.quietHoursEnd)),
        prefs.setInt('${_prefix}theme_mode', state.themeMode.index),
        prefs.setBool('${_prefix}profile_visible', state.profileVisible),
        prefs.setBool('${_prefix}two_factor_enabled', state.twoFactorEnabled),
        prefs.setString('${_prefix}display_language', state.displayLanguage),
        prefs.setString('${_prefix}timezone', state.timezone),
      ]);
    } catch (_) {
      // Silently fail
    }
  }

  void setEmailNotifications(bool value) {
    state = state.copyWith(emailNotifications: value);
    _save();
  }

  void setPushNotifications(bool value) {
    state = state.copyWith(pushNotifications: value);
    _save();
  }

  void setQuietHoursEnabled(bool value) {
    state = state.copyWith(quietHoursEnabled: value);
    _save();
  }

  void setQuietHoursStart(TimeOfDay value) {
    state = state.copyWith(quietHoursStart: value);
    _save();
  }

  void setQuietHoursEnd(TimeOfDay value) {
    state = state.copyWith(quietHoursEnd: value);
    _save();
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _save();
  }

  void setProfileVisible(bool value) {
    state = state.copyWith(profileVisible: value);
    _save();
  }

  void setTwoFactorEnabled(bool value) {
    state = state.copyWith(twoFactorEnabled: value);
    _save();
  }

  void setDisplayLanguage(String value) {
    state = state.copyWith(displayLanguage: value);
    _save();
  }

  void setTimezone(String value) {
    state = state.copyWith(timezone: value);
    _save();
  }

  static TimeOfDay _timeFromMinutes(int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  static int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
