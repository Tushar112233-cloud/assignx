import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../providers/preferences_provider.dart';

// ============================================================
// DESIGN CONSTANTS
// ============================================================

/// Colors used in the preferences section.
class _PreferencesColors {
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B6B6B);
  static const mutedText = Color(0xFF8B8B8B);
  static const toggleOn = Color(0xFF5D3A3A);
  static const toggleOff = Color(0xFFE0E0E0);
  static const iconBackground = Color(0xFFFFF3E0); // Soft orange
}

// ============================================================
// PREFERENCES SECTION WIDGET
// ============================================================

/// A card widget that displays user preferences with toggle switches.
///
/// Features:
/// - Push Notifications toggle
/// - Email Notifications toggle
/// - Project Updates toggle
/// - Promotional Messages toggle
///
/// Uses SharedPreferences for persistence via PreferencesNotifier.
///
/// Example usage:
/// ```dart
/// PreferencesSection()
/// ```
class PreferencesSection extends ConsumerWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);

    if (preferences.isLoading) {
      return _buildLoadingCard();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _PreferencesColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            _buildSectionHeader(),
            const SizedBox(height: 16),

            // Toggle Items
            _PreferencesToggleItem(
              title: 'Push Notifications',
              subtitle: 'Get push notifications on your device',
              value: preferences.pushNotifications,
              onChanged: (value) {
                ref.read(preferencesProvider.notifier).togglePushNotifications(value);
              },
            ),
            _PreferencesToggleItem(
              title: 'Email Notifications',
              subtitle: 'Receive important updates via email',
              value: preferences.emailNotifications,
              onChanged: (value) {
                ref.read(preferencesProvider.notifier).toggleEmailNotifications(value);
              },
            ),
            _PreferencesToggleItem(
              title: 'Project Updates',
              subtitle: 'Get notified when projects are updated',
              value: preferences.projectUpdates,
              onChanged: (value) {
                ref.read(preferencesProvider.notifier).toggleProjectUpdates(value);
              },
            ),
            _PreferencesToggleItem(
              title: 'Promotional Messages',
              subtitle: 'Receive offers and promotional content',
              value: preferences.promotionalMessages,
              onChanged: (value) {
                ref.read(preferencesProvider.notifier).togglePromotionalMessages(value);
              },
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the section header with icon and title.
  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _PreferencesColors.iconBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.tune_outlined,
            size: 20,
            color: _PreferencesColors.secondaryText,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preferences',
                style: AppTextStyles.headingSmall.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _PreferencesColors.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage your notification settings',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: _PreferencesColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a loading placeholder card.
  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
      decoration: BoxDecoration(
        color: _PreferencesColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

// ============================================================
// PRIVATE WIDGETS
// ============================================================

/// Toggle item widget for preferences.
class _PreferencesToggleItem extends StatelessWidget {
  /// Title of the preference.
  final String title;

  /// Description of the preference.
  final String subtitle;

  /// Current toggle value.
  final bool value;

  /// Callback when toggle value changes.
  final ValueChanged<bool> onChanged;

  /// Whether to show a divider below the item.
  final bool showDivider;

  const _PreferencesToggleItem({
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _PreferencesColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: _PreferencesColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _CustomToggle(value: value, onChanged: onChanged),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.grey.withAlpha(26),
          ),
      ],
    );
  }
}

/// Custom toggle switch matching design spec.
class _CustomToggle extends StatelessWidget {
  /// Current toggle value.
  final bool value;

  /// Callback when toggle value changes.
  final ValueChanged<bool> onChanged;

  const _CustomToggle({
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
          color: value ? _PreferencesColors.toggleOn : _PreferencesColors.toggleOff,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
