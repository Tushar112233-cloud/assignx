import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/project_provider.dart';

/// Modern timeline screen with glass morphism and animations.
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: projectAsync.when(
          data: (project) {
            if (project == null) {
              return Center(
                child: Text(
                  'Project not found',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              );
            }

            return timelineAsync.when(
              data: (timeline) => _buildTimeline(context, project, timeline),
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (e, _) => Center(
            child: Text(
              'Error: $e',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ),
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
        // Modern App Bar
        _buildSliverAppBar(),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Project header
              _buildAnimatedCard(
                delay: 0,
                child: _ProjectHeader(project: project),
              ),

              const SizedBox(height: 32),

              // Timeline
              ...displayEvents.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                final isLast = index == displayEvents.length - 1;

                return _buildAnimatedCard(
                  delay: (index + 1) * 100,
                  child: _TimelineNode(
                    event: event,
                    isLast: isLast,
                    isCurrent: !event.isCompleted &&
                        (index == 0 || displayEvents[index - 1].isCompleted),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Expected completion
              if (project.status != ProjectStatus.completed &&
                  project.status != ProjectStatus.cancelled)
                _buildAnimatedCard(
                  delay: (displayEvents.length + 1) * 100,
                  child: _ExpectedCompletion(deadline: project.deadline),
                ),

              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  /// Build modern sliver app bar.
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
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

  /// Build animated card with staggered animation.
  Widget _buildAnimatedCard({
    required int delay,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
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

/// Modern project header with glass morphism.
class _ProjectHeader extends StatelessWidget {
  final Project project;

  const _ProjectHeader({required this.project});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Service type icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.accent.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  project.serviceType.icon,
                  color: Colors.white,
                  size: 30,
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
                        color: Colors.white,
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
                            color: Colors.white.withValues(alpha: 0.6),
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
                            color: project.status.color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: project.status.color.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            project.status.displayName,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

/// Modern timeline node with glass morphism.
class _TimelineNode extends StatelessWidget {
  final ProjectTimelineEvent event;
  final bool isLast;
  final bool isCurrent;

  const _TimelineNode({
    required this.event,
    required this.isLast,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final color = event.isCompleted
        ? AppColors.success
        : isCurrent
            ? AppColors.primary
            : Colors.white.withValues(alpha: 0.3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and dot
        SizedBox(
          width: 50,
          child: Column(
            children: [
              // Animated dot
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: isCurrent ? value : 1.0,
                    child: child,
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: event.isCompleted || isCurrent
                        ? LinearGradient(
                            colors: [
                              color,
                              color.withValues(alpha: 0.7),
                            ],
                          )
                        : null,
                    color: event.isCompleted || isCurrent
                        ? null
                        : Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: 2.5,
                    ),
                    boxShadow: event.isCompleted || isCurrent
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: event.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.white,
                        )
                      : isCurrent
                          ? Container(
                              margin: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                ),
              ),

              // Animated line
              if (!isLast)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Container(
                      width: 3,
                      height: 80 * value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: event.isCompleted
                              ? [
                                  AppColors.success.withValues(alpha: 0.8),
                                  AppColors.success.withValues(alpha: 0.3),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Content with glass morphism
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 48),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.milestoneTitle,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.5),
                                    AppColors.accent.withValues(alpha: 0.5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'CURRENT',
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (event.description != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          event.description!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, y \u2022 h:mm a')
                                .format(event.createdAt),
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Expected completion card with glass morphism.
class _ExpectedCompletion extends StatelessWidget {
  final DateTime deadline;

  const _ExpectedCompletion({required this.deadline});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.accent.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.4),
                      AppColors.accent.withValues(alpha: 0.4),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_available,
                  color: Colors.white,
                  size: 28,
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMM d, y').format(deadline),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
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
