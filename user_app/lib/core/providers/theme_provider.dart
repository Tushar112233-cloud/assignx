/// Theme provider for the AssignX application.
///
/// Re-exports the base theme provider with all its components:
/// - [ThemeNotifier] with setLight(), setDark(), setSystem(), toggle()
/// - [themeProvider] - StateNotifierProvider for AppThemeMode
/// - [themeModeProvider] - Provider that converts to Flutter ThemeMode
/// - [isDarkModeProvider] - Provider indicating if dark mode is active
/// - [AppThemeMode] enum
///
/// The base implementation handles SharedPreferences persistence
/// with key 'app_theme_mode'.
library;

export '../../providers/theme_provider.dart';
