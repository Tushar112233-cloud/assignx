import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/user_type.dart';

/// Size variants for the account badge.
enum BadgeSize {
  /// Small badge - for compact spaces like lists
  sm,

  /// Medium badge - default size for most uses
  md,

  /// Large badge - for profile headers
  lg,
}

/// Configuration for each account type badge.
class _BadgeConfig {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final String description;

  const _BadgeConfig({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.description,
  });
}

/// Account badge widget that displays the user's account type.
///
/// Shows a color-coded pill badge with an icon and label indicating
/// whether the user is a Student, Professional, or Business Owner.
///
/// Features:
/// - Color coding: Student (Blue), Professional (Amber), Business (Purple)
/// - Optional verification checkmark overlay
/// - Multiple size variants (sm, md, lg)
/// - Animated appearance on load
/// - Long press tooltip with full description
///
/// Example usage:
/// ```dart
/// AccountBadge(
///   accountType: 'student',
///   isVerified: true,
///   size: BadgeSize.md,
/// )
/// ```
class AccountBadge extends StatefulWidget {
  /// The type of account. Accepts 'student', 'professional', or 'business_owner'.
  final String accountType;

  /// Whether the account is verified.
  final bool isVerified;

  /// Size variant of the badge.
  final BadgeSize size;

  /// Whether to animate the badge on first appearance.
  final bool animate;

  /// Callback when the badge is tapped.
  final VoidCallback? onTap;

  const AccountBadge({
    super.key,
    required this.accountType,
    this.isVerified = false,
    this.size = BadgeSize.md,
    this.animate = true,
    this.onTap,
  });

  /// Creates an AccountBadge from a UserType enum.
  factory AccountBadge.fromUserType({
    Key? key,
    required UserType? userType,
    bool isVerified = false,
    BadgeSize size = BadgeSize.md,
    bool animate = true,
    VoidCallback? onTap,
  }) {
    return AccountBadge(
      key: key,
      accountType: userType?.toDbString() ?? 'student',
      isVerified: isVerified,
      size: size,
      animate: animate,
      onTap: onTap,
    );
  }

  @override
  State<AccountBadge> createState() => _AccountBadgeState();
}

class _AccountBadgeState extends State<AccountBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  /// Badge configuration mapping for each account type.
  static final Map<String, _BadgeConfig> _badgeConfigs = {
    'student': const _BadgeConfig(
      label: 'Student',
      icon: Icons.school_outlined,
      backgroundColor: Color(0xFFDBEAFE), // blue-100
      textColor: Color(0xFF1D4ED8), // blue-700
      borderColor: Color(0xFFBFDBFE), // blue-200
      description: 'Currently pursuing education at a recognized institution',
    ),
    'professional': const _BadgeConfig(
      label: 'Professional',
      icon: Icons.work_outline,
      backgroundColor: Color(0xFFFEF3C7), // amber-100
      textColor: Color(0xFFB45309), // amber-700
      borderColor: Color(0xFFFDE68A), // amber-200
      description: 'Working professional with verified credentials',
    ),
    'business_owner': const _BadgeConfig(
      label: 'Business',
      icon: Icons.business_outlined,
      backgroundColor: Color(0xFFF3E8FF), // purple-100
      textColor: Color(0xFF7C3AED), // purple-700
      borderColor: Color(0xFFE9D5FF), // purple-200
      description: 'Registered business owner or entrepreneur',
    ),
  };

  /// Size configuration mapping.
  static const Map<BadgeSize, _SizeConfig> _sizeConfigs = {
    BadgeSize.sm: _SizeConfig(
      iconSize: 12,
      fontSize: 10,
      horizontalPadding: 6,
      verticalPadding: 2,
      checkSize: 10,
    ),
    BadgeSize.md: _SizeConfig(
      iconSize: 14,
      fontSize: 11,
      horizontalPadding: 8,
      verticalPadding: 3,
      checkSize: 12,
    ),
    BadgeSize.lg: _SizeConfig(
      iconSize: 16,
      fontSize: 13,
      horizontalPadding: 10,
      verticalPadding: 4,
      checkSize: 14,
    ),
  };

  _BadgeConfig get _config =>
      _badgeConfigs[widget.accountType.toLowerCase()] ??
      _badgeConfigs['student']!;

  _SizeConfig get _sizeConfig => _sizeConfigs[widget.size]!;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: Semantics(
        label: '${_config.label} account${widget.isVerified ? ', verified' : ''}',
        child: Tooltip(
          message: _config.description,
          preferBelow: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _sizeConfig.horizontalPadding,
                  vertical: _sizeConfig.verticalPadding,
                ),
                decoration: BoxDecoration(
                  color: _config.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _config.borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _config.icon,
                      size: _sizeConfig.iconSize,
                      color: _config.textColor,
                    ),
                    SizedBox(width: _sizeConfig.horizontalPadding / 2),
                    Text(
                      _config.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: _sizeConfig.fontSize,
                        fontWeight: FontWeight.w500,
                        color: _config.textColor,
                        height: 1.2,
                      ),
                    ),
                    if (widget.isVerified) ...[
                      SizedBox(width: _sizeConfig.horizontalPadding / 2),
                      Icon(
                        Icons.check_circle,
                        size: _sizeConfig.checkSize,
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Size configuration helper class.
class _SizeConfig {
  final double iconSize;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double checkSize;

  const _SizeConfig({
    required this.iconSize,
    required this.fontSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.checkSize,
  });
}

/// Compact account badge that only shows the icon.
///
/// Useful for tight spaces like project cards, chat headers, and user lists.
///
/// Example usage:
/// ```dart
/// CompactAccountBadge(
///   accountType: 'professional',
///   isVerified: true,
/// )
/// ```
class CompactAccountBadge extends StatelessWidget {
  /// The type of account.
  final String accountType;

  /// Whether the account is verified.
  final bool isVerified;

  /// Size of the badge (diameter).
  final double size;

  /// Callback when the badge is tapped.
  final VoidCallback? onTap;

  const CompactAccountBadge({
    super.key,
    required this.accountType,
    this.isVerified = false,
    this.size = 24,
    this.onTap,
  });

  /// Creates a CompactAccountBadge from a UserType enum.
  factory CompactAccountBadge.fromUserType({
    Key? key,
    required UserType? userType,
    bool isVerified = false,
    double size = 24,
    VoidCallback? onTap,
  }) {
    return CompactAccountBadge(
      key: key,
      accountType: userType?.toDbString() ?? 'student',
      isVerified: isVerified,
      size: size,
      onTap: onTap,
    );
  }

  static final Map<String, _CompactBadgeConfig> _configs = {
    'student': _CompactBadgeConfig(
      icon: Icons.school_outlined,
      backgroundColor: const Color(0xFFDBEAFE),
      iconColor: const Color(0xFF1D4ED8),
      label: 'Student',
    ),
    'professional': _CompactBadgeConfig(
      icon: Icons.work_outline,
      backgroundColor: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFB45309),
      label: 'Professional',
    ),
    'business_owner': _CompactBadgeConfig(
      icon: Icons.business_outlined,
      backgroundColor: const Color(0xFFF3E8FF),
      iconColor: const Color(0xFF7C3AED),
      label: 'Business',
    ),
  };

  _CompactBadgeConfig get _config =>
      _configs[accountType.toLowerCase()] ?? _configs['student']!;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${_config.label} account${isVerified ? ', verified' : ''}',
      child: Tooltip(
        message: '${_config.label}${isVerified ? ' (Verified)' : ''}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: _config.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _config.icon,
                      size: size * 0.55,
                      color: _config.iconColor,
                    ),
                  ),
                ),
                if (isVerified)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: size * 0.45,
                      height: size * 0.45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle,
                          size: size * 0.4,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Configuration for compact badge.
class _CompactBadgeConfig {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String label;

  const _CompactBadgeConfig({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.label,
  });
}

/// Account badge for use on dark/colored backgrounds (like profile hero).
///
/// Uses glass morphism styling for better visibility on gradients.
class AccountBadgeGlass extends StatelessWidget {
  /// The type of account.
  final String accountType;

  /// Whether the account is verified.
  final bool isVerified;

  /// Callback when the badge is tapped.
  final VoidCallback? onTap;

  const AccountBadgeGlass({
    super.key,
    required this.accountType,
    this.isVerified = false,
    this.onTap,
  });

  /// Creates an AccountBadgeGlass from a UserType enum.
  factory AccountBadgeGlass.fromUserType({
    Key? key,
    required UserType? userType,
    bool isVerified = false,
    VoidCallback? onTap,
  }) {
    return AccountBadgeGlass(
      key: key,
      accountType: userType?.toDbString() ?? 'student',
      isVerified: isVerified,
      onTap: onTap,
    );
  }

  static const Map<String, _GlassBadgeConfig> _configs = {
    'student': _GlassBadgeConfig(
      icon: Icons.school_outlined,
      label: 'Student',
    ),
    'professional': _GlassBadgeConfig(
      icon: Icons.work_outline,
      label: 'Professional',
    ),
    'business_owner': _GlassBadgeConfig(
      icon: Icons.business_outlined,
      label: 'Business',
    ),
  };

  _GlassBadgeConfig get _config =>
      _configs[accountType.toLowerCase()] ?? _configs['student']!;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${_config.label} account${isVerified ? ', verified' : ''}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withAlpha(80),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _config.icon,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  _config.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isVerified) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle,
                    size: 12,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Configuration for glass badge.
class _GlassBadgeConfig {
  final IconData icon;
  final String label;

  const _GlassBadgeConfig({
    required this.icon,
    required this.label,
  });
}

/// Helper extension to get account badge from UserType.
extension AccountBadgeExtension on UserType {
  /// Creates an AccountBadge widget for this user type.
  AccountBadge toBadge({
    bool isVerified = false,
    BadgeSize size = BadgeSize.md,
    bool animate = true,
    VoidCallback? onTap,
  }) {
    return AccountBadge.fromUserType(
      userType: this,
      isVerified: isVerified,
      size: size,
      animate: animate,
      onTap: onTap,
    );
  }

  /// Creates a CompactAccountBadge widget for this user type.
  CompactAccountBadge toCompactBadge({
    bool isVerified = false,
    double size = 24,
    VoidCallback? onTap,
  }) {
    return CompactAccountBadge.fromUserType(
      userType: this,
      isVerified: isVerified,
      size: size,
      onTap: onTap,
    );
  }

  /// Creates an AccountBadgeGlass widget for this user type.
  AccountBadgeGlass toGlassBadge({
    bool isVerified = false,
    VoidCallback? onTap,
  }) {
    return AccountBadgeGlass.fromUserType(
      userType: this,
      isVerified: isVerified,
      onTap: onTap,
    );
  }
}
