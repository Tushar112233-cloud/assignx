import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/accessibility_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../profile/widgets/subscription_card.dart';

// ============================================================
// PROVIDERS
// ============================================================

/// Provider for notification preferences.
final notificationPrefsProvider =
    FutureProvider<NotificationPrefs>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return NotificationPrefs(
    pushEnabled: prefs.getBool('push_notifications') ?? true,
    emailEnabled: prefs.getBool('email_notifications') ?? true,
    projectUpdates: prefs.getBool('project_updates') ?? true,
    promotions: prefs.getBool('promotional_notifications') ?? false,
  );
});

/// Provider for appearance preferences.
final appearancePrefsProvider =
    FutureProvider<AppearancePrefs>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return AppearancePrefs(
    reducedMotion: prefs.getBool('reduced_motion') ?? false,
    compactMode: prefs.getBool('compact_mode') ?? false,
  );
});

/// Provider for privacy preferences.
final privacyPrefsProvider =
    FutureProvider<PrivacyPrefs>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return PrivacyPrefs(
    analyticsOptOut: prefs.getBool('analytics_opt_out') ?? false,
    showOnlineStatus: prefs.getBool('show_online_status') ?? true,
  );
});

// ============================================================
// MODELS
// ============================================================

/// Model for notification preferences.
class NotificationPrefs {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool projectUpdates;
  final bool promotions;

  const NotificationPrefs({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.projectUpdates,
    required this.promotions,
  });
}

/// Model for appearance preferences.
class AppearancePrefs {
  final bool reducedMotion;
  final bool compactMode;

  const AppearancePrefs({
    required this.reducedMotion,
    required this.compactMode,
  });
}

/// Model for privacy preferences.
class PrivacyPrefs {
  final bool analyticsOptOut;
  final bool showOnlineStatus;

  const PrivacyPrefs({
    required this.analyticsOptOut,
    required this.showOnlineStatus,
  });
}

// ============================================================
// MAIN SCREEN
// ============================================================

/// Settings screen with a clean single-column list of setting items.
/// Each row opens a centered dialog with that section's controls.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Back button row
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => context.pop(),
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Page Title
                  Text(
                    'Settings',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage your preferences and account',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Settings list container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Notifications
                        _SettingsListItem(
                          icon: Icons.notifications_outlined,
                          iconColor: const Color(0xFFE07B4C),
                          iconBgColor: AppColors.meshOrange,
                          title: 'Notifications',
                          subtitle: 'Manage how you receive updates',
                          onTap: () => _showNotificationsDialog(),
                        ),
                        const _ListDivider(),

                        // Privacy & Data
                        _SettingsListItem(
                          icon: Icons.shield_outlined,
                          iconColor: const Color(0xFF259369),
                          iconBgColor: AppColors.meshGreen,
                          title: 'Privacy & Data',
                          subtitle: 'Control your data and privacy',
                          onTap: () => _showPrivacyDialog(),
                        ),
                        const _ListDivider(),

                        // Appearance
                        _SettingsListItem(
                          icon: Icons.auto_awesome_outlined,
                          iconColor: const Color(0xFF7E57C2),
                          iconBgColor: AppColors.meshPurple,
                          title: 'Appearance',
                          subtitle: 'Theme, reduced motion, compact mode',
                          onTap: () => _showAppearanceDialog(),
                        ),
                        const _ListDivider(),

                        // My Roles
                        _SettingsListItem(
                          icon: Icons.badge_outlined,
                          iconColor: AppColors.primary,
                          iconBgColor: AppColors.surfaceLight,
                          title: 'My Roles',
                          subtitle: 'Manage your portal access',
                          onTap: () => _showMyRolesDialog(),
                        ),
                        const _ListDivider(),

                        // Send Feedback
                        _SettingsListItem(
                          icon: Icons.feedback_outlined,
                          iconColor: const Color(0xFF2196F3),
                          iconBgColor: AppColors.meshBlue,
                          title: 'Send Feedback',
                          subtitle: 'Bug reports, feature requests',
                          onTap: () => _showFeedbackDialog(),
                        ),
                        const _ListDivider(),

                        // About AssignX
                        _SettingsListItem(
                          icon: Icons.info_outline,
                          iconColor: const Color(0xFF7E57C2),
                          iconBgColor: AppColors.meshPurple,
                          title: 'About AssignX',
                          subtitle: 'Version info and legal',
                          onTap: () => _showAboutDialog(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Danger Zone
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.error.withAlpha(60),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Log Out
                        _SettingsListItem(
                          icon: Icons.logout,
                          iconColor: AppColors.warning,
                          iconBgColor: AppColors.warningLight,
                          title: 'Log Out',
                          subtitle: 'Sign out of your account',
                          isDestructive: true,
                          onTap: () => _showLogoutDialog(),
                        ),
                        const _ListDivider(),
                        // Delete Account
                        _SettingsListItem(
                          icon: Icons.delete_forever_outlined,
                          iconColor: AppColors.error,
                          iconBgColor: AppColors.errorLight,
                          title: 'Delete Account',
                          subtitle: 'Permanently delete all data',
                          isDestructive: true,
                          onTap: () => _showDeleteAccountDialog(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATIONS DIALOG
  // ============================================================

  void _showNotificationsDialog() {
    final notifPrefsAsync = ref.read(notificationPrefsProvider);
    final prefs = notifPrefsAsync.valueOrNull ??
        const NotificationPrefs(
          pushEnabled: true,
          emailEnabled: true,
          projectUpdates: true,
          promotions: false,
        );

    showDialog(
      context: context,
      builder: (dialogContext) => _NotificationsDialogContent(
        initialPrefs: prefs,
        onSave: (key, value) async {
          final sp = await SharedPreferences.getInstance();
          await sp.setBool(key, value);
          ref.invalidate(notificationPrefsProvider);
        },
      ),
    );
  }

  // ============================================================
  // PRIVACY DIALOG
  // ============================================================

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _PrivacyDialogContent(
        ref: ref,
      ),
    );
  }

  // ============================================================
  // APPEARANCE DIALOG
  // ============================================================

  void _showAppearanceDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _AppearanceDialogContent(ref: ref),
    );
  }

  // ============================================================
  // MY ROLES DIALOG
  // ============================================================

  void _showMyRolesDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _MyRolesDialogContent(ref: ref),
    );
  }

  // ============================================================
  // FEEDBACK DIALOG
  // ============================================================

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => const _FeedbackDialogContent(),
    );
  }

  // ============================================================
  // ABOUT DIALOG
  // ============================================================

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => const _AboutDialogContent(),
    );
  }

  // ============================================================
  // LOG OUT DIALOG
  // ============================================================

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref.read(authStateProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Logout failed: ${e.toString()}')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELETE ACCOUNT DIALOG
  // ============================================================

  void _showDeleteAccountDialog() {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This action is permanent and irreversible. All your data will be deleted.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Type DELETE to confirm',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  hintStyle: TextStyle(
                    fontFamily: 'monospace',
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontFamily: 'monospace'),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: confirmController.text == 'DELETE'
                  ? () async {
                      Navigator.pop(dialogContext);
                      try {
                        await ApiClient.post('/users/me/delete', {});
                        await ref
                            .read(authStateProvider.notifier)
                            .signOut();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Account deletion request submitted'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          context.go('/login');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Failed: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SETTINGS LIST ITEM
// ============================================================

/// A single row in the settings list: icon + title + description + chevron.
class _SettingsListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsListItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDestructive
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDestructive
                  ? AppColors.error.withAlpha(120)
                  : AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Divider between settings list items.
class _ListDivider extends StatelessWidget {
  const _ListDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColors.border.withAlpha(60)),
    );
  }
}

// ============================================================
// DIALOG CONTENTS
// ============================================================

/// Notifications dialog with 4 toggle switches.
class _NotificationsDialogContent extends StatefulWidget {
  final NotificationPrefs initialPrefs;
  final Future<void> Function(String key, bool value) onSave;

  const _NotificationsDialogContent({
    required this.initialPrefs,
    required this.onSave,
  });

  @override
  State<_NotificationsDialogContent> createState() =>
      _NotificationsDialogContentState();
}

class _NotificationsDialogContentState
    extends State<_NotificationsDialogContent> {
  late bool _push;
  late bool _email;
  late bool _projectUpdates;
  late bool _promotions;

  @override
  void initState() {
    super.initState();
    _push = widget.initialPrefs.pushEnabled;
    _email = widget.initialPrefs.emailEnabled;
    _projectUpdates = widget.initialPrefs.projectUpdates;
    _promotions = widget.initialPrefs.promotions;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.meshOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications_outlined,
                size: 18, color: Color(0xFFE07B4C)),
          ),
          const SizedBox(width: 12),
          const Text('Notifications'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogToggle(
            title: 'Push Notifications',
            subtitle: 'Get push notifications on your device',
            value: _push,
            onChanged: (v) {
              setState(() => _push = v);
              widget.onSave('push_notifications', v);
            },
          ),
          _DialogToggle(
            title: 'Email Notifications',
            subtitle: 'Receive important updates via email',
            value: _email,
            onChanged: (v) {
              setState(() => _email = v);
              widget.onSave('email_notifications', v);
            },
          ),
          _DialogToggle(
            title: 'Project Updates',
            subtitle: 'Get notified when projects are updated',
            value: _projectUpdates,
            onChanged: (v) {
              setState(() => _projectUpdates = v);
              widget.onSave('project_updates', v);
            },
          ),
          _DialogToggle(
            title: 'Marketing Emails',
            subtitle: 'Receive promotional offers',
            value: _promotions,
            onChanged: (v) {
              setState(() => _promotions = v);
              widget.onSave('promotional_notifications', v);
            },
            showDivider: false,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

/// Privacy & Data dialog with toggles + export data + clear cache.
class _PrivacyDialogContent extends StatefulWidget {
  final WidgetRef ref;

  const _PrivacyDialogContent({required this.ref});

  @override
  State<_PrivacyDialogContent> createState() => _PrivacyDialogContentState();
}

class _PrivacyDialogContentState extends State<_PrivacyDialogContent> {
  bool _analyticsOptOut = false;
  bool _showOnlineStatus = true;
  bool _isExporting = false;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacy();
  }

  Future<void> _loadPrivacy() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _analyticsOptOut = prefs.getBool('analytics_opt_out') ?? false;
        _showOnlineStatus = prefs.getBool('show_online_status') ?? true;
      });
    }
  }

  Future<void> _savePrivacy(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    // Sync to API silently
    try {
      await ApiClient.put('/users/me/preferences', {key: value});
    } catch (_) {}
  }

  Future<void> _handleExportData() async {
    setState(() => _isExporting = true);
    try {
      final response = await ApiClient.get('/users/me/export');
      final exportData = response as Map<String, dynamic>? ?? {};
      final jsonString =
          const JsonEncoder.withIndent('  ').convert(exportData);
      await Share.share(jsonString, subject: 'AssignX Data Export');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleClearCache() async {
    setState(() => _isClearing = true);
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    } finally {
      if (mounted) setState(() => _isClearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.meshGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield_outlined,
                size: 18, color: Color(0xFF259369)),
          ),
          const SizedBox(width: 12),
          const Text('Privacy & Data'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DialogToggle(
            title: 'Analytics Opt-out',
            subtitle: 'Disable anonymous usage analytics',
            value: _analyticsOptOut,
            onChanged: (v) {
              setState(() => _analyticsOptOut = v);
              _savePrivacy('analytics_opt_out', v);
            },
          ),
          _DialogToggle(
            title: 'Show Online Status',
            subtitle: 'Let others see when you are online',
            value: _showOnlineStatus,
            onChanged: (v) {
              setState(() => _showOnlineStatus = v);
              _savePrivacy('show_online_status', v);
            },
            showDivider: false,
          ),
          const SizedBox(height: 16),
          // Export Data button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isExporting ? null : _handleExportData,
              icon: _isExporting
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined, size: 18),
              label: Text(_isExporting ? 'Exporting...' : 'Export Data'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Clear Cache button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isClearing ? null : _handleClearCache,
              icon: _isClearing
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline, size: 18,
                      color: AppColors.error),
              label: Text(
                _isClearing ? 'Clearing...' : 'Clear Cache',
                style: const TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.error.withAlpha(80)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

/// Appearance dialog with theme selector + reduced motion + compact mode.
class _AppearanceDialogContent extends StatefulWidget {
  final WidgetRef ref;

  const _AppearanceDialogContent({required this.ref});

  @override
  State<_AppearanceDialogContent> createState() =>
      _AppearanceDialogContentState();
}

class _AppearanceDialogContentState extends State<_AppearanceDialogContent> {
  bool _reducedMotion = false;
  bool _compactMode = false;

  @override
  void initState() {
    super.initState();
    _reducedMotion = widget.ref.read(reducedMotionProvider);
    _loadAppearance();
  }

  Future<void> _loadAppearance() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _compactMode = prefs.getBool('compact_mode') ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appThemeMode = widget.ref.watch(themeProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.meshPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_outlined,
                size: 18, color: Color(0xFF7E57C2)),
          ),
          const SizedBox(width: 12),
          const Text('Appearance'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme selector
          Text(
            'Theme',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ThemeChip(
                icon: Icons.settings_suggest_outlined,
                label: 'System',
                isSelected: appThemeMode == AppThemeMode.system,
                onTap: () {
                  widget.ref
                      .read(themeProvider.notifier)
                      .setTheme(AppThemeMode.system);
                  setState(() {});
                },
              ),
              const SizedBox(width: 8),
              _ThemeChip(
                icon: Icons.wb_sunny_outlined,
                label: 'Light',
                isSelected: appThemeMode == AppThemeMode.light,
                onTap: () {
                  widget.ref
                      .read(themeProvider.notifier)
                      .setTheme(AppThemeMode.light);
                  setState(() {});
                },
              ),
              const SizedBox(width: 8),
              _ThemeChip(
                icon: Icons.dark_mode_outlined,
                label: 'Dark',
                isSelected: appThemeMode == AppThemeMode.dark,
                onTap: () {
                  widget.ref
                      .read(themeProvider.notifier)
                      .setTheme(AppThemeMode.dark);
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Toggles
          _DialogToggle(
            title: 'Reduce Motion',
            subtitle: 'Use instant transitions',
            value: _reducedMotion,
            onChanged: (v) async {
              setState(() => _reducedMotion = v);
              await widget.ref
                  .read(reducedMotionProvider.notifier)
                  .setReducedMotion(v);
              final sp = await SharedPreferences.getInstance();
              await sp.setBool('reduced_motion', v);
            },
          ),
          _DialogToggle(
            title: 'Compact Mode',
            subtitle: 'Use a more compact layout',
            value: _compactMode,
            onChanged: (v) async {
              setState(() => _compactMode = v);
              final sp = await SharedPreferences.getInstance();
              await sp.setBool('compact_mode', v);
            },
            showDivider: false,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

/// My Roles dialog with student/professional/business toggles.
class _MyRolesDialogContent extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _MyRolesDialogContent({required this.ref});

  @override
  ConsumerState<_MyRolesDialogContent> createState() => _MyRolesDialogContentState();
}

class _MyRolesDialogContentState extends ConsumerState<_MyRolesDialogContent> {
  bool _isSaving = false;

  Future<void> _toggleRole(String role, bool value) async {
    final portalRole = PortalRole.values.where((e) => e.name == role).firstOrNull;
    if (portalRole == null) return;

    final notifier = ref.read(userRolesProvider.notifier);
    final primary = notifier.primaryRole;

    // Can't disable primary role
    if (!value && portalRole == primary) return;

    setState(() => _isSaving = true);

    // Update the shared provider (affects ConnectHub immediately)
    await notifier.toggleRole(portalRole, value);

    try {
      final roles = ref.read(userRolesProvider);
      await ApiClient.put('/users/me/preferences', {
        'roles': {
          'student': roles.contains(PortalRole.student),
          'professional': roles.contains(PortalRole.professional),
          'business': roles.contains(PortalRole.business),
        },
      });
    } catch (_) {
      // Revert on error
      await notifier.toggleRole(portalRole, !value);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.badge_outlined,
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('My Roles')),
          if (_isSaving)
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
      content: Builder(builder: (ctx) {
        final activeRoles = ref.watch(userRolesProvider);
        final primary = ref.read(userRolesProvider.notifier).primaryRole;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoleToggle(
              icon: Icons.school_outlined,
              title: 'Student',
              subtitle: primary == PortalRole.student ? 'Primary role' : 'Access Campus Connect',
              value: activeRoles.contains(PortalRole.student),
              onChanged: primary == PortalRole.student ? null : (v) => _toggleRole('student', v),
            ),
            _RoleToggle(
              icon: Icons.work_outline,
              title: 'Professional',
              subtitle: primary == PortalRole.professional ? 'Primary role' : 'Access Job Portal',
              value: activeRoles.contains(PortalRole.professional),
              onChanged: primary == PortalRole.professional ? null : (v) => _toggleRole('professional', v),
            ),
            _RoleToggle(
              icon: Icons.business_outlined,
              title: 'Business',
              subtitle: primary == PortalRole.business ? 'Primary role' : 'Access Business Portal & VC Funding',
              value: activeRoles.contains(PortalRole.business),
              onChanged: primary == PortalRole.business ? null : (v) => _toggleRole('business', v),
              showDivider: false,
            ),
          ],
        );
      }),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

/// Role toggle item for the My Roles dialog.
class _RoleToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showDivider;

  const _RoleToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Opacity(opacity: onChanged != null ? 1.0 : 0.5, child: _CoffeeBeanToggle(value: value, onChanged: onChanged ?? (_) {})),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: AppColors.border.withAlpha(40)),
      ],
    );
  }
}

/// Feedback dialog with bug/feature/general selector + textarea.
class _FeedbackDialogContent extends StatefulWidget {
  const _FeedbackDialogContent();

  @override
  State<_FeedbackDialogContent> createState() =>
      _FeedbackDialogContentState();
}

class _FeedbackDialogContentState extends State<_FeedbackDialogContent> {
  final _feedbackController = TextEditingController();
  String _selectedType = 'general';
  bool _isSending = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final message = _feedbackController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      await ApiClient.post('/feedback', {
        'feedback_type': _selectedType,
        'message': message,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.meshBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.feedback_outlined,
                size: 18, color: Color(0xFF2196F3)),
          ),
          const SizedBox(width: 12),
          const Text('Send Feedback'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Type selector
          Row(
            children: [
              _FeedbackChip(
                label: 'Bug',
                icon: Icons.bug_report_outlined,
                isSelected: _selectedType == 'bug',
                onTap: () => setState(() => _selectedType = 'bug'),
              ),
              const SizedBox(width: 8),
              _FeedbackChip(
                label: 'Feature',
                icon: Icons.lightbulb_outline,
                isSelected: _selectedType == 'feature',
                onTap: () => setState(() => _selectedType = 'feature'),
              ),
              const SizedBox(width: 8),
              _FeedbackChip(
                label: 'General',
                icon: Icons.chat_bubble_outline,
                isSelected: _selectedType == 'general',
                onTap: () => setState(() => _selectedType = 'general'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Textarea
          TextFormField(
            controller: _feedbackController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your thoughts...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSending ? null : _handleSend,
          icon: _isSending
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send, size: 16),
          label: Text(_isSending ? 'Sending...' : 'Send'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

/// About AssignX dialog with version/build + legal links.
class _AboutDialogContent extends StatelessWidget {
  const _AboutDialogContent();

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.meshPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.info_outline,
                size: 18, color: Color(0xFF7E57C2)),
          ),
          const SizedBox(width: 12),
          const Text('About AssignX'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Version info
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '1.0.0';
              final buildNumber = snapshot.data?.buildNumber ?? '1';

              return Row(
                children: [
                  _InfoChip(label: 'Version', value: version),
                  const SizedBox(width: 10),
                  _InfoChip(label: 'Build', value: buildNumber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Beta',
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Legal links
          _AboutLink(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => _launchUrl('https://assignx.in/terms'),
          ),
          _AboutLink(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _launchUrl('https://assignx.in/privacy'),
          ),
          _AboutLink(
            icon: Icons.code_outlined,
            title: 'Open Source',
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'AssignX',
              applicationVersion: '1.0.0',
            ),
            showDivider: false,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

// ============================================================
// SHARED DIALOG WIDGETS
// ============================================================

/// Toggle switch for dialog content.
class _DialogToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _DialogToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _CoffeeBeanToggle(value: value, onChanged: onChanged),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: AppColors.border.withAlpha(40)),
      ],
    );
  }
}

/// Custom toggle switch using the coffee bean primary color.
class _CoffeeBeanToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CoffeeBeanToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 26,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Theme selection chip for appearance dialog.
class _ThemeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withAlpha(20)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withAlpha(100)
                  : AppColors.border.withAlpha(60),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feedback type chip.
class _FeedbackChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedbackChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withAlpha(60),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14,
                color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Info chip for About dialog version/build display.
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Link row for About dialog.
class _AboutLink extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const _AboutLink({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18,
                    color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: AppColors.border.withAlpha(40)),
      ],
    );
  }
}
