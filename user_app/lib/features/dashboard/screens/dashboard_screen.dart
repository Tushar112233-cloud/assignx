import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';

// ─────────────────────────────────────────────────────────────
// Design System — Coffee Bean palette matched to user-web
// ─────────────────────────────────────────────────────────────
class _C {
  _C._();
  // Brand
  static const Color coffee = Color(0xFF765341);
  static const Color coffeeLight = Color(0xFFA07A65);
  static const Color coffeeDark = Color(0xFF54442B);
  static const Color graphite = Color(0xFF34312D);
  static const Color cream = Color(0xFFE4E1C7);

  // Accents
  static const Color caramel = Color(0xFFBD916B);
  static const Color terracotta = Color(0xFFCC9870);

  // Status
  static const Color emerald = Color(0xFF259369);
  static const Color amber = Color(0xFFF59E0B);
  static const Color sky = Color(0xFF2B93BE);
  static const Color rose = Color(0xFFE11D48);
  static const Color violet = Color(0xFF7C3AED);

  // Surfaces — exactly from user-web
  static const Color bg = Color(0xFFFEFDFB);
  static const Color surface = Color(0xFFFDFCFB);
  static const Color surfaceMuted = Color(0xFFF6F5F3);
  static const Color surfaceHover = Color(0xFFF1F0ED);

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

/// Premium mobile dashboard — Coffee Bean design system.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.valueOrNull;
    final wallet = walletAsync.valueOrNull;
    final isLoading = walletAsync.isLoading || projectsAsync.isLoading;
    final hasError = walletAsync.hasError || projectsAsync.hasError;

    final allProjects = projectsAsync.valueOrNull ?? [];

    final needsAttention = allProjects
        .where((p) =>
            p.status == ProjectStatus.paymentPending ||
            p.status == ProjectStatus.quoted ||
            p.status == ProjectStatus.delivered)
        .toList();

    final activeCount = allProjects
        .where((p) =>
            p.status == ProjectStatus.inProgress ||
            p.status == ProjectStatus.assigned ||
            p.status == ProjectStatus.qcInProgress)
        .length;

    final pendingCount = needsAttention.length;
    final walletBalance = wallet?.balance ?? 0.0;
    final completedCount = allProjects
        .where((p) =>
            p.status == ProjectStatus.completed ||
            p.status == ProjectStatus.paid)
        .length;
    final recentProjects = allProjects.take(5).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: SubtleGradientScaffold.standard(
        body: Stack(
          children: [
            // Ambient background gradient
            const _AmbientBackground(),

            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(walletProvider);
                  ref.invalidate(projectsProvider);
                  ref.invalidate(unreadCountProvider);
                },
                color: _C.coffee,
                backgroundColor: Colors.white,
                child: hasError
                    ? _ErrorView(onRetry: () {
                        ref.invalidate(walletProvider);
                        ref.invalidate(projectsProvider);
                      })
                    : CustomScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          // ── Top bar ──
                          SliverToBoxAdapter(
                            child: _TopBar(
                              walletBalance:
                                  wallet?.formattedBalance ?? '\u20B90',
                              unreadCount: ref
                                      .watch(unreadCountProvider)
                                      .valueOrNull ??
                                  0,
                            ),
                          ),

                          // ── Hero card ──
                          SliverToBoxAdapter(
                            child: _HeroCard(
                              userName: profile?.displayName,
                              activeCount: activeCount,
                              pendingCount: pendingCount,
                              completedCount: completedCount,
                              walletBalance: walletBalance,
                              isLoading: isLoading,
                            ),
                          ),

                          // ── Quick Actions ──
                          SliverToBoxAdapter(
                            child: _QuickActions(isLoading: isLoading),
                          ),

                          // ── Needs attention ──
                          if (needsAttention.isNotEmpty)
                            SliverToBoxAdapter(
                              child: _AttentionSection(
                                  projects: needsAttention),
                            ),

                          // ── Recent Projects ──
                          if (recentProjects.isNotEmpty)
                            SliverToBoxAdapter(
                              child: _RecentSection(
                                projects: recentProjects,
                                onViewAll: () {
                                  ref
                                      .read(navigationIndexProvider.notifier)
                                      .state = 1;
                                },
                              ),
                            ),

                          // ── Campus Connect ──
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _CampusConnectCard(),
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// AMBIENT BACKGROUND — subtle warm gradient wash
// ═══════════════════════════════════════════════════════════════
class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _AmbientPainter()),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Warm Linen — subtle top-to-bottom warm white to soft cream
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFEFDFB), // warm white
          Color(0xFFF6F4EF), // soft cream
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String walletBalance;
  final int unreadCount;

  const _TopBar({required this.walletBalance, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          // Logo mark
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_C.coffee, _C.coffeeDark],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _C.coffee.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'AssignX',
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: _C.text,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Wallet pill
          GestureDetector(
            onTap: () => context.push('/wallet'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _C.coffee.withValues(alpha: 0.08),
                    _C.caramel.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _C.coffee.withValues(alpha: 0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.wallet, size: 15, color: _C.coffee),
                  const SizedBox(width: 6),
                  Text(
                    walletBalance,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.coffee,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Notification bell
          GestureDetector(
            onTap: () => context.push('/notifications'),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _C.borderLight),
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
                  Icon(
                    LucideIcons.bell,
                    size: 19,
                    color: unreadCount > 0 ? _C.text : _C.textSoft,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _C.rose,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
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
}

// ═══════════════════════════════════════════════════════════════
// HERO CARD — greeting + frosted stats
// ═══════════════════════════════════════════════════════════════
class _HeroCard extends StatelessWidget {
  final String? userName;
  final int activeCount;
  final int pendingCount;
  final int completedCount;
  final double walletBalance;
  final bool isLoading;

  const _HeroCard({
    this.userName,
    required this.activeCount,
    required this.pendingCount,
    required this.completedCount,
    required this.walletBalance,
    required this.isLoading,
  });

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _firstName(String? n) {
    if (n == null || n.isEmpty) return 'there';
    return n.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _HeroSkeleton();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            '${_greeting().tr(context)} \u{1f44b}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15,
              color: _C.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _firstName(userName),
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _C.text,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 20),

          // Premium stats card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF765341),
                  Color(0xFF5E3F2E),
                  Color(0xFF4A3320),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.circular(_C.r),
              boxShadow: [
                BoxShadow(
                  color: _C.coffee.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: _C.coffee.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_C.r),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -25,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _C.caramel.withValues(alpha: 0.2),
                            _C.caramel.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -15,
                    bottom: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _C.cream.withValues(alpha: 0.1),
                            _C.cream.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 22),
                    child: Row(
                      children: [
                        _GlassStat(
                          value: '$activeCount',
                          label: 'Active',
                          icon: LucideIcons.zap,
                          iconColor: const Color(0xFFFBBF24),
                        ),
                        _GlassStat(
                          value: '$pendingCount',
                          label: 'Pending',
                          icon: LucideIcons.clock,
                          iconColor: const Color(0xFFFB923C),
                        ),
                        _GlassStat(
                          value: '$completedCount',
                          label: 'Done',
                          icon: LucideIcons.checkCircle,
                          iconColor: const Color(0xFF34D399),
                        ),
                        _GlassStat(
                          value: _formatBal(walletBalance),
                          label: 'Balance',
                          icon: LucideIcons.indianRupee,
                          iconColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  String _formatBal(double b) {
    if (b >= 1000) return '\u20B9${(b / 1000).toStringAsFixed(1)}k';
    return '\u20B9${b.toInt()}';
  }
}

/// Glass stat pill for the brown gradient banner.
class _GlassStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _GlassStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label.tr(context),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(width: 140, height: 15, borderRadius: 4),
          const SizedBox(height: 6),
          const SkeletonLoader(width: 100, height: 30, borderRadius: 6),
          const SizedBox(height: 20),
          SkeletonLoader(
            width: double.infinity,
            height: 120,
            borderRadius: _C.r,
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// QUICK ACTIONS — 2×2 glass cards
// ═══════════════════════════════════════════════════════════════
class _QuickActions extends StatelessWidget {
  final bool isLoading;
  const _QuickActions({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _QuickActionsSkeleton();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Quick Actions'.tr(context)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: LucideIcons.filePlus,
                  title: 'Project Support'.tr(context),
                  subtitle: 'Get expert help',
                  accentColor: _C.violet,
                  onTap: () => context.push('/add-project/wizard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionTile(
                  icon: LucideIcons.searchCheck,
                  title: 'Turnitin Check'.tr(context),
                  subtitle: 'AI & plagiarism',
                  accentColor: _C.amber,
                  onTap: () => context.push('/add-project/report'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: LucideIcons.graduationCap,
                  title: 'Expert Sessions'.tr(context),
                  subtitle: 'Consult an expert',
                  accentColor: _C.sky,
                  onTap: () => context.push('/add-project/expert'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionTile(
                  icon: LucideIcons.bookOpen,
                  title: 'Ref. Generator'.tr(context),
                  subtitle: 'Free citations',
                  accentColor: _C.emerald,
                  badge: 'Free',
                  onTap: () async {
                    final uri =
                        Uri.parse('https://www.citethisforme.com/');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? accentColor;
  final List<Color>? gradient;
  final Color? iconBgColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? subtitleColor;
  final String? badge;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accentColor,
    this.gradient,
    this.iconBgColor,
    this.iconColor,
    this.textColor,
    this.subtitleColor,
    this.badge,
    this.onTap,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasGrad = widget.gradient != null;
    final c = widget.accentColor ?? _C.coffee;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 128,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: hasGrad
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradient!,
                  )
                : null,
            color: hasGrad ? null : Colors.white,
            borderRadius: BorderRadius.circular(_C.rSm),
            border: hasGrad
                ? null
                : Border.all(color: _C.borderLight),
            boxShadow: [
              BoxShadow(
                color: (hasGrad ? widget.gradient!.first : c)
                    .withValues(alpha: hasGrad ? 0.28 : 0.06),
                blurRadius: hasGrad ? 20 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.iconBgColor ?? c,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 21,
                      color: widget.iconColor ?? Colors.white,
                    ),
                  ),
                  const Spacer(),
                  if (widget.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: hasGrad
                            ? Colors.white.withValues(alpha: 0.18)
                            : c.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.badge!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: hasGrad ? Colors.white : c,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                widget.title,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: widget.textColor ?? _C.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: widget.subtitleColor ?? _C.textSoft,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsSkeleton extends StatelessWidget {
  const _QuickActionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(width: 130, height: 20, borderRadius: 6),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: SkeletonLoader(
                      width: double.infinity,
                      height: 128,
                      borderRadius: _C.rSm)),
              const SizedBox(width: 12),
              Expanded(
                  child: SkeletonLoader(
                      width: double.infinity,
                      height: 128,
                      borderRadius: _C.rSm)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: SkeletonLoader(
                      width: double.infinity,
                      height: 128,
                      borderRadius: _C.rSm)),
              const SizedBox(width: 12),
              Expanded(
                  child: SkeletonLoader(
                      width: double.infinity,
                      height: 128,
                      borderRadius: _C.rSm)),
            ],
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NEEDS ATTENTION — horizontal scroll with frosted glass cards
// ═══════════════════════════════════════════════════════════════
class _AttentionSection extends StatelessWidget {
  final List<Project> projects;
  const _AttentionSection({required this.projects});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _SectionTitle(title: 'Needs Attention'.tr(context)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: _C.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${projects.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _C.amber,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 88,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final p = projects[i];
              return _AttentionCard(
                project: p,
                onTap: () => context.push('/projects/${p.id}'),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _AttentionCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  const _AttentionCard({required this.project, this.onTap});

  Color get _color {
    switch (project.status) {
      case ProjectStatus.paymentPending:
        return _C.amber;
      case ProjectStatus.delivered:
        return _C.emerald;
      case ProjectStatus.quoted:
        return _C.caramel;
      default:
        return project.status.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_C.rSm),
          border: Border.all(
            color: _color.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _color.withValues(alpha: 0.15),
                    _color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(project.status.icon, color: _color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _C.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      project.status.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: _C.textSoft),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// RECENT PROJECTS
// ═══════════════════════════════════════════════════════════════
class _RecentSection extends StatelessWidget {
  final List<Project> projects;
  final VoidCallback? onViewAll;
  const _RecentSection({required this.projects, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _SectionTitle(title: 'Recent Projects'.tr(context)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: _C.coffee.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${projects.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _C.coffee,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onViewAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.coffee.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All'.tr(context),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _C.coffee,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(LucideIcons.chevronRight,
                          size: 14, color: _C.coffee),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final p = projects[i];
              return _ProjectCard(
                project: p,
                onTap: () => context.push('/projects/${p.id}'),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  const _ProjectCard({required this.project, this.onTap});

  Color get _dotColor {
    switch (project.status) {
      case ProjectStatus.completed:
      case ProjectStatus.qcApproved:
      case ProjectStatus.paid:
        return _C.emerald;
      case ProjectStatus.inProgress:
      case ProjectStatus.assigned:
      case ProjectStatus.delivered:
        return _C.sky;
      case ProjectStatus.analyzing:
      case ProjectStatus.quoted:
      case ProjectStatus.paymentPending:
        return _C.amber;
      default:
        return _C.textSoft;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_C.rSm),
          border: Border.all(color: _C.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _dotColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.text,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: Text(
                    project.projectNumber,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: _C.textSoft,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _timeAgo(project.createdAt),
                  style: TextStyle(fontSize: 11, color: _C.textSoft),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CAMPUS CONNECT — animated carousel card
// ═══════════════════════════════════════════════════════════════

class _CCItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _CCItem(this.title, this.subtitle, this.icon, this.color);
}

class _CampusConnectCard extends StatefulWidget {
  const _CampusConnectCard();

  @override
  State<_CampusConnectCard> createState() => _CampusConnectCardState();
}

class _CampusConnectCardState extends State<_CampusConnectCard>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _timer;
  late AnimationController _progressController;

  static const _items = [
    _CCItem('Student Housing', 'Find your perfect place',
        LucideIcons.home, Color(0xFFE11D48)),
    _CCItem('Campus Events', "Never miss what's happening",
        LucideIcons.calendar, Color(0xFF6366F1)),
    _CCItem('Study Resources', 'Notes, guides & materials',
        LucideIcons.bookOpen, Color(0xFFF59E0B)),
    _CCItem('Marketplace', 'Buy & sell with students',
        LucideIcons.shoppingBag, Color(0xFF14B8A6)),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _startCycle();
  }

  void _startCycle() {
    _progressController.forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _items.length;
      });
      _progressController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_currentIndex];

    return GestureDetector(
      onTap: () {
        final container = ProviderScope.containerOf(context);
        container.read(navigationIndexProvider.notifier).state = 2;
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon circle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  // Title, badge, subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Campus Connect',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Live badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.messageCircle,
                                      size: 10, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Live',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Animated subtitle
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            final slideIn = Tween<Offset>(
                              begin: const Offset(0, 0.5),
                              end: Offset.zero,
                            ).animate(animation);
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: slideIn,
                                child: child,
                              ),
                            );
                          },
                          child: SizedBox(
                            key: ValueKey(_currentIndex),
                            width: double.infinity,
                            child: Text(
                              '${item.title} — ${item.subtitle}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Dots
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_items.length, (i) {
                          final isActive = i == _currentIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: isActive ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      // Arrow button
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Progress bar
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, _) {
                return Container(
                  height: 2,
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _progressController.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED COMPONENTS
// ═══════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.headingSmall.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _C.text,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _C.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.wifiOff,
                size: 28, color: _C.textSoft),
          ),
          const SizedBox(height: 20),
          Text(
            'Something went wrong',
            style: AppTextStyles.headingSmall.copyWith(
              color: _C.text,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh or tap retry',
            style: TextStyle(color: _C.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: _C.coffee,
              backgroundColor: _C.coffee.withValues(alpha: 0.08),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
