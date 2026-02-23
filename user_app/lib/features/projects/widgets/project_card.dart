import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../shared/animations/common_animations.dart';
import '../../../shared/decorations/app_gradients.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import 'deadline_badge.dart';
import 'progress_indicator.dart';
import 'status_badge.dart';

/// Full project card for list display.
///
/// Uses the new UI polish system with:
/// - AppShadows for elevation and hover effects (cardHover)
/// - Earthy color palette from AppColors
/// - TapScaleContainer for press animations
/// - Staggered animations for list entrance
class ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback? onPayNow;
  final VoidCallback? onApprove;
  final VoidCallback? onRequestChanges;

  const ProjectCard({
    super.key,
    required this.project,
    this.onPayNow,
    this.onApprove,
    this.onRequestChanges,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Project: ${widget.project.title}, Status: ${widget.project.status.displayName}, '
          'Type: ${widget.project.serviceType.displayName}, Deadline: ${_getDeadlineDescription()}',
      hint: 'Double tap to view project details',
      child: TapScaleContainer(
        onTap: () => context.push('/projects/${widget.project.id}'),
        pressedScale: 0.98,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.borderRadiusLg,
              border: Border.all(
                color: widget.project.canApprove
                    ? widget.project.status.color.withAlpha(100)
                    : (_isHovered
                        ? AppColors.primary.withAlpha(50)
                        : AppColors.border),
                width: widget.project.canApprove ? 2 : (_isHovered ? 1.5 : 1),
              ),
              boxShadow: _isHovered ? AppShadows.cardHover : AppShadows.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context),

                const Divider(height: 1, color: AppColors.divider),

                // Body
                _buildBody(context),

                // Footer
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get accessible deadline description.
  String _getDeadlineDescription() {
    final now = DateTime.now();
    final difference = widget.project.deadline.difference(now);
    if (widget.project.deadline.isBefore(now)) {
      return 'Deadline passed';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours left';
    } else {
      return '${difference.inDays} days left';
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Service type icon with earthy colors
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withAlpha(_isHovered ? 40 : 25),
                  AppColors.accent.withAlpha(_isHovered ? 25 : 13),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: _isHovered ? AppShadows.xs : null,
            ),
            child: Icon(
              widget.project.serviceType.icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title and type
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.project.serviceType.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          StatusBadge(status: widget.project.status, compact: true),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project ID and Deadline row
          Row(
            children: [
              // Project ID
              Row(
                children: [
                  Icon(
                    Icons.tag,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.project.displayId,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Deadline
              DeadlineBadge(deadline: widget.project.deadline, compact: true),
            ],
          ),

          // Progress bar (only for In Progress)
          if (widget.project.status == ProjectStatus.inProgress) ...[
            const SizedBox(height: 16),
            ProjectProgressIndicator(
              percent: widget.project.progressPercentage,
              showLabel: true,
            ),
          ],

          // Payment amount (for Payment Pending)
          if (widget.project.status == ProjectStatus.paymentPending &&
              widget.project.userQuote != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning.withAlpha(20),
                    AppColors.warning.withAlpha(10),
                  ],
                ),
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(
                  color: AppColors.warning.withAlpha(40),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.currency_rupee,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  Text(
                    '${widget.project.userQuote!.toStringAsFixed(0)} due',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Auto-approval countdown (for Delivered)
          if (widget.project.status == ProjectStatus.delivered &&
              widget.project.autoApproveAt != null) ...[
            const SizedBox(height: 12),
            _AutoApprovalCountdown(deadline: widget.project.autoApproveAt!),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isHovered
            ? AppColors.surfaceVariant.withAlpha(80)
            : AppColors.surfaceVariant.withAlpha(50),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Row(
        children: [
          // Status description
          Expanded(
            child: Text(
              _getStatusDescription(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Action button
          _buildActionButton(context),
        ],
      ),
    );
  }

  String _getStatusDescription() {
    switch (widget.project.status) {
      case ProjectStatus.draft:
        return 'Draft - continue editing';
      case ProjectStatus.submitted:
        return 'Submitted for review';
      case ProjectStatus.analyzing:
        return 'Analyzing Requirements...';
      case ProjectStatus.quoted:
        return 'Quote ready for review';
      case ProjectStatus.paymentPending:
        return 'Quote ready - Pay to proceed';
      case ProjectStatus.paid:
        return 'Payment received';
      case ProjectStatus.assigning:
        return 'Finding an expert...';
      case ProjectStatus.assigned:
        return 'Expert assigned';
      case ProjectStatus.inProgress:
        return widget.project.progressPercentage > 0
            ? '${widget.project.progressPercentage}% Completed'
            : 'Expert is working on it';
      case ProjectStatus.submittedForQc:
        return 'Submitted for quality check';
      case ProjectStatus.qcInProgress:
        return 'Quality check in progress';
      case ProjectStatus.qcApproved:
        return 'Quality check passed';
      case ProjectStatus.qcRejected:
        return 'Quality check failed';
      case ProjectStatus.delivered:
        return 'Review and approve delivery';
      case ProjectStatus.revisionRequested:
        return 'Changes requested';
      case ProjectStatus.inRevision:
        return 'Making requested changes';
      case ProjectStatus.completed:
        return 'Delivered successfully';
      case ProjectStatus.autoApproved:
        return 'Auto-approved';
      case ProjectStatus.cancelled:
        return 'Project cancelled';
      case ProjectStatus.refunded:
        return 'Payment refunded';
    }
  }

  Widget _buildActionButton(BuildContext context) {
    switch (widget.project.status) {
      case ProjectStatus.quoted:
      case ProjectStatus.paymentPending:
        return _ActionButton(
          label: 'Pay Now',
          icon: Icons.payment,
          color: AppColors.warning,
          gradient: AppGradients.warning,
          onTap: widget.onPayNow ?? () => context.push('/projects/${widget.project.id}/pay'),
        );

      case ProjectStatus.delivered:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionButton(
              label: 'Changes',
              icon: Icons.edit_note,
              color: AppColors.textSecondary,
              outlined: true,
              compact: true,
              onTap: widget.onRequestChanges,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: 'Approve',
              icon: Icons.check,
              color: AppColors.success,
              gradient: AppGradients.success,
              compact: true,
              onTap: widget.onApprove,
            ),
          ],
        );

      case ProjectStatus.completed:
      case ProjectStatus.autoApproved:
        return _ActionButton(
          label: 'View',
          icon: Icons.visibility,
          color: AppColors.primary,
          outlined: true,
          onTap: () => context.push('/projects/${widget.project.id}'),
        );

      default:
        return _ActionButton(
          label: 'View',
          icon: Icons.arrow_forward,
          color: AppColors.primary,
          outlined: true,
          onTap: () => context.push('/projects/${widget.project.id}'),
        );
    }
  }
}

/// Action button with press animation and optional gradient.
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Gradient? gradient;
  final bool outlined;
  final bool compact;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.gradient,
    this.outlined = false,
    this.compact = false,
    this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      hint: 'Double tap to ${widget.label}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.diagonal3Values(_isPressed ? 0.95 : 1.0, _isPressed ? 0.95 : 1.0, 1.0),
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 10 : 14,
              vertical: widget.compact ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: widget.outlined ? Colors.transparent : null,
              gradient: widget.outlined ? null : (widget.gradient ?? LinearGradient(colors: [widget.color, widget.color])),
              borderRadius: BorderRadius.circular(8),
              border: widget.outlined ? Border.all(color: widget.color) : null,
              boxShadow: widget.outlined ? null : AppShadows.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: widget.compact ? 14 : 16,
                  color: widget.outlined ? widget.color : Colors.white,
                ),
                SizedBox(width: widget.compact ? 4 : 6),
                Text(
                  widget.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: widget.compact ? 11 : 12,
                    fontWeight: FontWeight.w600,
                    color: widget.outlined ? widget.color : Colors.white,
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

/// Auto-approval countdown with animated styling.
class _AutoApprovalCountdown extends StatefulWidget {
  final DateTime deadline;

  const _AutoApprovalCountdown({required this.deadline});

  @override
  State<_AutoApprovalCountdown> createState() => _AutoApprovalCountdownState();
}

class _AutoApprovalCountdownState extends State<_AutoApprovalCountdown> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.deadline.difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    // Cancel any existing timer before creating new one
    _timer?.cancel();

    // Don't start timer if already expired
    if (_remaining.isNegative) return;

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      setState(() {
        _remaining = widget.deadline.difference(DateTime.now());
      });
      // Stop the timer if deadline has passed
      if (_remaining.isNegative) {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return const SizedBox.shrink();
    }

    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(20),
            AppColors.accent.withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.primary.withAlpha(30),
        ),
        boxShadow: AppShadows.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'Auto-approves in ${hours}h ${minutes}m',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for project cards.
class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          // Header skeleton
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const SkeletonLoader(width: 40, height: 40, borderRadius: 10),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLoader(height: 16, width: 150),
                      SizedBox(height: 6),
                      SkeletonLoader(height: 12, width: 100),
                    ],
                  ),
                ),
                const SkeletonLoader(width: 70, height: 24, borderRadius: 12),
              ],
            ),
          ),
          const Divider(height: 1),
          // Body skeleton
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: const [
                    SkeletonLoader(width: 80, height: 14),
                    SizedBox(width: 16),
                    SkeletonLoader(width: 100, height: 14),
                  ],
                ),
              ],
            ),
          ),
          // Footer skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withAlpha(50),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonLoader(width: 140, height: 14),
                SkeletonLoader(width: 70, height: 32, borderRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
