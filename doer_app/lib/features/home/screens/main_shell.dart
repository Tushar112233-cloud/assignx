import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/navigation_provider.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../dashboard/widgets/bottom_nav_bar.dart';
import '../../projects/screens/my_projects_screen.dart';
import '../../resources/screens/resources_hub_screen.dart';
import '../../profile/screens/payment_history_screen.dart';
import '../../profile/screens/profile_screen.dart';

/// Main app shell with bottom navigation.
///
/// Provides a floating pill-shaped navigation bar at the bottom
/// with 5 items:
/// 0: Dashboard
/// 1: Projects
/// 2: Resources
/// 3: Earnings (Payment History)
/// 4: Profile
///
/// Features subtle gradient background with teal/cyan corner orbs.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    // TODO: Get avatar URL from doer profile provider when available
    const String? avatarUrl = null;

    return SubtleGradientScaffold.standard(
      body: Stack(
        children: [
          // Main content with IndexedStack for state preservation
          IndexedStack(
            index: currentIndex,
            children: const [
              DashboardScreen(),        // 0: Dashboard
              MyProjectsScreen(),       // 1: Projects
              ResourcesHubScreen(),     // 2: Resources
              PaymentHistoryScreen(),   // 3: Earnings
              ProfileScreen(),          // 4: Profile
            ],
          ),
          // Floating bottom navigation bar
          BottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) =>
                ref.read(navigationIndexProvider.notifier).setIndex(index),
            profileImageUrl: avatarUrl,
          ),
        ],
      ),
    );
  }
}
