import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';

/// Button variant types.
enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

/// Button size types.
enum AppButtonSize {
  small,
  medium,
  large,
}

/// Reusable app button with multiple variants.
///
/// Supports primary, secondary, outline, and text variants
/// with loading state and icon support.
class AppButton extends StatelessWidget {
  /// Button label text.
  final String label;

  /// Callback when button is pressed.
  final VoidCallback? onPressed;

  /// Button variant style.
  final AppButtonVariant variant;

  /// Button size.
  final AppButtonSize size;

  /// Whether button is in loading state.
  final bool isLoading;

  /// Whether button takes full width.
  final bool fullWidth;

  /// Optional icon to show before label.
  final IconData? icon;

  /// Optional icon widget (takes precedence over icon).
  final Widget? iconWidget;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context, isDisabled),
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.medium:
        return 52;
      case AppButtonSize.large:
        return 60;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
    }
  }

  double _getFontSize() {
    switch (size) {
      case AppButtonSize.small:
        return 14;
      case AppButtonSize.medium:
        return 16;
      case AppButtonSize.large:
        return 18;
    }
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            elevation: 0,
          ),
          child: _buildContent(AppColors.textOnPrimary),
        );

      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight.withAlpha(25), // 0.1 opacity
            foregroundColor: AppColors.primary,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            elevation: 0,
          ),
          child: _buildContent(AppColors.primary),
        );

      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _getPadding(),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.borderRadiusMd,
            ),
          ),
          child: _buildContent(AppColors.primary),
        );

      case AppButtonVariant.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _getPadding(),
          ),
          child: _buildContent(AppColors.primary),
        );
    }
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    final hasIcon = icon != null || iconWidget != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasIcon) ...[
          iconWidget ?? Icon(icon, size: _getFontSize() + 4),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
