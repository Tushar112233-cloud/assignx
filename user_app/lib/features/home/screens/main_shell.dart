import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/home_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';
import '../../campus_connect/screens/campus_connect_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../dashboard/widgets/bottom_nav_bar.dart';
import '../../experts/screens/experts_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/screens/wallet_screen.dart';
import '../../projects/screens/my_projects_screen.dart';

/// Main app shell with bottom navigation.
///
/// Provides a floating pill-shaped navigation bar at the bottom
/// with 6 items:
/// 0: Home (Dashboard)
/// 1: Projects
/// 2: Campus Connect (Community)
/// 3: Experts
/// 4: Wallet
/// 5: Profile
///
/// Settings is accessible from the Profile screen.
/// Features subtle gradient background patches for elegant visual design.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final profileAsync = ref.watch(userProfileProvider);

    // Get avatar URL from profile
    final avatarUrl = profileAsync.valueOrNull?.avatarUrl;

    return SubtleGradientScaffold.standard(
      body: Stack(
        children: [
          // Main content with IndexedStack for state preservation
          IndexedStack(
            index: currentIndex,
            children: const [
              DashboardScreen(),      // 0: Home
              MyProjectsScreen(),     // 1: Projects
              CampusConnectScreen(),  // 2: Campus Connect
              ExpertsScreen(),        // 3: Experts
              WalletScreen(),         // 4: Wallet
              ProfileScreen(),        // 5: Profile
            ],
          ),
          // Bottom navigation bar per design spec
          BottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
            profileImageUrl: avatarUrl,
          ),
        ],
      ),
    );
  }
}
