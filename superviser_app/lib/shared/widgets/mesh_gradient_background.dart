library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Enum representing the position of the mesh gradient focal point.
enum MeshPosition {
  topRight,
  bottomRight,
  center,
  topLeft,
  bottomLeft,
}

/// Pastel mesh gradient colors for creating organic, flowing background effects.
class MeshColors {
  MeshColors._();

  static const Color meshPink = Color(0xFFFFE4E6);
  static const Color meshPeach = Color(0xFFFFEDD5);
  static const Color meshOrange = Color(0xFFFED7AA);
  static const Color meshYellow = Color(0xFFFEF08A);
  static const Color meshGreen = Color(0xFFBBF7D0);
  static const Color meshBlue = Color(0xFFBAE6FD);
  static const Color meshPurple = Color(0xFFE9D5FF);

  static const List<Color> defaultColors = [meshPink, meshPeach, meshOrange];
  static const List<Color> coolColors = [meshBlue, meshGreen, meshPurple];
  static const List<Color> warmColors = [meshOrange, meshYellow, meshPeach];
  static const List<Color> sunsetColors = [meshPink, meshOrange, meshYellow];

  static const Color modernPink = Color(0xFFFFB6C1);
  static const Color modernMagenta = Color(0xFFE991CF);
  static const Color modernPurple = Color(0xFFC471ED);
  static const Color modernBlue = Color(0xFF8EC5FC);
  static const Color modernCyan = Color(0xFF00D4FF);

  static const List<Color> modernColors = [
    modernPink,
    modernMagenta,
    modernPurple,
    modernBlue,
  ];

  static const List<Color> subtleModernColors = [
    Color(0xFFFFF5F7),
    Color(0xFFFAF5FF),
    Color(0xFFF5FAFF),
  ];
}

/// A widget that creates an organic, flowing mesh gradient background effect.
///
/// Uses Container-based gradients instead of Positioned widgets to avoid
/// ParentDataWidget issues when used inside non-Stack parents.
class MeshGradientBackground extends StatelessWidget {
  final Widget child;
  final MeshPosition position;
  final List<Color>? colors;
  final double opacity;
  final bool animated;
  final Duration animationDuration;

  const MeshGradientBackground({
    super.key,
    required this.child,
    this.position = MeshPosition.bottomRight,
    this.colors,
    this.opacity = 0.6,
    this.animated = false,
    this.animationDuration = const Duration(seconds: 20),
  }) : assert(opacity >= 0.0 && opacity <= 1.0,
            'Opacity must be between 0.0 and 1.0');

  Alignment _getCenter() {
    switch (position) {
      case MeshPosition.topRight:
        return const Alignment(1.0, -1.0);
      case MeshPosition.bottomRight:
        return const Alignment(1.0, 1.0);
      case MeshPosition.center:
        return Alignment.center;
      case MeshPosition.topLeft:
        return const Alignment(-1.0, -1.0);
      case MeshPosition.bottomLeft:
        return const Alignment(-1.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColors = colors ?? MeshColors.defaultColors;
    final center = _getCenter();

    // Create a simple layered gradient using BoxDecoration
    // instead of Positioned widgets to avoid ParentDataWidget issues
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: center,
          radius: 1.5,
          colors: [
            effectiveColors[0].withValues(alpha: opacity * 0.5),
            effectiveColors.length > 1
                ? effectiveColors[1].withValues(alpha: opacity * 0.25)
                : effectiveColors[0].withValues(alpha: opacity * 0.25),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(
              -center.x * 0.5,
              -center.y * 0.5,
            ),
            radius: 1.2,
            colors: [
              effectiveColors.length > 1
                  ? effectiveColors[1].withValues(alpha: opacity * 0.3)
                  : effectiveColors[0].withValues(alpha: opacity * 0.3),
              Colors.transparent,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Preset mesh gradient background configurations for common use cases.
class MeshGradientBackgroundPresets {
  MeshGradientBackgroundPresets._();

  static MeshGradientBackground sunset({
    required Widget child,
    double opacity = 0.6,
    bool animated = false,
  }) {
    return MeshGradientBackground(
      position: MeshPosition.bottomRight,
      colors: MeshColors.sunsetColors,
      opacity: opacity,
      child: child,
    );
  }

  static MeshGradientBackground ocean({
    required Widget child,
    double opacity = 0.6,
    bool animated = false,
  }) {
    return MeshGradientBackground(
      position: MeshPosition.topRight,
      colors: MeshColors.coolColors,
      opacity: opacity,
      child: child,
    );
  }

  static MeshGradientBackground peach({
    required Widget child,
    double opacity = 0.5,
    bool animated = false,
  }) {
    return MeshGradientBackground(
      position: MeshPosition.center,
      colors: MeshColors.warmColors,
      opacity: opacity,
      child: child,
    );
  }

  static MeshGradientBackground subtle({
    required Widget child,
    bool animated = false,
  }) {
    return MeshGradientBackground(
      position: MeshPosition.bottomRight,
      colors: MeshColors.defaultColors,
      opacity: 0.4,
      child: child,
    );
  }

  static MeshGradientBackground vibrant({
    required Widget child,
    List<Color>? colors,
  }) {
    return MeshGradientBackground(
      position: MeshPosition.center,
      colors: colors ?? MeshColors.defaultColors,
      opacity: 0.7,
      child: child,
    );
  }

  static MeshGradientBackground modern({
    required Widget child,
    double opacity = 0.8,
    bool animated = false,
    MeshPosition position = MeshPosition.topRight,
  }) {
    return MeshGradientBackground(
      position: position,
      colors: MeshColors.modernColors,
      opacity: opacity,
      child: child,
    );
  }

  static MeshGradientBackground subtleModern({
    required Widget child,
    double opacity = 0.7,
    MeshPosition position = MeshPosition.topRight,
  }) {
    return MeshGradientBackground(
      position: position,
      colors: MeshColors.subtleModernColors,
      opacity: opacity,
      child: child,
    );
  }
}
