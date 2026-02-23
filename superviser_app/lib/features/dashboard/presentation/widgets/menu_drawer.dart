import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import 'availability_toggle.dart';

/// Menu drawer for dashboard navigation.
///
/// Contains profile card, availability toggle, and navigation items.
class MenuDrawer extends ConsumerWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(dashboardProvider);
    final userName = authState.user?.fullName ?? 'Supervisor';
    final email = authState.user?.email ?? '';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Profile card
            _ProfileCard(
              name: userName,
              email: email,
              isAvailable: dashboardState.isAvailable,
              onAvailabilityChanged: () {
                ref.read(dashboardProvider.notifier).toggleAvailability();
              },
            ),
            const Divider(height: 1),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _MenuSection(
                    title: 'Dashboard',
                    children: [
                      _MenuItem(
                        icon: Icons.dashboard_outlined,
                        title: 'Overview',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(RoutePaths.dashboard);
                        },
                      ),
                      _MenuItem(
                        icon: Icons.pending_actions_outlined,
                        title: 'Pending Requests',
                        badge: dashboardState.pendingCount.toString(),
                        onTap: () {
                          Navigator.pop(context);
                          context.go(RoutePaths.projects);
                        },
                      ),
                      _MenuItem(
                        icon: Icons.assignment_turned_in_outlined,
                        title: 'Assigned Projects',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(RoutePaths.projects);
                        },
                      ),
                    ],
                  ),
                  _MenuSection(
                    title: 'Doers',
                    children: [
                      _MenuItem(
                        icon: Icons.people_outline,
                        title: 'My Doers',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(RoutePaths.doers);
                        },
                      ),
                      _MenuItem(
                        icon: Icons.person_add_outlined,
                        title: 'Find Doers',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(RoutePaths.doers);
                        },
                      ),
                    ],
                  ),
                  _MenuSection(
                    title: 'Reports',
                    children: [
                      _MenuItem(
                        icon: Icons.analytics_outlined,
                        title: 'Analytics',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(RoutePaths.earnings);
                        },
                      ),
                      _MenuItem(
                        icon: Icons.payments_outlined,
                        title: 'Earnings',
                        onTap: () {
                          Navigator.pop(context);
                          context.go(RoutePaths.earnings);
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(RoutePaths.settings);
                    },
                  ),
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      context.go(RoutePaths.support);
                    },
                  ),
                ],
              ),
            ),
            // Logout button
            const Divider(height: 1),
            _MenuItem(
              icon: Icons.logout,
              title: 'Logout',
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).signOut();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Profile card at top of drawer.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.email,
    required this.isAvailable,
    required this.onAvailabilityChanged,
  });

  final String name;
  final String email;
  final bool isAvailable;
  final VoidCallback onAvailabilityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  _getInitials(name),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Availability toggle
          AvailabilityToggle(
            isAvailable: isAvailable,
            onChanged: (_) => onAvailabilityChanged(),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

/// Menu section with title.
class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// Single menu item.
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.badge,
    this.iconColor,
    this.textColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? badge;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textSecondaryLight,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimaryLight,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
