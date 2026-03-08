/// Subtle gradient scaffold widget with amber/orange corner orbs.
///
/// Provides a modern gradient background for all main screens using
/// soft pastel orbs that glow from screen corners. The supervisor app uses
/// an amber/orange/gold palette to match its warm professional theme.
///
/// ## Usage
/// ```dart
/// SubtleGradientScaffold.standard(
///   body: MyContent(),
///   appBar: myAppBar,
/// )
/// ```
library;

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Amber/orange gradient colors for the supervisor app orb system.
class GradientColors {
  GradientColors._();

  /// Soft amber - primary orb color.
  ///
  /// Hex: #FBBF24
  static const Color amber = Color(0xFFFBBF24);

  /// Soft orange - secondary orb color.
  ///
  /// Hex: #FB923C
  static const Color orange = Color(0xFFFB923C);

  /// Soft gold - tertiary orb color.
  ///
  /// Hex: #FDE68A
  static const Color gold = Color(0xFFFDE68A);

  /// Soft peach - accent orb color.
  ///
  /// Hex: #FED7AA
  static const Color peach = Color(0xFFFED7AA);

  /// Base background - uses AppColors.background.
  static const Color background = Color(0xFFFAFAF8);
}

/// Gradient blob position on screen.
enum BlobPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  centerRight,
  centerLeft,
  center,
}

/// A gradient orb that creates a soft glowing effect from screen corners.
///
/// Uses radial gradients with color fills that fade to transparent,
/// producing a subtle pastel glow when placed behind content.
class GradientOrb extends StatelessWidget {
  /// The position of the orb on screen.
  final BlobPosition position;

  /// The base color of the orb gradient.
  final Color color;

  /// The diameter of the orb in logical pixels.
  final double size;

  /// The peak opacity of the orb center (0.0 to 1.0).
  final double opacity;

  const GradientOrb({
    super.key,
    required this.position,
    required this.color,
    this.size = 300,
    this.opacity = 0.4,
  });

  /// Amber orb - primary supervisor brand gradient.
  factory GradientOrb.amber({
    BlobPosition position = BlobPosition.topRight,
    double opacity = 0.15,
    double size = 350,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.amber,
      opacity: opacity,
      size: size,
    );
  }

  /// Orange orb - warm accent gradient.
  factory GradientOrb.orange({
    BlobPosition position = BlobPosition.bottomLeft,
    double opacity = 0.15,
    double size = 320,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.orange,
      opacity: opacity,
      size: size,
    );
  }

  /// Gold orb - soft warm accent.
  factory GradientOrb.gold({
    BlobPosition position = BlobPosition.topLeft,
    double opacity = 0.12,
    double size = 280,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.gold,
      opacity: opacity,
      size: size,
    );
  }

  /// Peach orb - gentle warm accent.
  factory GradientOrb.peach({
    BlobPosition position = BlobPosition.bottomRight,
    double opacity = 0.12,
    double size = 280,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.peach,
      opacity: opacity,
      size: size,
    );
  }

  Alignment get _alignment {
    switch (position) {
      case BlobPosition.topLeft:
        return const Alignment(-0.9, -0.9);
      case BlobPosition.topRight:
        return const Alignment(0.9, -0.8);
      case BlobPosition.bottomLeft:
        return const Alignment(-0.9, 0.9);
      case BlobPosition.bottomRight:
        return const Alignment(0.9, 0.9);
      case BlobPosition.centerRight:
        return const Alignment(1.0, 0.3);
      case BlobPosition.centerLeft:
        return const Alignment(-1.0, 0.0);
      case BlobPosition.center:
        return Alignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: _alignment,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: opacity),
                  color.withValues(alpha: opacity * 0.5),
                  color.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern gradient background with multiple amber/orange orbs.
///
/// Provides preset orb patterns and supports custom configurations.
class ModernGradientBackground extends StatelessWidget {
  /// Custom orbs to display. Falls back to [defaultOrbs] if null.
  final List<GradientOrb>? customOrbs;

  /// Whether to apply a blur filter for smoother orb blending.
  final bool useBlur;

  const ModernGradientBackground({
    super.key,
    this.customOrbs,
    this.useBlur = true,
  });

  /// Default amber/orange/gold orb pattern for the supervisor app.
  static List<GradientOrb> get defaultOrbs => [
        // Amber orb at top-right
        GradientOrb.amber(
          position: BlobPosition.topRight,
          opacity: 0.15,
          size: 400,
        ),
        // Orange orb at bottom-left
        GradientOrb.orange(
          position: BlobPosition.bottomLeft,
          opacity: 0.15,
          size: 350,
        ),
        // Gold orb at top-left
        GradientOrb.gold(
          position: BlobPosition.topLeft,
          opacity: 0.12,
          size: 300,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final orbs = customOrbs ?? defaultOrbs;

    Widget content = Stack(children: orbs);

    if (useBlur) {
      content = Stack(
        children: [
          ...orbs,
          // Apply blur for smooth blending
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      );
    }

    return content;
  }
}

/// A scaffold with amber/orange gradient background orbs.
///
/// Wraps all main screens with a subtle gradient background using soft
/// pastel orbs that glow from screen corners. Individual tab screens
/// do not need their own gradient background when wrapped by this.
///
/// ## Usage
/// ```dart
/// // Standard amber/orange preset (recommended for AppShell)
/// SubtleGradientScaffold.standard(
///   body: myContent,
/// )
///
/// // Custom orb configuration
/// SubtleGradientScaffold(
///   body: myContent,
///   orbs: [
///     GradientOrb.amber(position: BlobPosition.topRight),
///     GradientOrb.peach(position: BlobPosition.bottomLeft),
///   ],
/// )
/// ```
class SubtleGradientScaffold extends StatelessWidget {
  /// The primary content of the scaffold.
  final Widget body;

  /// Optional app bar widget.
  final PreferredSizeWidget? appBar;

  /// Optional bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Position of the floating action button.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Whether body extends behind the bottom navigation bar.
  final bool extendBody;

  /// Whether body extends behind the app bar.
  final bool extendBodyBehindAppBar;

  /// Override background color. Defaults to [AppColors.background].
  final Color? backgroundColor;

  /// Custom gradient orbs. Falls back to [ModernGradientBackground.defaultOrbs].
  final List<GradientOrb>? orbs;

  /// Whether to show gradient orbs. Set false to disable gradients.
  final bool showGradients;

  const SubtleGradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = true,
    this.extendBodyBehindAppBar = true,
    this.backgroundColor,
    this.orbs,
    this.showGradients = true,
  });

  /// Standard preset with amber, orange, and gold orbs.
  ///
  /// This is the recommended factory for the AppShell wrapper.
  factory SubtleGradientScaffold.standard({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
  }) {
    return SubtleGradientScaffold(
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      orbs: ModernGradientBackground.defaultOrbs,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientOrbs = orbs ?? ModernGradientBackground.defaultOrbs;

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Gradient orbs with blur for smooth blending
          if (showGradients) ...[
            ...gradientOrbs,
            // Blur layer for smooth blending
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],

          // Actual content
          Positioned.fill(
            child: body,
          ),
        ],
      ),
    );
  }
}
