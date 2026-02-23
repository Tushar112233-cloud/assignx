import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/project_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../home/widgets/home_app_bar.dart';
import '../widgets/greeting_section.dart';
import '../widgets/needs_attention_card.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/services_grid.dart';
import '../widgets/recent_projects_section.dart';
import '../widgets/campus_pulse_section.dart';

/// Dashboard screen with modern UI design matching web.
///
/// Features:
/// - Time-based personalized greeting
/// - Quick stats row (Active, Pending, Wallet)
/// - Services grid (Project Support, AI/Plag Report, Expert Sessions, Generate Content)
/// - Needs Attention section
/// - Recent Projects horizontal scroll
/// - Campus Pulse preview
/// - Subtle gradient background
///
/// Uses Riverpod for state management and responsive to wallet, projects, and profile data.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers for data
    final walletAsync = ref.watch(walletProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.valueOrNull;
    final wallet = walletAsync.valueOrNull;

    // Determine loading state
    final isLoading = walletAsync.isLoading || projectsAsync.isLoading;

    // Check for errors (local variable, not state mutation in build)
    final hasError = walletAsync.hasError || projectsAsync.hasError;

    // Get all projects
    final allProjects = projectsAsync.valueOrNull ?? [];

    // Get projects that need attention (payment_pending, quoted, delivered, revision)
    final needsAttentionProjects = allProjects
        .where((p) =>
            p.status == ProjectStatus.paymentPending ||
            p.status == ProjectStatus.quoted ||
            p.status == ProjectStatus.delivered)
        .toList();

    // Calculate stats for QuickStatsRow
    final activeProjects = allProjects
        .where((p) =>
            p.status == ProjectStatus.inProgress ||
            p.status == ProjectStatus.assigned ||
            p.status == ProjectStatus.qcInProgress)
        .length;
    final pendingActions = needsAttentionProjects.length;
    final walletBalance = wallet?.balance ?? 0.0;

    // Get recent projects (up to 5)
    final recentProjects = allProjects.take(5).toList();

    return Scaffold(
      // Transparent to show SubtleGradientScaffold from MainShell
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false, // Don't apply SafeArea to bottom (for fixed navbar)
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(walletProvider);
            ref.invalidate(projectsProvider);
            ref.invalidate(unreadCountProvider);
          },
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: hasError
              ? _buildErrorState(ref)
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // App Bar
                    const SliverToBoxAdapter(
                      child: HomeAppBar(),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),

                    // Greeting Section
                    SliverToBoxAdapter(
                      child: GreetingSection(
                        userName: profile?.fullName,
                        isLoading: isLoading,
                        animationDelay: const Duration(milliseconds: 50),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 16),
                    ),

                    // Quick Stats Row (Active, Pending, Wallet)
                    SliverToBoxAdapter(
                      child: QuickStatsRow(
                        activeProjects: activeProjects,
                        pendingActions: pendingActions,
                        walletBalance: walletBalance,
                        isLoading: isLoading,
                      ),
                    ),

                    // Needs Attention Section (if any)
                    if (needsAttentionProjects.isNotEmpty) ...[
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),
                      SliverToBoxAdapter(
                        child: NeedsAttentionSection(
                          projects: needsAttentionProjects,
                          onProjectTap: (project) =>
                              context.push('/projects/${project.id}'),
                        ),
                      ),
                    ],

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 28),
                    ),

                    // Services Grid (2x2 matching web)
                    SliverToBoxAdapter(
                      child: isLoading
                          ? const ServicesGridSkeleton()
                          : ServicesGrid(
                              onNewProject: () =>
                                  context.push('/add-project/new'),
                              onAiPlagReport: () =>
                                  context.push('/add-project/report'),
                              onExpertSessions: () =>
                                  context.push('/add-project/expert'),
                              onRefGenerator: () => _launchRefGenerator(),
                            ),
                    ),

                    // Recent Projects Section
                    if (recentProjects.isNotEmpty) ...[
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 28),
                      ),
                      SliverToBoxAdapter(
                        child: RecentProjectsSection(
                          projects: recentProjects,
                          onProjectTap: (project) =>
                              context.push('/projects/${project.id}'),
                          onViewAll: () {
                            // Navigate to Projects tab (index 1)
                            ref.read(navigationIndexProvider.notifier).state = 1;
                          },
                          isLoading: isLoading,
                        ),
                      ),
                    ],

                    // Campus Pulse Section
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 28),
                    ),
                    SliverToBoxAdapter(
                      child: CampusPulseSection(
                        onExploreMarketplace: () {
                          // Navigate to Campus Connect tab (index 2)
                          ref.read(navigationIndexProvider.notifier).state = 2;
                        },
                      ),
                    ),

                    // Bottom padding for fixed navbar
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 120),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Launches the reference generator external URL.
  Future<void> _launchRefGenerator() async {
    final uri = Uri.parse('https://www.citethisforme.com/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }


  /// Builds error state with retry option.
  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: EmptyStateVariants.networkError(
        onRetry: () {
          ref.invalidate(walletProvider);
          ref.invalidate(projectsProvider);
          ref.invalidate(unreadCountProvider);
        },
      ),
    );
  }

}
