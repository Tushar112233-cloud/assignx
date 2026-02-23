import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App theme mode enum with system, light, and dark options.
enum AppThemeMode {
  system,
  light,
  dark;

  /// Convert to display string for UI.
  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  /// Convert to string for storage.
  String toStorageString() => name;

  /// Parse from storage string.
  static AppThemeMode fromStorageString(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }
}

/// Storage key for theme preference.
const String _themeStorageKey = 'app_theme_mode';

/// Provider for app theme mode with persistence.
///
/// Loads the theme preference from SharedPreferences on initialization
/// and persists changes automatically.
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

/// Provider that converts [AppThemeMode] to Flutter's [ThemeMode].
///
/// Use this provider in MaterialApp's themeMode property.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final appTheme = ref.watch(themeProvider);
  switch (appTheme) {
    case AppThemeMode.system:
      return ThemeMode.system;
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
  }
});

/// Provider that indicates if dark mode is currently active.
///
/// Takes into account system theme when AppThemeMode.system is selected.
final isDarkModeProvider = Provider<bool>((ref) {
  final appTheme = ref.watch(themeProvider);
  switch (appTheme) {
    case AppThemeMode.light:
      return false;
    case AppThemeMode.dark:
      return true;
    case AppThemeMode.system:
      // For system mode, we need to check platform brightness
      // This will be determined by the actual theme applied
      return false; // Default to light for initial load
  }
});

/// State notifier for managing theme preferences.
///
/// Handles loading from and saving to SharedPreferences.
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  /// Load theme preference from SharedPreferences.
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedTheme = prefs.getString(_themeStorageKey);
      state = AppThemeMode.fromStorageString(storedTheme);
    } catch (e) {
      // If loading fails, keep the default (system)
      debugPrint('Failed to load theme preference: $e');
    }
  }

  /// Set the theme mode and persist to SharedPreferences.
  Future<void> setTheme(AppThemeMode mode) async {
    if (state == mode) return;

    state = mode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeStorageKey, mode.toStorageString());
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }

  /// Toggle between light and dark mode.
  ///
  /// If currently on system mode, toggles to light.
  /// If on light, toggles to dark.
  /// If on dark, toggles to light.
  Future<void> toggle() async {
    switch (state) {
      case AppThemeMode.system:
      case AppThemeMode.dark:
        await setTheme(AppThemeMode.light);
        break;
      case AppThemeMode.light:
        await setTheme(AppThemeMode.dark);
        break;
    }
  }

  /// Cycle through all theme modes: system -> light -> dark -> system.
  Future<void> cycle() async {
    switch (state) {
      case AppThemeMode.system:
        await setTheme(AppThemeMode.light);
        break;
      case AppThemeMode.light:
        await setTheme(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
        await setTheme(AppThemeMode.system);
        break;
    }
  }
}
