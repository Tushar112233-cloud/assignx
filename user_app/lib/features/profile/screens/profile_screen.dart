import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/api/api_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/dashboard_app_bar.dart';
import '../../../shared/widgets/glass_container.dart';
import '../widgets/account_upgrade_card.dart';
import '../widgets/app_info_footer.dart';
import '../widgets/avatar_upload_dialog.dart';
import '../widgets/preferences_section.dart';
import '../widgets/subscription_card.dart';

/// Sage green accent color for the profile page.
const Color _sageGreen = Color(0xFF6B8F71);

/// Sage green light background tint.
const Color _sageGreenLight = Color(0xFFE8F0E9);

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
      backgroundColor: AppColors.background,
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

                    // Stats Grid (2x2)
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
                      error: (e, s) => _buildStatsGrid(
                        context,
                        ref,
                        balance: 0,
                        projects: 0,
                        referrals: 0,
                        earned: 0,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Account Role Card
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
                      error: (e, s) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 16),

                    // Preferences Section
                    const PreferencesSection(),

                    const SizedBox(height: 24),

                    // Settings Section
                    _buildSettingsSection(context, ref, profile),

                    const SizedBox(height: 24),

                    // App Info Footer
                    const AppInfoFooter(),
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
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
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

  /// Builds the main profile card with gradient-bordered avatar, name, and edit button.
  Widget _buildProfileCard(
    BuildContext context,
    WidgetRef ref, {
    required dynamic profile,
  }) {
    final joinDate = DateFormat('MMMM yyyy').format(profile.createdAt);

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      elevation: 2,
      child: Column(
        children: [
          // Avatar with gradient border and camera overlay
          GestureDetector(
            onTap: () => _showAvatarOptions(context, ref),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient border ring
                Container(
                  width: 114,
                  height: 114,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _sageGreen,
                        AppColors.primary,
                        AppColors.accent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: profile.avatarUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  profile.avatarUrl!,
                                  width: 104,
                                  height: 104,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) =>
                                      _buildInitials(profile.initials),
                                ),
                              )
                            : _buildInitials(profile.initials),
                      ),
                    ),
                  ),
                ),
                // Camera icon overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _sageGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _sageGreen.withAlpha(60),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 14,
                        color: Colors.white,
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
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Account type badge (Student/Professional/Business)
              _buildAccountTypeBadge(
                AccountType.fromDbString(
                    profile.userType?.toDbString() ?? 'student'),
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
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  profile.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Email verification badge (OAuth users are verified)
              if (profile.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(
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
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'Joined $joinDate',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Edit Profile button
          OutlinedButton(
            onPressed: () => context.push('/profile/edit'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _sageGreen.withAlpha(120),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: _sageGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Edit Profile',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _sageGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds initials avatar widget with a warm gradient background
  /// and a person icon for a polished default look.
  Widget _buildInitials(String initials) {
    return Center(
      child: Container(
        width: 104,
        height: 104,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5EDE4), // warm cream
              Color(0xFFE8DDD1), // light peach
            ],
          ),
        ),
        child: const Icon(
          Icons.person_rounded,
          size: 48,
          color: AppColors.accent, // warm brown from palette
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

  /// Builds the 2x2 bento-style stats grid with glass cards.
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
                  iconColor: _sageGreen,
                  iconBgColor: _sageGreenLight,
                  value: '\u20B9${balance.toStringAsFixed(0)}',
                  label: 'Balance',
                  onTap: () => context.push('/wallet'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.primary,
                  iconBgColor: AppColors.surfaceLight,
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
                  iconColor: AppColors.accent,
                  iconBgColor: AppColors.surfaceVariant,
                  value: referrals.toString(),
                  label: 'Referrals',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.card_giftcard,
                  iconColor: AppColors.warning,
                  iconBgColor: AppColors.warningLight,
                  value: '\u20B9${earned.toStringAsFixed(0)}',
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

  /// Builds a single bento-style stat card with glass effect.
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      elevation: 1,
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
                color: AppColors.textTertiary,
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
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          // Label
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Add Money to Wallet banner with sage green accent.
  Widget _buildAddMoneyBanner(BuildContext context, WidgetRef ref) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      elevation: 1,
      backgroundColor: _sageGreenLight,
      borderColor: _sageGreen.withAlpha(40),
      child: Row(
        children: [
          // Plus icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _sageGreen.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.add,
              size: 20,
              color: _sageGreen,
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Top-up for quick payments',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    color: _sageGreen,
                  ),
                ),
              ],
            ),
          ),
          // Top Up button
          GestureDetector(
            onTap: () => _showTopUpSheet(context, ref),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.darkBrown,
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

  /// Builds the Refer & Earn card with glass styling.
  Widget _buildReferralCard(
    BuildContext context, {
    required String code,
    required int referrals,
    required double earned,
  }) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      elevation: 2,
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
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  size: 20,
                  color: AppColors.warning,
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Earn \u20B950 per referral',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
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
              color: AppColors.surfaceVariant,
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
                      color: AppColors.textPrimary,
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
                    color: AppColors.textSecondary,
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
                      color: AppColors.border,
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
                    color: AppColors.textPrimary,
                  ),
                  label: Text(
                    'Copy Code',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
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
                    backgroundColor: AppColors.darkBrown,
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
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        referrals.toString(),
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Referrals',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textTertiary,
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
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\u20B9${earned.toStringAsFixed(0)}',
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Earned',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textTertiary,
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

  /// Builds the settings section with glass card items.
  Widget _buildSettingsSection(
      BuildContext context, WidgetRef ref, dynamic profile) {
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
              color: AppColors.textPrimary,
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
          // Switch Account Type - uses actual account role from profile
          _buildUpgradeSettingsItem(
            context: context,
            currentType: AccountType.fromDbString(
                profile.userType?.toDbString() ?? 'student'),
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
          // My Roles
          _buildSettingsItem(
            icon: Icons.badge_outlined,
            title: 'My Roles',
            subtitle: 'Manage your portal access',
            onTap: () => context.push('/settings'),
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
          const SizedBox(height: 10),
          // Deactivate Account
          _buildSettingsItem(
            icon: Icons.pause_circle_outline,
            title: 'Deactivate Account',
            subtitle: 'Temporarily disable your account',
            onTap: () => _showDeactivateDialog(context, ref),
            isDestructive: true,
          ),
          const SizedBox(height: 10),
          // Delete Account
          _buildSettingsItem(
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            subtitle: 'Permanently delete all data',
            onTap: () => _showDeleteAccountDialog(context, ref),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  /// Builds a single settings item with glass card styling.
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final iconColor =
        isDestructive ? AppColors.error : AppColors.textTertiary;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      elevation: 1,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppColors.errorLight
                  : AppColors.surfaceVariant,
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
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Builds the switch account type settings item with special styling.
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
      onTap: () =>
          context.push('/profile/upgrade?type=${currentType.toDbString()}'),
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
              decoration: const BoxDecoration(
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
                    'Switch Account Type',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Switch to ${nextTier.displayName} role',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: nextTier.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Switch',
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
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        '\u20B9$amount',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
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
                            const SnackBar(
                                content: Text('Opening payment...')),
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
              await ref.read(authStateProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              'Log Out',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Deactivate Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deactivating your account will:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            const Text('- Hide your profile from other users'),
            const Text('- Pause all active projects'),
            const SizedBox(height: 8),
            Text(
              'You can reactivate anytime by logging back in.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ApiClient.post('/users/me/deactivate', {});
                await ref.read(authStateProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: ${e.toString()}')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This action is permanent and irreversible. All your data will be deleted.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Type DELETE to confirm',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  hintStyle: TextStyle(
                    fontFamily: 'monospace',
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontFamily: 'monospace'),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: confirmController.text == 'DELETE'
                  ? () async {
                      Navigator.pop(dialogContext);
                      try {
                        await ApiClient.post('/users/me/delete', {});
                        await ref
                            .read(authStateProvider.notifier)
                            .signOut();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Account deletion request submitted'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          context.go('/login');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Failed: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
