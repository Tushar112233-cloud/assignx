library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'report_dialog.dart';

/// Report button for flagging inappropriate posts.
class ReportButton extends StatefulWidget {
  final String postId;
  final bool isReported;
  final ReportButtonSize size;
  final bool showLabel;
  final VoidCallback? onReportSubmitted;

  const ReportButton({
    super.key,
    required this.postId,
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
    HapticFeedback.lightImpact();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    showReportBottomSheet(
      context: context,
      postId: widget.postId,
      onSuccess: () {
        setState(() => _isReported = true);
        widget.onReportSubmitted?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _getSizeConfig(widget.size);

    return Tooltip(
      message: _isReported ? 'Already reported' : 'Report this post',
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
                      style: AppTypography.labelMedium.copyWith(
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
            iconSize: 16, fontSize: 11, padding: 6);
      case ReportButtonSize.medium:
        return const _ReportButtonSizeConfig(
            iconSize: 20, fontSize: 13, padding: 8);
      case ReportButtonSize.large:
        return const _ReportButtonSizeConfig(
            iconSize: 24, fontSize: 15, padding: 10);
    }
  }
}

enum ReportButtonSize { small, medium, large }

class _ReportButtonSizeConfig {
  final double iconSize;
  final double fontSize;
  final double padding;
  const _ReportButtonSizeConfig(
      {required this.iconSize, required this.fontSize, required this.padding});
}
