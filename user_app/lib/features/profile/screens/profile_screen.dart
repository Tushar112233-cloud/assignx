import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/dashboard_app_bar.dart';
import '../widgets/account_upgrade_card.dart';
import '../widgets/avatar_upload_dialog.dart';
import '../widgets/preferences_section.dart';
import '../widgets/subscription_card.dart';

/// Profile screen colors matching the design specification.
class _ProfileColors {
  // Note: scaffoldBackground removed - now using transparent for gradient from MainShell
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B6B6B);
  static const mutedText = Color(0xFF8B8B8B);
  static const avatarBackground = Color(0xFFF5F0E8);
  static const avatarInitials = Color(0xFF5D4E37);
  static const greenIconBg = Color(0xFFE8F5E9);
  static const yellowIconBg = Color(0xFFFFF8E1);
  static const creamIconBg = Color(0xFFF5F0E8);
  static const tealBannerBg = Color(0xFFE0F2F1);
  static const darkButton = Color(0xFF3D3228);
  static const badgeBackground = Color(0xFFF0F0F0);
  static const borderColor = Color(0xFFD0D0D0);
  static const tealAccent = Color(0xFF26A69A);
}

/// Main profile screen with hero section, stats, and settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final walletAsync = ref.watch(walletProvider);
    final projectsAsync = ref.watch(completedProjectsCountProvider);
    final referralAsync = ref.watch(referralProvider);

    return Scaffold(
      // Transparent to show SubtleGradientScaffold from MainShell
      backgroundColor: Colors.transparent,
      body: profileAsync.when(
        data: (profile) => Column(
          children: [
            // Unified Dashboard App Bar (dark theme)
            const DashboardAppBar(),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Profile Card
                    _buildProfileCard(
                      context,
                      ref,
                      profile: profile,
                    ),

                    const SizedBox(height: 16),

                    // Stats Grid (2×2)
                    walletAsync.when(
                      data: (wallet) => _buildStatsGrid(
                        context,
                        ref,
                        balance: wallet.balance,
                        projects: projectsAsync.valueOrNull ?? 0,
                        referrals: referralAsync.valueOrNull?.totalReferrals ?? 0,
                        earned: referralAsync.valueOrNull?.totalEarnings ?? 0,
                      ),
                      loading: () => _buildStatsGrid(
                        context,
                        ref,
                        balance: 0,
                        projects: 0,
                        referrals: 0,
                        earned: 0,
                      ),
                      error: (_, __) => _buildStatsGrid(
                        context,
                        ref,
                        balance: 0,
                        projects: 0,
                        referrals: 0,
                        earned: 0,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subscription Card
                    const SubscriptionCard(),

                    const SizedBox(height: 16),

                    // Add Money Banner
                    _buildAddMoneyBanner(context, ref),

                    const SizedBox(height: 16),

                    // Refer & Earn Card
                    referralAsync.when(
                      data: (referral) => _buildReferralCard(
                        context,
                        code: referral.code,
                        referrals: referral.totalReferrals,
                        earned: referral.totalEarnings,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 16),

                    // Preferences Section
                    const PreferencesSection(),

                    const SizedBox(height: 24),

                    // Settings Section
                    _buildSettingsSection(context, ref, profile),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Failed to load profile'),
              TextButton(
                onPressed: () => ref.invalidate(userProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the transparent header bar with AssignX title and notification icon.
  Widget _buildHeaderBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AssignX',
            style: AppTextStyles.headingMedium.copyWith(
              color: _ProfileColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(
              Icons.notifications_outlined,
              color: _ProfileColors.primaryText,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main profile card with avatar, name, and edit button.
  Widget _buildProfileCard(
    BuildContext context,
    WidgetRef ref, {
    required dynamic profile,
  }) {
    final joinDate = DateFormat('MMMM yyyy').format(profile.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _ProfileColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with camera overlay
          GestureDetector(
            onTap: () => _showAvatarOptions(context, ref),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main avatar
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: _ProfileColors.avatarBackground,
                    shape: BoxShape.circle,
                  ),
                  child: profile.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            profile.avatarUrl!,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildInitials(profile.initials),
                          ),
                        )
                      : _buildInitials(profile.initials),
                ),
                // Camera icon overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _ProfileColors.borderColor.withAlpha(100),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 14,
                        color: _ProfileColors.secondaryText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Name row with account type badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  (profile.fullName ?? 'User').toUpperCase(),
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _ProfileColors.primaryText,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Account type badge (Student/Professional/Business)
              _buildAccountTypeBadge(
                AccountType.fromDbString(profile.userType?.toDbString() ?? 'student'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Email row with verification badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 16,
                color: _ProfileColors.secondaryText,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  profile.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    color: _ProfileColors.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Email verification badge (OAuth users are verified)
              if (profile.isVerified) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.success,
                ),
              ],
            ],
          ),

          const SizedBox(height: 6),

          // Join date row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: _ProfileColors.mutedText,
              ),
              const SizedBox(width: 6),
              Text(
                'Joined $joinDate',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: _ProfileColors.mutedText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Edit Profile button
          OutlinedButton(
            onPressed: () => context.push('/profile/edit'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: _ProfileColors.borderColor,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: _ProfileColors.primaryText,
                ),
                const SizedBox(width: 8),
                Text(
                  'Edit Profile',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _ProfileColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds initials avatar widget.
  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.displayMedium.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: _ProfileColors.avatarInitials,
        ),
      ),
    );
  }

  /// Builds the account type badge matching web design.
  /// Shows Student (blue), Professional (purple), or Business (amber) badge.
  Widget _buildAccountTypeBadge(AccountType accountType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accountType.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accountType.color.withAlpha(50),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            accountType.icon,
            size: 12,
            color: accountType.color,
          ),
          const SizedBox(width: 4),
          Text(
            accountType.displayName,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: accountType.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the 2×2 stats grid.
  Widget _buildStatsGrid(
    BuildContext context,
    WidgetRef ref, {
    required double balance,
    required int projects,
    required int referrals,
    required double earned,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Top row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AppColors.success,
                  iconBgColor: _ProfileColors.greenIconBg,
                  value: '₹${balance.toStringAsFixed(0)}',
                  label: 'Balance',
                  onTap: () => context.push('/wallet'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.success,
                  iconBgColor: _ProfileColors.greenIconBg,
                  value: projects.toString(),
                  label: 'Projects',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_outline,
                  iconColor: _ProfileColors.avatarInitials,
                  iconBgColor: _ProfileColors.creamIconBg,
                  value: referrals.toString(),
                  label: 'Referrals',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.card_giftcard,
                  iconColor: const Color(0xFFF5A623),
                  iconBgColor: _ProfileColors.yellowIconBg,
                  value: '₹${earned.toStringAsFixed(0)}',
                  label: 'Earned',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single stat card for the grid.
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _ProfileColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with icon and arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
                const Icon(
                  Icons.arrow_outward,
                  size: 14,
                  color: _ProfileColors.mutedText,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Value
            Text(
              value,
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _ProfileColors.primaryText,
              ),
            ),
            const SizedBox(height: 2),
            // Label
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: _ProfileColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Add Money to Wallet banner.
  Widget _buildAddMoneyBanner(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ProfileColors.tealBannerBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Plus icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _ProfileColors.tealAccent.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add,
              size: 20,
              color: _ProfileColors.tealAccent,
            ),
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Money to Wallet',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _ProfileColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Top-up for quick payments',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    color: _ProfileColors.tealAccent,
                  ),
                ),
              ],
            ),
          ),
          // Top Up button
          GestureDetector(
            onTap: () => _showTopUpSheet(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _ProfileColors.darkButton,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Top Up',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_outward,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Refer & Earn card.
  Widget _buildReferralCard(
    BuildContext context, {
    required String code,
    required int referrals,
    required double earned,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ProfileColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _ProfileColors.yellowIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  size: 20,
                  color: Color(0xFFF5A623),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refer & Earn',
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _ProfileColors.primaryText,
                      ),
                    ),
                    Text(
                      'Earn ₹50 per referral',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 13,
                        color: _ProfileColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Referral code display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    code,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _ProfileColors.primaryText,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code copied!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.copy_outlined,
                    size: 20,
                    color: _ProfileColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action buttons row
          Row(
            children: [
              // Copy Code button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code copied!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: _ProfileColors.borderColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(
                    Icons.copy_outlined,
                    size: 16,
                    color: _ProfileColors.primaryText,
                  ),
                  label: Text(
                    'Copy Code',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _ProfileColors.primaryText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Share button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Share.share(
                      'Use my referral code $code to get 20% off your first project on AssignX!',
                      subject: 'Join AssignX',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ProfileColors.darkButton,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.share, size: 16),
                  label: Text(
                    'Share',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Referral stats row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 18,
                        color: _ProfileColors.mutedText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        referrals.toString(),
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _ProfileColors.primaryText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Referrals',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: _ProfileColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18,
                        color: _ProfileColors.mutedText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${earned.toStringAsFixed(0)}',
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _ProfileColors.primaryText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Earned',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: _ProfileColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the settings section.
  Widget _buildSettingsSection(BuildContext context, WidgetRef ref, dynamic profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: AppTextStyles.headingSmall.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _ProfileColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          // Personal Information
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: 'Personal Information',
            subtitle: 'Name, photo, contact',
            onTap: () => context.push('/profile/edit'),
          ),
          const SizedBox(height: 10),
          // Academic Details
          _buildSettingsItem(
            icon: Icons.school_outlined,
            title: 'Academic Details',
            subtitle: 'University and course info',
            onTap: () => context.push('/profile/edit'),
          ),
          const SizedBox(height: 10),
          // Upgrade Account - uses actual account type from profile
          _buildUpgradeSettingsItem(
            context: context,
            currentType: AccountType.fromDbString(profile.userType?.toDbString() ?? 'student'),
          ),
          const SizedBox(height: 10),
          // Security Settings
          _buildSettingsItem(
            icon: Icons.security_outlined,
            title: 'Security',
            subtitle: 'Password, 2FA, sessions',
            onTap: () => context.push('/profile/security'),
          ),
          const SizedBox(height: 10),
          // App Settings
          _buildSettingsItem(
            icon: Icons.settings_outlined,
            title: 'App Settings',
            subtitle: 'Notifications, theme, language',
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 24),
          // Additional settings
          _buildSettingsItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'FAQ, Contact us',
            onTap: () => context.push('/profile/help'),
          ),
          const SizedBox(height: 10),
          _buildSettingsItem(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            subtitle: 'Read our terms',
            onTap: () => _launchUrl('https://assignx.in/terms'),
          ),
          const SizedBox(height: 10),
          _buildSettingsItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Your data privacy',
            onTap: () => _launchUrl('https://assignx.in/privacy'),
          ),
          const SizedBox(height: 24),
          // Logout
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Log Out',
            subtitle: 'Sign out of your account',
            onTap: () => _showLogoutDialog(context, ref),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  /// Builds a single settings item.
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final iconColor = isDestructive ? AppColors.error : _ProfileColors.mutedText;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _ProfileColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.errorLight
                    : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDestructive
                          ? AppColors.error
                          : _ProfileColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: _ProfileColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: _ProfileColors.mutedText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the upgrade account settings item with special styling.
  Widget _buildUpgradeSettingsItem({
    required BuildContext context,
    required AccountType currentType,
  }) {
    // Don't show if user is already at highest tier
    if (currentType.canUpgradeTo.isEmpty) {
      return const SizedBox.shrink();
    }

    final nextTier = currentType.canUpgradeTo.first;

    return GestureDetector(
      onTap: () => context.push('/profile/upgrade?type=${currentType.toDbString()}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              nextTier.backgroundColor,
              nextTier.backgroundColor.withAlpha(180),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: nextTier.color.withAlpha(60),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 20,
                color: nextTier.color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade Account',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _ProfileColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Unlock ${nextTier.displayName} features',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: _ProfileColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: nextTier.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Upgrade',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarOptions(BuildContext context, WidgetRef ref) async {
    final result = await showAvatarOptionsSheet(context);
    if (result == true) {
      ref.invalidate(userProfileProvider);
    }
  }

  void _showTopUpSheet(BuildContext context, WidgetRef ref) {
    final amounts = [100, 500, 1000, 2000, 5000];
    int? selectedAmount;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add Money to Wallet',
                style: AppTextStyles.headingSmall.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: amounts.map((amount) {
                  final isSelected = selectedAmount == amount;
                  return GestureDetector(
                    onTap: () => setState(() => selectedAmount = amount),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        '₹$amount',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAmount != null
                      ? () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening payment...')),
                          );
                        }
                      : null,
                  child: const Text('Proceed to Pay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final repository = ref.read(profileRepositoryProvider);
              await repository.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              'Log Out',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
