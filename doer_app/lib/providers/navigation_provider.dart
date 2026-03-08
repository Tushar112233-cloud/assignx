import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier that manages the active bottom nav bar tab index.
///
/// Tab indices:
/// - 0: Dashboard
/// - 1: Projects
/// - 2: Resources
/// - 3: Earnings
/// - 4: Profile
class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Sets the active tab index.
  void setIndex(int index) {
    state = index;
  }
}

/// Tracks which tab is active in the bottom nav bar.
/// 0: Dashboard, 1: Projects, 2: Resources, 3: Earnings, 4: Profile
final navigationIndexProvider =
    NotifierProvider<NavigationIndexNotifier, int>(() {
  return NavigationIndexNotifier();
});
