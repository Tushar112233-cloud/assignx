import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

/// Skeleton loader for project cards.
class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: status badge and deadline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 80, height: 24, borderRadius: 12),
                ShimmerBox(width: 100, height: 20, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            const ShimmerBox(width: double.infinity, height: 20),
            const SizedBox(height: 8),
            // Subject
            const ShimmerBox(width: 150, height: 16),
            const SizedBox(height: 12),
            // Footer row
            Row(
              children: [
                const ShimmerCircle(size: 32),
                const SizedBox(width: 8),
                const ShimmerBox(width: 100, height: 14),
                const Spacer(),
                ShimmerBox(width: 80, height: 32, borderRadius: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for dashboard screen.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats summary
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: StatsCardSkeleton()),
                SizedBox(width: 12),
                Expanded(child: StatsCardSkeleton()),
                SizedBox(width: 12),
                Expanded(child: StatsCardSkeleton()),
              ],
            ),
          ),
          // Section header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerLoading(
              child: ShimmerBox(width: 150, height: 24),
            ),
          ),
          const SizedBox(height: 8),
          // Project cards
          const ProjectCardSkeleton(),
          const ProjectCardSkeleton(),
          const ProjectCardSkeleton(),
        ],
      ),
    );
  }
}

/// Skeleton loader for stats cards.
class StatsCardSkeleton extends StatelessWidget {
  const StatsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 24, height: 24, borderRadius: 6),
            const SizedBox(height: 12),
            const ShimmerBox(width: 60, height: 28),
            const SizedBox(height: 4),
            const ShimmerBox(width: 80, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for chat messages.
class ChatMessageSkeleton extends StatelessWidget {
  const ChatMessageSkeleton({
    super.key,
    this.isMe = false,
  });

  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe) ...[
              const ShimmerCircle(size: 32),
              const SizedBox(width: 8),
            ],
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: 150 + (isMe ? 0 : 50),
                    height: 16,
                  ),
                  const SizedBox(height: 4),
                  const ShimmerBox(width: 100, height: 14),
                ],
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              const ShimmerCircle(size: 32),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for chat list.
class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 8,
      itemBuilder: (context, index) => const ChatRoomTileSkeleton(),
    );
  }
}

/// Skeleton loader for chat room tile.
class ChatRoomTileSkeleton extends StatelessWidget {
  const ChatRoomTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const ShimmerCircle(size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ShimmerBox(width: 150, height: 16),
                      ShimmerBox(width: 50, height: 12),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const ShimmerBox(width: 200, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for profile screen.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Profile header
          ShimmerLoading(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const ShimmerCircle(size: 100),
                  const SizedBox(height: 16),
                  const ShimmerBox(width: 180, height: 24),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 150, height: 16),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      3,
                      (index) => Column(
                        children: [
                          const ShimmerBox(width: 50, height: 28),
                          const SizedBox(height: 4),
                          const ShimmerBox(width: 60, height: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          // Menu items
          ...List.generate(
            6,
            (index) => ShimmerLoading(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    ShimmerBox(width: 24, height: 24, borderRadius: 6),
                    const SizedBox(width: 16),
                    const ShimmerBox(width: 150, height: 16),
                    const Spacer(),
                    ShimmerBox(width: 20, height: 20, borderRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for notification items.
class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 40, height: 40, borderRadius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: double.infinity, height: 16),
                  const SizedBox(height: 6),
                  const ShimmerBox(width: 200, height: 14),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 80, height: 12),
                ],
              ),
            ),
            ShimmerBox(width: 8, height: 8, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for notification list.
class NotificationListSkeleton extends StatelessWidget {
  const NotificationListSkeleton({
    super.key,
    this.itemCount = 10,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => const NotificationSkeleton(),
    );
  }
}

/// Skeleton loader for earnings screen.
class EarningsSkeleton extends StatelessWidget {
  const EarningsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: ShimmerLoading(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const ShimmerBox(width: 100, height: 16),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 150, height: 40),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        3,
                        (index) => Column(
                          children: [
                            const ShimmerBox(width: 60, height: 24),
                            const SizedBox(height: 4),
                            const ShimmerBox(width: 70, height: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Chart placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerLoading(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Section header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerLoading(
              child: ShimmerBox(width: 150, height: 20),
            ),
          ),
          const SizedBox(height: 12),
          // Transaction list
          ...List.generate(
            5,
            (index) => const TransactionSkeleton(),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for transaction items.
class TransactionSkeleton extends StatelessWidget {
  const TransactionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ShimmerBox(width: 44, height: 44, borderRadius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 150, height: 16),
                  const SizedBox(height: 4),
                  const ShimmerBox(width: 100, height: 12),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const ShimmerBox(width: 80, height: 18),
                const SizedBox(height: 4),
                ShimmerBox(width: 60, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for support tickets.
class TicketSkeleton extends StatelessWidget {
  const TicketSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBox(width: 70, height: 22, borderRadius: 4),
                const Spacer(),
                ShimmerBox(width: 60, height: 22, borderRadius: 11),
              ],
            ),
            const SizedBox(height: 12),
            const ShimmerBox(width: double.infinity, height: 18),
            const SizedBox(height: 8),
            const ShimmerBox(width: 200, height: 14),
            const SizedBox(height: 12),
            Row(
              children: [
                ShimmerBox(width: 80, height: 14),
                const Spacer(),
                ShimmerBox(width: 100, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for doer cards.
class DoerCardSkeleton extends StatelessWidget {
  const DoerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                const ShimmerCircle(size: 56),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: ShimmerBox(width: 14, height: 14, borderRadius: 7),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 150, height: 18),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ShimmerBox(width: 16, height: 16, borderRadius: 2),
                      const SizedBox(width: 4),
                      const ShimmerBox(width: 30, height: 14),
                      const SizedBox(width: 12),
                      const ShimmerBox(width: 80, height: 14),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ShimmerBox(width: 60, height: 24, borderRadius: 12),
                      ),
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
