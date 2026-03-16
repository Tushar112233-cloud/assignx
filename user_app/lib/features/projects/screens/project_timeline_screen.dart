import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/project_provider.dart';

/// Timeline theme colors matching Coffee Bean Design System.
class _TimelineColors {
  static const scaffoldBg = Color(0xFFFEFDFB);
  static const headerStart = Color(0xFF3D3228);
  static const headerMiddle = Color(0xFF54442B);
  static const headerEnd = Color(0xFF765341);
  static const warmAccent = Color(0xFF765341);
  static const lightAccent = Color(0xFF9D7B65);
  static const completedGreen = Color(0xFF259369);
  static const mutedLine = Color(0xFFDDD7CD);
  static const futureDot = Color(0xFFBFB5A8);
  static const primaryText = Color(0xFF14110F);
  static const secondaryText = Color(0xFF6B5D4D);
  static const mutedText = Color(0xFF8F826F);
  static const borderColor = Color(0xFFDDD7CD);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [headerStart, headerMiddle, headerEnd],
  );
}

/// Modern timeline screen with Coffee Bean glassmorphic theme.
class ProjectTimelineScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectTimelineScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectTimelineScreen> createState() =>
      _ProjectTimelineScreenState();
}

class _ProjectTimelineScreenState extends ConsumerState<ProjectTimelineScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectProvider(widget.projectId));
    final timelineAsync = ref.watch(projectTimelineProvider(widget.projectId));

    return Scaffold(
      backgroundColor: _TimelineColors.scaffoldBg,
      extendBodyBehindAppBar: true,
      body: projectAsync.when(
        data: (project) {
          if (project == null) {
            return Center(
              child: Text(
                'Project not found',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _TimelineColors.secondaryText,
                ),
              ),
            );
          }

          return timelineAsync.when(
            data: (timeline) => _buildTimeline(context, project, timeline),
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: _TimelineColors.warmAccent,
              ),
            ),
            error: (e, stack) {
              debugPrint('Timeline error: $e\n$stack');
              return Center(
                child: Text(
                  'Error: $e',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _TimelineColors.secondaryText,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: _TimelineColors.warmAccent,
          ),
        ),
        error: (e, stack) {
          debugPrint('Project error for timeline: $e\n$stack');
          return Center(
            child: Text(
              'Error: $e',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _TimelineColors.secondaryText,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    Project project,
    List<ProjectTimelineEvent> events,
  ) {
    final displayEvents = events.isEmpty ? _getDefaultEvents(project) : events;

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Project header card
              _buildAnimatedCard(
                delay: 0,
                child: _ProjectHeader(project: project),
              ),

              const SizedBox(height: 28),

              // Timeline section title
              _buildAnimatedCard(
                delay: 50,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _TimelineColors.warmAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Timeline',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: _TimelineColors.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Timeline nodes
              ...displayEvents.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                final isLast = index == displayEvents.length - 1;

                return _buildAnimatedCard(
                  delay: (index + 2) * 80,
                  child: _TimelineNode(
                    event: event,
                    isLast: isLast,
                    isCurrent: !event.isCompleted &&
                        (index == 0 || displayEvents[index - 1].isCompleted),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Expected completion
              if (project.status != ProjectStatus.completed &&
                  project.status != ProjectStatus.cancelled)
                _buildAnimatedCard(
                  delay: (displayEvents.length + 2) * 80,
                  child: _ExpectedCompletion(deadline: project.deadline),
                ),

              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  /// Build sliver app bar with Coffee Bean gradient.
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      backgroundColor: _TimelineColors.headerStart,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: _TimelineColors.headerGradient,
              boxShadow: [
                BoxShadow(
                  color: _TimelineColors.headerStart.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FlexibleSpaceBar(
              title: Text(
                'Project Timeline',
                style: AppTextStyles.headingSmall.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Build animated card with staggered slide-in animation.
  Widget _buildAnimatedCard({
    required int delay,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(24 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  List<ProjectTimelineEvent> _getDefaultEvents(Project project) {
    final now = DateTime.now();
    final events = <ProjectTimelineEvent>[];
    int order = 0;

    // Project Created
    events.add(ProjectTimelineEvent(
      id: '1',
      projectId: project.id,
      milestoneType: 'created',
      milestoneTitle: 'Project Created',
      description: 'Your project was submitted successfully',
      createdAt: project.createdAt,
      sequenceOrder: order++,
      isCompleted: true,
      completedAt: project.createdAt,
    ));

    // Requirements Analysis
    events.add(ProjectTimelineEvent(
      id: '2',
      projectId: project.id,
      milestoneType: 'analyzing',
      milestoneTitle: 'Requirements Analysis',
      description: 'Our team is analyzing your requirements',
      createdAt: project.createdAt.add(const Duration(hours: 1)),
      sequenceOrder: order++,
      isCompleted: project.status != ProjectStatus.analyzing &&
          project.status != ProjectStatus.submitted &&
          project.status != ProjectStatus.draft,
    ));

    // Quote Ready
    final hasQuote = project.status != ProjectStatus.draft &&
        project.status != ProjectStatus.submitted &&
        project.status != ProjectStatus.analyzing;
    if (hasQuote) {
      events.add(ProjectTimelineEvent(
        id: '3',
        projectId: project.id,
        milestoneType: 'quoted',
        milestoneTitle: 'Quote Ready',
        description: project.userQuote != null
            ? 'Quote: ${project.formattedQuote}'
            : 'Quote provided',
        createdAt: project.createdAt.add(const Duration(hours: 2)),
        sequenceOrder: order++,
        isCompleted: project.status != ProjectStatus.quoted &&
            project.status != ProjectStatus.paymentPending,
      ));
    }

    // Payment Received
    if (project.isPaid) {
      events.add(ProjectTimelineEvent(
        id: '4',
        projectId: project.id,
        milestoneType: 'paid',
        milestoneTitle: 'Payment Received',
        description: 'Thank you for your payment',
        createdAt:
            project.paidAt ?? project.createdAt.add(const Duration(hours: 3)),
        sequenceOrder: order++,
        isCompleted: true,
        completedAt: project.paidAt,
      ));
    }

    // Expert Assigned
    if (project.doerId != null) {
      events.add(ProjectTimelineEvent(
        id: '5',
        projectId: project.id,
        milestoneType: 'assigned',
        milestoneTitle: 'Expert Assigned',
        description: 'A specialist has been assigned to your project',
        createdAt: project.doerAssignedAt ??
            project.createdAt.add(const Duration(hours: 4)),
        sequenceOrder: order++,
        isCompleted: true,
        completedAt: project.doerAssignedAt,
      ));
    }

    // Work in Progress
    if (project.status == ProjectStatus.inProgress ||
        project.status == ProjectStatus.submittedForQc ||
        project.status == ProjectStatus.qcInProgress) {
      events.add(ProjectTimelineEvent(
        id: '6',
        projectId: project.id,
        milestoneType: 'in_progress',
        milestoneTitle: 'Work in Progress',
        description: '${project.progressPercentage}% completed',
        createdAt: now,
        sequenceOrder: order++,
        isCompleted: false,
      ));
    }

    // Delivery
    if (project.status == ProjectStatus.delivered ||
        project.status == ProjectStatus.completed ||
        project.status == ProjectStatus.autoApproved) {
      events.add(ProjectTimelineEvent(
        id: '7',
        projectId: project.id,
        milestoneType: 'delivered',
        milestoneTitle: 'Delivery Uploaded',
        description: 'Files are ready for your review',
        createdAt: project.deliveredAt ?? project.updatedAt ?? now,
        sequenceOrder: order++,
        isCompleted: project.status == ProjectStatus.completed ||
            project.status == ProjectStatus.autoApproved,
        completedAt: project.deliveredAt,
      ));
    }

    // Completed
    if (project.status == ProjectStatus.completed ||
        project.status == ProjectStatus.autoApproved) {
      events.add(ProjectTimelineEvent(
        id: '8',
        projectId: project.id,
        milestoneType: 'completed',
        milestoneTitle: project.status == ProjectStatus.autoApproved
            ? 'Auto-Approved'
            : 'Project Completed',
        description: 'Successfully delivered',
        createdAt: project.completedAt ?? project.updatedAt ?? now,
        sequenceOrder: order++,
        isCompleted: true,
        completedAt: project.completedAt,
      ));
    }

    return events;
  }
}

/// Project header card with glassmorphic style.
class _ProjectHeader extends StatelessWidget {
  final Project project;

  const _ProjectHeader({required this.project});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Service type icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _TimelineColors.warmAccent.withValues(alpha: 0.15),
                      _TimelineColors.lightAccent.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _TimelineColors.warmAccent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  project.serviceType.icon,
                  color: _TimelineColors.warmAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Project info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: _TimelineColors.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          project.displayId,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _TimelineColors.mutedText,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: project.status.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: project.status.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            project.status.displayName,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: project.status.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Timeline node with Coffee Bean theme.
class _TimelineNode extends StatelessWidget {
  final ProjectTimelineEvent event;
  final bool isLast;
  final bool isCurrent;

  const _TimelineNode({
    required this.event,
    required this.isLast,
    required this.isCurrent,
  });

  /// Get the icon for this milestone type.
  IconData _getMilestoneIcon() {
    switch (event.milestoneType) {
      case 'created':
        return Icons.add_circle_outline;
      case 'analyzing':
        return Icons.search;
      case 'quoted':
        return Icons.request_quote_outlined;
      case 'paid':
        return Icons.payment;
      case 'assigned':
        return Icons.person_add_outlined;
      case 'in_progress':
        return Icons.engineering_outlined;
      case 'delivered':
        return Icons.cloud_upload_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Color scheme: completed = sage green, current = warm accent, future = muted
    final dotColor = event.isCompleted
        ? _TimelineColors.completedGreen
        : isCurrent
            ? _TimelineColors.warmAccent
            : _TimelineColors.futureDot;

    final lineColor = event.isCompleted
        ? _TimelineColors.completedGreen.withValues(alpha: 0.4)
        : _TimelineColors.mutedLine;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail (dot + line)
          SizedBox(
            width: 44,
            child: Column(
              children: [
                // Dot with icon
                _buildDot(dotColor),

                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            lineColor,
                            lineColor.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1.25),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Content card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: _buildContentCard(context, dotColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color dotColor) {
    if (isCurrent) {
      // Pulsing current dot
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.85, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: dotColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: dotColor,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: dotColor.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: event.isCompleted
            ? dotColor.withValues(alpha: 0.12)
            : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: event.isCompleted
              ? dotColor
              : _TimelineColors.borderColor,
          width: 2,
        ),
        boxShadow: event.isCompleted
            ? [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Icon(
        event.isCompleted ? Icons.check : _getMilestoneIcon(),
        size: 16,
        color: event.isCompleted ? dotColor : _TimelineColors.futureDot,
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCurrent
                  ? accentColor.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.4),
              width: isCurrent ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  // Milestone icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getMilestoneIcon(),
                      size: 16,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      event.milestoneTitle,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: _TimelineColors.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _TimelineColors.warmAccent,
                            _TimelineColors.lightAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _TimelineColors.warmAccent
                                .withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'CURRENT',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  if (event.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _TimelineColors.completedGreen
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: _TimelineColors.completedGreen,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Done',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _TimelineColors.completedGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Description
              if (event.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  event.description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _TimelineColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Timestamp
              Wrap(
                spacing: 5,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 13,
                    color: _TimelineColors.mutedText,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat('MMM d, y \u2022 h:mm a')
                        .format(event.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: _TimelineColors.mutedText,
                      fontSize: 11,
                    ),
                  ),
                  if (event.completedAt != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _TimelineColors.mutedText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check_circle_outline,
                      size: 13,
                      color: _TimelineColors.completedGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed ${DateFormat('MMM d').format(event.completedAt!)}',
                      style: AppTextStyles.caption.copyWith(
                        color: _TimelineColors.completedGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expected completion card with glassmorphic style.
class _ExpectedCompletion extends StatelessWidget {
  final DateTime deadline;

  const _ExpectedCompletion({required this.deadline});

  @override
  Widget build(BuildContext context) {
    final daysRemaining = deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysRemaining < 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _TimelineColors.warmAccent.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _TimelineColors.warmAccent.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _TimelineColors.warmAccent.withValues(alpha: 0.12),
                      _TimelineColors.lightAccent.withValues(alpha: 0.06),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _TimelineColors.warmAccent.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Icons.event_available,
                  color: _TimelineColors.warmAccent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expected Completion',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: _TimelineColors.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMM d, y').format(deadline),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _TimelineColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? AppColors.error.withValues(alpha: 0.1)
                            : _TimelineColors.warmAccent
                                .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOverdue
                            ? 'Overdue by ${-daysRemaining} day${daysRemaining == -1 ? '' : 's'}'
                            : daysRemaining == 0
                                ? 'Due today'
                                : '$daysRemaining day${daysRemaining == 1 ? '' : 's'} remaining',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isOverdue
                              ? AppColors.error
                              : _TimelineColors.warmAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
