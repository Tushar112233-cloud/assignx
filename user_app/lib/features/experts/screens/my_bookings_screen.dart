import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/expert_model.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../providers/experts_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../widgets/expert_review_form.dart';
import '../widgets/session_card.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';

/// My Bookings screen showing user's consultation bookings.
///
/// Features tabs for Upcoming, Completed, and Cancelled bookings
/// with action buttons for managing sessions.
class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    _BookingTab(
      id: 'upcoming',
      label: 'Upcoming',
      icon: Icons.calendar_today,
      statuses: [BookingStatus.upcoming, BookingStatus.inProgress],
    ),
    _BookingTab(
      id: 'completed',
      label: 'Completed',
      icon: Icons.check_circle,
      statuses: [BookingStatus.completed],
    ),
    _BookingTab(
      id: 'cancelled',
      label: 'Cancelled',
      icon: Icons.cancel,
      statuses: [BookingStatus.cancelled, BookingStatus.noShow],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return SubtleGradientScaffold.standard(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        title: Text(
          'My Bookings'.tr(context),
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab bar
          _buildTabBar(bookingsAsync),
          const SizedBox(height: 8),

          // Tab content
          Expanded(
            child: bookingsAsync.when(
              data: (bookings) => TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) {
                  final filteredBookings = bookings
                      .where((b) => tab.statuses.contains(b.status))
                      .toList();

                  return _BookingsTab(
                    bookings: filteredBookings,
                    tabType: tab.id,
                    onReschedule: _handleReschedule,
                    onCancel: _handleCancel,
                    onJoin: _handleJoin,
                    onLeaveReview: _handleLeaveReview,
                  );
                }).toList(),
              ),
              loading: () => const _LoadingSkeleton(),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load bookings'.tr(context),
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(userBookingsProvider),
                      child: Text('Retry'.tr(context)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AsyncValue<List<ConsultationBooking>> bookingsAsync) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        blur: 10,
        opacity: 0.8,
        padding: const EdgeInsets.all(6),
        borderRadius: BorderRadius.circular(16),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.darkBrown,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBrown.withAlpha(40),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: _tabs.map((tab) {
            final count = bookingsAsync.whenData((bookings) => bookings
                    .where((b) => tab.statuses.contains(b.status))
                    .length)
                .valueOrNull;

            return Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(tab.icon, size: 16),
                  const SizedBox(width: 6),
                  Text(tab.label.tr(context)),
                  if (count != null && count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _handleReschedule(String bookingId) {
    // Show reschedule dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reschedule Session'.tr(context)),
        content: Text(
            'Would you like to reschedule this session? You can select a new date and time.'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(context)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to booking screen
            },
            child: Text('Reschedule'.tr(context)),
          ),
        ],
      ),
    );
  }

  void _handleCancel(String bookingId) {
    // Show cancel confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking'.tr(context)),
        content: Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Booking'.tr(context)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Cancel booking
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking cancelled'.tr(context)),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Cancel Booking'.tr(context)),
          ),
        ],
      ),
    );
  }

  void _handleJoin(String bookingId) {
    // Find the booking's meet link and open it
    final bookingsAsync = ref.read(userBookingsProvider);
    final bookings = bookingsAsync.valueOrNull ?? [];
    final booking = bookings.where((b) => b.id == bookingId).firstOrNull;
    if (booking?.meetLink != null && booking!.meetLink!.isNotEmpty) {
      launchUrl(Uri.parse(booking.meetLink!), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meet link not yet available. The admin will share it before your session.'.tr(context)),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _handleLeaveReview(ConsultationBooking booking, Expert? expert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.all(16),
          child: ExpertReviewForm(
            expertId: booking.expertId,
            bookingId: booking.id,
            expertName: expert?.name ?? 'Expert',
            onSubmitted: () {
              Navigator.pop(context);
              ref.invalidate(userBookingsProvider);
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}

class _BookingTab {
  final String id;
  final String label;
  final IconData icon;
  final List<BookingStatus> statuses;

  const _BookingTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.statuses,
  });
}

/// Bookings tab content.
class _BookingsTab extends ConsumerWidget {
  final List<ConsultationBooking> bookings;
  final String tabType;
  final Function(String) onReschedule;
  final Function(String) onCancel;
  final Function(String) onJoin;
  final Function(ConsultationBooking, Expert?) onLeaveReview;

  const _BookingsTab({
    required this.bookings,
    required this.tabType,
    required this.onReschedule,
    required this.onCancel,
    required this.onJoin,
    required this.onLeaveReview,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookings.isEmpty) {
      return _EmptyState(tabType: tabType);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userBookingsProvider);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final expertAsync =
              ref.watch(expertDetailProvider(booking.expertId));
          final isCompleted = booking.status == BookingStatus.completed;

          return expertAsync.when(
            data: (expert) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SessionCard(
                  booking: booking,
                  expert: expert,
                  onTap: () => context.push('/experts/${booking.expertId}'),
                  onReschedule: () => onReschedule(booking.id),
                  onCancel: () => onCancel(booking.id),
                  onJoin: () => onJoin(booking.id),
                ),
                // Show "Leave Review" button for completed sessions
                if (isCompleted) ...[
                  const SizedBox(height: 8),
                  _LeaveReviewButton(
                    onTap: () => onLeaveReview(booking, expert),
                  ),
                ],
              ],
            ),
            loading: () => const _SessionCardSkeleton(),
            error: (_, __) => SessionCard(
              booking: booking,
              expert: null,
              onTap: null,
            ),
          );
        },
      ),
    );
  }
}

/// Leave review button widget.
class _LeaveReviewButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LeaveReviewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withAlpha(15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withAlpha(40),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_outline_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Leave a Review'.tr(context),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state widget.
class _EmptyState extends StatelessWidget {
  final String tabType;

  const _EmptyState({required this.tabType});

  @override
  Widget build(BuildContext context) {
    final (icon, title, description) = _getEmptyStateContent(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (tabType == 'upcoming') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/experts'),
                icon: const Icon(Icons.add),
                label: Text('Book a Session'.tr(context)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  (IconData, String, String) _getEmptyStateContent(BuildContext context) {
    switch (tabType) {
      case 'upcoming':
        return (
          Icons.calendar_today_outlined,
          'No upcoming bookings'.tr(context),
          'Book a consultation with an expert to get started'.tr(context),
        );
      case 'completed':
        return (
          Icons.check_circle_outline,
          'No completed sessions'.tr(context),
          'Your completed consultations will appear here'.tr(context),
        );
      case 'cancelled':
        return (
          Icons.cancel_outlined,
          'No cancelled bookings'.tr(context),
          'Any cancelled sessions will appear here'.tr(context),
        );
      default:
        return (
          Icons.inbox_outlined,
          'No bookings'.tr(context),
          'Your bookings will appear here'.tr(context),
        );
    }
  }
}

/// Session card skeleton.
class _SessionCardSkeleton extends StatelessWidget {
  const _SessionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 10,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader.circle(size: 52),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(height: 16, width: 120),
                    SizedBox(height: 6),
                    SkeletonLoader(height: 12, width: 80),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              SkeletonLoader(height: 24, width: 80),
              SizedBox(width: 12),
              SkeletonLoader(height: 24, width: 100),
            ],
          ),
        ],
      ),
    );
  }
}

/// Loading skeleton.
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _SessionCardSkeleton(),
    );
  }
}
