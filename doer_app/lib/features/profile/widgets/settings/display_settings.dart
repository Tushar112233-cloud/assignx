import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Display settings tab content.
///
/// Provides theme selection (light/dark/system), font size control,
/// compact mode, and cache management.
class DisplaySettings extends StatefulWidget {
  const DisplaySettings({super.key});

  @override
  State<DisplaySettings> createState() => _DisplaySettingsState();
}

class _DisplaySettingsState extends State<DisplaySettings> {
  String _selectedTheme = 'Light';
  String _selectedLanguage = 'English';
  bool _compactMode = false;

  @override
  Widget build(BuildContext context) {
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

          // Language & Layout
          _buildSectionHeader('Language & Layout', Icons.translate_outlined),
          const SizedBox(height: AppSpacing.sm),
          _buildSettingsCard([
            _buildSelectionItem(
              'Language',
              _selectedLanguage,
              Icons.language,
              onTap: () => _showLanguageSheet(context),
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
          const Text(
            'Theme',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          const Text(
            'Select your preferred color theme',
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

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: AppSpacing.paddingMd,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLanguageOption('English'),
            _buildLanguageOption('Hindi'),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;
    return ListTile(
      leading: isSelected
          ? const Icon(Icons.check, color: Color(0xFF5A7CFF))
          : const SizedBox(width: 24),
      title: Text(language),
      onTap: () {
        setState(() => _selectedLanguage = language);
        Navigator.pop(context);
      },
    );
  }

  void _clearCache(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared successfully'),
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
