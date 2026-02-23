import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/services/app_info_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../widgets/settings/account_settings.dart';
import '../widgets/settings/display_settings.dart';
import '../widgets/settings/notification_settings.dart';
import '../widgets/settings/privacy_settings.dart';
import '../widgets/settings/settings_hero.dart';

/// Settings screen for managing app preferences and account settings.
///
/// Provides a redesigned settings interface with a hero section and
/// tabbed navigation for Account, Notifications, Privacy, and Display.
///
/// ## Layout
/// - [SettingsHero] at the top with user name, email, gradient background
/// - [TabBar] with 4 tabs: Account, Notifications, Privacy, Display
/// - [TabBarView] with content for each tab
/// - Logout button and app version at the bottom
///
/// ## Tabs
/// 1. **Account**: Profile info, security, availability
/// 2. **Notifications**: Push, email, project, payment, marketing toggles
/// 3. **Privacy**: Profile visibility, contact info, data sharing
/// 4. **Display**: Theme selection, language, compact mode, cache
///
/// ## State Management
/// Uses [ProfileProvider] for preferences and [AuthProvider] for logout.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    final preferences = profileState.notificationPreferences;
    final appInfo = ref.watch(appInfoSyncProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Hero section
            if (profile != null) SettingsHero(profile: profile),
            if (profile == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF5A7CFF),
                      Color(0xFF49C5FF),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Expanded(
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Tab bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5A7CFF), Color(0xFF49C5FF)],
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: -AppSpacing.sm,
                ),
                tabs: const [
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_outline, size: 16),
                          SizedBox(width: 6),
                          Text('Account'),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_outlined, size: 16),
                          SizedBox(width: 6),
                          Text('Notifications'),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline, size: 16),
                          SizedBox(width: 6),
                          Text('Privacy'),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.display_settings_outlined, size: 16),
                          SizedBox(width: 6),
                          Text('Display'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  // Account tab
                  _buildAccountTab(ref, profile, profileState),

                  // Notifications tab
                  NotificationSettings(
                    preferences: preferences,
                    onPreferencesChanged: (prefs) {
                      ref
                          .read(profileProvider.notifier)
                          .updateNotificationPreferences(prefs);
                    },
                  ),

                  // Privacy tab
                  const PrivacySettings(),

                  // Display tab
                  const DisplaySettings(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context, ref, appInfo),
      ),
    );
  }

  Widget _buildAccountTab(
    WidgetRef ref,
    UserProfile? profile,
    ProfileState profileState,
  ) {
    if (profile == null) {
      return const Center(
        child: Text(
          'Profile not found',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return AccountSettings(
      profile: profile,
      isAvailable: profile.isAvailable,
      onAvailabilityChanged: (value) {
        ref.read(profileProvider.notifier).updateAvailability(value);
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    AppInfo appInfo,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // App version
            Text(
              'DOER App ${appInfo.displayVersion}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
