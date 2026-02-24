import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../providers/translation_provider.dart';
import '../../../../shared/widgets/language_picker.dart';
import '../../../../core/translation/translation_extensions.dart';

/// Display settings tab content.
///
/// Provides theme selection (light/dark/system), language selection,
/// compact mode, and cache management.
class DisplaySettings extends ConsumerStatefulWidget {
  const DisplaySettings({super.key});

  @override
  ConsumerState<DisplaySettings> createState() => _DisplaySettingsState();
}

class _DisplaySettingsState extends ConsumerState<DisplaySettings> {
  String _selectedTheme = 'Light';
  bool _compactMode = false;

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(translationProvider);

    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme
          _buildSectionHeader('Appearance', Icons.palette_outlined),
          const SizedBox(height: AppSpacing.sm),
          _buildSettingsCard([
            _buildThemeSelector(),
          ]),

          const SizedBox(height: AppSpacing.lg),

          // Language & Layout (hidden on web)
          if (!kIsWeb) ...[
            _buildSectionHeader('Language & Layout', Icons.translate_outlined),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsCard([
              _buildSelectionItem(
                'Language',
                translationState.selectedLanguageName,
                Icons.language,
                onTap: () => showLanguagePicker(context),
              ),
              _buildSwitchItem(
                'Compact Mode',
                'Use a denser layout with less spacing',
                Icons.view_compact_outlined,
                _compactMode,
                (value) => setState(() => _compactMode = value),
              ),
            ]),

            const SizedBox(height: AppSpacing.lg),
          ],

          // Storage
          _buildSectionHeader('Storage', Icons.storage_outlined),
          const SizedBox(height: AppSpacing.sm),
          _buildSettingsCard([
            _buildActionItem(
              'Clear Cache',
              'Free up storage space',
              Icons.cleaning_services_outlined,
              onTap: () => _clearCache(context),
            ),
          ]),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        children: List.generate(
          children.length * 2 - 1,
          (index) {
            if (index.isOdd) {
              return const Divider(height: 1);
            }
            return children[index ~/ 2];
          },
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    final themes = [
      _ThemeOption('Light', Icons.light_mode_outlined),
      _ThemeOption('Dark', Icons.dark_mode_outlined),
      _ThemeOption('System', Icons.settings_suggest_outlined),
    ];

    return Padding(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme'.tr(context),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Select your preferred color theme'.tr(context),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: themes.map((theme) {
              final isSelected = _selectedTheme == theme.label;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: theme.label != 'System' ? AppSpacing.sm : 0,
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _selectedTheme = theme.label),
                    borderRadius: AppSpacing.borderRadiusSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppSpacing.borderRadiusSm,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF5A7CFF)
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected
                            ? const Color(0xFF5A7CFF).withValues(alpha: 0.05)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            theme.icon,
                            size: 24,
                            color: isSelected
                                ? const Color(0xFF5A7CFF)
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            theme.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF5A7CFF)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionItem(
    String title,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: AppSpacing.paddingMd,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF5A7CFF),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _clearCache(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cache cleared successfully'.tr(context)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ThemeOption {
  final String label;
  final IconData icon;

  const _ThemeOption(this.label, this.icon);
}
