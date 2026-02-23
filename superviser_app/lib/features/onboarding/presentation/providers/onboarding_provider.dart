import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/constants.dart';

/// State for onboarding completion tracking.
class OnboardingState {
  const OnboardingState({
    this.isCompleted = false,
    this.isLoading = true,
  });

  final bool isCompleted;
  final bool isLoading;

  OnboardingState copyWith({
    bool? isCompleted,
    bool? isLoading,
  }) {
    return OnboardingState(
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for onboarding state management.
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState()) {
    _loadOnboardingStatus();
  }

  static const _key = AppConstants.storageKeyOnboardingComplete;

  /// Loads onboarding completion status from storage
  Future<void> _loadOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isCompleted = prefs.getBool(_key) ?? false;
      state = OnboardingState(
        isCompleted: isCompleted,
        isLoading: false,
      );
    } catch (e) {
      state = const OnboardingState(
        isCompleted: false,
        isLoading: false,
      );
    }
  }

  /// Marks onboarding as completed
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
      state = state.copyWith(isCompleted: true);
    } catch (e) {
      // Silently fail - onboarding will show again next time
    }
  }

  /// Resets onboarding (for testing/debugging)
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      state = state.copyWith(isCompleted: false);
    } catch (e) {
      // Silently fail
    }
  }
}

/// Provider for onboarding state
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);

/// Provider for checking if onboarding is completed
final isOnboardingCompleteProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider).isCompleted;
});

/// Provider for checking if onboarding status is loading
final isOnboardingLoadingProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider).isLoading;
});
