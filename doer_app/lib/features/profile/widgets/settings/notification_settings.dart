import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../providers/profile_provider.dart';

/// Notification settings tab content.
///
/// Provides toggle switches for email, push, project updates,
/// payment alerts, and review notifications.
class NotificationSettings extends StatelessWidget {
  const NotificationSettings({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
  });

  final NotificationPreferences preferences;
  final ValueChanged<NotificationPreferences> onPreferencesChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General Notifications
          _buildSectionHeader('General', Icons.notifications_outlined),
          const SizedBox(height: AppSpacing.sm),
          _buildSettingsCard([
            _buildSwitchItem(
              'Push Notifications',
              'Receive push notifications on your device',
              Icons.notifications_active_outlined,
              preferences.pushNotifications,
              (value) => onPreferencesChanged(
                preferences.copyWith(pushNotifications: value),
              ),
            ),
            _buildSwitchItem(
              'Email Notifications',
              'Receive email updates about your activity',
              Icons.email_outlined,
              preferences.emailNotifications,
              (value) => onPreferencesChanged(
                preferences.copyWith(emailNotifications: value),
              ),
            ),
          ]),

          const SizedBox(height: AppSpacing.lg),

          // Project Notifications
          _buildSectionHeader('Projects', Icons.assignment_outlined),
          const SizedBox(height: AppSpacing.sm),
          _buildSettingsCard([
            _buildSwitchItem(
              'New Project Alerts',
              'Get notified when matching projects are posted',
              Icons.campaign_outlined,
              preferences.newProjectAlerts,
              (value) => onPreferencesChanged(
                preferences.copyWith(newProjectAlerts: value),
              ),
            ),
            _buildSwitchItem(
              'Deadline Reminders',
              'Receive reminders before project deadlines',
              Icons.alarm_outlined,
              preferences.deadlineReminders,
              (value) => onPreferencesChanged(
                preferences.copyWith(deadlineReminders: value),
              ),
            ),
          ]),

          const SizedBox(height: AppSpacing.lg),

          // Payment Notifications
          _buildSectionHeader('Payments & Promotions', Icons.payment_outlined),
          const SizedBox(height: AppSpacing.sm),
          _buildSettingsCard([
            _buildSwitchItem(
              'Payment Alerts',
              'Get notified about payment status changes',
              Icons.payment_outlined,
              preferences.paymentUpdates,
              (value) => onPreferencesChanged(
                preferences.copyWith(paymentUpdates: value),
              ),
            ),
            _buildSwitchItem(
              'Marketing Emails',
              'Receive promotional content and offers',
              Icons.local_offer_outlined,
              preferences.marketingEmails,
              (value) => onPreferencesChanged(
                preferences.copyWith(marketingEmails: value),
              ),
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
}
