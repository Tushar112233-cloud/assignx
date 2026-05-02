import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/animations/page_transitions.dart';

/// Key used to store reduced motion preference in SharedPreferences.
const String _reducedMotionKey = 'reduced_motion';

/// Provider for reduced motion preference.
///
/// Combines system-level reduced motion setting with user preference.
/// User preference takes precedence if explicitly set.
///
/// Usage:
/// ```dart
/// final reducedMotion = ref.watch(reducedMotionProvider);
/// if (reducedMotion) {
///   // Use instant transitions
/// } else {
///   // Use normal animations
/// }
/// ```
final reducedMotionProvider =
    StateNotifierProvider<ReducedMotionNotifier, bool>((ref) {
  return ReducedMotionNotifier();
});

/// Notifier for managing reduced motion state.
///
/// Checks both system accessibility settings and user preferences.
/// User preference (stored in SharedPreferences) takes precedence.
class ReducedMotionNotifier extends StateNotifier<bool> {
  /// Creates a new [ReducedMotionNotifier].
  ///
  /// Initializes with false and loads preference asynchronously.
  ReducedMotionNotifier() : super(false) {
    _loadPreference();
  }

  /// User's explicit preference (null means follow system).
  bool? _userPreference;

  /// Whether the system has reduced motion enabled.
  bool _systemReducedMotion = false;

  /// Load the user's preference from SharedPreferences.
  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if user has explicitly set a preference
    if (prefs.containsKey(_reducedMotionKey)) {
      _userPreference = prefs.getBool(_reducedMotionKey);
    }

    // Update state based on user preference
    _updateState();
  }

  /// Update the state based on user preference and system setting.
  void _updateState() {
    // User preference takes precedence if set
    if (_userPreference != null) {
      state = _userPreference!;
    } else {
      // Fall back to system setting
      state = _systemReducedMotion;
    }
  }

  /// Check system accessibility settings.
  ///
  /// Call this method with the BuildContext to check
  /// MediaQueryData.disableAnimations.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void didChangeDependencies() {
  ///   super.didChangeDependencies();
  ///   ref.read(reducedMotionProvider.notifier).checkSystemSetting(context);
  /// }
  /// ```
  void checkSystemSetting(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery != null) {
      _systemReducedMotion = mediaQuery.disableAnimations;
      _updateState();
    }
  }

  /// Toggle the reduced motion preference.
  ///
  /// Saves the new preference to SharedPreferences.
  Future<void> toggle() async {
    await setReducedMotion(!state);
  }

  /// Set the reduced motion preference explicitly.
  ///
  /// [value] - true to enable reduced motion, false to disable.
  /// Saves the preference to SharedPreferences.
  Future<void> setReducedMotion(bool value) async {
    _userPreference = value;
    state = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reducedMotionKey, value);

    // Sync with the ReducedMotionHelper for page transitions
    ReducedMotionHelper.updateUserPreference(value);
  }

  /// Reset to follow system setting.
  ///
  /// Removes the user preference and follows system accessibility setting.
  Future<void> resetToSystem() async {
    _userPreference = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reducedMotionKey);

    // Sync with the ReducedMotionHelper for page transitions
    ReducedMotionHelper.updateUserPreference(null);

    _updateState();
  }

  /// Check if user has explicitly set a preference.
  bool get hasUserPreference => _userPreference != null;

  /// Get the current system setting.
  bool get systemReducedMotion => _systemReducedMotion;
}

/// Provider that checks if animations should be disabled.
///
/// Convenience provider that combines reduced motion preference
/// with additional conditions if needed.
final shouldReduceAnimationsProvider = Provider<bool>((ref) {
  return ref.watch(reducedMotionProvider);
});

/// Extension on WidgetRef for convenient reduced motion access.
extension ReducedMotionRefExtension on WidgetRef {
  /// Check if animations should be reduced.
  bool get shouldReduceMotion => watch(reducedMotionProvider);

  /// Get the animation duration respecting reduced motion.
  Duration getAnimationDuration(Duration normalDuration) {
    return shouldReduceMotion ? Duration.zero : normalDuration;
  }

  /// Get the animation curve respecting reduced motion.
  Curve getAnimationCurve(Curve normalCurve) {
    return shouldReduceMotion ? Curves.linear : normalCurve;
  }
}
