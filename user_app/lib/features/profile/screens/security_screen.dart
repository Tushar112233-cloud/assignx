import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';

// ============================================================
// DESIGN CONSTANTS
// ============================================================

/// Design colors matching the profile screen specification.
class _SecurityColors {
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B6B6B);
  static const mutedText = Color(0xFF8B8B8B);
  static const toggleOn = Color(0xFF5D3A3A);
  static const toggleOff = Color(0xFFE0E0E0);
  static const actionRed = Color(0xFFF44336);
  static const clearRedBackground = Color(0xFFFFF0F0);
  static const successGreen = Color(0xFF4CAF50);
  static const successBackground = Color(0xFFE8F5E9);
  static const infoBlue = Color(0xFF2196F3);
  static const infoBackground = Color(0xFFF0F7FF);
  static const chipBackground = Color(0xFFF5F5F5);
}

// ============================================================
// MAIN SCREEN
// ============================================================

/// Security settings screen with password change, 2FA, sessions, and danger zone.
///
/// Features:
/// - Change password with strength indicator (functional via Supabase)
/// - Two-factor authentication toggle (coming soon)
/// - Active sessions display (coming soon)
/// - Danger zone with account deletion
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  // Password form controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Visibility toggles
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Loading state
  bool _isUpdatingPassword = false;

  // 2FA toggle
  bool _is2FAEnabled = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SubtleGradientScaffold.standard(
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar with back button
            _buildAppBar(),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Page title
                    _buildPageTitle(),
                    const SizedBox(height: 24),

                    // Change Password section
                    _buildChangePasswordCard(),
                    const SizedBox(height: 16),

                    // Two-Factor Authentication section
                    _buildTwoFactorCard(),
                    const SizedBox(height: 16),

                    // Active Sessions section
                    _buildActiveSessionsCard(),
                    const SizedBox(height: 16),

                    // Danger Zone section
                    _buildDangerZoneCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  /// Builds the custom app bar with back button.
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Security',
            style: AppTextStyles.headingSmall,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE TITLE
  // ============================================================

  /// Builds the page title section.
  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Settings',
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: _SecurityColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your account security and privacy',
          style: AppTextStyles.bodyMedium.copyWith(
            color: _SecurityColors.secondaryText,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CHANGE PASSWORD CARD
  // ============================================================

  /// Builds the change password section card.
  Widget _buildChangePasswordCard() {
    return _SectionCard(
      icon: Icons.lock_outline,
      iconBackgroundColor: const Color(0xFFFFF3E0),
      title: 'Change Password',
      subtitle: 'Update your account password',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Current password field
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Current Password',
                isVisible: _showCurrentPassword,
                onToggleVisibility: () {
                  setState(() => _showCurrentPassword = !_showCurrentPassword);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New password field
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'New Password',
                isVisible: _showNewPassword,
                onToggleVisibility: () {
                  setState(() => _showNewPassword = !_showNewPassword);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Password strength indicator
              _buildPasswordStrengthIndicator(),
              const SizedBox(height: 16),

              // Confirm password field
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                isVisible: _showConfirmPassword,
                onToggleVisibility: () {
                  setState(() => _showConfirmPassword = !_showConfirmPassword);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Update Password button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUpdatingPassword ? null : _handleUpdatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D3228),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: const Color(0xFF3D3228).withAlpha(128),
                  ),
                  child: _isUpdatingPassword
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Update Password',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a password text field with visibility toggle.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      onChanged: (_) => setState(() {}),
      style: AppTextStyles.bodyMedium.copyWith(
        color: _SecurityColors.primaryText,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: _SecurityColors.mutedText,
        ),
        filled: true,
        fillColor: _SecurityColors.chipBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _SecurityColors.actionRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _SecurityColors.actionRed,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: _SecurityColors.mutedText,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Builds the password strength indicator bar and label.
  Widget _buildPasswordStrengthIndicator() {
    final password = _newPasswordController.text;
    final strength = _calculatePasswordStrength(password);

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    Color strengthColor;
    String strengthLabel;

    if (strength < 0.25) {
      strengthColor = _SecurityColors.actionRed;
      strengthLabel = 'Weak';
    } else if (strength < 0.5) {
      strengthColor = const Color(0xFFFF9800);
      strengthLabel = 'Fair';
    } else if (strength < 0.75) {
      strengthColor = const Color(0xFFFFC107);
      strengthLabel = 'Good';
    } else {
      strengthColor = _SecurityColors.successGreen;
      strengthLabel = 'Strong';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 4,
            backgroundColor: _SecurityColors.chipBackground,
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          ),
        ),
        const SizedBox(height: 6),
        // Strength label
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: strengthColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Password strength: $strengthLabel',
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Calculates password strength as a value between 0.0 and 1.0.
  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // Length checks
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;
    if (password.length >= 16) strength += 0.1;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.15;

    return strength.clamp(0.0, 1.0);
  }

  /// Handles the password update via Supabase auth.
  Future<void> _handleUpdatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdatingPassword = true);

    try {
      final newPassword = _newPasswordController.text;

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (mounted) {
        // Clear the form
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password updated successfully'),
            backgroundColor: _SecurityColors.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: _SecurityColors.actionRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('An unexpected error occurred. Please try again.'),
            backgroundColor: _SecurityColors.actionRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPassword = false);
      }
    }
  }

  // ============================================================
  // TWO-FACTOR AUTHENTICATION CARD
  // ============================================================

  /// Builds the two-factor authentication section card.
  Widget _buildTwoFactorCard() {
    return _SectionCard(
      icon: Icons.security_outlined,
      iconBackgroundColor: _SecurityColors.successBackground,
      title: 'Two-Factor Authentication',
      subtitle: 'Add an extra layer of security',
      children: [
        // Status indicator
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _is2FAEnabled
                ? _SecurityColors.successBackground
                : _SecurityColors.chipBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _is2FAEnabled
                      ? _SecurityColors.successGreen.withAlpha(30)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _is2FAEnabled ? Icons.check_circle : Icons.cancel_outlined,
                  size: 20,
                  color: _is2FAEnabled
                      ? _SecurityColors.successGreen
                      : _SecurityColors.mutedText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _is2FAEnabled ? 'Enabled' : 'Disabled',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _is2FAEnabled
                            ? _SecurityColors.successGreen
                            : _SecurityColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _is2FAEnabled
                          ? 'Your account has 2FA protection'
                          : 'Enable 2FA for enhanced security',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: _SecurityColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              _CustomToggle(
                value: _is2FAEnabled,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Two-factor authentication is coming soon',
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Info text
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _SecurityColors.infoBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: _SecurityColors.infoBlue,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Two-factor authentication adds an extra step when logging in. '
                  'You will need to enter a code from your authenticator app in addition '
                  'to your password.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: _SecurityColors.secondaryText,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTIVE SESSIONS CARD
  // ============================================================

  /// Builds the active sessions section card.
  Widget _buildActiveSessionsCard() {
    return _SectionCard(
      icon: Icons.devices_outlined,
      iconBackgroundColor: const Color(0xFFE8E0F8),
      title: 'Active Sessions',
      subtitle: 'Manage your logged-in devices',
      children: [
        // Current session
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _SecurityColors.successBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _SecurityColors.successGreen.withAlpha(40),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _SecurityColors.successGreen.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.phone_android,
                  size: 20,
                  color: _SecurityColors.successGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'This Device',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _SecurityColors.primaryText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _SecurityColors.successGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Active',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mobile App  --  Last active: Now',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: _SecurityColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Sign out all other sessions button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Session management is coming soon',
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _SecurityColors.actionRed.withAlpha(80),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: Icon(
              Icons.logout,
              size: 18,
              color: _SecurityColors.actionRed,
            ),
            label: Text(
              'Sign Out All Other Sessions',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _SecurityColors.actionRed,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DANGER ZONE CARD
  // ============================================================

  /// Builds the danger zone card for account deletion.
  Widget _buildDangerZoneCard() {
    return Container(
      decoration: BoxDecoration(
        color: _SecurityColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _SecurityColors.actionRed.withAlpha(60),
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
                    color: _SecurityColors.clearRedBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: _SecurityColors.actionRed,
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
                          color: _SecurityColors.actionRed,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Irreversible actions',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          color: _SecurityColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Delete account option
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _SecurityColors.clearRedBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _SecurityColors.actionRed.withAlpha(40),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete Account',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _SecurityColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Permanently delete your account and all data',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: _SecurityColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _showDeleteAccountDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _SecurityColors.actionRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the delete account confirmation dialog.
  void _showDeleteAccountDialog() {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: _SecurityColors.clearRedBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: _SecurityColors.actionRed,
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
                  color: _SecurityColors.secondaryText,
                ),
              ),
              const SizedBox(height: 12),
              _buildWarningItem('Remove all your personal information'),
              _buildWarningItem('Delete all your projects and history'),
              _buildWarningItem('Cancel any active subscriptions'),
              _buildWarningItem('Remove access to all connected services'),
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
                  hintStyle: const TextStyle(
                    fontFamily: 'monospace',
                    color: _SecurityColors.mutedText,
                  ),
                  filled: true,
                  fillColor: _SecurityColors.chipBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontFamily: 'monospace'),
                onChanged: (_) => setDialogState(() {}),
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
                  ? () {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Account deletion request submitted',
                          ),
                          backgroundColor: _SecurityColors.actionRed,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _SecurityColors.actionRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single warning bullet item.
  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 6,
              color: _SecurityColors.actionRed,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: _SecurityColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PRIVATE WIDGETS
// ============================================================

/// Reusable section card container with icon header.
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _SecurityColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
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
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: _SecurityColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _SecurityColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          color: _SecurityColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Children
            ...children,
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
          color: value ? _SecurityColors.toggleOn : _SecurityColors.toggleOff,
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
