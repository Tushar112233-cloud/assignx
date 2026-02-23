import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_text_styles.dart';
import '../../providers/home_provider.dart';
import '../../providers/profile_provider.dart';

/// Unified dashboard app bar used across all main shell pages.
///
/// Transparent header that blends with background:
/// - Star icon + "AssignX" branding
/// - Wallet balance pill
/// - Notification bell with badge
///
/// Consistent design across Home, Projects, Campus Connect, etc.
class DashboardAppBar extends ConsumerWidget {
  const DashboardAppBar({super.key});

  // Light theme colors (transparent header matching background)
  static const Color _backgroundColor = Colors.transparent;
  static const Color _textColor = Color(0xFF1A1A1A); // Dark text
  static const Color _iconColor = Color(0xFF1A1A1A); // Dark icons
  static const Color _inactiveColor = Color(0xFF6B6B6B); // Gray
  static const Color _pillBackground = Color(0xFFF5F0EB); // Light brown/cream

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Container(
      color: _backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Left side: App logo + name
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo image
                  Image.asset(
                    'assets/images/logo.png',
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 8),
                  // App name
                  Text(
                    'AssignX',
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Right side: Wallet pill + Notification bell
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wallet pill
                  wallet.when(
                    data: (w) => _WalletPill(
                      balance: w.formattedBalance,
                      onTap: () => context.push('/wallet'),
                    ),
                    loading: () => _WalletPill(
                      balance: '...',
                      onTap: () {},
                    ),
                    error: (_, __) => _WalletPill(
                      balance: '\u20B90',
                      onTap: () => context.push('/wallet'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Notification bell
                  _NotificationBell(
                    count: unreadCount.valueOrNull ?? 0,
                    onTap: () => context.push('/notifications'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletPill extends StatelessWidget {
  final String balance;
  final VoidCallback onTap;

  static const Color _pillBackground = Color(0xFFF5F0EB); // Light cream
  static const Color _textColor = Color(0xFF1A1A1A); // Dark text

  const _WalletPill({
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _pillBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: _textColor,
              ),
              const SizedBox(width: 6),
              Text(
                balance,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  static const Color _iconColor = Color(0xFF6B6B6B); // Gray when inactive
  static const Color _activeIconColor = Color(0xFF1A1A1A); // Dark when active
  static const Color _badgeColor = Color(0xFFDC352F); // Error red

  const _NotificationBell({
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Bell icon - gray by default, dark if has notifications
              Icon(
                Icons.notifications_none_outlined,
                size: 26,
                color: count > 0 ? _activeIconColor : _iconColor,
              ),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: _badgeColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
