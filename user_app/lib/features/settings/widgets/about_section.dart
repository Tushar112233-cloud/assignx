import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_text_styles.dart';

// ============================================================
// DESIGN CONSTANTS
// ============================================================

class _AboutColors {
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B6B6B);
  static const mutedText = Color(0xFF8B8B8B);
  static const chipBackground = Color(0xFFF5F5F5);
  static const iconBackground = Color(0xFFE8E0F8);
  static const betaBadgeColor = Color(0xFF4CAF50);
  static const betaBadgeBackground = Color(0xFFE8F5E9);
}

// ============================================================
// WIDGET
// ============================================================

/// About AssignX section card for the settings screen.
/// Displays version info, build number, status badge, and legal links.
class AboutSection extends ConsumerWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: _AboutColors.cardBackground,
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
                    color: _AboutColors.iconBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: _AboutColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About AssignX',
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _AboutColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'App information',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          color: _AboutColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info Chips with dynamic version
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
                    _StatusBadge(),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Navigation Links
            _NavigationLinkItem(
              title: 'Terms of Service',
              icon: Icons.description_outlined,
              onTap: () => _launchUrl('https://assignx.in/terms'),
            ),
            _NavigationLinkItem(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: () => _launchUrl('https://assignx.in/privacy'),
            ),
            _NavigationLinkItem(
              title: 'Open Source',
              icon: Icons.code_outlined,
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'AssignX',
                applicationVersion: '1.0.0',
              ),
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ============================================================
// PRIVATE WIDGETS
// ============================================================

/// Info chip for displaying version, build, etc.
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _AboutColors.chipBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: _AboutColors.mutedText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _AboutColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status badge showing "Beta".
class _StatusBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _AboutColors.betaBadgeBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: _AboutColors.mutedText,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _AboutColors.betaBadgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Beta',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _AboutColors.betaBadgeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation link item with icon and chevron.
class _NavigationLinkItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showDivider;

  const _NavigationLinkItem({
    required this.title,
    required this.icon,
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
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: _AboutColors.chipBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: _AboutColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _AboutColors.primaryText,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: _AboutColors.mutedText,
                ),
              ],
            ),
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
