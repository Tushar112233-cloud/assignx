/// Password strength indicator widgets for form validation.
///
/// This file provides visual indicators for password strength,
/// helping users create secure passwords during registration.
///
/// ## Widgets
/// - [PasswordStrengthIndicator] - Visual strength meter with label
/// - [PasswordRequirements] - Checklist of password requirements
/// - [PasswordStrength] - Enum for strength levels
///
/// ## Features
/// - Four-segment strength bar
/// - Color-coded strength levels (red, yellow, blue, green)
/// - Icon and label display for current strength
/// - Requirements checklist with real-time validation
/// - Automatic strength calculation based on password
///
/// ## Strength Criteria
/// - Length (8+ characters, 12+ characters)
/// - Lowercase letters
/// - Uppercase letters
/// - Numbers
/// - Special characters
///
/// ## Example
/// ```dart
/// // Strength indicator with label
/// PasswordStrengthIndicator(
///   password: passwordController.text,
///   showLabel: true,
/// )
///
/// // Requirements checklist
/// PasswordRequirements(
///   password: passwordController.text,
/// )
/// ```
///
/// See also:
/// - [AppTextField] for password input field
/// - [AppColors] for the color scheme
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Password strength levels.
///
/// Represents the four levels of password security:
/// - [weak]: Minimal security, easy to crack
/// - [fair]: Some security, could be stronger
/// - [good]: Decent security, acceptable
/// - [strong]: High security, recommended
enum PasswordStrength {
  /// Minimal password security.
  weak,

  /// Basic password security.
  fair,

  /// Acceptable password security.
  good,

  /// Strong password security.
  strong,
}

/// Visual password strength indicator.
///
/// Displays a four-segment bar showing password strength,
/// with optional label and icon indicating the current level.
///
/// ## Usage
/// ```dart
/// PasswordStrengthIndicator(
///   password: 'MyP@ssw0rd123',
///   showLabel: true,
/// )
/// ```
///
/// ## Strength Levels
/// - **Weak** (red, 1 bar): Score <= 2
/// - **Fair** (yellow, 2 bars): Score 3
/// - **Good** (blue, 3 bars): Score 4-5
/// - **Strong** (green, 4 bars): Score 6+
///
/// ## Scoring System
/// - +1 for length >= 8
/// - +1 for length >= 12
/// - +1 for lowercase letters
/// - +1 for uppercase letters
/// - +1 for numbers
/// - +1 for special characters
///
/// See also:
/// - [PasswordRequirements] for detailed checklist
/// - [PasswordStrength] for strength enumeration
class PasswordStrengthIndicator extends StatelessWidget {
  /// Creates a password strength indicator.
  ///
  /// [password] is required.
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showLabel = true,
  });

  /// The password to evaluate.
  final String password;

  /// Whether to show the strength label below the bar.
  ///
  /// Defaults to true.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password);
    final strengthData = _getStrengthData(strength);

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index < 3 ? AppSpacing.xs : 0,
                ),
                decoration: BoxDecoration(
                  color: index < strengthData.level
                      ? strengthData.color
                      : AppColors.border,
                  borderRadius: AppSpacing.borderRadiusXs,
                ),
              ),
            );
          }),
        ),
        if (showLabel) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                strengthData.icon,
                size: 14,
                color: strengthData.color,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                strengthData.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: strengthData.color,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Calculates password strength based on various criteria.
  PasswordStrength _calculateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    int score = 0;

    // Length checks
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.fair;
    if (score <= 5) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  /// Returns the visual data for a given strength level.
  _StrengthData _getStrengthData(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return const _StrengthData(
          level: 1,
          label: 'Weak',
          color: AppColors.error,
          icon: Icons.warning_amber_rounded,
        );
      case PasswordStrength.fair:
        return const _StrengthData(
          level: 2,
          label: 'Fair',
          color: AppColors.warning,
          icon: Icons.info_outline,
        );
      case PasswordStrength.good:
        return const _StrengthData(
          level: 3,
          label: 'Good',
          color: AppColors.info,
          icon: Icons.check_circle_outline,
        );
      case PasswordStrength.strong:
        return const _StrengthData(
          level: 4,
          label: 'Strong',
          color: AppColors.success,
          icon: Icons.verified_outlined,
        );
    }
  }
}

/// Internal data class for strength visual properties.
class _StrengthData {
  const _StrengthData({
    required this.level,
    required this.label,
    required this.color,
    required this.icon,
  });

  /// Number of bars to fill (1-4).
  final int level;

  /// Display label for the strength level.
  final String label;

  /// Color for the strength level.
  final Color color;

  /// Icon representing the strength level.
  final IconData icon;
}

/// Password requirements checklist widget.
///
/// Displays a list of password requirements with real-time
/// validation indicators showing which requirements are met.
///
/// ## Usage
/// ```dart
/// PasswordRequirements(
///   password: passwordController.text,
/// )
/// ```
///
/// ## Requirements Checked
/// - Minimum 8 characters
/// - Contains uppercase letter
/// - Contains lowercase letter
/// - Contains a number
///
/// ## Visual States
/// - **Met**: Green check circle icon
/// - **Not met**: Gray circle outline icon
///
/// See also:
/// - [PasswordStrengthIndicator] for visual strength meter
class PasswordRequirements extends StatelessWidget {
  /// Creates a password requirements checklist.
  ///
  /// [password] is required.
  const PasswordRequirements({
    super.key,
    required this.password,
  });

  /// The password to validate against requirements.
  final String password;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequirementItem(
          label: 'At least 8 characters',
          isMet: password.length >= 8,
        ),
        _RequirementItem(
          label: 'Contains uppercase letter',
          isMet: RegExp(r'[A-Z]').hasMatch(password),
        ),
        _RequirementItem(
          label: 'Contains lowercase letter',
          isMet: RegExp(r'[a-z]').hasMatch(password),
        ),
        _RequirementItem(
          label: 'Contains a number',
          isMet: RegExp(r'\d').hasMatch(password),
        ),
      ],
    );
  }
}

/// Internal widget for a single requirement item.
class _RequirementItem extends StatelessWidget {
  final String label;
  final bool isMet;

  const _RequirementItem({
    required this.label,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
