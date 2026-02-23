import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/payment_service.dart';
import '../../../data/models/wallet_model.dart';
import '../../../providers/profile_provider.dart';
import '../widgets/wallet_offers_carousel.dart';
import '../widgets/wallet_rewards.dart';
import '../widgets/monthly_spend_chart.dart';

/// Wallet screen with curved dome hero, credit card design, and glass styling.
///
/// Features:
/// - Tall curved dome hero with mesh gradient
/// - Credit card widget with balance display
/// - Balance widgets grid (2x2 on mobile)
/// - Glass-styled transaction items
/// - Horizontal scrolling offer pills
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final userName = profileAsync.valueOrNull?.fullName;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(walletProvider);
            ref.invalidate(walletTransactionsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Curved dome hero with credit card
              SliverToBoxAdapter(
                child: walletAsync.when(
                  data: (wallet) => _CurvedDomeHero(
                    wallet: wallet,
                    userName: userName,
                    onTopUp: () => _showTopUpSheet(context, ref),
                    onBack: () => context.pop(),
                  ),
                  loading: () => _CurvedDomeHero(
                    wallet: null,
                    userName: userName,
                    isLoading: true,
                    onBack: () => context.pop(),
                  ),
                  error: (_, _) => _CurvedDomeHero(
                    wallet: null,
                    userName: userName,
                    hasError: true,
                    onBack: () => context.pop(),
                  ),
                ),
              ),

              // Balance widgets grid
              SliverToBoxAdapter(
                child: walletAsync.when(
                  data: (wallet) => _BalanceWidgetsGrid(wallet: wallet),
                  loading: () => const _BalanceWidgetsGrid(wallet: null, isLoading: true),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),

              // Offer pills section (quick categories)
              const SliverToBoxAdapter(
                child: _OfferPillsSection(),
              ),

              // Special Offers Carousel
              const SliverToBoxAdapter(
                child: WalletOffersCarousel(),
              ),

              // Rewards Display
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: WalletRewards(),
                ),
              ),

              // Monthly Spend Chart (collapsible)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: MonthlySpendChart(),
                ),
              ),

              // Transaction history header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment History',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.71),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Transactions list with glass styling
              transactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _EmptyTransactions(),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final transaction = transactions[index];
                          return _GlassTransactionTile(transaction: transaction);
                        },
                        childCount: transactions.length,
                      ),
                    ),
                  );
                },
                loading: () => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
                error: (_, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.error, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load transactions',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom padding for safe area
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTopUpSheet(BuildContext context, WidgetRef ref) {
    final amounts = [100, 500, 1000, 2000, 5000];
    int? selectedAmount;
    final logger = Logger(printer: PrettyPrinter(methodCount: 0));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add Money to Wallet',
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Select an amount to top up your wallet',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: amounts.map((amount) {
                  final isSelected = selectedAmount == amount;
                  return GestureDetector(
                    onTap: () => setState(() => selectedAmount = amount),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.78),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '\u20B9$amount',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAmount != null
                      ? () {
                          Navigator.pop(context);
                          _initiatePayment(
                            context: context,
                            ref: ref,
                            amount: selectedAmount!,
                            logger: logger,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Proceed to Pay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Initiates the payment flow with proper loading and error handling.
  void _initiatePayment({
    required BuildContext context,
    required WidgetRef ref,
    required int amount,
    required Logger logger,
  }) {
    logger.i('[Wallet] Initiating payment for INR $amount');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
              const SizedBox(width: 20),
              const Text('Creating order...'),
            ],
          ),
        ),
      ),
    );

    // Initialize payment service
    final paymentService = PaymentService();

    // Open Razorpay checkout
    paymentService.topUpWallet(
      amountInRupees: amount,
      onSuccess: (result) {
        logger.i('[Wallet] Payment verified: ${result.paymentId}');

        // Close loading dialog if still showing
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Show success message with new balance if available
        String successMessage = 'Payment successful! Wallet updated.';
        if (result.newBalance != null) {
          successMessage = 'Payment successful! New balance: \u20B9${result.newBalance!.toStringAsFixed(2)}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Refresh wallet data to show updated balance immediately
        ref.invalidate(walletProvider);
        ref.invalidate(walletTransactionsProvider);

        // Dispose payment service
        paymentService.dispose();
      },
      onError: (result) {
        logger.e('[Wallet] Payment failed: ${result.errorMessage}');

        // Close loading dialog if still showing
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Determine user-friendly error message
        String errorMessage = result.errorMessage ?? 'Payment failed';
        if (result.errorCode == 'VERIFICATION_ERROR') {
          errorMessage = result.errorMessage ??
            'Payment may have been processed. Please contact support.';
        } else if (result.errorCode == 'INIT_ERROR') {
          errorMessage = 'Could not initiate payment. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 5),
            action: result.errorCode == 'VERIFICATION_ERROR'
              ? SnackBarAction(
                  label: 'Contact Support',
                  textColor: Colors.white,
                  onPressed: () {
                    // TODO: Open support chat or email
                  },
                )
              : null,
          ),
        );

        // Dispose payment service
        paymentService.dispose();
      },
      onExternalWallet: () {
        logger.i('[Wallet] External wallet selected');

        // Close loading dialog if still showing
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Dispose payment service
        paymentService.dispose();
      },
    );

    // Close the loading dialog after checkout opens (with slight delay)
    final navigator = Navigator.of(context);
    Future.delayed(const Duration(seconds: 2), () {
      try {
        if (navigator.canPop()) {
          navigator.pop();
        }
      } catch (e) {
        logger.d('[Wallet] Dialog already closed');
      }
    });
  }
}

/// Custom clipper for curved bottom edge on the dome hero.
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    // Quadratic bezier curve for smooth bottom edge
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

/// Curved dome hero widget with gradient background and credit card.
class _CurvedDomeHero extends StatelessWidget {
  final Wallet? wallet;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onTopUp;
  final VoidCallback? onBack;
  final String? userName;

  const _CurvedDomeHero({
    this.wallet,
    this.isLoading = false,
    this.hasError = false,
    this.onTopUp,
    this.onBack,
    this.userName,
  });

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
              Color(0xFF54442B), // dark brown
              Color(0xFF3A2E1E), // mid dark
              Color(0xFF14110F), // pitch black
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Mesh gradient overlay effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.8, -0.3),
                    radius: 1.5,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.5, 0.8),
                    radius: 1.2,
                    colors: [
                      AppColors.accent.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onBack,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Wallet',
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Credit card widget
                    _CreditCardWidget(
                      wallet: wallet,
                      isLoading: isLoading,
                      userName: userName,
                    ),

                    const SizedBox(height: 14),

                    // Quick action buttons row
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.add_rounded,
                            label: 'Add Balance',
                            gradientColors: const [
                              Color(0xFF10B981), // emerald-500
                              Color(0xFF059669), // emerald-600
                            ],
                            onTap: onTopUp,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.send_rounded,
                            label: 'Send Money',
                            gradientColors: const [
                              Color(0xFF8B5CF6), // violet-500
                              Color(0xFF7C3AED), // violet-600
                            ],
                            onTap: () {
                              // TODO: Implement send money
                            },
                          ),
                        ),
                      ],
                    ),
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

/// Quick action button widget with glassmorphic style.
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.24),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Credit card widget with premium design matching web - assignX branding.
/// Features: EMV chip, card number dots, balance, card holder, valid thru, assignX logo.
class _CreditCardWidget extends StatelessWidget {
  final Wallet? wallet;
  final bool isLoading;
  final String? userName;

  const _CreditCardWidget({
    this.wallet,
    this.isLoading = false,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final validMonth = now.month.toString().padLeft(2, '0');
    final validYear = ((now.year % 100) + 5).toString().padLeft(2, '0');

    return Container(
      height: 220,
      decoration: BoxDecoration(
        // Premium brown gradient matching web
        gradient: const LinearGradient(
          colors: [
            Color(0xFF44403C), // stone-700
            Color(0xFF292524), // stone-800
            Color(0xFF1C1917), // stone-900
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Amber gradient overlay (top right) - matching web
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF59E0B).withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Orange gradient overlay
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF97316).withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Violet gradient overlay (bottom left)
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C3AED).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: EMV Chip and Contactless icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Premium EMV Chip
                      _CreditCardChip(),
                      // Contactless payment icon
                      Icon(
                        Icons.contactless_rounded,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 22,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Card number dots - matching web design
                  Row(
                    children: [
                      // First group of dots
                      _buildCardDots(),
                      const SizedBox(width: 10),
                      _buildCardDots(),
                      const SizedBox(width: 10),
                      _buildCardDots(),
                      const SizedBox(width: 10),
                      // Last 4 digits
                      Text(
                        '4242',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.5),
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Balance section
                  Text(
                    'AVAILABLE BALANCE',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  isLoading
                      ? Container(
                          width: 140,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                      : Text(
                          wallet?.balanceString ?? '\u20B90.00',
                          style: AppTextStyles.headingLarge.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),

                  const Spacer(),

                  // Bottom section: Card holder, Valid thru, and assignX logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Left: Card holder and Valid Thru
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Card holder
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'CARD HOLDER',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                (userName ?? 'User').toUpperCase(),
                                style: AppTextStyles.labelMedium.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          // Valid Thru
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'VALID THRU',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$validMonth/$validYear',
                                style: AppTextStyles.labelMedium.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  letterSpacing: 1,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Right: assignX logo with glow effect
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.10),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Amber dot
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.white, Color(0xFFFEF3C7), Colors.white],
                              ).createShader(bounds),
                              child: Text(
                                'assignX',
                                style: AppTextStyles.headingSmall.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  /// Builds a group of 4 card number dots.
  Widget _buildCardDots() {
    return Row(
      children: List.generate(4, (index) {
        return Container(
          width: 5,
          height: 5,
          margin: EdgeInsets.only(right: index < 3 ? 3 : 0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

/// EMV chip widget for credit card
class _CreditCardChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 34,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD4AF37), // Gold
            Color(0xFFC5A028), // Darker gold
            Color(0xFFD4AF37), // Gold
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Chip pattern (grid lines)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CustomPaint(
                painter: _ChipPatternPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for chip grid pattern
class _ChipPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9D8420).withValues(alpha: 0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (int i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Balance widgets grid (2x2 on mobile) with glassmorphic design.
class _BalanceWidgetsGrid extends StatelessWidget {
  final Wallet? wallet;
  final bool isLoading;

  const _BalanceWidgetsGrid({
    this.wallet,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          // First row: Rewards and Wallet Balance
          Row(
            children: [
              Expanded(
                child: _GlassmorphicStatCard(
                  icon: Icons.emoji_events_rounded,
                  gradientColors: const [Color(0xFFF59E0B), Color(0xFFF97316)],
                  label: 'REWARDS',
                  value: '1,250',
                  isLoading: isLoading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GlassmorphicStatCard(
                  icon: Icons.account_balance_wallet_rounded,
                  gradientColors: const [Color(0xFF3B82F6), Color(0xFF6366F1)],
                  label: 'WALLET BALANCE',
                  value: wallet?.balanceString ?? '\u20B90',
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second row: Monthly Spend (full width)
          _GlassmorphicStatCard(
            icon: Icons.credit_card_rounded,
            gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            label: 'MONTHLY SPEND',
            value: '\u20B9${wallet?.totalDebited.toStringAsFixed(0) ?? '0'}',
            isLoading: isLoading,
            isWide: true,
          ),
        ],
      ),
    );
  }
}

/// Glassmorphic stat card matching user-web design.
class _GlassmorphicStatCard extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final String label;
  final String value;
  final bool isLoading;
  final bool isWide;

  const _GlassmorphicStatCard({
    required this.icon,
    required this.gradientColors,
    required this.label,
    required this.value,
    this.isLoading = false,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    // Card with gradient tint integrated into decoration
    final cardContent = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // Gradient background with subtle color tint
        gradient: LinearGradient(
          colors: [
            Color.lerp(Colors.white, gradientColors.first, 0.08)!,
            Color.lerp(Colors.white, gradientColors.last, 0.03)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isWide
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors.first.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          label,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    isLoading
                        ? Container(
                            width: 60,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.shimmerBase,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : Text(
                            value,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors.first.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    isLoading
                        ? Container(
                            width: 60,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.shimmerBase,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : Text(
                            value,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ],
                ),
    );

    return cardContent;
  }
}

/// Offers section with glassmorphic cards matching user-web.
class _OfferPillsSection extends StatelessWidget {
  const _OfferPillsSection();

  @override
  Widget build(BuildContext context) {
    final offers = [
      _OfferData(
        icon: Icons.wifi_rounded,
        title: 'Internet',
        subtitle: 'Airtel',
        gradientColors: const [Color(0xFF3B82F6), Color(0xFF6366F1)],
      ),
      _OfferData(
        icon: Icons.bolt_rounded,
        title: 'Electricity',
        subtitle: 'Bill Pay',
        gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
      ),
      _OfferData(
        icon: Icons.shopping_bag_rounded,
        title: 'Shopping',
        subtitle: 'Amazon',
        gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      ),
      _OfferData(
        icon: Icons.restaurant_rounded,
        title: 'Food',
        subtitle: 'Cafeteria',
        gradientColors: const [Color(0xFFF59E0B), Color(0xFFF97316)],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Offers',
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: offers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final offer = offers[index];
              return _GlassmorphicOfferCard(offer: offer);
            },
          ),
        ),
      ],
    );
  }
}

/// Glassmorphic offer card widget.
class _GlassmorphicOfferCard extends StatelessWidget {
  final _OfferData offer;

  const _GlassmorphicOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: offer.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: offer.gradientColors.first.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              offer.icon,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  offer.title,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  offer.subtitle,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Offer data model.
class _OfferData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const _OfferData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}

/// Glass-styled transaction tile widget matching user-web design.
class _GlassTransactionTile extends StatelessWidget {
  final WalletTransaction transaction;

  const _GlassTransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type.isCredit;

    // Gradient colors based on transaction type
    final gradientColors = isCredit
        ? const [Color(0xFF10B981), Color(0xFF059669)] // emerald
        : const [Color(0xFF6B7280), Color(0xFF4B5563)]; // gray

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Transaction type icon with gradient
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${transaction.dateString} \u2022 ${transaction.timeString}',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '−'} ${transaction.amountString}',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 14,
                    color: isCredit ? const Color(0xFF10B981) : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (transaction.status != 'completed')
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: transaction.status == 'pending'
                          ? Colors.amber.withValues(alpha: 0.12)
                          : Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      transaction.status == 'pending' ? 'Pending' : 'Failed',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: transaction.status == 'pending'
                            ? Colors.amber.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty transactions state widget matching user-web design.
class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.71),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.06),
                    const Color(0xFF7C3AED).withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.71),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.credit_card_rounded,
                    size: 32,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No transactions yet',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your transaction history will appear here',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
