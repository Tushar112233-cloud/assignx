/// Subtle gradient scaffold widget with teal/cyan corner orbs.
///
/// Provides a modern gradient background for all main screens using
/// soft pastel orbs that glow from screen corners. The doer app uses
/// a teal/cyan/mint palette to match its professional theme.
///
/// ## Usage
/// ```dart
/// SubtleGradientScaffold.standard(
///   body: MyContent(),
///   appBar: myAppBar,
///   bottomNavigationBar: myBottomNav,
/// )
/// ```
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Teal/cyan gradient colors for the doer app orb system.
class GradientColors {
  GradientColors._();

  /// Soft teal - primary orb color.
  ///
  /// Hex: #99F6E4
  static const Color teal = Color(0xFF99F6E4);

  /// Soft cyan - secondary orb color.
  ///
  /// Hex: #A5F3FC
  static const Color cyan = Color(0xFFA5F3FC);

  /// Soft mint green - tertiary orb color.
  ///
  /// Hex: #A7F3D0
  static const Color mint = Color(0xFFA7F3D0);

  /// Soft lavender - accent orb color.
  ///
  /// Hex: #C7D2FE
  static const Color lavender = Color(0xFFC7D2FE);

  /// Soft sky blue - cool orb accent.
  ///
  /// Hex: #BAE6FD
  static const Color sky = Color(0xFFBAE6FD);

  /// Soft emerald - warm orb accent.
  ///
  /// Hex: #6EE7B7
  static const Color emerald = Color(0xFF6EE7B7);

  /// Base background - uses AppColors.background.
  static const Color background = Color(0xFFFAFBFC);
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

  /// Teal orb - primary doer brand gradient.
  factory GradientOrb.teal({
    BlobPosition position = BlobPosition.topRight,
    double opacity = 0.20,
    double size = 350,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.teal,
      opacity: opacity,
      size: size,
    );
  }

  /// Cyan orb - cool accent gradient.
  factory GradientOrb.cyan({
    BlobPosition position = BlobPosition.bottomLeft,
    double opacity = 0.20,
    double size = 320,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.cyan,
      opacity: opacity,
      size: size,
    );
  }

  /// Mint orb - fresh green accent.
  factory GradientOrb.mint({
    BlobPosition position = BlobPosition.topLeft,
    double opacity = 0.15,
    double size = 280,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.mint,
      opacity: opacity,
      size: size,
    );
  }

  /// Lavender orb - soft purple accent.
  factory GradientOrb.lavender({
    BlobPosition position = BlobPosition.bottomRight,
    double opacity = 0.15,
    double size = 280,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.lavender,
      opacity: opacity,
      size: size,
    );
  }

  /// Sky orb - light blue accent.
  factory GradientOrb.sky({
    BlobPosition position = BlobPosition.centerRight,
    double opacity = 0.18,
    double size = 260,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.sky,
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

/// Modern gradient background with multiple teal/cyan orbs.
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

  /// Default teal/cyan/mint orb pattern for the doer app.
  static List<GradientOrb> get defaultOrbs => [
        // Teal orb at top-right
        GradientOrb.teal(
          position: BlobPosition.topRight,
          opacity: 0.20,
          size: 400,
        ),
        // Cyan orb at bottom-left
        GradientOrb.cyan(
          position: BlobPosition.bottomLeft,
          opacity: 0.20,
          size: 350,
        ),
        // Mint orb at top-left
        GradientOrb.mint(
          position: BlobPosition.topLeft,
          opacity: 0.15,
          size: 300,
        ),
      ];

  /// Cool pattern with sky and lavender tones.
  static List<GradientOrb> get coolPattern => [
        GradientOrb.sky(
          position: BlobPosition.topRight,
          opacity: 0.20,
          size: 380,
        ),
        GradientOrb.lavender(
          position: BlobPosition.bottomLeft,
          opacity: 0.18,
          size: 320,
        ),
        GradientOrb.cyan(
          position: BlobPosition.centerRight,
          opacity: 0.15,
          size: 260,
        ),
      ];

  /// Fresh pattern with mint and emerald tones.
  static List<GradientOrb> get freshPattern => [
        GradientOrb.mint(
          position: BlobPosition.topRight,
          opacity: 0.20,
          size: 400,
        ),
        GradientOrb.teal(
          position: BlobPosition.bottomRight,
          opacity: 0.18,
          size: 350,
        ),
        const GradientOrb(
          position: BlobPosition.bottomLeft,
          color: GradientColors.emerald,
          opacity: 0.15,
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
          // Apply blur for smoother blending
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

/// A scaffold with teal/cyan gradient background orbs.
///
/// Wraps all main screens with a subtle gradient background using soft
/// pastel orbs that glow from screen corners. Individual tab screens
/// do not need their own gradient background when wrapped by this.
///
/// ## Usage
/// ```dart
/// // Standard teal/cyan preset (recommended for MainShell)
/// SubtleGradientScaffold.standard(
///   body: myContent,
///   bottomNavigationBar: myBottomNav,
/// )
///
/// // Custom orb configuration
/// SubtleGradientScaffold(
///   body: myContent,
///   orbs: [
///     GradientOrb.teal(position: BlobPosition.topRight),
///     GradientOrb.lavender(position: BlobPosition.bottomLeft),
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

  /// Standard preset with teal, cyan, and mint orbs.
  ///
  /// This is the recommended factory for the MainShell wrapper.
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

  /// Cool-toned gradient preset with sky and lavender.
  factory SubtleGradientScaffold.cool({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
  }) {
    return SubtleGradientScaffold(
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      orbs: ModernGradientBackground.coolPattern,
    );
  }

  /// Fresh gradient preset with mint and emerald.
  factory SubtleGradientScaffold.fresh({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
  }) {
    return SubtleGradientScaffold(
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      orbs: ModernGradientBackground.freshPattern,
    );
  }

  /// Time-based gradient (morning/afternoon/evening).
  factory SubtleGradientScaffold.timeBased({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
  }) {
    final hour = DateTime.now().hour;
    List<GradientOrb> orbs;

    if (hour >= 5 && hour < 12) {
      // Morning: fresh mint and teal
      orbs = [
        GradientOrb.mint(
          position: BlobPosition.topRight,
          opacity: 0.20,
          size: 400,
        ),
        GradientOrb.teal(
          position: BlobPosition.bottomLeft,
          opacity: 0.18,
          size: 320,
        ),
        const GradientOrb(
          position: BlobPosition.centerRight,
          color: GradientColors.emerald,
          opacity: 0.15,
          size: 260,
        ),
      ];
    } else if (hour >= 12 && hour < 17) {
      // Afternoon: teal and cyan
      orbs = [
        GradientOrb.teal(
          position: BlobPosition.topRight,
          opacity: 0.22,
          size: 400,
        ),
        GradientOrb.cyan(
          position: BlobPosition.bottomLeft,
          opacity: 0.20,
          size: 350,
        ),
        GradientOrb.sky(
          position: BlobPosition.bottomRight,
          opacity: 0.15,
          size: 280,
        ),
      ];
    } else {
      // Evening: deeper tones with lavender
      orbs = [
        GradientOrb.lavender(
          position: BlobPosition.topRight,
          opacity: 0.22,
          size: 420,
        ),
        GradientOrb.cyan(
          position: BlobPosition.bottomLeft,
          opacity: 0.20,
          size: 350,
        ),
        GradientOrb.teal(
          position: BlobPosition.centerRight,
          opacity: 0.18,
          size: 280,
        ),
      ];
    }

    return SubtleGradientScaffold(
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      orbs: orbs,
    );
  }

  /// Minimal preset with a single teal orb.
  factory SubtleGradientScaffold.minimal({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
  }) {
    return SubtleGradientScaffold(
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      orbs: [
        GradientOrb.teal(
          position: BlobPosition.bottomRight,
          opacity: 0.22,
          size: 400,
        ),
      ],
    );
  }

  /// Random gradient based on seed.
  factory SubtleGradientScaffold.random({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    int? seed,
  }) {
    final random = math.Random(seed ?? DateTime.now().millisecondsSinceEpoch);
    final positions = BlobPosition.values.toList()..shuffle(random);

    final colors = [
      GradientColors.teal,
      GradientColors.cyan,
      GradientColors.mint,
      GradientColors.lavender,
      GradientColors.sky,
      GradientColors.emerald,
    ];

    final orbs = <GradientOrb>[];
    final orbCount = 2 + random.nextInt(2);

    for (int i = 0; i < orbCount; i++) {
      orbs.add(GradientOrb(
        position: positions[i],
        color: colors[random.nextInt(colors.length)],
        opacity: 0.15 + random.nextDouble() * 0.10,
        size: 280 + random.nextDouble() * 120,
      ));
    }

    return SubtleGradientScaffold(
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      orbs: orbs,
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

/// Simple gradient background wrapper for any widget.
///
/// Unlike [SubtleGradientScaffold], this does not include a Scaffold.
/// Use this to wrap content that already lives inside a scaffold.
class SubtleGradientBackground extends StatelessWidget {
  /// The child widget to display on top of the gradient.
  final Widget child;

  /// Custom orbs. Falls back to [ModernGradientBackground.defaultOrbs].
  final List<GradientOrb>? orbs;

  /// Override background color. Defaults to [AppColors.background].
  final Color? backgroundColor;

  /// Whether to apply a blur filter for smoother blending.
  final bool useBlur;

  const SubtleGradientBackground({
    super.key,
    required this.child,
    this.orbs,
    this.backgroundColor,
    this.useBlur = true,
  });

  /// Standard teal/cyan/mint background.
  factory SubtleGradientBackground.standard({required Widget child}) {
    return SubtleGradientBackground(
      orbs: ModernGradientBackground.defaultOrbs,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientOrbs = orbs ?? ModernGradientBackground.defaultOrbs;

    return Container(
      color: backgroundColor ?? AppColors.background,
      child: Stack(
        children: [
          ...gradientOrbs,
          if (useBlur)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

// Backward compatibility aliases
typedef GradientBlob = GradientOrb;
typedef GradientPatch = GradientOrb;
typedef GradientPatchPosition = BlobPosition;
typedef OrganicGradientBlob = GradientOrb;
typedef GradientDirection = BlobPosition;
typedef SubtleGradientColors = GradientColors;
typedef RandomGradientBackground = ModernGradientBackground;

// Helper for TimeTheme compatibility
enum TimeTheme { morning, afternoon, evening }

/// Returns the current time theme based on hour of day.
TimeTheme getTimeTheme() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return TimeTheme.morning;
  if (hour >= 12 && hour < 17) return TimeTheme.afternoon;
  return TimeTheme.evening;
}
