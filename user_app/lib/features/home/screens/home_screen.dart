import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../shared/animations/common_animations.dart';
import '../../../shared/decorations/app_gradients.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../widgets/home_app_bar.dart';

/// Home screen with bento grid dashboard layout.
///
/// Uses the new UI polish system with:
/// - MeshGradientBackground for organic gradient effect
/// - Bento grid layout for content cards
/// - GlassCard components for modern glass morphism
/// - Staggered animations for content entrance
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasError = false;

  /// Returns time-appropriate greeting.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  /// Extracts first name from full name.
  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Student';
    final parts = fullName.split(' ');
    return parts.first;
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers for data
    final walletAsync = ref.watch(walletProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final profile = ref.watch(currentProfileProvider);

    // Determine if we're in a loading state
    final isLoading = walletAsync.isLoading || projectsAsync.isLoading;

    // Check for errors
    _hasError = walletAsync.hasError || projectsAsync.hasError;

    // Get projects that need attention (payment_pending, quoted, delivered)
    final needsAttentionProjects = projectsAsync.valueOrNull?.where((p) =>
        p.status == ProjectStatus.paymentPending ||
        p.status == ProjectStatus.quoted ||
        p.status == ProjectStatus.delivered).toList() ?? [];

    // Get active projects count
    final activeProjectsCount = projectsAsync.valueOrNull?.where((p) =>
        p.status == ProjectStatus.inProgress ||
        p.status == ProjectStatus.assigned ||
        p.status == ProjectStatus.paid).length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.bottomRight,
        colors: [
          AppColors.meshPink,
          AppColors.meshPeach,
          AppColors.meshOrange,
        ],
        opacity: 0.5,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(walletProvider);
              ref.invalidate(projectsProvider);
              ref.invalidate(unreadCountProvider);
              setState(() => _hasError = false);
            },
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: _hasError
                ? _buildErrorState()
                : CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // App Bar
                      SliverToBoxAdapter(
                        child: const HomeAppBar().fadeInSlideDown(
                          duration: const Duration(milliseconds: 400),
                        ),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),

                      // Greeting Section
                      SliverToBoxAdapter(
                        child: isLoading
                            ? _buildGreetingSkeleton()
                            : _buildGreetingSection(
                                _getFirstName(profile?.fullName),
                              ).fadeInSlideUp(
                                delay: const Duration(milliseconds: 50),
                                duration: const Duration(milliseconds: 400),
                              ),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),

                      // Needs Attention Section
                      if (needsAttentionProjects.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildNeedsAttentionSection(
                            needsAttentionProjects,
                          ).fadeInSlideUp(
                            delay: const Duration(milliseconds: 100),
                            duration: const Duration(milliseconds: 400),
                          ),
                        ),

                      if (needsAttentionProjects.isNotEmpty)
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 24),
                        ),

                      // Bento Grid
                      SliverToBoxAdapter(
                        child: isLoading
                            ? _buildBentoGridSkeleton()
                            : _buildBentoGrid(
                                walletBalance: walletAsync.valueOrNull?.balance ?? 0,
                                activeProjectsCount: activeProjectsCount,
                              ),
                      ),

                      // Bottom padding for navigation
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// Greeting section with personalized message.
  Widget _buildGreetingSection(String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
          Text(
            userName,
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to tackle your assignments?',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// Greeting skeleton loader.
  Widget _buildGreetingSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonLoader(width: 180, height: 28, borderRadius: 6),
          SizedBox(height: 4),
          SkeletonLoader(width: 120, height: 28, borderRadius: 6),
          SizedBox(height: 12),
          SkeletonLoader(width: 220, height: 14, borderRadius: 4),
        ],
      ),
    );
  }

  /// Needs attention section showing projects requiring user action.
  Widget _buildNeedsAttentionSection(List<Project> projects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Needs Attention',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${projects.length} item${projects.length > 1 ? 's' : ''}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: projects.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final project = projects[index];
              return _buildAttentionCard(project, index);
            },
          ),
        ),
      ],
    );
  }

  /// Card for a project needing attention.
  Widget _buildAttentionCard(Project project, int index) {
    return GlassCard(
      width: 260,
      height: 90,
      padding: const EdgeInsets.all(14),
      onTap: () => context.push('/projects/${project.id}'),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: project.status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              project.status.icon,
              color: project.status.color,
              size: 22,
            ),
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
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: project.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    project.status.displayName,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: project.status.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    ).fadeInSlideUp(
      delay: Duration(milliseconds: 50 * index),
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Bento grid with action cards.
  Widget _buildBentoGrid({
    required double walletBalance,
    required int activeProjectsCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // First row: New Assignment (large) + Active Projects (small)
          Row(
            children: [
              // New Assignment - Primary action card
              Expanded(
                flex: 3,
                child: _buildNewAssignmentCard().fadeInSlideUp(
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 400),
                ),
              ),
              const SizedBox(width: 12),
              // Active Projects - Stats card
              Expanded(
                flex: 2,
                child: _buildActiveProjectsCard(activeProjectsCount).fadeInSlideUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 400),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second row: Wallet Balance + Quick Help
          Row(
            children: [
              // Wallet Balance
              Expanded(
                child: _buildWalletCard(walletBalance).fadeInSlideUp(
                  delay: const Duration(milliseconds: 250),
                  duration: const Duration(milliseconds: 400),
                ),
              ),
              const SizedBox(width: 12),
              // Quick Help
              Expanded(
                child: _buildQuickHelpCard().fadeInSlideUp(
                  delay: const Duration(milliseconds: 300),
                  duration: const Duration(milliseconds: 400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// New Assignment primary action card with gradient.
  Widget _buildNewAssignmentCard() {
    return GlassCard(
      height: 140,
      padding: EdgeInsets.zero,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary,
          AppColors.primaryLight,
        ],
      ),
      borderColor: Colors.white.withValues(alpha: 0.2),
      onTap: () => context.push('/new-project'),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.add_circle_outline_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  'New Assignment',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Submit your work',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Active projects stats card.
  Widget _buildActiveProjectsCard(int count) {
    return GlassCard(
      height: 140,
      padding: const EdgeInsets.all(16),
      onTap: () {
        // Navigate to projects and set tab to In Progress
        ref.read(selectedProjectTabProvider.notifier).state = 1;
        context.push('/my-projects');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.folder_open_rounded,
              color: AppColors.info,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Active Projects',
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Wallet balance card.
  Widget _buildWalletCard(double balance) {
    return GlassCard(
      height: 140,
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/wallet'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.success,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            '\u20B9${balance.toStringAsFixed(0)}',
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Wallet Balance',
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Quick help card.
  Widget _buildQuickHelpCard() {
    return GlassCard(
      height: 140,
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/help'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.help_outline_rounded,
              color: AppColors.accent,
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            'Quick Help',
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'FAQs & Support',
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Bento grid skeleton loader.
  Widget _buildBentoGridSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(width: 100, height: 16, borderRadius: 4),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CardSkeleton(
                  height: 140,
                  borderRadius: 16,
                  showImage: false,
                  textLines: 2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: CardSkeleton(
                  height: 140,
                  borderRadius: 16,
                  showImage: false,
                  textLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CardSkeleton(
                  height: 140,
                  borderRadius: 16,
                  showImage: false,
                  textLines: 2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CardSkeleton(
                  height: 140,
                  borderRadius: 16,
                  showImage: false,
                  textLines: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Error state with retry option.
  Widget _buildErrorState() {
    return Center(
      child: EmptyStateVariants.networkError(
        onRetry: () {
          ref.invalidate(walletProvider);
          ref.invalidate(projectsProvider);
          ref.invalidate(unreadCountProvider);
          setState(() => _hasError = false);
        },
      ),
    );
  }
}

/// Loading overlay widget for transitions.
class HomeLoadingOverlay extends StatelessWidget {
  const HomeLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withAlpha(200),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom loading animation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1454442B),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated logo or icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ).pulse(
                    duration: const Duration(milliseconds: 1200),
                    scale: 1.05,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
