import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Data model for promotional offers.
class WalletOffer {
  final IconData icon;
  final String title;
  final int discountPercent;
  final String code;
  final DateTime expiryDate;
  final List<Color> gradientColors;

  const WalletOffer({
    required this.icon,
    required this.title,
    required this.discountPercent,
    required this.code,
    required this.expiryDate,
    required this.gradientColors,
  });

  /// Returns formatted expiry string.
  String get expiryString {
    final now = DateTime.now();
    final diff = expiryDate.difference(now);
    if (diff.inDays > 1) {
      return 'Expires in ${diff.inDays} days';
    } else if (diff.inDays == 1) {
      return 'Expires tomorrow';
    } else if (diff.inHours > 0) {
      return 'Expires in ${diff.inHours}h';
    } else {
      return 'Expires soon';
    }
  }
}

/// Horizontal scrolling carousel of promotional offers with auto-scroll.
///
/// Features:
/// - Glassmorphic card style on dark background
/// - Auto-scrolls every 5 seconds
/// - Manual scroll override with resume after inactivity
/// - "Apply" button with haptic feedback
class WalletOffersCarousel extends StatefulWidget {
  /// Callback when an offer is applied.
  final void Function(WalletOffer offer)? onApplyOffer;

  /// Custom list of offers. If null, uses sample offers.
  final List<WalletOffer>? offers;

  const WalletOffersCarousel({
    super.key,
    this.onApplyOffer,
    this.offers,
  });

  @override
  State<WalletOffersCarousel> createState() => _WalletOffersCarouselState();
}

class _WalletOffersCarouselState extends State<WalletOffersCarousel> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  bool _isUserScrolling = false;

  /// Sample offers for demonstration.
  static final List<WalletOffer> _sampleOffers = [
    WalletOffer(
      icon: Icons.celebration_rounded,
      title: 'First Project Discount',
      discountPercent: 10,
      code: 'FIRST10',
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
    ),
    WalletOffer(
      icon: Icons.support_agent_rounded,
      title: 'Free Consultation',
      discountPercent: 100,
      code: 'CONSULT100',
      expiryDate: DateTime.now().add(const Duration(days: 14)),
      gradientColors: const [Color(0xFF3B82F6), Color(0xFF6366F1)],
    ),
    WalletOffer(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Cashback on Top-up',
      discountPercent: 5,
      code: 'CASH500',
      expiryDate: DateTime.now().add(const Duration(days: 3)),
      gradientColors: const [Color(0xFFF59E0B), Color(0xFFF97316)],
    ),
    WalletOffer(
      icon: Icons.star_rounded,
      title: 'Premium Member Bonus',
      discountPercent: 15,
      code: 'PREMIUM15',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    ),
  ];

  List<WalletOffer> get _offers => widget.offers ?? _sampleOffers;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Starts the auto-scroll timer (every 5 seconds).
  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isUserScrolling && mounted) {
        final nextPage = (_currentPage + 1) % _offers.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Handles user scroll interaction.
  void _onUserScroll(bool isScrolling) {
    _isUserScrolling = isScrolling;
    if (!isScrolling) {
      // Resume auto-scroll after 3 seconds of inactivity
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_isUserScrolling) {
          _startAutoScroll();
        }
      });
    }
  }

  /// Applies an offer with haptic feedback.
  void _applyOffer(WalletOffer offer) {
    HapticFeedback.mediumImpact();

    // Copy code to clipboard
    Clipboard.setData(ClipboardData(text: offer.code));

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code "${offer.code}" copied to clipboard!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    widget.onApplyOffer?.call(offer);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Special Offers',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // Page indicator dots
              Row(
                children: List.generate(
                  _offers.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 4),
                    width: _currentPage == index ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Carousel
        SizedBox(
          height: 160,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _onUserScroll(true);
              } else if (notification is ScrollEndNotification) {
                _onUserScroll(false);
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _offers.length,
              itemBuilder: (context, index) {
                return _OfferCard(
                  offer: _offers[index],
                  onApply: () => _applyOffer(_offers[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Individual offer card with glassmorphic design.
class _OfferCard extends StatelessWidget {
  final WalletOffer offer;
  final VoidCallback onApply;

  const _OfferCard({
    required this.offer,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        // Glassmorphic dark background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D2620).withValues(alpha: 0.95),
            const Color(0xFF1C1815).withValues(alpha: 0.98),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative gradient orb
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    offer.gradientColors.first.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left side - Icon and discount
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with gradient background
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: offer.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: offer.gradientColors.first.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        offer.icon,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Discount badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: offer.gradientColors.first.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: offer.gradientColors.first.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${offer.discountPercent}% OFF',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: offer.gradientColors.first,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Right side - Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        offer.title,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Code display
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              offer.code,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontFamily: 'monospace',
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.copy_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Expiry and apply button row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Expiry text
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 12,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                offer.expiryString,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          // Apply button
                          GestureDetector(
                            onTap: onApply,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: offer.gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: offer.gradientColors.first.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Apply',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
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
        ],
      ),
    );
  }
}
