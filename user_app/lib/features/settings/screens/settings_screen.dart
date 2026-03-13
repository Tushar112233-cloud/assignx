import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/accessibility_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../shared/widgets/dashboard_app_bar.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../profile/widgets/account_upgrade_card.dart';
import '../widgets/language_selector.dart';
import '../widgets/about_section.dart';
import '../widgets/danger_zone_section.dart';
import '../widgets/feedback_section.dart';
import '../widgets/my_roles_section.dart';
import '../widgets/privacy_data_section.dart';

// ============================================================
// PROVIDERS
// ============================================================

/// Provider for notification preferences.
final notificationPrefsProvider = FutureProvider<NotificationPrefs>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return NotificationPrefs(
    pushEnabled: prefs.getBool('push_notifications') ?? true,
    emailEnabled: prefs.getBool('email_notifications') ?? true,
    projectUpdates: prefs.getBool('project_updates') ?? true,
    promotions: prefs.getBool('promotional_notifications') ?? false,
  );
});

/// Provider for appearance preferences.
final appearancePrefsProvider = FutureProvider<AppearancePrefs>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return AppearancePrefs(
    reducedMotion: prefs.getBool('reduced_motion') ?? false,
    compactMode: prefs.getBool('compact_mode') ?? false,
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

// ============================================================
// MAIN SCREEN
// ============================================================

/// Settings screen with redesigned UI using GlassCard containers
/// and the AppColors coffee bean palette for visual consistency.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final appThemeMode = ref.watch(themeProvider);
    final notifPrefsAsync = ref.watch(notificationPrefsProvider);
    final appearancePrefsAsync = ref.watch(appearancePrefsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Unified Dashboard App Bar (dark theme)
          const DashboardAppBar(),

          // Content
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),

                      // Page Title Section
                      _buildPageTitle(),
                      const SizedBox(height: 28),

                      // Account Upgrade Banner
                      _buildAccountUpgradeCard(),
                      const SizedBox(height: 20),

                      // Notifications Section
                      notifPrefsAsync.when(
                        data: (prefs) => _buildNotificationsCard(prefs),
                        loading: () => _buildLoadingCard(),
                        error: (e, s) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 20),

                      // Appearance Section
                      appearancePrefsAsync.when(
                        data: (prefs) => _buildAppearanceCard(appThemeMode, prefs),
                        loading: () => _buildLoadingCard(),
                        error: (e, s) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 20),

                      // Language Section
                      _buildLanguageCard(),
                      const SizedBox(height: 20),

                      // My Roles Section
                      const MyRolesSection(),
                      const SizedBox(height: 20),

                      // Privacy & Data Section
                      const PrivacyDataSection(),
                      const SizedBox(height: 20),

                      // Send Feedback Section
                      const FeedbackSection(),
                      const SizedBox(height: 20),

                      // About AssignX Section
                      const AboutSection(),
                      const SizedBox(height: 20),

                      // Danger Zone Section
                      const DangerZoneSection(),
                      const SizedBox(height: 100), // Bottom padding for nav bar
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE TITLE
  // ============================================================

  /// Builds the page title section with improved hierarchy.
  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  // ============================================================
  // ACCOUNT UPGRADE CARD
  // ============================================================

  /// Builds the account upgrade banner card using actual user profile data.
  Widget _buildAccountUpgradeCard() {
    final profileAsync = ref.watch(userProfileProvider);
    final currentType = profileAsync.whenOrNull(
      data: (profile) => AccountType.fromDbString(profile.userType?.toDbString() ?? 'student'),
    ) ?? AccountType.student;

    // Only show if user can upgrade
    if (currentType.canUpgradeTo.isEmpty) {
      return const SizedBox.shrink();
    }

    return CompactUpgradeBanner(
      currentType: currentType,
      onUpgradeTap: () {
        context.push('/profile/upgrade?type=${currentType.toDbString()}');
      },
    );
  }

  // ============================================================
  // NOTIFICATIONS CARD
  // ============================================================

  /// Builds the notifications settings card wrapped in a GlassCard.
  Widget _buildNotificationsCard(NotificationPrefs prefs) {
    return _SettingsCard(
      icon: Icons.notifications_outlined,
      iconColor: const Color(0xFFE07B4C),
      iconBackgroundColor: AppColors.meshOrange,
      title: 'Notifications',
      subtitle: 'Manage how you receive updates',
      children: [
        _SettingsToggleItem(
          title: 'Push Notifications',
          subtitle: 'Get push notifications on your device',
          value: prefs.pushEnabled,
          onChanged: (value) => _updateNotifPref('push_notifications', value),
        ),
        _SettingsToggleItem(
          title: 'Email Notifications',
          subtitle: 'Receive important updates via email',
          value: prefs.emailEnabled,
          onChanged: (value) => _updateNotifPref('email_notifications', value),
        ),
        _SettingsToggleItem(
          title: 'Project Updates',
          subtitle: 'Get notified when projects are updated',
          value: prefs.projectUpdates,
          onChanged: (value) => _updateNotifPref('project_updates', value),
        ),
        _SettingsToggleItem(
          title: 'Marketing Emails',
          subtitle: 'Receive promotional offers',
          value: prefs.promotions,
          onChanged: (value) => _updateNotifPref('promotional_notifications', value),
          showDivider: false,
        ),
      ],
    );
  }

  // ============================================================
  // APPEARANCE CARD
  // ============================================================

  /// Builds the appearance settings card wrapped in a GlassCard.
  Widget _buildAppearanceCard(AppThemeMode appThemeMode, AppearancePrefs prefs) {
    // Watch the accessibility provider for reduced motion state
    final reducedMotion = ref.watch(reducedMotionProvider);

    return _SettingsCard(
      icon: Icons.auto_awesome_outlined,
      iconColor: const Color(0xFF7E57C2),
      iconBackgroundColor: AppColors.meshPurple,
      title: 'Appearance',
      subtitle: 'Customize how the app looks',
      children: [
        // Theme Label
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Theme',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        // Theme Selector - 3 options: System, Light, Dark
        Row(
          children: [
            Expanded(
              child: _ThemeOptionCard(
                icon: Icons.settings_suggest_outlined,
                label: 'System',
                isSelected: appThemeMode == AppThemeMode.system,
                onTap: () => ref.read(themeProvider.notifier).setTheme(AppThemeMode.system),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ThemeOptionCard(
                icon: Icons.wb_sunny_outlined,
                label: 'Light',
                isSelected: appThemeMode == AppThemeMode.light,
                onTap: () => ref.read(themeProvider.notifier).setTheme(AppThemeMode.light),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ThemeOptionCard(
                icon: Icons.dark_mode_outlined,
                label: 'Dark',
                isSelected: appThemeMode == AppThemeMode.dark,
                onTap: () => ref.read(themeProvider.notifier).setTheme(AppThemeMode.dark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Accessibility Section Header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.meshBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.accessibility_new,
                  size: 16,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Accessibility',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        _SettingsToggleItem(
          title: 'Reduce Motion',
          subtitle: 'Use instant transitions instead of animations. Helpful for motion sensitivity or to save battery.',
          value: reducedMotion,
          onChanged: (value) async {
            // Update the accessibility provider (primary)
            await ref.read(reducedMotionProvider.notifier).setReducedMotion(value);
            // Also sync with appearance prefs for consistency
            _updateAppearancePref('reduced_motion', value);
          },
        ),
        _SettingsToggleItem(
          title: 'Compact Mode',
          subtitle: 'Use a more compact layout',
          value: prefs.compactMode,
          onChanged: (value) => _updateAppearancePref('compact_mode', value),
          showDivider: false,
        ),
      ],
    );
  }

  // ============================================================
  // LANGUAGE CARD
  // ============================================================

  /// Builds the language settings card with selectable language options.
  Widget _buildLanguageCard() {
    final selectedCode = ref.watch(languageProvider);

    return _SettingsCard(
      icon: Icons.language,
      iconColor: const Color(0xFF2B93BE),
      iconBackgroundColor: AppColors.meshBlue,
      title: 'Language',
      subtitle: 'Choose your preferred language',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kLanguageOptions.map((lang) {
            final isSelected = selectedCode == lang.code;
            return _LanguageOptionChip(
              flag: lang.flag,
              label: lang.name,
              isSelected: isSelected,
              onTap: () {
                ref.read(languageProvider.notifier).setLanguage(lang.code);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================
  // LOADING CARD
  // ============================================================

  /// Builds a loading placeholder card using GlassCard.
  Widget _buildLoadingCard() {
    return GlassCard(
      elevation: 1,
      enableHoverEffect: false,
      child: SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PREFERENCE UPDATE METHODS
  // ============================================================

  Future<void> _updateNotifPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    ref.invalidate(notificationPrefsProvider);
  }

  Future<void> _updateAppearancePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    ref.invalidate(appearancePrefsProvider);
  }
}

// ============================================================
// PRIVATE WIDGETS
// ============================================================

/// Settings card container with section header, wrapped in a GlassCard
/// for the glassmorphic design language.
class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SettingsCard({
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      elevation: 1,
      opacity: 0.80,
      enableHoverEffect: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
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
            ],
          ),
          const SizedBox(height: 20),
          // Children
          ...children,
        ],
      ),
    );
  }
}

/// Settings toggle item with title, subtitle, and a coffee-bean-themed switch.
class _SettingsToggleItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _SettingsToggleItem({
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
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
                    const SizedBox(height: 3),
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
          Divider(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}

/// Custom toggle switch using the coffee bean primary color palette.
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
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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

/// Theme option card for system/light/dark selection.
class _ThemeOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 76,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
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
    );
  }
}

/// Language option chip for selecting app language.
class _LanguageOptionChip extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionChip({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
