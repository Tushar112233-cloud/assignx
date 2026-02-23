import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/project_provider.dart';
import '../../chat/widgets/floating_chat_button.dart';
import '../widgets/deadline_badge.dart';
import '../widgets/deliverables_section.dart';
import '../widgets/live_draft_section.dart';
import '../widgets/project_brief_accordion.dart';
import '../widgets/quality_badges.dart';
import '../widgets/review_actions.dart';
import '../widgets/status_banner.dart';

/// Project detail screen colors matching the Coffee Bean Design System.
class _ProjectDetailColors {
  static const scaffoldBackground = Color(0xFFFAF8F5);
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B5D4D);
  static const mutedText = Color(0xFF8F826F);
  static const warmAccent = Color(0xFF765341);
  static const lightAccent = Color(0xFF9D7B65);
  static const creamBackground = Color(0xFFF5F0E8);
  static const borderColor = Color(0xFFDDD7CD);

  /// Warm gradient for header
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3D3228),
      Color(0xFF54442B),
      Color(0xFF765341),
    ],
  );
}

/// Project detail screen with modern UI matching app theme.
class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectStreamProvider(projectId));

    return projectAsync.when(
      data: (project) {
        if (project == null) {
          return Scaffold(
            backgroundColor: _ProjectDetailColors.scaffoldBackground,
            appBar: _buildAppBar(context, null),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_off_outlined,
                    size: 64,
                    color: _ProjectDetailColors.mutedText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Project not found',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _ProjectDetailColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return _ProjectDetailContent(project: project);
      },
      loading: () => Scaffold(
        backgroundColor: _ProjectDetailColors.scaffoldBackground,
        appBar: _buildAppBar(context, null),
        body: const Center(
          child: CircularProgressIndicator(
            color: _ProjectDetailColors.warmAccent,
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: _ProjectDetailColors.scaffoldBackground,
        appBar: _buildAppBar(context, null),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading project',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _ProjectDetailColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static PreferredSizeWidget _buildAppBar(BuildContext context, Project? project) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _ProjectDetailColors.cardBackground,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            color: _ProjectDetailColors.primaryText,
            size: 20,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      title: project != null
          ? Text(
              project.displayId,
              style: AppTextStyles.labelMedium.copyWith(
                color: _ProjectDetailColors.secondaryText,
                fontFamily: 'monospace',
              ),
            )
          : null,
      centerTitle: true,
    );
  }
}

class _ProjectDetailContent extends ConsumerStatefulWidget {
  final Project project;

  const _ProjectDetailContent({required this.project});

  @override
  ConsumerState<_ProjectDetailContent> createState() =>
      _ProjectDetailContentState();
}

class _ProjectDetailContentState extends ConsumerState<_ProjectDetailContent>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
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
    final project = widget.project;

    return Scaffold(
      backgroundColor: _ProjectDetailColors.scaffoldBackground,
      body: Stack(
        children: [
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Header with project info
                _buildSliverHeader(context, project),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Status Card
                      _buildAnimatedCard(
                        delay: 100,
                        child: _buildStatusCard(project),
                      ),

                      const SizedBox(height: 16),

                      // Review Actions (if delivered)
                      if (project.status == ProjectStatus.delivered) ...[
                        _buildAnimatedCard(
                          delay: 200,
                          child: ReviewActions(
                            project: project,
                            isLoading: _isLoading,
                            onApprove: () => _handleApprove(),
                            onRequestChanges: () => _handleRequestChanges(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Payment section (if pending)
                      if (project.status == ProjectStatus.paymentPending) ...[
                        _buildAnimatedCard(
                          delay: 200,
                          child: _buildPaymentCard(project),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Live Draft Section
                      _buildAnimatedCard(
                        delay: 300,
                        child: LiveDraftSection(project: project),
                      ),

                      const SizedBox(height: 16),

                      // Project Brief
                      _buildAnimatedCard(
                        delay: 400,
                        child: ProjectBriefAccordion(project: project),
                      ),

                      const SizedBox(height: 16),

                      // Deliverables
                      _buildAnimatedCard(
                        delay: 500,
                        child: DeliverablesSection(project: project),
                      ),

                      const SizedBox(height: 16),

                      // Quality Badges
                      _buildAnimatedCard(
                        delay: 600,
                        child: QualityBadgesSection(project: project),
                      ),

                      // Actions Card
                      const SizedBox(height: 16),
                      _buildAnimatedCard(
                        delay: 700,
                        child: _buildActionsCard(context, project),
                      ),

                      // Bottom padding for FAB
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Floating Chat Button
          Positioned(
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            child: AnimatedFloatingChatButton(
              unreadCount: 0,
              onTap: () => context.push('/projects/${project.id}/chat'),
            ),
          ),
        ],
      ),
    );
  }

  /// Build sliver header with project info.
  Widget _buildSliverHeader(BuildContext context, Project project) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: _ProjectDetailColors.headerGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // App bar row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Text(
                        project.displayId,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white.withAlpha(180),
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onSelected: (value) => _handleMenuAction(value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'timeline',
                          child: Row(
                            children: [
                              Icon(Icons.timeline, size: 20),
                              SizedBox(width: 12),
                              Text('View Timeline'),
                            ],
                          ),
                        ),
                        if (_isInvoiceAvailable(project.status))
                          const PopupMenuItem(
                            value: 'invoice',
                            child: Row(
                              children: [
                                Icon(Icons.receipt_long, size: 20),
                                SizedBox(width: 12),
                                Text('Download Invoice'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'support',
                          child: Row(
                            children: [
                              Icon(Icons.support_agent, size: 20),
                              SizedBox(width: 12),
                              Text('Contact Support'),
                            ],
                          ),
                        ),
                        if (project.status != ProjectStatus.completed &&
                            project.status != ProjectStatus.cancelled)
                          PopupMenuItem(
                            value: 'cancel',
                            child: Row(
                              children: [
                                Icon(Icons.cancel_outlined,
                                    size: 20, color: AppColors.error),
                                const SizedBox(width: 12),
                                Text('Cancel Project',
                                    style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Project title and info
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            project.serviceType.icon,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            project.serviceType.displayName,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      project.title,
                      style: AppTextStyles.headingMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Subject and deadline row
                    Row(
                      children: [
                        if (project.subjectName != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _ProjectDetailColors.lightAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              project.subjectName!,
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.white.withAlpha(180),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Due: ',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withAlpha(180),
                          ),
                        ),
                        DeadlineTimer(
                          deadline: project.deadline,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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

  /// Build status card.
  Widget _buildStatusCard(Project project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ProjectDetailColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: StatusBanner(status: project.status),
    );
  }

  /// Build payment card.
  Widget _buildPaymentCard(Project project) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ProjectDetailColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withAlpha(60),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.payment,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Required',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: _ProjectDetailColors.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Complete payment to start work',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _ProjectDetailColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                project.formattedQuote,
                style: AppTextStyles.headingMedium.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _ProjectDetailColors.warmAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/projects/${project.id}/pay'),
              icon: const Icon(Icons.payment, size: 20),
              label: Text(
                'Pay Now',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _ProjectDetailColors.warmAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build actions card.
  Widget _buildActionsCard(BuildContext context, Project project) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ProjectDetailColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.labelLarge.copyWith(
              color: _ProjectDetailColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.timeline,
                  label: 'Timeline',
                  onTap: () =>
                      context.push('/projects/${project.id}/timeline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  onTap: () => context.push('/projects/${project.id}/chat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.support_agent,
                  label: 'Support',
                  onTap: () => context.push('/profile/help'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _ProjectDetailColors.creamBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: _ProjectDetailColors.warmAccent,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: _ProjectDetailColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  bool _isInvoiceAvailable(ProjectStatus status) {
    return status == ProjectStatus.completed ||
        status == ProjectStatus.delivered ||
        status == ProjectStatus.qcApproved ||
        status == ProjectStatus.autoApproved;
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'timeline':
        context.push('/projects/${widget.project.id}/timeline');
        break;
      case 'invoice':
        _downloadInvoice();
        break;
      case 'support':
        context.push('/profile/help');
        break;
      case 'cancel':
        _showCancelDialog();
        break;
    }
  }

  Future<void> _downloadInvoice() async {
    const baseUrl = String.fromEnvironment(
      'WEB_APP_URL',
      defaultValue: 'https://assignx.in',
    );

    final invoiceUrl = '$baseUrl/invoice/${widget.project.id}';

    try {
      final uri = Uri.parse(invoiceUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invoice opened in browser'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        throw Exception('Could not launch invoice URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open invoice: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleApprove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Approve Delivery'),
        content: const Text(
          'Are you sure you want to approve this delivery? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: _ProjectDetailColors.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      setState(() => _isLoading = true);
      await ref
          .read(projectNotifierProvider.notifier)
          .approveProject(widget.project.id);
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRequestChanges() async {
    final controller = TextEditingController();

    try {
      final feedback = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Request Changes'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe the changes you need...',
              hintStyle: TextStyle(color: _ProjectDetailColors.mutedText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _ProjectDetailColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _ProjectDetailColors.warmAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: _ProjectDetailColors.secondaryText),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: _ProjectDetailColors.warmAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

      if (feedback != null && feedback.trim().isNotEmpty) {
        if (!mounted) return;
        setState(() => _isLoading = true);
        await ref
            .read(projectNotifierProvider.notifier)
            .requestChanges(widget.project.id, feedback);
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _showCancelDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Cancel Project'),
        content: const Text(
          'Are you sure you want to cancel this project? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No, Keep It',
              style: TextStyle(color: _ProjectDetailColors.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(projectNotifierProvider.notifier)
          .cancelProject(widget.project.id);
      if (mounted) {
        context.pop();
      }
    }
  }
}
