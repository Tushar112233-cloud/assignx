import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Skeleton loader for the Wallet screen.
///
/// Matches the layout of WalletScreen with:
/// - Curved dome hero with credit card
/// - Balance widgets grid (2x2)
/// - Offers section (horizontal scroll)
/// - Transaction list
class WalletSkeleton extends StatelessWidget {
  const WalletSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Curved dome hero skeleton
          const _CurvedDomeHeroSkeleton(),

          // Balance widgets grid skeleton
          const _BalanceWidgetsGridSkeleton(),

          // Offers section skeleton
          const _OffersSectionSkeleton(),

          // Transaction history header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoader(
                  height: 16,
                  width: 120,
                  borderRadius: AppSpacing.radiusSm,
                ),
                SkeletonLoader(
                  height: 38,
                  width: 38,
                  borderRadius: AppSpacing.radiusMd,
                ),
              ],
            ),
          ),

          // Transaction list skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(5, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index < 4 ? 8 : 0),
                  child: const _TransactionTileSkeleton(),
                );
              }),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

/// Curved dome hero skeleton with credit card.
class _CurvedDomeHeroSkeleton extends StatelessWidget {
  const _CurvedDomeHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return ClipPath(
      clipper: _CurvedBottomClipper(),
      child: Container(
        height: 440 + topPadding,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF54442B),
              Color(0xFF3A2E1E),
              Color(0xFF14110F),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and title row
                Row(
                  children: [
                    SkeletonLoader(
                      height: 38,
                      width: 38,
                      borderRadius: 10,
                      baseColor: Colors.white.withAlpha(20),
                      highlightColor: Colors.white.withAlpha(40),
                    ),
                    const SizedBox(width: 16),
                    SkeletonLoader(
                      height: 20,
                      width: 60,
                      borderRadius: AppSpacing.radiusSm,
                      baseColor: Colors.white.withAlpha(20),
                      highlightColor: Colors.white.withAlpha(40),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Credit card skeleton
                const _CreditCardSkeleton(),

                const SizedBox(height: 14),

                // Quick action buttons row
                Row(
                  children: [
                    Expanded(child: _QuickActionButtonSkeleton()),
                    const SizedBox(width: 12),
                    Expanded(child: _QuickActionButtonSkeleton()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Credit card skeleton widget.
class _CreditCardSkeleton extends StatelessWidget {
  const _CreditCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF44403C),
            Color(0xFF292524),
            Color(0xFF1C1917),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF292524).withAlpha(100),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(
                height: 34,
                width: 34,
                borderRadius: 12,
                baseColor: Colors.white.withAlpha(15),
                highlightColor: Colors.white.withAlpha(30),
              ),
              SkeletonLoader(
                height: 24,
                width: 100,
                borderRadius: 16,
                baseColor: Colors.white.withAlpha(15),
                highlightColor: Colors.white.withAlpha(30),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Balance label
          SkeletonLoader(
            height: 12,
            width: 100,
            borderRadius: AppSpacing.radiusXs,
            baseColor: Colors.white.withAlpha(10),
            highlightColor: Colors.white.withAlpha(25),
          ),

          const SizedBox(height: 6),

          // Balance amount
          SkeletonLoader(
            height: 32,
            width: 140,
            borderRadius: AppSpacing.radiusSm,
            baseColor: Colors.white.withAlpha(15),
            highlightColor: Colors.white.withAlpha(30),
          ),

          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withAlpha(26),
          ),

          const SizedBox(height: 12),

          // Footer row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(
                    height: 10,
                    width: 60,
                    borderRadius: AppSpacing.radiusXs,
                    baseColor: Colors.white.withAlpha(10),
                    highlightColor: Colors.white.withAlpha(25),
                  ),
                  const SizedBox(height: 4),
                  SkeletonLoader(
                    height: 14,
                    width: 100,
                    borderRadius: AppSpacing.radiusXs,
                    baseColor: Colors.white.withAlpha(15),
                    highlightColor: Colors.white.withAlpha(30),
                  ),
                ],
              ),
              SkeletonLoader(
                height: 28,
                width: 28,
                borderRadius: AppSpacing.radiusSm,
                baseColor: Colors.white.withAlpha(15),
                highlightColor: Colors.white.withAlpha(30),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Quick action button skeleton.
class _QuickActionButtonSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withAlpha(20),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonLoader(
            height: 32,
            width: 32,
            borderRadius: 10,
            baseColor: Colors.white.withAlpha(20),
            highlightColor: Colors.white.withAlpha(40),
          ),
          const SizedBox(width: 8),
          SkeletonLoader(
            height: 12,
            width: 70,
            borderRadius: AppSpacing.radiusXs,
            baseColor: Colors.white.withAlpha(20),
            highlightColor: Colors.white.withAlpha(40),
          ),
        ],
      ),
    );
  }
}

/// Balance widgets grid skeleton (2x2 + full width).
class _BalanceWidgetsGridSkeleton extends StatelessWidget {
  const _BalanceWidgetsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          // First row: 2 cards
          Row(
            children: [
              Expanded(child: _StatCardSkeleton()),
              const SizedBox(width: 12),
              Expanded(child: _StatCardSkeleton()),
            ],
          ),
          const SizedBox(height: 12),
          // Second row: full width card
          _StatCardSkeleton(isWide: true),
        ],
      ),
    );
  }
}

/// Stat card skeleton.
class _StatCardSkeleton extends StatelessWidget {
  final bool isWide;

  const _StatCardSkeleton({this.isWide = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(180),
          width: 1,
        ),
      ),
      child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SkeletonLoader(
                      height: 32,
                      width: 32,
                      borderRadius: 10,
                    ),
                    const SizedBox(width: 12),
                    SkeletonLoader(
                      height: 12,
                      width: 100,
                      borderRadius: AppSpacing.radiusXs,
                    ),
                  ],
                ),
                SkeletonLoader(
                  height: 22,
                  width: 70,
                  borderRadius: AppSpacing.radiusSm,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  height: 32,
                  width: 32,
                  borderRadius: 10,
                ),
                const SizedBox(height: 10),
                SkeletonLoader(
                  height: 10,
                  width: 60,
                  borderRadius: AppSpacing.radiusXs,
                ),
                const SizedBox(height: 4),
                SkeletonLoader(
                  height: 18,
                  width: 80,
                  borderRadius: AppSpacing.radiusSm,
                ),
              ],
            ),
    );
  }
}

/// Offers section skeleton.
class _OffersSectionSkeleton extends StatelessWidget {
  const _OffersSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: SkeletonLoader(
            height: 16,
            width: 60,
            borderRadius: AppSpacing.radiusSm,
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => const _OfferCardSkeleton(),
          ),
        ),
      ],
    );
  }
}

/// Offer card skeleton.
class _OfferCardSkeleton extends StatelessWidget {
  const _OfferCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha(180),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonLoader(
            height: 44,
            width: 44,
            borderRadius: 14,
          ),
          const SizedBox(height: 12),
          SkeletonLoader(
            height: 14,
            width: 80,
            borderRadius: AppSpacing.radiusXs,
          ),
          const SizedBox(height: 4),
          SkeletonLoader(
            height: 10,
            width: 50,
            borderRadius: AppSpacing.radiusXs,
          ),
        ],
      ),
    );
  }
}

/// Transaction tile skeleton.
class _TransactionTileSkeleton extends StatelessWidget {
  const _TransactionTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          SkeletonLoader(
            height: 40,
            width: 40,
            borderRadius: 14,
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  height: 14,
                  width: 140,
                  borderRadius: AppSpacing.radiusSm,
                ),
                const SizedBox(height: 4),
                SkeletonLoader(
                  height: 11,
                  width: 100,
                  borderRadius: AppSpacing.radiusXs,
                ),
              ],
            ),
          ),
          // Amount
          SkeletonLoader(
            height: 14,
            width: 60,
            borderRadius: AppSpacing.radiusSm,
          ),
        ],
      ),
    );
  }
}

/// Custom clipper for curved bottom edge.
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
