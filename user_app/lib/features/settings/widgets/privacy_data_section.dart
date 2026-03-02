import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_text_styles.dart';

// ============================================================
// DESIGN CONSTANTS
// ============================================================

class _PrivacyColors {
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B6B6B);
  static const mutedText = Color(0xFF8B8B8B);
  static const toggleOn = Color(0xFF5D3A3A);
  static const toggleOff = Color(0xFFE0E0E0);
  static const actionBlue = Color(0xFF2196F3);
  static const actionRed = Color(0xFFF44336);
  static const iconBackground = Color(0xFFE8F5E9);
  static const exportBlueBackground = Color(0xFFF0F7FF);
  static const clearRedBackground = Color(0xFFFFF0F0);
}

// ============================================================
// PRIVACY STATE
// ============================================================

/// State class for privacy preferences.
class PrivacyState {
  final bool analyticsOptOut;
  final bool showOnlineStatus;
  final bool isLoading;

  const PrivacyState({
    this.analyticsOptOut = false,
    this.showOnlineStatus = true,
    this.isLoading = true,
  });

  PrivacyState copyWith({
    bool? analyticsOptOut,
    bool? showOnlineStatus,
    bool? isLoading,
  }) {
    return PrivacyState(
      analyticsOptOut: analyticsOptOut ?? this.analyticsOptOut,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ============================================================
// PRIVACY NOTIFIER
// ============================================================

/// StateNotifier for managing privacy preferences.
class PrivacyNotifier extends StateNotifier<PrivacyState> {
  PrivacyNotifier() : super(const PrivacyState()) {
    _loadPreferences();
  }

  static const String _keyAnalyticsOptOut = 'analytics_opt_out';
  static const String _keyShowOnlineStatus = 'show_online_status';

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = PrivacyState(
        analyticsOptOut: prefs.getBool(_keyAnalyticsOptOut) ?? false,
        showOnlineStatus: prefs.getBool(_keyShowOnlineStatus) ?? true,
        isLoading: false,
      );
    } catch (e) {
      state = const PrivacyState(isLoading: false);
    }
  }

  /// Toggle analytics opt-out.
  Future<void> toggleAnalyticsOptOut(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAnalyticsOptOut, value);
    state = state.copyWith(analyticsOptOut: value);

    // Also sync to API user_preferences
    _syncToApi('analytics_opt_out', value);
  }

  /// Toggle show online status.
  Future<void> toggleShowOnlineStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowOnlineStatus, value);
    state = state.copyWith(showOnlineStatus: value);

    // Also sync to API user_preferences
    _syncToApi('show_online_status', value);
  }

  /// Sync a preference to the API.
  Future<void> _syncToApi(String key, bool value) async {
    try {
      await ApiClient.put('/profiles/me/preferences', {
        key: value,
      });
    } catch (_) {
      // Silent fail for sync - local preference is the source of truth
    }
  }
}

// ============================================================
// PROVIDER
// ============================================================

/// Provider for privacy preferences state.
final privacyProvider =
    StateNotifierProvider<PrivacyNotifier, PrivacyState>((ref) {
  return PrivacyNotifier();
});

// ============================================================
// WIDGET
// ============================================================

/// Privacy & Data section card for the settings screen.
/// Displays toggles for analytics and online status, plus export/clear actions.
class PrivacyDataSection extends ConsumerStatefulWidget {
  const PrivacyDataSection({super.key});

  @override
  ConsumerState<PrivacyDataSection> createState() =>
      _PrivacyDataSectionState();
}

class _PrivacyDataSectionState extends ConsumerState<PrivacyDataSection> {
  bool _isExporting = false;
  bool _isClearing = false;

  @override
  Widget build(BuildContext context) {
    final privacy = ref.watch(privacyProvider);

    if (privacy.isLoading) {
      return _buildLoadingCard();
    }

    return Container(
      decoration: BoxDecoration(
        color: _PrivacyColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _PrivacyColors.iconBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 20,
                    color: _PrivacyColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy & Data',
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _PrivacyColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Control your data',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          color: _PrivacyColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Analytics Opt-out Toggle
            _PrivacyToggleItem(
              title: 'Analytics Opt-out',
              subtitle: 'Disable anonymous usage analytics',
              value: privacy.analyticsOptOut,
              onChanged: (value) =>
                  ref.read(privacyProvider.notifier).toggleAnalyticsOptOut(value),
            ),

            // Show Online Status Toggle
            _PrivacyToggleItem(
              title: 'Show Online Status',
              subtitle: 'Let others see when you are online',
              value: privacy.showOnlineStatus,
              onChanged: (value) =>
                  ref.read(privacyProvider.notifier).toggleShowOnlineStatus(value),
              showDivider: false,
            ),

            const SizedBox(height: 16),

            // Export Data
            _ActionListTile(
              icon: Icons.download_outlined,
              title: 'Export Data',
              subtitle: 'Download your data as JSON',
              backgroundColor: _PrivacyColors.exportBlueBackground,
              textColor: _PrivacyColors.actionBlue,
              isLoading: _isExporting,
              onTap: _handleExportData,
            ),
            const SizedBox(height: 10),

            // Clear Cache
            _ActionListTile(
              icon: Icons.delete_outline,
              title: 'Clear Cache',
              subtitle: 'Clear local storage data',
              backgroundColor: _PrivacyColors.clearRedBackground,
              textColor: _PrivacyColors.actionRed,
              isLoading: _isClearing,
              onTap: _handleClearCache,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: _PrivacyColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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

  /// Exports user data from the API as JSON and shares it.
  Future<void> _handleExportData() async {
    setState(() => _isExporting = true);

    try {
      final response = await ApiClient.get('/profiles/me/export');
      final exportData = response as Map<String, dynamic>? ?? {};

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      await Share.share(
        jsonString,
        subject: 'AssignX Data Export',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// Clears SharedPreferences and image cache.
  Future<void> _handleClearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear cached images and temporary data. You may need to download some content again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _PrivacyColors.actionRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isClearing = true);

      try {
        // Clear SharedPreferences (non-critical keys only)
        final prefs = await SharedPreferences.getInstance();
        // Only clear cache-related keys, not user preferences
        await prefs.remove('cached_images');
        await prefs.remove('cached_data');

        // Clear Flutter image cache
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cache cleared successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to clear cache: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isClearing = false);
        }
      }
    }
  }
}

// ============================================================
// PRIVATE WIDGETS
// ============================================================

/// Toggle item for privacy settings.
class _PrivacyToggleItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _PrivacyToggleItem({
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
                        color: _PrivacyColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: _PrivacyColors.mutedText,
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
            color: Colors.grey.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}

/// Action list tile with icon, title, subtitle, and optional loading state.
class _ActionListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.textColor,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
              )
            : Row(
                children: [
                  Icon(icon, size: 20, color: textColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: textColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Custom toggle switch matching design spec.
class _CustomToggle extends StatelessWidget {
  final bool value;
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
          color: value ? _PrivacyColors.toggleOn : _PrivacyColors.toggleOff,
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
