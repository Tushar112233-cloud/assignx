import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/translation/translation_provider.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/misc/language_picker.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'.tr(context)),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondaryLight,
            tabs: [
              Tab(icon: const Icon(Icons.notifications_outlined), text: 'Notifications'.tr(context)),
              Tab(icon: const Icon(Icons.palette_outlined), text: 'Appearance'.tr(context)),
              Tab(icon: const Icon(Icons.lock_outline), text: 'Privacy'.tr(context)),
              Tab(icon: const Icon(Icons.language_outlined), text: 'Language'.tr(context)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _NotificationsTab(),
            _AppearanceTab(),
            _PrivacyTab(),
            _LanguageTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications Tab
// ---------------------------------------------------------------------------

class _NotificationsTab extends ConsumerWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsCard(
          title: 'Channels'.tr(context),
          children: [
            _ToggleTile(
              icon: Icons.email_outlined,
              title: 'Email Notifications'.tr(context),
              subtitle: 'Receive updates via email'.tr(context),
              value: settings.emailNotifications,
              onChanged: notifier.setEmailNotifications,
            ),
            const Divider(height: 1),
            _ToggleTile(
              icon: Icons.notifications_active_outlined,
              title: 'Push Notifications'.tr(context),
              subtitle: 'Receive push alerts on your device'.tr(context),
              value: settings.pushNotifications,
              onChanged: notifier.setPushNotifications,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsCard(
          title: 'Quiet Hours'.tr(context),
          children: [
            _ToggleTile(
              icon: Icons.do_not_disturb_on_outlined,
              title: 'Enable Quiet Hours'.tr(context),
              subtitle: 'Mute notifications during set hours'.tr(context),
              value: settings.quietHoursEnabled,
              onChanged: notifier.setQuietHoursEnabled,
            ),
            if (settings.quietHoursEnabled) ...[
              const Divider(height: 1),
              _TimeTile(
                icon: Icons.nightlight_outlined,
                title: 'Start Time'.tr(context),
                time: settings.quietHoursStart,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: settings.quietHoursStart,
                  );
                  if (picked != null) notifier.setQuietHoursStart(picked);
                },
              ),
              const Divider(height: 1),
              _TimeTile(
                icon: Icons.wb_sunny_outlined,
                title: 'End Time'.tr(context),
                time: settings.quietHoursEnd,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: settings.quietHoursEnd,
                  );
                  if (picked != null) notifier.setQuietHoursEnd(picked);
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Appearance Tab
// ---------------------------------------------------------------------------

class _AppearanceTab extends ConsumerWidget {
  const _AppearanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsCard(
          title: 'Theme'.tr(context),
          children: [
            _ThemeOption(
              icon: Icons.brightness_5,
              title: 'Light'.tr(context),
              isSelected: currentTheme == ThemeMode.light,
              onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
            ),
            const Divider(height: 1),
            _ThemeOption(
              icon: Icons.brightness_2,
              title: 'Dark'.tr(context),
              isSelected: currentTheme == ThemeMode.dark,
              onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
            ),
            const Divider(height: 1),
            _ThemeOption(
              icon: Icons.settings_brightness,
              title: 'System'.tr(context),
              isSelected: currentTheme == ThemeMode.system,
              onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Privacy Tab
// ---------------------------------------------------------------------------

class _PrivacyTab extends ConsumerWidget {
  const _PrivacyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsCard(
          title: 'Visibility'.tr(context),
          children: [
            _ToggleTile(
              icon: Icons.visibility_outlined,
              title: 'Profile Visibility'.tr(context),
              subtitle: 'Allow others to view your profile'.tr(context),
              value: settings.profileVisible,
              onChanged: notifier.setProfileVisible,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsCard(
          title: 'Security'.tr(context),
          children: [
            _ToggleTile(
              icon: Icons.security_outlined,
              title: 'Two-Factor Authentication'.tr(context),
              subtitle: 'Add an extra layer of security'.tr(context),
              value: settings.twoFactorEnabled,
              onChanged: notifier.setTwoFactorEnabled,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsCard(
          title: 'Account'.tr(context),
          children: [
            _ActionTile(
              icon: Icons.logout,
              title: 'Log Out'.tr(context),
              iconColor: AppColors.warning,
              onTap: () => _confirmLogout(context, ref),
            ),
            const Divider(height: 1),
            _ActionTile(
              icon: Icons.delete_forever,
              title: 'Delete Account'.tr(context),
              iconColor: AppColors.error,
              titleColor: AppColors.error,
              onTap: () => _confirmDeleteAccount(context),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Log Out'.tr(ctx)),
        content: Text('Are you sure you want to log out?'.tr(ctx)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'.tr(ctx)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go(RoutePaths.login);
            },
            child: Text('Log Out'.tr(ctx)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Delete Account'.tr(ctx)),
        content: Text(
          'This action is permanent and cannot be undone. All your data will be lost.'.tr(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'.tr(ctx)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (context.mounted) {
                context.pushNamed(RouteNames.support);
              }
            },
            child: Text('Request Deletion'.tr(ctx)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language Tab
// ---------------------------------------------------------------------------

class _LanguageTab extends ConsumerWidget {
  const _LanguageTab();

  static const _timezones = [
    'UTC',
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'Europe/London',
    'Europe/Paris',
    'Europe/Berlin',
    'Asia/Tokyo',
    'Asia/Shanghai',
    'Asia/Kolkata',
    'Asia/Dubai',
    'Australia/Sydney',
    'Pacific/Auckland',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final translationState = ref.watch(translationProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!kIsWeb) ...[
          _SettingsCard(
            title: 'Display Language'.tr(context),
            children: [
              ListTile(
                leading: Icon(Icons.translate, color: AppColors.textSecondaryLight),
                title: Text('Language'.tr(context), style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      translationState.selectedLanguageName,
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
                  ],
                ),
                onTap: () => showLanguagePicker(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        _SettingsCard(
          title: 'Region'.tr(context),
          children: [
            _DropdownTile(
              icon: Icons.access_time_outlined,
              title: 'Timezone'.tr(context),
              value: settings.timezone,
              items: _timezones,
              onChanged: (v) {
                if (v != null) notifier.setTimezone(v);
              },
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable card wrapper
// ---------------------------------------------------------------------------

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.borderLight),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable tiles
// ---------------------------------------------------------------------------

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.textSecondaryLight),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
      ),
      value: value,
      activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
      activeThumbColor: AppColors.accent,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.icon,
    required this.title,
    required this.time,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondaryLight),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Text(
        time.format(context),
        style: TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.accent : AppColors.textSecondaryLight,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.accent : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.accent)
          : const Icon(Icons.circle_outlined, color: AppColors.textSecondaryLight),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondaryLight),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondaryLight),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondaryLight),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(8),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
