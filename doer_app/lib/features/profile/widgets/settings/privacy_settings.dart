import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Privacy settings tab content.
///
/// Provides toggles for profile visibility, show email, show phone,
/// and data sharing preferences.
class PrivacySettings extends StatefulWidget {
  const PrivacySettings({super.key});

  @override
  State<PrivacySettings> createState() => _PrivacySettingsState();
}

class _PrivacySettingsState extends State<PrivacySettings> {
  bool _profileVisible = true;
  bool _showEmail = false;
  bool _showPhone = false;
  bool _dataSharing = false;
  bool _activityStatus = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Visibility
          _buildSectionHeader('Profile Visibility', Icons.visibility_outlined),
          const SizedBox(height: AppSpacing.sm),
          _buildSettingsCard([
            _buildSwitchItem(
              'Public Profile',
              'Allow others to view your profile',
              Icons.person_outline,
              _profileVisible,
              (value) => setState(() => _profileVisible = value),
            ),
            _buildSwitchItem(
              'Show Activity Status',
              'Let others see when you are online',
              Icons.circle_outlined,
              _activityStatus,
              (value) => setState(() => _activityStatus = value),
            ),
          ]),

          const SizedBox(height: AppSpacing.lg),

          // Contact Information
          _buildSectionHeader(
            'Contact Information',
            Icons.contact_mail_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildSettingsCard([
            _buildSwitchItem(
              'Show Email Address',
              'Display your email on your public profile',
              Icons.alternate_email,
              _showEmail,
              (value) => setState(() => _showEmail = value),
            ),
            _buildSwitchItem(
              'Show Phone Number',
              'Display your phone number on your profile',
              Icons.phone_outlined,
              _showPhone,
              (value) => setState(() => _showPhone = value),
            ),
          ]),

          const SizedBox(height: AppSpacing.lg),

          // Data & Analytics
          _buildSectionHeader('Data & Analytics', Icons.analytics_outlined),
          const SizedBox(height: AppSpacing.sm),
          _buildSettingsCard([
            _buildSwitchItem(
              'Data Sharing',
              'Allow anonymous usage data to improve the app',
              Icons.bar_chart_outlined,
              _dataSharing,
              (value) => setState(() => _dataSharing = value),
            ),
          ]),

          const SizedBox(height: AppSpacing.lg),

          // Legal
          _buildSectionHeader('Legal', Icons.gavel_outlined),
          const SizedBox(height: AppSpacing.sm),
          _buildSettingsCard([
            _buildNavigationItem(
              'Privacy Policy',
              'Read our privacy policy',
              Icons.privacy_tip_outlined,
            ),
            _buildNavigationItem(
              'Terms of Service',
              'Read our terms of service',
              Icons.description_outlined,
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

  Widget _buildNavigationItem(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {},
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
}
