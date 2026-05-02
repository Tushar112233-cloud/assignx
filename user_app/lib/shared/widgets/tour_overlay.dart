import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/tour_step.dart';
import '../../providers/tour_provider.dart';

/// Full-screen tour overlay with cutout highlighting.
///
/// Displays a semi-transparent overlay with a cutout around the target widget,
/// and a glassmorphic tooltip with step information.
///
/// Example:
/// ```dart
/// TourOverlay(
///   tourConfig: dashboardTour,
///   child: DashboardScreen(),
/// )
/// ```
class TourOverlay extends ConsumerStatefulWidget {
  /// The child widget to display behind the overlay.
  final Widget child;

  const TourOverlay({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends ConsumerState<TourOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool _dontShowAgainChecked = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tourState = ref.watch(tourProvider);
    final isActive = tourState.isActive;
    final currentStep = tourState.currentStepData;
    final activeTour = tourState.activeTour;

    // Handle animation states
    if (isActive && !_fadeController.isAnimating) {
      _fadeController.forward();
      if (currentStep?.pulseAnimation == true) {
        _pulseController.repeat(reverse: true);
      }
    } else if (!isActive && _fadeController.value > 0) {
      _fadeController.reverse();
      _pulseController.stop();
    }

    return Stack(
      children: [
        // Main content
        widget.child,

        // Tour overlay (only when active)
        if (isActive && currentStep != null && activeTour != null)
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: GestureDetector(
                  // Allow tapping anywhere to skip tour if tooltip fails
                  onTap: () => ref.read(tourProvider.notifier).skipTour(),
                  behavior: HitTestBehavior.translucent,
                  child: _buildOverlay(
                    context,
                    tourState,
                    currentStep,
                    activeTour,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildOverlay(
    BuildContext context,
    TourState tourState,
    TourStep step,
    TourConfig config,
  ) {
    final targetRect = _getTargetRect(step.targetKey);
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Dark overlay with cutout
        CustomPaint(
          size: screenSize,
          painter: _OverlayPainter(
            targetRect: targetRect,
            opacity: config.overlayOpacity,
            cutoutPadding: step.cutoutPadding ?? const EdgeInsets.all(8),
            cutoutBorderRadius: step.cutoutBorderRadius ?? 12,
            pulseScale:
                step.pulseAnimation ? _pulseAnimation.value : 1.0,
          ),
        ),

        // Cutout glow effect
        if (targetRect != null)
          Positioned(
            left: targetRect.left - 12,
            top: targetRect.top - 12,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: targetRect.width + 24,
                  height: targetRect.height + 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      (step.cutoutBorderRadius ?? 12) + 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(51),
                        blurRadius: 20 * _pulseAnimation.value,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        // Tooltip
        _buildTooltip(context, tourState, step, config, targetRect, screenSize),

        // Step indicator dots
        if (config.showStepIndicator)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: _buildStepIndicator(tourState, config),
          ),
      ],
    );
  }

  Rect? _getTargetRect(GlobalKey? key) {
    if (key == null) return null;

    try {
      final RenderBox? renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return null;

      final position = renderBox.localToGlobal(Offset.zero);
      return Rect.fromLTWH(
        position.dx,
        position.dy,
        renderBox.size.width,
        renderBox.size.height,
      );
    } catch (e) {
      return null;
    }
  }

  Widget _buildTooltip(
    BuildContext context,
    TourState tourState,
    TourStep step,
    TourConfig config,
    Rect? targetRect,
    Size screenSize,
  ) {
    // Calculate tooltip position
    final tooltipPosition = _calculateTooltipPosition(
      step.position,
      targetRect,
      screenSize,
    );

    return Positioned(
      left: tooltipPosition.left,
      top: tooltipPosition.top,
      right: tooltipPosition.right,
      bottom: tooltipPosition.bottom,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 340,
        ),
        child: _TourTooltip(
        step: step,
        currentStepIndex: tourState.currentStep,
        totalSteps: config.totalSteps,
        showDontShowAgain: config.showDontShowAgain,
        allowSkip: config.allowSkip,
        dontShowAgainChecked: _dontShowAgainChecked,
        onDontShowAgainChanged: (value) {
          setState(() => _dontShowAgainChecked = value);
        },
        onNext: () {
          final notifier = ref.read(tourProvider.notifier);
          if (tourState.hasNextStep) {
            notifier.nextStep();
          } else {
            if (_dontShowAgainChecked) {
              notifier.setDontShowAgain(true);
            }
            notifier.completeTour();
          }
        },
        onSkip: () {
          final notifier = ref.read(tourProvider.notifier);
          if (_dontShowAgainChecked) {
            notifier.setDontShowAgain(true);
          }
          notifier.skipTour();
        },
        onPrevious: tourState.hasPreviousStep
            ? () => ref.read(tourProvider.notifier).previousStep()
            : null,
      ),
      ),
    );
  }

  _TooltipPosition _calculateTooltipPosition(
    TourPosition position,
    Rect? targetRect,
    Size screenSize,
  ) {
    const double margin = 20;
    const double tooltipWidth = 300;
    const double tooltipHeight = 200;

    // Default centered position for welcome screens
    if (targetRect == null || position == TourPosition.center) {
      return _TooltipPosition(
        left: (screenSize.width - tooltipWidth) / 2,
        top: (screenSize.height - tooltipHeight) / 2,
        right: null,
        bottom: null,
      );
    }

    double? left, top, right, bottom;

    switch (position) {
      case TourPosition.above:
        left = margin;
        right = margin;
        bottom = screenSize.height - targetRect.top + margin;
        break;

      case TourPosition.below:
        left = margin;
        right = margin;
        top = targetRect.bottom + margin;
        break;

      case TourPosition.left:
        left = margin;
        right = screenSize.width - targetRect.left + margin;
        top = targetRect.top;
        break;

      case TourPosition.right:
        left = targetRect.right + margin;
        right = margin;
        top = targetRect.top;
        break;

      case TourPosition.center:
        left = margin;
        right = margin;
        top = (screenSize.height - tooltipHeight) / 2;
        break;
    }

    // Ensure tooltip stays within screen bounds
    if (top != null && top < margin) top = margin;
    if (bottom != null && bottom < margin) bottom = margin;
    if (top != null && top > screenSize.height - tooltipHeight - margin) {
      top = screenSize.height - tooltipHeight - margin;
    }

    return _TooltipPosition(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  Widget _buildStepIndicator(TourState tourState, TourConfig config) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(config.totalSteps, (index) {
        final isActive = index == tourState.currentStep;
        final isCompleted = index < tourState.currentStep;

        return GestureDetector(
          onTap: () => ref.read(tourProvider.notifier).goToStep(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? AppColors.primary
                  : isCompleted
                      ? AppColors.primary.withAlpha(128)
                      : Colors.white.withAlpha(128),
            ),
          ),
        );
      }),
    );
  }
}

/// Position data for tooltip placement.
class _TooltipPosition {
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  _TooltipPosition({this.left, this.top, this.right, this.bottom});
}

/// Custom painter for the overlay with cutout.
class _OverlayPainter extends CustomPainter {
  final Rect? targetRect;
  final double opacity;
  final EdgeInsets cutoutPadding;
  final double cutoutBorderRadius;
  final double pulseScale;

  _OverlayPainter({
    this.targetRect,
    required this.opacity,
    required this.cutoutPadding,
    required this.cutoutBorderRadius,
    this.pulseScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha((opacity * 255).round());

    // Full screen path
    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (targetRect != null) {
      // Calculate padded rect with pulse scale
      final paddedRect = Rect.fromLTRB(
        targetRect!.left - cutoutPadding.left * pulseScale,
        targetRect!.top - cutoutPadding.top * pulseScale,
        targetRect!.right + cutoutPadding.right * pulseScale,
        targetRect!.bottom + cutoutPadding.bottom * pulseScale,
      );

      // Cutout path (rounded rectangle)
      final cutoutPath = Path()
        ..addRRect(RRect.fromRectAndRadius(
          paddedRect,
          Radius.circular(cutoutBorderRadius),
        ));

      // Combine paths (full screen minus cutout)
      final combinedPath = Path.combine(
        PathOperation.difference,
        fullScreenPath,
        cutoutPath,
      );

      canvas.drawPath(combinedPath, paint);
    } else {
      // No target - just draw full overlay
      canvas.drawPath(fullScreenPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.opacity != opacity ||
        oldDelegate.pulseScale != pulseScale;
  }
}

/// Glassmorphic tooltip widget.
class _TourTooltip extends StatelessWidget {
  final TourStep step;
  final int currentStepIndex;
  final int totalSteps;
  final bool showDontShowAgain;
  final bool allowSkip;
  final bool dontShowAgainChecked;
  final ValueChanged<bool> onDontShowAgainChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback? onPrevious;

  const _TourTooltip({
    required this.step,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.showDontShowAgain,
    required this.allowSkip,
    required this.dontShowAgainChecked,
    required this.onDontShowAgainChanged,
    required this.onNext,
    required this.onSkip,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(230),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAlpha(128),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and step counter
              Row(
                children: [
                  if (step.icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        step.icon,
                        size: 22,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      step.title,
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${currentStepIndex + 1}/$totalSteps',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                step.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Don't show again checkbox
              if (showDontShowAgain) ...[
                GestureDetector(
                  onTap: () => onDontShowAgainChanged(!dontShowAgainChecked),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: dontShowAgainChecked,
                          onChanged: (value) =>
                              onDontShowAgainChanged(value ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Don't show this tour again",
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action buttons
              Row(
                children: [
                  // Skip button
                  if (allowSkip && !step.isLast)
                    TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textTertiary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'Skip Tour',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  const Spacer(),

                  // Previous button
                  if (onPrevious != null) ...[
                    OutlinedButton(
                      onPressed: onPrevious,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Back',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Next/Done button
                  ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          step.isLast ? 'Get Started' : 'Next',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          step.isLast ? Icons.check : Icons.arrow_forward,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrapper widget that handles tour overlay for a specific screen.
///
/// Use this to wrap screens that should support the tour system.
class TourAwareScreen extends ConsumerWidget {
  /// The screen content.
  final Widget child;

  /// Optional callback when the tour completes.
  final VoidCallback? onTourComplete;

  const TourAwareScreen({
    super.key,
    required this.child,
    this.onTourComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<TourState>(tourProvider, (previous, next) {
      // Call completion callback when tour ends
      if (previous?.isActive == true && !next.isActive) {
        onTourComplete?.call();
      }
    });

    return TourOverlay(child: child);
  }
}
