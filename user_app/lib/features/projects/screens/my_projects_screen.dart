import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/project_provider.dart';
import '../widgets/payment_prompt_modal.dart';
import '../widgets/progress_indicator.dart';

// ─────────────────────────────────────────────────────────────
// Projects page design tokens
// Base: Coffee Bean palette | Pop via status icons/dots only
// ─────────────────────────────────────────────────────────────
class _P {
  _P._();
  // Brand base
  static const Color coffee = Color(0xFF765341);
  static const Color coffeeDark = Color(0xFF54442B);
  static const Color coffeeLight = Color(0xFFA07A65);
  static const Color cream = Color(0xFFE4E1C7);
  static const Color caramel = Color(0xFFBD916B);

  // Pop is coffee — color pops come from status icons/dots only
  static const Color pop = Color(0xFF765341);
  static const Color popLight = Color(0xFFA07A65);
  static const Color popSoft = Color(0xFFF5F0EB);
  static const Color popAccent = Color(0xFF765341);

  // Status
  static const Color emerald = Color(0xFF259369);
  static const Color amber = Color(0xFFF59E0B);
  static const Color sky = Color(0xFF0EA5E9);
  static const Color rose = Color(0xFFE11D48);
  static const Color violet = Color(0xFF7C3AED);

  // Surfaces
  static const Color bg = Color(0xFFFEFDFB);
  static const Color surface = Color(0xFFFDFCFB);
  static const Color surfaceMuted = Color(0xFFF6F5F3);

  // Text
  static const Color text = Color(0xFF14110F);
  static const Color textMuted = Color(0xFF5C5652);
  static const Color textSoft = Color(0xFF85807A);

  // Border
  static const Color border = Color(0xFFE5E2DD);
  static const Color borderLight = Color(0xFFF0EEEA);

  // Radii
  static const double r = 22;
  static const double rSm = 16;
  static const double rXs = 12;
}

/// Redesigned My Projects screen — slate indigo identity.
class MyProjectsScreen extends ConsumerStatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  ConsumerState<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends ConsumerState<MyProjectsScreen> {
  int _selectedTab = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final _tabs = const [
    ('In Review', LucideIcons.clock),
    ('In Progress', LucideIcons.zap),
    ('For Review', LucideIcons.checkCircle),
    ('History', LucideIcons.archive),
  ];

  static bool _isPaymentModalShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPending());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkPending() async {
    if (_isPaymentModalShowing) return;
    final pending = await ref.read(pendingPaymentProjectsProvider.future);
    if (pending.isNotEmpty && mounted) {
      final p = pending.first;
      _isPaymentModalShowing = true;
      PaymentPromptModal.show(
        context,
        project: p,
        onPayNow: () {
          _isPaymentModalShowing = false;
          if (mounted) context.push(RouteNames.projectPayPath(p.id));
        },
        onRemindLater: () {
          _isPaymentModalShowing = false;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('We\'ll remind you about "${p.title}"'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ).then((_) => _isPaymentModalShowing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _P.bg,
        body: Stack(
          children: [
            // Page-specific ambient background
            const _ProjectsBg(),

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ── Header ──
                  _buildHeader(context),

                  // ── Content ──
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(projectsProvider);
                        ref.invalidate(projectCountsProvider);
                        ref.invalidate(walletProvider);
                      },
                      color: _P.coffee,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          // Stats banner
                          SliverToBoxAdapter(child: _buildStatsBanner()),

                          // Filter tabs
                          SliverToBoxAdapter(child: _buildTabs()),

                          // Search
                          SliverToBoxAdapter(child: _buildSearch()),

                          // Project list
                          SliverToBoxAdapter(
                            child: _ProjectsList(
                              tabIndex: _selectedTab,
                              searchQuery: _searchQuery,
                              onApprove: _handleApprove,
                              onRequestChanges: _handleRequestChanges,
                            ),
                          ),

                          const SliverToBoxAdapter(
                              child: SizedBox(height: 120)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // FAB for new project
        floatingActionButton: _buildFab(context),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final unread = ref.watch(unreadCountProvider).valueOrNull ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          // Page title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Projects',
                style: AppTextStyles.headingMedium.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _P.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Track & manage your work',
                style: TextStyle(
                  fontSize: 13,
                  color: _P.textSoft,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Wallet pill
          GestureDetector(
            onTap: () => context.push('/wallet'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _P.pop.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _P.pop.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.wallet, size: 15, color: _P.pop),
                  const SizedBox(width: 6),
                  Text(
                    wallet.valueOrNull?.formattedBalance ?? '\u20B90',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _P.pop,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Notification
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _P.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(LucideIcons.bell, size: 19,
                      color: unread > 0 ? _P.text : _P.textSoft),
                  if (unread > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _P.rose,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Inline stats row ──
  Widget _buildStatsBanner() {
    final countsAsync = ref.watch(projectCountsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: countsAsync.when(
        data: (counts) {
          final total = counts[5] ?? 0;
          final active = counts[1] ?? 0;
          final review = counts[2] ?? 0;
          final done = counts[4] ?? 0;

          return Row(
            children: [
              _InlineStat(value: total, label: 'Total', color: _P.pop),
              const SizedBox(width: 6),
              Container(width: 1, height: 22, color: _P.border),
              const SizedBox(width: 6),
              _InlineStat(value: active, label: 'Active', color: _P.sky),
              const SizedBox(width: 6),
              Container(width: 1, height: 22, color: _P.border),
              const SizedBox(width: 6),
              _InlineStat(value: review, label: 'Review', color: _P.amber),
              const SizedBox(width: 6),
              Container(width: 1, height: 22, color: _P.border),
              const SizedBox(width: 6),
              _InlineStat(value: done, label: 'Done', color: _P.emerald),
            ],
          );
        },
        loading: () => Row(
          children: [
            _InlineStat(value: 0, label: 'Total', color: _P.pop, loading: true),
            const SizedBox(width: 6),
            Container(width: 1, height: 22, color: _P.border),
            const SizedBox(width: 6),
            _InlineStat(value: 0, label: 'Active', color: _P.sky, loading: true),
            const SizedBox(width: 6),
            Container(width: 1, height: 22, color: _P.border),
            const SizedBox(width: 6),
            _InlineStat(value: 0, label: 'Review', color: _P.amber, loading: true),
            const SizedBox(width: 6),
            Container(width: 1, height: 22, color: _P.border),
            const SizedBox(width: 6),
            _InlineStat(value: 0, label: 'Done', color: _P.emerald, loading: true),
          ],
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  // ── Filter tabs ──
  Widget _buildTabs() {
    final countsAsync = ref.watch(projectCountsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final isSelected = _selectedTab == i;
            final (label, icon) = _tabs[i];

            int count = 0;
            countsAsync.whenData((c) => count = c[i] ?? 0);

            return Padding(
              padding: EdgeInsets.only(right: i < _tabs.length - 1 ? 10 : 0),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = i);
                  ref.read(selectedProjectTabProvider.notifier).state = i;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? _P.pop : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? _P.pop
                          : _P.border,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _P.pop.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected
                            ? Colors.white
                            : _P.textSoft,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : _P.textMuted,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.2)
                                : _P.pop.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : _P.pop,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Search bar ──
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_P.rXs),
          border: Border.all(color: _P.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: AppTextStyles.bodyMedium.copyWith(
            color: _P.text,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search projects...',
            hintStyle: TextStyle(color: _P.textSoft, fontSize: 14),
            prefixIcon:
                Icon(LucideIcons.search, size: 18, color: _P.textSoft),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                    child:
                        Icon(LucideIcons.x, size: 16, color: _P.textSoft),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── FAB ──
  Widget _buildFab(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 70),
      child: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.projectWizard),
        backgroundColor: _P.coffee,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text(
          'New Project',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  // ── Actions ──
  Future<void> _handleApprove(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Approve Delivery'),
        content: const Text(
            'Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _P.emerald,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(projectNotifierProvider.notifier)
          .approveProject(project.id);
    }
  }

  Future<void> _handleRequestChanges(Project project) async {
    FeedbackInputModal.show(
      context,
      onSubmit: (feedback) async {
        await ref
            .read(projectNotifierProvider.notifier)
            .requestChanges(project.id, feedback);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAGE BACKGROUND — warm linen + cool slate tint
// ═══════════════════════════════════════════════════════════════
class _ProjectsBg extends StatelessWidget {
  const _ProjectsBg();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _BgPainter()),
    );
  }
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Warm linen base
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFEFDFB),
          Color(0xFFF5F3EE),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    // Subtle warm coffee wash top-right
    final p1 = Paint()
      ..shader = RadialGradient(
        center: const Alignment(1.0, -0.5),
        radius: 1.3,
        colors: [
          const Color(0xFF765341).withValues(alpha: 0.04),
          const Color(0xFF765341).withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, p1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
// INLINE STAT — compact dot + number + label
// ═══════════════════════════════════════════════════════════════
class _InlineStat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final bool loading;

  const _InlineStat({
    required this.value,
    required this.label,
    required this.color,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loading ? '-' : '$value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _P.text,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  color: _P.textSoft,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PROJECTS LIST
// ═══════════════════════════════════════════════════════════════
class _ProjectsList extends ConsumerWidget {
  final int tabIndex;
  final String searchQuery;
  final Future<void> Function(Project) onApprove;
  final Future<void> Function(Project) onRequestChanges;

  const _ProjectsList({
    required this.tabIndex,
    required this.searchQuery,
    required this.onApprove,
    required this.onRequestChanges,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsByTabProvider(tabIndex));

    return projectsAsync.when(
      data: (projects) {
        var filtered = projects;
        if (searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          filtered = projects
              .where((p) =>
                  p.title.toLowerCase().contains(q) ||
                  p.projectNumber.toLowerCase().contains(q))
              .toList();
        }

        if (filtered.isEmpty) {
          return _EmptyState(
            tabIndex: tabIndex,
            isSearch: searchQuery.isNotEmpty,
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            children: List.generate(filtered.length, (i) {
              final p = filtered[i];
              return Padding(
                padding: EdgeInsets.only(
                    bottom: i < filtered.length - 1 ? 12 : 0),
                child: _ProjectCard(
                  project: p,
                  onTap: () => context.push('/projects/${p.id}'),
                  onApprove: () => onApprove(p),
                  onRequestChanges: () => onRequestChanges(p),
                ),
              );
            }),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: _P.pop, strokeWidth: 2.5),
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _P.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.alertCircle,
                    size: 24, color: _P.textSoft),
              ),
              const SizedBox(height: 16),
              const Text('Failed to load projects'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(projectsByTabProvider(tabIndex)),
                style:
                    TextButton.styleFrom(foregroundColor: _P.pop),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PROJECT CARD
// ═══════════════════════════════════════════════════════════════
class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onRequestChanges;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    this.onApprove,
    this.onRequestChanges,
  });

  _Style get _style {
    switch (project.status) {
      case ProjectStatus.completed:
      case ProjectStatus.autoApproved:
        return _Style(
          color: _P.emerald,
          icon: LucideIcons.checkCircle2,
          label: 'Completed',
        );
      case ProjectStatus.delivered:
      case ProjectStatus.submittedForQc:
      case ProjectStatus.qcInProgress:
      case ProjectStatus.qcApproved:
        return _Style(
          color: _P.amber,
          icon: LucideIcons.clock,
          label: 'Under Review',
        );
      case ProjectStatus.quoted:
      case ProjectStatus.paymentPending:
        return _Style(
          color: _P.amber,
          icon: LucideIcons.creditCard,
          label: 'Payment Pending',
        );
      case ProjectStatus.inProgress:
      case ProjectStatus.assigned:
      case ProjectStatus.assigning:
        return _Style(
          color: _P.sky,
          icon: LucideIcons.activity,
          label: 'In Progress',
        );
      case ProjectStatus.revisionRequested:
      case ProjectStatus.inRevision:
        return _Style(
          color: _P.violet,
          icon: LucideIcons.pencil,
          label: 'Revision',
        );
      case ProjectStatus.cancelled:
      case ProjectStatus.refunded:
      case ProjectStatus.qcRejected:
        return _Style(
          color: _P.rose,
          icon: LucideIcons.xCircle,
          label: project.status.displayName,
        );
      default:
        return _Style(
          color: _P.pop,
          icon: LucideIcons.fileText,
          label: project.status.displayName,
        );
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_P.rSm),
          border: Border.all(color: _P.borderLight),
          boxShadow: [
            BoxShadow(
              color: s.color.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + title + badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        s.color.withValues(alpha: 0.15),
                        s.color.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(s.icon, color: s.color, size: 20),
                ),
                const SizedBox(width: 14),
                // Title + project number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: _P.text,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '#${project.projectNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: _P.textSoft,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            width: 3,
                            height: 3,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 8),
                            decoration: const BoxDecoration(
                              color: _P.textSoft,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              project.serviceType.displayName,
                              style: const TextStyle(
                                  fontSize: 12, color: _P.textSoft),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: s.color,
                    ),
                  ),
                ),
              ],
            ),

            // Progress bar
            if (project.status == ProjectStatus.inProgress) ...[
              const SizedBox(height: 14),
              ProjectProgressIndicator(
                percent: project.progressPercentage,
                showLabel: true,
              ),
            ],

            const SizedBox(height: 14),

            // Bottom row: time + actions
            Row(
              children: [
                Icon(LucideIcons.clock, size: 13, color: _P.textSoft),
                const SizedBox(width: 5),
                Text(
                  _timeAgo(project.updatedAt ?? project.createdAt),
                  style: const TextStyle(fontSize: 12, color: _P.textSoft),
                ),
                const Spacer(),
                _buildActions(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    switch (project.status) {
      case ProjectStatus.quoted:
      case ProjectStatus.paymentPending:
        return _Chip(
          label: 'Pay Now',
          icon: LucideIcons.creditCard,
          color: _P.amber,
          onTap: () => context.push('/projects/${project.id}/pay'),
        );
      case ProjectStatus.delivered:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Chip(
              label: 'Changes',
              icon: LucideIcons.pencil,
              color: _P.textMuted,
              outlined: true,
              onTap: onRequestChanges,
            ),
            const SizedBox(width: 8),
            _Chip(
              label: 'Approve',
              icon: LucideIcons.check,
              color: _P.emerald,
              onTap: onApprove,
            ),
          ],
        );
      default:
        return _Chip(
          label: 'View',
          icon: LucideIcons.arrowRight,
          color: _P.pop,
          outlined: true,
          onTap: onTap,
        );
    }
  }
}

class _Style {
  final Color color;
  final IconData icon;
  final String label;
  const _Style({
    required this.color,
    required this.icon,
    required this.label,
  });
}

// ═══════════════════════════════════════════════════════════════
// ACTION CHIP
// ═══════════════════════════════════════════════════════════════
class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback? onTap;

  const _Chip({
    required this.label,
    required this.icon,
    required this.color,
    this.outlined = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(10),
          border: outlined
              ? Border.all(color: color.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: outlined ? color : Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: outlined ? color : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final int tabIndex;
  final bool isSearch;

  const _EmptyState({required this.tabIndex, this.isSearch = false});

  @override
  Widget build(BuildContext context) {
    final (icon, title, sub) = isSearch
        ? (LucideIcons.searchX, 'No Results', 'Try a different search term')
        : _content();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _P.popSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: _P.popLight),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.headingSmall.copyWith(
                color: _P.text,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              sub,
              style: TextStyle(color: _P.textSoft, fontSize: 13.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  (IconData, String, String) _content() {
    switch (tabIndex) {
      case 0:
        return (LucideIcons.clock, 'Nothing In Review',
            'Projects awaiting review will appear here');
      case 1:
        return (LucideIcons.zap, 'Nothing In Progress',
            'Active projects will appear here');
      case 2:
        return (LucideIcons.eye, 'Nothing For Review',
            'Delivered projects will appear here');
      case 3:
        return (LucideIcons.archive, 'No History Yet',
            'Completed projects will appear here');
      default:
        return (LucideIcons.folder, 'No Projects', 'Your projects appear here');
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// FEEDBACK INPUT MODAL (kept from original)
// ═══════════════════════════════════════════════════════════════
class FeedbackInputModal extends StatefulWidget {
  final Future<void> Function(String feedback) onSubmit;

  const FeedbackInputModal({super.key, required this.onSubmit});

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function(String feedback) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FeedbackInputModal(onSubmit: onSubmit),
    );
  }

  @override
  State<FeedbackInputModal> createState() => _FeedbackInputModalState();
}

class _FeedbackInputModalState extends State<FeedbackInputModal> {
  final _ctrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Request Changes',
            style: AppTextStyles.headingSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: _P.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Describe the changes you need',
            style: TextStyle(color: _P.textSoft, fontSize: 14),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g., Please fix the formatting in section 2...',
              hintStyle: TextStyle(color: _P.textSoft, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _P.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _P.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _P.coffee, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final text = _ctrl.text.trim();
                      if (text.isEmpty) return;
                      setState(() => _isSubmitting = true);
                      try {
                        await widget.onSubmit(text);
                        if (mounted) Navigator.pop(context);
                      } finally {
                        if (mounted) setState(() => _isSubmitting = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _P.coffee,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
