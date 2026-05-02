import 'package:flutter/material.dart';

import '../../../data/models/tour_step.dart';

/// GlobalKeys for dashboard widgets that can be highlighted in the tour.
class DashboardTourKeys {
  /// Key for the app bar / header area.
  final GlobalKey appBarKey = GlobalKey(debugLabel: 'tour_app_bar');

  /// Key for the greeting section.
  final GlobalKey greetingKey = GlobalKey(debugLabel: 'tour_greeting');

  /// Key for the quick stats row.
  final GlobalKey statsKey = GlobalKey(debugLabel: 'tour_stats');

  /// Key for the services grid.
  final GlobalKey servicesKey = GlobalKey(debugLabel: 'tour_services');

  /// Key for the needs attention section.
  final GlobalKey attentionKey = GlobalKey(debugLabel: 'tour_attention');

  /// Key for the recent projects section.
  final GlobalKey projectsKey = GlobalKey(debugLabel: 'tour_projects');

  /// Key for the bottom navigation bar.
  final GlobalKey navBarKey = GlobalKey(debugLabel: 'tour_nav_bar');

  /// Key for the notifications bell.
  final GlobalKey notificationsKey = GlobalKey(debugLabel: 'tour_notifications');

  /// Key for the profile avatar.
  final GlobalKey profileKey = GlobalKey(debugLabel: 'tour_profile');
}

/// Generates the dashboard tour steps configuration.
///
/// The tour highlights key areas of the dashboard:
/// 1. Welcome screen (centered, no target)
/// 2. Services grid
/// 3. Quick stats
/// 4. Recent projects
/// 5. Navigation bar
///
/// [navBarKey] is optional and can be provided from the main shell
/// to highlight the navigation bar in the tour.
///
/// Example:
/// ```dart
/// final keys = DashboardTourKeys();
/// final navBarKey = ref.read(navBarKeyProvider);
/// final tour = getDashboardTourConfig(keys, navBarKey: navBarKey);
/// ref.read(tourProvider.notifier).startTour(tour);
/// ```
TourConfig getDashboardTourConfig(DashboardTourKeys keys, {GlobalKey? navBarKey}) {
  return TourConfig(
    tourId: 'dashboard',
    steps: [
      // Step 1: Welcome
      TourStep(
        id: 'welcome',
        title: 'Welcome to AssignX!',
        description:
            'Your all-in-one academic assistance platform. Let us show you around and help you get started with our services.',
        targetKey: null, // Centered welcome
        position: TourPosition.center,
        icon: Icons.waving_hand_outlined,
        pulseAnimation: false,
      ),

      // Step 2: Services Grid
      TourStep(
        id: 'services',
        title: 'Quick Actions',
        description:
            'Access our core services here. Get project support, AI/plagiarism reports, expert consultations, and reference generators all in one place.',
        targetKey: keys.servicesKey,
        position: TourPosition.above,
        icon: Icons.auto_awesome,
        cutoutPadding: const EdgeInsets.all(12),
        pulseAnimation: true,
      ),

      // Step 3: Quick Stats
      TourStep(
        id: 'stats',
        title: 'Your Dashboard Stats',
        description:
            'Track your active projects, pending actions, and wallet balance at a glance. Stay on top of your academic work.',
        targetKey: keys.statsKey,
        position: TourPosition.below,
        icon: Icons.insights,
        cutoutPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Step 4: Recent Projects
      TourStep(
        id: 'projects',
        title: 'Recent Projects',
        description:
            'Quick access to your most recent projects. Tap any project to view details, track progress, or download deliverables.',
        targetKey: keys.projectsKey,
        position: TourPosition.above,
        icon: Icons.folder_outlined,
        cutoutPadding: const EdgeInsets.all(8),
      ),

      // Step 5: Navigation
      TourStep(
        id: 'navigation',
        title: 'Easy Navigation',
        description:
            'Use the bottom navigation to access all areas: Home, Projects, Campus Connect, Experts, Wallet, Settings, and your Profile.',
        targetKey: navBarKey ?? keys.navBarKey,
        position: TourPosition.above,
        icon: Icons.explore_outlined,
        cutoutPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        isLast: true,
      ),
    ],
    showStepIndicator: true,
    allowSkip: true,
    showDontShowAgain: true,
    overlayOpacity: 0.75,
    animationDurationMs: 350,
  );
}

/// Extended tour configuration for new users.
///
/// This version includes additional steps for notifications and profile.
TourConfig getExtendedDashboardTourConfig(DashboardTourKeys keys) {
  return TourConfig(
    tourId: 'dashboard',
    steps: [
      // Step 1: Welcome
      TourStep(
        id: 'welcome',
        title: 'Welcome to AssignX!',
        description:
            'Your all-in-one academic assistance platform. Let us show you around and help you get started.',
        targetKey: null,
        position: TourPosition.center,
        icon: Icons.waving_hand_outlined,
      ),

      // Step 2: Notifications
      TourStep(
        id: 'notifications',
        title: 'Stay Updated',
        description:
            'Receive important updates about your projects, payments, and deadlines. Never miss a notification.',
        targetKey: keys.notificationsKey,
        position: TourPosition.below,
        icon: Icons.notifications_outlined,
        cutoutPadding: const EdgeInsets.all(8),
        cutoutBorderRadius: 20,
      ),

      // Step 3: Services Grid
      TourStep(
        id: 'services',
        title: 'Quick Actions',
        description:
            'Access our core services: Project Support, AI/Plag Reports, Expert Sessions, and Reference Generator.',
        targetKey: keys.servicesKey,
        position: TourPosition.above,
        icon: Icons.auto_awesome,
        cutoutPadding: const EdgeInsets.all(12),
        pulseAnimation: true,
      ),

      // Step 4: Quick Stats
      TourStep(
        id: 'stats',
        title: 'Dashboard Stats',
        description:
            'Track active projects, pending actions, and wallet balance. Tap any stat for quick access.',
        targetKey: keys.statsKey,
        position: TourPosition.below,
        icon: Icons.insights,
      ),

      // Step 5: Recent Projects
      TourStep(
        id: 'projects',
        title: 'Recent Projects',
        description:
            'View and manage your projects. Track progress, communicate with experts, and download deliverables.',
        targetKey: keys.projectsKey,
        position: TourPosition.above,
        icon: Icons.folder_outlined,
      ),

      // Step 6: Profile
      TourStep(
        id: 'profile',
        title: 'Your Profile',
        description:
            'Access your profile settings, manage your account, and update your preferences anytime.',
        targetKey: keys.profileKey,
        position: TourPosition.below,
        icon: Icons.person_outlined,
        cutoutPadding: const EdgeInsets.all(8),
        cutoutBorderRadius: 20,
      ),

      // Step 7: Navigation
      TourStep(
        id: 'navigation',
        title: 'Explore the App',
        description:
            'Navigate between Home, Projects, Campus Connect, Experts, Wallet, Settings, and Profile.',
        targetKey: keys.navBarKey,
        position: TourPosition.above,
        icon: Icons.explore_outlined,
        isLast: true,
      ),
    ],
    showStepIndicator: true,
    allowSkip: true,
    showDontShowAgain: true,
    overlayOpacity: 0.75,
    animationDurationMs: 350,
  );
}

/// Mini tour for returning users who haven't seen updates.
TourConfig getQuickDashboardTourConfig(DashboardTourKeys keys) {
  return TourConfig(
    tourId: 'dashboard_quick',
    steps: [
      TourStep(
        id: 'new_features',
        title: 'New Features!',
        description:
            "We've added new ways to help you succeed. Check out the updated Quick Actions for faster access to our services.",
        targetKey: keys.servicesKey,
        position: TourPosition.above,
        icon: Icons.new_releases_outlined,
        pulseAnimation: true,
        isLast: true,
      ),
    ],
    showStepIndicator: false,
    allowSkip: true,
    showDontShowAgain: true,
    overlayOpacity: 0.7,
    animationDurationMs: 300,
  );
}
