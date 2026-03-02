import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/profile_provider.dart';

// ============================================================
// DESIGN CONSTANTS
// ============================================================

class _DangerColors {
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B6B6B);
  static const mutedText = Color(0xFF8B8B8B);
  static const actionRed = Color(0xFFF44336);
  static const redBackground = Color(0xFFFFF0F0);
  static const warningAmber = Color(0xFFF59E0B);
  static const amberBackground = Color(0xFFFFF8E1);
}

// ============================================================
// WIDGET
// ============================================================

/// Danger Zone section card for the settings screen.
/// Contains destructive actions: Log Out, Deactivate Account, Delete Account.
class DangerZoneSection extends ConsumerWidget {
  const DangerZoneSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: _DangerColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _DangerColors.actionRed.withValues(alpha: 0.3),
          width: 1,
        ),
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
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _DangerColors.redBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: _DangerColors.actionRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger Zone',
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _DangerColors.actionRed,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Irreversible actions',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          color: _DangerColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Log Out Button
            _DangerActionTile(
              icon: Icons.logout,
              title: 'Log Out',
              subtitle: 'Sign out of your account',
              backgroundColor: _DangerColors.amberBackground,
              borderColor: _DangerColors.warningAmber.withValues(alpha: 0.3),
              buttonColor: _DangerColors.warningAmber,
              buttonLabel: 'Log Out',
              onPressed: () => _showLogoutDialog(context, ref),
            ),
            const SizedBox(height: 10),

            // Deactivate Account Button
            _DangerActionTile(
              icon: Icons.pause_circle_outline,
              title: 'Deactivate Account',
              subtitle: 'Temporarily disable your account',
              backgroundColor: _DangerColors.amberBackground,
              borderColor: _DangerColors.warningAmber.withValues(alpha: 0.3),
              buttonColor: _DangerColors.warningAmber,
              buttonLabel: 'Deactivate',
              onPressed: () => _showDeactivateDialog(context, ref),
            ),
            const SizedBox(height: 10),

            // Delete Account Button
            _DangerActionTile(
              icon: Icons.delete_forever_outlined,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account and all data',
              backgroundColor: _DangerColors.redBackground,
              borderColor: _DangerColors.actionRed.withValues(alpha: 0.2),
              buttonColor: _DangerColors.actionRed,
              buttonLabel: 'Delete',
              onPressed: () => _showDeleteAccountDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the log out confirmation dialog.
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
                final repository = ref.read(profileRepositoryProvider);
                await repository.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: ${e.toString()}')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _DangerColors.warningAmber,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  /// Shows the deactivate account confirmation dialog.
  void _showDeactivateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: _DangerColors.amberBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pause_circle_outline,
                color: _DangerColors.warningAmber,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Deactivate Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deactivating your account will:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _DangerColors.secondaryText,
              ),
            ),
            const SizedBox(height: 12),
            _WarningItem(
              text: 'Hide your profile from other users',
              color: _DangerColors.warningAmber,
            ),
            _WarningItem(
              text: 'Pause all active projects',
              color: _DangerColors.warningAmber,
            ),
            _WarningItem(
              text: 'You can reactivate anytime by logging back in',
              color: _DangerColors.warningAmber,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deactivateAccount(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _DangerColors.warningAmber,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  /// Deactivates the account via the API, then signs out.
  Future<void> _deactivateAccount(BuildContext context, WidgetRef ref) async {
    try {
      await ApiClient.post('/profiles/me/deactivate', {});

      final repository = ref.read(profileRepositoryProvider);
      await repository.logout();

      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to deactivate account: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Shows the delete account confirmation dialog with password re-entry.
  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: _DangerColors.redBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: _DangerColors.actionRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Delete Account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This action is permanent and irreversible. Deleting your account will:',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _DangerColors.secondaryText,
                ),
              ),
              const SizedBox(height: 12),
              _WarningItem(
                text: 'Remove all your personal information',
                color: _DangerColors.actionRed,
              ),
              _WarningItem(
                text: 'Delete all your projects and history',
                color: _DangerColors.actionRed,
              ),
              _WarningItem(
                text: 'Cancel any active subscriptions',
                color: _DangerColors.actionRed,
              ),
              _WarningItem(
                text: 'Remove access to all connected services',
                color: _DangerColors.actionRed,
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
                    color: _DangerColors.mutedText,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
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
                      await _deleteAccount(context, ref);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _DangerColors.actionRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }

  /// Deletes the account by setting deleted_at = now(), then signs out.
  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    try {
      await ApiClient.post('/profiles/me/delete', {});

      final repository = ref.read(profileRepositoryProvider);
      await repository.logout();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deletion request submitted'),
            backgroundColor: _DangerColors.actionRed,
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ============================================================
// PRIVATE WIDGETS
// ============================================================

/// Action tile for danger zone buttons.
class _DangerActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color borderColor;
  final Color buttonColor;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _DangerActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.borderColor,
    required this.buttonColor,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: buttonColor,
          ),
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
                    color: _DangerColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: _DangerColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

/// Warning item for confirmation dialogs.
class _WarningItem extends StatelessWidget {
  final String text;
  final Color color;

  const _WarningItem({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: _DangerColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
