library;

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Glass morphism container with backdrop blur effect.
class GlassContainer extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHoverEffect;
  final Duration animationDuration;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.85,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.width,
    this.height,
    this.shadows,
    this.gradient,
    this.onTap,
    this.onLongPress,
    this.enableHoverEffect = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  Matrix4 _createPressTransform() {
    return Matrix4.diagonal3Values(0.98, 0.98, 1.0)
      ..setTranslationRaw(0.0, -2.0, 0.0);
  }

  List<BoxShadow> get _defaultShadows => [
        BoxShadow(
          color: Colors.black.withAlpha(8),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withAlpha(5),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withAlpha(3),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableHoverEffect && (widget.onTap != null || widget.onLongPress != null)) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Colors.white;
    final bdrColor = widget.borderColor ?? Colors.white.withAlpha(77);
    final radius = widget.borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);
    final isInteractive = widget.onTap != null || widget.onLongPress != null;

    Widget glassWidget = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: Curves.easeOutCubic,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bgColor.withAlpha((widget.opacity * 255).round()),
            borderRadius: radius,
            border: Border.all(
              color: bdrColor,
              width: widget.borderWidth,
            ),
            boxShadow: widget.shadows ?? _defaultShadows,
            gradient: widget.gradient,
          ),
          transform: _isPressed && widget.enableHoverEffect
              ? _createPressTransform()
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );

    if (isInteractive) {
      glassWidget = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: glassWidget,
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: glassWidget,
    );
  }
}

/// Preset glass container variants for common use cases.
class GlassContainerVariants {
  GlassContainerVariants._();

  static GlassContainer light({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return GlassContainer(
      blur: 12,
      opacity: 0.2,
      borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg),
      borderColor: Colors.white.withAlpha(64),
      padding: padding,
      margin: margin,
      backgroundColor: Colors.white,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  static GlassContainer dark({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return GlassContainer(
      blur: 15,
      opacity: 0.3,
      borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg),
      borderColor: Colors.white.withAlpha(38),
      padding: padding,
      margin: margin,
      backgroundColor: AppColors.textPrimary,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  static GlassContainer primary({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return GlassContainer(
      blur: 10,
      opacity: 0.12,
      borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg),
      borderColor: AppColors.primaryLight.withAlpha(51),
      padding: padding,
      margin: margin,
      backgroundColor: AppColors.primary,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  static GlassContainer card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return GlassContainer(
      blur: 8,
      opacity: 0.7,
      borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg),
      borderColor: AppColors.border.withAlpha(26),
      padding: padding ?? AppSpacing.cardPadding,
      margin: margin,
      backgroundColor: Colors.white,
      onTap: onTap,
      onLongPress: onLongPress,
      shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(10),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
      child: child,
    );
  }
}

/// Glass card widget with sensible card defaults.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHoverEffect;
  final List<BoxShadow>? shadows;
  final int elevation;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.75,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.enableHoverEffect = true,
    this.shadows,
    this.elevation = 2,
  });

  List<BoxShadow> get _elevationShadows {
    final shadowAlpha = (elevation * 4).clamp(0, 25);
    final blurRadius = (elevation * 8.0).clamp(4.0, 40.0);
    final yOffset = (elevation * 2.0).clamp(1.0, 12.0);

    return [
      BoxShadow(
        color: Colors.black.withAlpha(shadowAlpha),
        blurRadius: blurRadius,
        offset: Offset(0, yOffset),
      ),
      BoxShadow(
        color: Colors.black.withAlpha((shadowAlpha * 0.5).round()),
        blurRadius: blurRadius * 2,
        offset: Offset(0, yOffset * 2),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: blur,
      opacity: opacity,
      borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg),
      borderColor: borderColor ?? Colors.white.withAlpha(51),
      borderWidth: borderWidth,
      padding: padding ?? AppSpacing.cardPadding,
      margin: margin,
      backgroundColor: backgroundColor ?? Colors.white,
      gradient: gradient,
      width: width,
      height: height,
      onTap: onTap,
      onLongPress: onLongPress,
      enableHoverEffect: enableHoverEffect,
      shadows: shadows ?? _elevationShadows,
      child: child,
    );
  }
}

/// Glass button widget with built-in tap effects and loading state.
class GlassButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final bool fullWidth;
  final double height;
  final bool isLoading;
  final bool enableHoverEffect;
  final Duration animationDuration;
  final List<BoxShadow>? shadows;
  final double fontSize;
  final FontWeight fontWeight;

  const GlassButton({
    super.key,
    this.label,
    this.icon,
    this.iconWidget,
    this.onPressed,
    this.onLongPress,
    this.blur = 20.0,
    this.opacity = 0.85,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.0,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.margin,
    this.gradient,
    this.fullWidth = true,
    this.height = 52.0,
    this.isLoading = false,
    this.enableHoverEffect = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.shadows,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w600,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  Matrix4 _createPressTransform() {
    return Matrix4.diagonal3Values(0.98, 0.98, 1.0)
      ..setTranslationRaw(0.0, -2.0, 0.0);
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isDisabled && widget.enableHoverEffect) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? Colors.white;
    final fgColor = widget.foregroundColor ?? AppColors.textPrimary;
    final bdrColor = widget.borderColor ?? Colors.white.withAlpha(77);
    final radius = widget.borderRadius ?? BorderRadius.circular(AppSpacing.radiusMd);
    final defaultPadding = EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    );

    final buttonContent = widget.isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.iconWidget != null) ...[
                widget.iconWidget!,
                if (widget.label != null) const SizedBox(width: 8),
              ] else if (widget.icon != null) ...[
                Icon(widget.icon, size: widget.fontSize + 4, color: fgColor),
                if (widget.label != null) const SizedBox(width: 8),
              ],
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: widget.fontSize,
                    fontWeight: widget.fontWeight,
                    color: fgColor,
                  ),
                ),
            ],
          );

    Widget button = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: AnimatedContainer(
          duration: widget.animationDuration,
          curve: Curves.easeOutCubic,
          height: widget.height,
          padding: widget.padding ?? defaultPadding,
          decoration: BoxDecoration(
            color: bgColor.withAlpha(
              _isDisabled
                  ? ((widget.opacity * 255) * 0.6).round()
                  : (widget.opacity * 255).round(),
            ),
            borderRadius: radius,
            border: Border.all(
              color: bdrColor,
              width: widget.borderWidth,
            ),
            boxShadow: widget.shadows ??
                [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
            gradient: widget.gradient,
          ),
          transform: _isPressed
              ? _createPressTransform()
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: Center(child: buttonContent),
        ),
      ),
    );

    button = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _isDisabled ? null : widget.onPressed,
      onLongPress: _isDisabled ? null : widget.onLongPress,
      child: Opacity(
        opacity: _isDisabled ? 0.6 : 1.0,
        child: button,
      ),
    );

    return Container(
      width: widget.fullWidth ? double.infinity : null,
      margin: widget.margin,
      child: button,
    );
  }
}

/// Animated glass container with shimmer effect.
class AnimatedGlassContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;

  const AnimatedGlassContainer({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.blur = 20.0,
    this.opacity = 0.85,
    this.borderRadius,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  State<AnimatedGlassContainer> createState() => _AnimatedGlassContainerState();
}

class _AnimatedGlassContainerState extends State<AnimatedGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: widget.opacity,
      end: (widget.opacity + 0.1).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return GlassContainer(
          blur: widget.blur,
          opacity: _opacityAnimation.value,
          borderRadius: widget.borderRadius,
          borderColor: widget.borderColor,
          padding: widget.padding,
          margin: widget.margin,
          backgroundColor: widget.backgroundColor,
          child: widget.child,
        );
      },
    );
  }
}

/// Extension methods for creating glass containers easily.
extension GlassContainerExtensions on Widget {
  Widget withGlass({
    double blur = 20.0,
    double opacity = 0.85,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return GlassContainer(
      blur: blur,
      opacity: opacity,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: this,
    );
  }

  Widget withGlassCard({
    double blur = 15.0,
    double opacity = 0.75,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    int elevation = 2,
  }) {
    return GlassCard(
      blur: blur,
      opacity: opacity,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      onTap: onTap,
      elevation: elevation,
      child: this,
    );
  }
}
