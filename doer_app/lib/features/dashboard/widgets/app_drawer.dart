/// Application navigation drawer widget.
///
/// Provides the main navigation drawer used throughout the app
/// with user info, availability toggle, quick stats, and navigation menu items.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/services/app_info_service.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'availability_toggle.dart';
import '../../../core/translation/translation_extensions.dart';

/// Main navigation drawer with user info, quick stats, and menu items.
///
/// Navigation links match the web sidebar: Dashboard, My Projects,
/// Resources, Profile, Reviews, Statistics, Help & Support, Settings.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final stats = ref.watch(doerStatsProvider);
    final appInfo = ref.watch(appInfoSyncProvider);
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header with AX logo, user info, and quick stats
            _buildDrawerHeader(context, user, stats),

            const Divider(height: 1),

            // Availability toggle
            const Padding(
              padding: AppSpacing.paddingMd,
              child: AvailabilityToggle(),
            ),

            const Divider(height: 1),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerMenuItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: 'Dashboard'.tr(context),
                    isActive: currentRoute == '/dashboard' ||
                        currentRoute == '/',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/dashboard');
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.assignment_outlined,
                    activeIcon: Icons.assignment,
                    label: 'My Projects'.tr(context),
                    isActive: currentRoute.startsWith('/dashboard/projects'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/dashboard/projects');
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.forum_outlined,
                    activeIcon: Icons.forum,
                    label: 'Pro Network'.tr(context),
                    isActive: currentRoute.startsWith('/community'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/community');
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.library_books_outlined,
                    activeIcon: Icons.library_books,
                    label: 'Resources'.tr(context),
                    isActive: currentRoute.startsWith('/resources'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/resources');
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile'.tr(context),
                    isActive: currentRoute.startsWith('/profile'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.star_outline,
                    activeIcon: Icons.star,
                    label: 'Reviews'.tr(context),
                    badge: stats.rating > 0
                        ? stats.rating.toStringAsFixed(1)
                        : null,
                    badgeColor: AppColors.warning,
                    isActive:
                        currentRoute.startsWith('/dashboard/reviews'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/dashboard/reviews');
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart,
                    label: 'Statistics'.tr(context),
                    isActive: currentRoute
                        .startsWith('/dashboard/statistics'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/dashboard/statistics');
                    },
                  ),

                  const Divider(height: AppSpacing.lg),

                  _DrawerMenuItem(
                    icon: Icons.help_outline,
                    activeIcon: Icons.help,
                    label: 'Help & Support'.tr(context),
                    isActive: currentRoute.startsWith('/support'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/support');
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Settings'.tr(context),
                    isActive: currentRoute.startsWith('/settings'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),

                  const Divider(height: AppSpacing.lg),

                  _DrawerMenuItem(
                    icon: Icons.info_outline,
                    activeIcon: Icons.info,
                    label: 'About'.tr(context),
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context, appInfo.displayVersion);
                    },
                  ),
                ],
              ),
            ),

            // Logout button
            const Divider(height: 1),
            _buildLogoutButton(context, ref),
          ],
        ),
      ),
    );
  }

  /// Builds the drawer header with AX gradient logo, user info, and quick stats.
  Widget _buildDrawerHeader(
    BuildContext context,
    dynamic user,
    DoerStats stats,
  ) {
    final displayName = user?.fullName ?? 'Doer';
    final email = user?.email ?? '';

    return Container(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          // AX logo with gradient
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'AX',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'DOER'.tr(context),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  displayName.isNotEmpty
                      ? displayName[0].toUpperCase()
                      : 'D',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Quick stats row
          Row(
            children: [
              _DrawerQuickStat(
                icon: Icons.assignment,
                value: stats.activeProjects.toString(),
                label: 'Active'.tr(context),
                color: AppColors.info,
              ),
              const SizedBox(width: AppSpacing.md),
              _DrawerQuickStat(
                icon: Icons.account_balance_wallet,
                value: '\u20B9${_formatEarnings(stats.totalEarnings)}',
                label: 'Earnings'.tr(context),
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.md),
              _DrawerQuickStat(
                icon: Icons.star,
                value: stats.rating > 0
                    ? stats.rating.toStringAsFixed(1)
                    : '--',
                label: 'Rating'.tr(context),
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatEarnings(double earnings) {
    if (earnings >= 100000) {
      return '${(earnings / 1000).toStringAsFixed(0)}K';
    } else if (earnings >= 1000) {
      return '${(earnings / 1000).toStringAsFixed(1)}K';
    }
    return earnings.toStringAsFixed(0);
  }

  /// Builds the logout button.
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: AppSpacing.paddingMd,
      child: InkWell(
        onTap: () => _showLogoutDialog(context, ref),
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: AppColors.error, size: 20),
              SizedBox(width: 8),
              Text(
                'Logout'.tr(context),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before logging out.
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'.tr(context)),
        content: Text('Are you sure you want to logout?'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close the dialog
              ref.read(authProvider.notifier).signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text('Logout'.tr(context)),
          ),
        ],
      ),
    );
  }

  /// Shows the about dialog.
  void _showAboutDialog(BuildContext context, String version) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text(
                  'AX',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('DOER'.tr(context)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(version),
            const SizedBox(height: 8),
            Text(
              'DOER is a platform connecting talented individuals with academic projects.'.tr(context),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'.tr(context)),
          ),
        ],
      ),
    );
  }
}

/// Quick stat item for the drawer header.
class _DrawerQuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _DrawerQuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A styled menu item for the navigation drawer with active indicator.
class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.activeIcon,
    this.badge,
    this.badgeColor,
    this.isActive = false,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: ListTile(
        leading: Icon(
          isActive ? (activeIcon ?? icon) : icon,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        trailing: _buildTrailing(),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 0,
        ),
        visualDensity: const VisualDensity(vertical: -1),
      ),
    );
  }

  Widget? _buildTrailing() {
    final List<Widget> items = [];

    if (badge != null) {
      items.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: (badgeColor ?? AppColors.primary)
                .withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badgeColor == AppColors.warning) ...[
                const Icon(Icons.star, size: 12, color: AppColors.warning),
                const SizedBox(width: 2),
              ],
              Text(
                badge!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: badgeColor ?? AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isActive) {
      items.add(
        Container(
          width: 4,
          height: 20,
          margin: badge != null
              ? const EdgeInsets.only(left: 6)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }

    if (items.isEmpty) return null;
    if (items.length == 1) return items.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items,
    );
  }
}
