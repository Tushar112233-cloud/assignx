import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'report_dialog.dart';

/// Report button for flagging inappropriate listings.
///
/// Features:
/// - Flag icon with appropriate styling
/// - Disabled state when already reported
/// - Triggers report bottom sheet on tap
class ReportButton extends StatefulWidget {
  /// The listing ID to report.
  final String listingId;

  /// Whether this listing has already been reported by the user.
  final bool isReported;

  /// Size variant (small, medium, large).
  final ReportButtonSize size;

  /// Whether to show the label text.
  final bool showLabel;

  /// Callback when report is successfully submitted.
  final VoidCallback? onReportSubmitted;

  const ReportButton({
    super.key,
    required this.listingId,
    this.isReported = false,
    this.size = ReportButtonSize.medium,
    this.showLabel = false,
    this.onReportSubmitted,
  });

  @override
  State<ReportButton> createState() => _ReportButtonState();
}

class _ReportButtonState extends State<ReportButton>
    with SingleTickerProviderStateMixin {
  late bool _isReported;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isReported = widget.isReported;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isReported) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Play animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Show report dialog
    showReportBottomSheet(
      context: context,
      listingId: widget.listingId,
      onSuccess: () {
        setState(() {
          _isReported = true;
        });
        widget.onReportSubmitted?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _getSizeConfig(widget.size);

    return Tooltip(
      message: _isReported ? 'Already reported' : 'Report this listing',
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isReported ? null : _handleTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.all(config.padding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _isReported
                    ? AppColors.warning.withAlpha(26)
                    : Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isReported ? Icons.flag : Icons.flag_outlined,
                    size: config.iconSize,
                    color: _isReported
                        ? AppColors.warning
                        : AppColors.textSecondary,
                  ),
                  if (widget.showLabel) ...[
                    const SizedBox(width: 6),
                    Text(
                      _isReported ? 'Reported' : 'Report',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: config.fontSize,
                        fontWeight: FontWeight.w500,
                        color: _isReported
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ReportButtonSizeConfig _getSizeConfig(ReportButtonSize size) {
    switch (size) {
      case ReportButtonSize.small:
        return const _ReportButtonSizeConfig(
          iconSize: 16,
          fontSize: 11,
          padding: 6,
        );
      case ReportButtonSize.medium:
        return const _ReportButtonSizeConfig(
          iconSize: 20,
          fontSize: 13,
          padding: 8,
        );
      case ReportButtonSize.large:
        return const _ReportButtonSizeConfig(
          iconSize: 24,
          fontSize: 15,
          padding: 10,
        );
    }
  }
}

/// Size variants for the report button.
enum ReportButtonSize { small, medium, large }

/// Configuration for button sizes.
class _ReportButtonSizeConfig {
  final double iconSize;
  final double fontSize;
  final double padding;

  const _ReportButtonSizeConfig({
    required this.iconSize,
    required this.fontSize,
    required this.padding,
  });
}

/// Outlined version of the report button with a border.
class ReportButtonOutline extends StatefulWidget {
  /// The listing ID to report.
  final String listingId;

  /// Whether this listing has already been reported by the user.
  final bool isReported;

  /// Callback when report is successfully submitted.
  final VoidCallback? onReportSubmitted;

  const ReportButtonOutline({
    super.key,
    required this.listingId,
    this.isReported = false,
    this.onReportSubmitted,
  });

  @override
  State<ReportButtonOutline> createState() => _ReportButtonOutlineState();
}

class _ReportButtonOutlineState extends State<ReportButtonOutline> {
  late bool _isReported;

  @override
  void initState() {
    super.initState();
    _isReported = widget.isReported;
  }

  void _handleTap() {
    if (_isReported) return;

    HapticFeedback.lightImpact();

    showReportBottomSheet(
      context: context,
      listingId: widget.listingId,
      onSuccess: () {
        setState(() {
          _isReported = true;
        });
        widget.onReportSubmitted?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _isReported
          ? AppColors.warning.withAlpha(26)
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _isReported ? null : _handleTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isReported
                  ? AppColors.warning.withAlpha(77)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isReported ? Icons.flag : Icons.flag_outlined,
                size: 18,
                color: _isReported
                    ? AppColors.warning
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                _isReported ? 'Reported' : 'Report',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _isReported
                      ? AppColors.warning
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
