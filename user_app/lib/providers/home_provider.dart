import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/banner_model.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/home_repository.dart';
import 'auth_provider.dart';

// Note: walletProvider is defined in profile_provider.dart to avoid duplication

/// Home repository provider.
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

/// Promotional banners provider.
final bannersProvider = FutureProvider<List<AppBanner>>((ref) async {
  final repository = ref.read(homeRepositoryProvider);
  return repository.getBanners();
});

/// User notifications provider.
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repository = ref.read(homeRepositoryProvider);
  return repository.getNotifications(user.id);
});

/// Unread notification count provider.
final unreadCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final repository = ref.read(homeRepositoryProvider);
  return repository.getUnreadCount(user.id);
});

/// Navigation index provider for bottom navigation.
/// Note: This is the canonical provider - do not duplicate elsewhere.
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Navigation items for bottom bar.
/// Matches the 5-item IndexedStack in MainShell.
enum NavItem {
  home,       // 0: Dashboard
  projects,   // 1: My Projects
  connect,    // 2: Campus Connect
  // experts, // Hidden for now; keep enum slot commented for future restore.
  wallet,     // 3: Wallet
  profile,    // 4: Profile
}

extension NavItemExtension on NavItem {
  String get label {
    switch (this) {
      case NavItem.home:
        return 'Home';
      case NavItem.projects:
        return 'Projects';
      case NavItem.connect:
        return 'Connect';
      case NavItem.wallet:
        return 'Wallet';
      case NavItem.profile:
        return 'Profile';
    }
  }

  /// Index in the MainShell IndexedStack.
  int get index => NavItem.values.indexOf(this);
}
