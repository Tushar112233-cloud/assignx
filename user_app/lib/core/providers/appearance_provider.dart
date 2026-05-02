import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// APPEARANCE STATE MODEL
// ============================================================

/// State class for appearance preferences.
/// Controls visual settings like reduced motion and compact mode.
class AppearanceState {
  /// Whether animations should be reduced for accessibility.
  final bool reducedMotion;

  /// Whether the UI should use a more compact layout.
  final bool compactMode;

  /// Whether preferences are currently loading.
  final bool isLoading;

  const AppearanceState({
    this.reducedMotion = false,
    this.compactMode = false,
    this.isLoading = false,
  });

  /// Create a copy with modified fields.
  AppearanceState copyWith({
    bool? reducedMotion,
    bool? compactMode,
    bool? isLoading,
  }) {
    return AppearanceState(
      reducedMotion: reducedMotion ?? this.reducedMotion,
      compactMode: compactMode ?? this.compactMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ============================================================
// APPEARANCE NOTIFIER
// ============================================================

/// StateNotifier for managing appearance preferences.
/// Handles loading from and persisting to SharedPreferences.
class AppearanceNotifier extends StateNotifier<AppearanceState> {
  AppearanceNotifier() : super(const AppearanceState(isLoading: true)) {
    _loadPreferences();
  }

  // SharedPreferences keys
  static const String _keyReducedMotion = 'reduced_motion';
  static const String _keyCompactMode = 'compact_mode';

  /// Load preferences from SharedPreferences.
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = AppearanceState(
        reducedMotion: prefs.getBool(_keyReducedMotion) ?? false,
        compactMode: prefs.getBool(_keyCompactMode) ?? false,
        isLoading: false,
      );
    } catch (e) {
      state = const AppearanceState(isLoading: false);
    }
  }

  /// Toggle reduced motion preference.
  Future<void> toggleReducedMotion(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReducedMotion, value);
    state = state.copyWith(reducedMotion: value);
  }

  /// Toggle compact mode preference.
  Future<void> toggleCompactMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompactMode, value);
    state = state.copyWith(compactMode: value);
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

/// Provider for appearance notifier.
/// Manages appearance state (reduced motion, compact mode) and persistence.
final appearanceProvider =
    StateNotifierProvider<AppearanceNotifier, AppearanceState>((ref) {
  return AppearanceNotifier();
});
