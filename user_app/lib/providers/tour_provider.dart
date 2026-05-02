import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/tour_step.dart';

/// Keys for storing tour completion status.
class TourPrefsKeys {
  static const String dashboardTourCompleted = 'tour_dashboard_completed';
  static const String projectsTourCompleted = 'tour_projects_completed';
  static const String profileTourCompleted = 'tour_profile_completed';
  static const String dontShowToursAgain = 'tour_dont_show_again';
}

/// State for the tour system.
class TourState {
  /// Whether the dashboard tour has been completed.
  final bool dashboardTourCompleted;

  /// Whether the projects tour has been completed.
  final bool projectsTourCompleted;

  /// Whether the profile tour has been completed.
  final bool profileTourCompleted;

  /// Current step index in the active tour.
  final int currentStep;

  /// Whether a tour is currently active.
  final bool isActive;

  /// Current active tour configuration.
  final TourConfig? activeTour;

  /// Whether user has opted out of all tours.
  final bool dontShowAgain;

  /// Whether tour state is loading from storage.
  final bool isLoading;

  const TourState({
    this.dashboardTourCompleted = false,
    this.projectsTourCompleted = false,
    this.profileTourCompleted = false,
    this.currentStep = 0,
    this.isActive = false,
    this.activeTour,
    this.dontShowAgain = false,
    this.isLoading = true,
  });

  /// Creates a copy with updated fields.
  TourState copyWith({
    bool? dashboardTourCompleted,
    bool? projectsTourCompleted,
    bool? profileTourCompleted,
    int? currentStep,
    bool? isActive,
    TourConfig? activeTour,
    bool clearActiveTour = false,
    bool? dontShowAgain,
    bool? isLoading,
  }) {
    return TourState(
      dashboardTourCompleted:
          dashboardTourCompleted ?? this.dashboardTourCompleted,
      projectsTourCompleted:
          projectsTourCompleted ?? this.projectsTourCompleted,
      profileTourCompleted: profileTourCompleted ?? this.profileTourCompleted,
      currentStep: currentStep ?? this.currentStep,
      isActive: isActive ?? this.isActive,
      activeTour: clearActiveTour ? null : (activeTour ?? this.activeTour),
      dontShowAgain: dontShowAgain ?? this.dontShowAgain,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Gets the current step data if a tour is active.
  TourStep? get currentStepData {
    if (!isActive || activeTour == null) return null;
    return activeTour!.getStep(currentStep);
  }

  /// Whether there are more steps after the current one.
  bool get hasNextStep {
    if (activeTour == null) return false;
    return currentStep < activeTour!.totalSteps - 1;
  }

  /// Whether there are steps before the current one.
  bool get hasPreviousStep => currentStep > 0;

  /// Total number of steps in the active tour.
  int get totalSteps => activeTour?.totalSteps ?? 0;

  /// Whether a specific tour has been completed.
  bool isTourCompleted(String tourId) {
    switch (tourId) {
      case 'dashboard':
        return dashboardTourCompleted;
      case 'projects':
        return projectsTourCompleted;
      case 'profile':
        return profileTourCompleted;
      default:
        return false;
    }
  }
}

/// Notifier for managing tour state.
class TourNotifier extends StateNotifier<TourState> {
  TourNotifier() : super(const TourState()) {
    _loadFromPrefs();
  }

  /// Loads tour completion status from SharedPreferences.
  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = state.copyWith(
        dashboardTourCompleted:
            prefs.getBool(TourPrefsKeys.dashboardTourCompleted) ?? false,
        projectsTourCompleted:
            prefs.getBool(TourPrefsKeys.projectsTourCompleted) ?? false,
        profileTourCompleted:
            prefs.getBool(TourPrefsKeys.profileTourCompleted) ?? false,
        dontShowAgain:
            prefs.getBool(TourPrefsKeys.dontShowToursAgain) ?? false,
        isLoading: false,
      );
    } catch (e) {
      // If loading fails, just mark as not loading
      state = state.copyWith(isLoading: false);
    }
  }

  /// Starts a tour with the given configuration.
  void startTour(TourConfig tour) {
    if (state.dontShowAgain) return;
    if (state.isTourCompleted(tour.tourId)) return;

    state = state.copyWith(
      activeTour: tour,
      currentStep: 0,
      isActive: true,
    );
  }

  /// Moves to the next step in the tour.
  void nextStep() {
    if (!state.isActive || state.activeTour == null) return;

    if (state.hasNextStep) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    } else {
      // Last step - complete the tour
      completeTour();
    }
  }

  /// Moves to the previous step in the tour.
  void previousStep() {
    if (!state.isActive || !state.hasPreviousStep) return;
    state = state.copyWith(currentStep: state.currentStep - 1);
  }

  /// Jumps to a specific step.
  void goToStep(int step) {
    if (!state.isActive || state.activeTour == null) return;
    if (step < 0 || step >= state.totalSteps) return;
    state = state.copyWith(currentStep: step);
  }

  /// Skips the current tour without marking it as completed.
  void skipTour() {
    if (!state.isActive || state.activeTour == null) return;
    state = state.copyWith(
      isActive: false,
      currentStep: 0,
      clearActiveTour: true,
    );
  }

  /// Completes the current tour and saves the status.
  Future<void> completeTour() async {
    if (!state.isActive || state.activeTour == null) return;

    final tourId = state.activeTour!.tourId;

    // Update state
    switch (tourId) {
      case 'dashboard':
        state = state.copyWith(
          dashboardTourCompleted: true,
          isActive: false,
          currentStep: 0,
          clearActiveTour: true,
        );
        break;
      case 'projects':
        state = state.copyWith(
          projectsTourCompleted: true,
          isActive: false,
          currentStep: 0,
          clearActiveTour: true,
        );
        break;
      case 'profile':
        state = state.copyWith(
          profileTourCompleted: true,
          isActive: false,
          currentStep: 0,
          clearActiveTour: true,
        );
        break;
      default:
        state = state.copyWith(
          isActive: false,
          currentStep: 0,
          clearActiveTour: true,
        );
    }

    // Persist to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (tourId) {
        case 'dashboard':
          await prefs.setBool(TourPrefsKeys.dashboardTourCompleted, true);
          break;
        case 'projects':
          await prefs.setBool(TourPrefsKeys.projectsTourCompleted, true);
          break;
        case 'profile':
          await prefs.setBool(TourPrefsKeys.profileTourCompleted, true);
          break;
      }
    } catch (e) {
      // Silently fail - tour completion will be tracked in memory
    }
  }

  /// Sets the "don't show again" preference.
  Future<void> setDontShowAgain(bool value) async {
    state = state.copyWith(dontShowAgain: value);

    if (value && state.isActive) {
      // If turning on, also skip the current tour
      skipTour();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(TourPrefsKeys.dontShowToursAgain, value);
    } catch (e) {
      // Silently fail
    }
  }

  /// Resets all tour completion status (for testing or user request).
  Future<void> resetAllTours() async {
    state = const TourState(isLoading: false);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(TourPrefsKeys.dashboardTourCompleted);
      await prefs.remove(TourPrefsKeys.projectsTourCompleted);
      await prefs.remove(TourPrefsKeys.profileTourCompleted);
      await prefs.remove(TourPrefsKeys.dontShowToursAgain);
    } catch (e) {
      // Silently fail
    }
  }

  /// Marks a specific tour as completed without showing it.
  Future<void> markTourCompleted(String tourId) async {
    switch (tourId) {
      case 'dashboard':
        state = state.copyWith(dashboardTourCompleted: true);
        break;
      case 'projects':
        state = state.copyWith(projectsTourCompleted: true);
        break;
      case 'profile':
        state = state.copyWith(profileTourCompleted: true);
        break;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      switch (tourId) {
        case 'dashboard':
          await prefs.setBool(TourPrefsKeys.dashboardTourCompleted, true);
          break;
        case 'projects':
          await prefs.setBool(TourPrefsKeys.projectsTourCompleted, true);
          break;
        case 'profile':
          await prefs.setBool(TourPrefsKeys.profileTourCompleted, true);
          break;
      }
    } catch (e) {
      // Silently fail
    }
  }
}

/// Main tour state provider.
final tourProvider = StateNotifierProvider<TourNotifier, TourState>((ref) {
  return TourNotifier();
});

/// Convenience provider for checking if dashboard tour should be shown.
final shouldShowDashboardTourProvider = Provider<bool>((ref) {
  final tourState = ref.watch(tourProvider);
  return !tourState.isLoading &&
      !tourState.dashboardTourCompleted &&
      !tourState.dontShowAgain;
});

/// Convenience provider for checking if a tour is currently active.
final isTourActiveProvider = Provider<bool>((ref) {
  return ref.watch(tourProvider).isActive;
});

/// Convenience provider for the current tour step.
final currentTourStepProvider = Provider<TourStep?>((ref) {
  return ref.watch(tourProvider).currentStepData;
});

/// Provider to share the navigation bar key with child screens.
/// This allows the dashboard tour to highlight the nav bar.
final navBarKeyProvider = StateProvider<GlobalKey?>((ref) => null);
