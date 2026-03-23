import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/api/api_client.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/dashboard_app_bar.dart';
import '../widgets/account_upgrade_card.dart';
import '../widgets/app_info_footer.dart';
import '../widgets/avatar_upload_dialog.dart';

/// Sage green accent color for the profile page.
const Color _sageGreen = Color(0xFF6B8F71);

/// Sage green light background tint.
const Color _sageGreenLight = Color(0xFFE8F0E9);

/// Main profile screen matching the user website design.
///
/// Structure:
/// - Profile header (avatar, name, email, joined date, edit button)
/// - Stats grid (Balance, Projects, Referrals, Earned)
/// - Add Money to Wallet banner
/// - Refer & Earn section with referral code
/// - Settings navigation list (clickable rows that open dialogs/pages)
/// - Danger Zone (Delete Account)
/// - App Info Footer
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
            const DashboardAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Profile Header Card
                    _buildProfileHeader(context, ref, profile: profile),
                    const SizedBox(height: 16),

                    // Stats Grid (2x2)
                    walletAsync.when(
                      data: (wallet) => _buildStatsGrid(
                        context,
                        ref,
                        balance: wallet.balance,
                        projects: projectsAsync.valueOrNull ?? 0,
                        referrals:
                            referralAsync.valueOrNull?.totalReferrals ?? 0,
                        earned:
                            referralAsync.valueOrNull?.totalEarnings ?? 0,
                      ),
                      loading: () => _buildStatsGrid(
                        context, ref,
                        balance: 0, projects: 0, referrals: 0, earned: 0,
                      ),
                      error: (e, s) => _buildStatsGrid(
                        context, ref,
                        balance: 0, projects: 0, referrals: 0, earned: 0,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Add Money Banner
                    _buildAddMoneyBanner(context, ref),
                    const SizedBox(height: 16),

                    // Refer & Earn Card
                    referralAsync.when(
                      data: (referral) => _buildReferralCard(
                        context,
                        code: referral.code,
                        userId: profile.id,
                        referrals: referral.totalReferrals,
                        earned: referral.totalEarnings,
                      ),
                      loading: () => _buildReferralCardLoading(context),
                      error: (e, s) => _buildReferralCard(
                        context,
                        code: '',
                        userId: profile.id,
                        referrals: 0,
                        earned: 0,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Settings Navigation List
                    _buildSettingsNavList(context, ref, profile),
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

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  /// Profile header with avatar, name, email, joined date, and edit button.
  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref, {
    required dynamic profile,
  }) {
    final joinDate = DateFormat('MMMM yyyy').format(profile.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          // Avatar with camera overlay
          GestureDetector(
            onTap: () => _showAvatarOptions(context, ref),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: isValidImageUrl(profile.avatarUrl)
                        ? ClipOval(
                            child: Image.network(
                              profile.avatarUrl!,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) =>
                                  _buildInitials(profile.initials),
                            ),
                          )
                        : _buildInitials(profile.initials),
                  ),
                ),
                // Camera icon overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Name with account type badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  profile.fullName ?? 'User',
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildAccountTypeBadge(
                AccountType.fromDbString(
                    profile.userType?.toDbString() ?? 'student'),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Email with verification badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
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

          const SizedBox(height: 4),

          // Joined date
          Text(
            'Joined $joinDate',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),

          const SizedBox(height: 16),

          // Edit Profile button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/profile/edit'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.edit_outlined, size: 16,
                  color: AppColors.textSecondary),
              label: Text(
                'Edit Profile',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Initials avatar fallback.
  Widget _buildInitials(String initials) {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceVariant,
      ),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 40,
          color: AppColors.accent,
        ),
      ),
    );
  }

  /// Account type badge (Student/Professional/Business).
  Widget _buildAccountTypeBadge(AccountType accountType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accountType.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(accountType.icon, size: 12, color: accountType.color),
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

  // ============================================================
  // STATS GRID
  // ============================================================

  /// 2x2 stats grid: Balance, Projects, Referrals, Earned.
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
          Row(
            children: [
              Expanded(
                child: _StatCard(
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
                child: _StatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.primary,
                  iconBgColor: AppColors.surfaceLight,
                  value: projects.toString(),
                  label: 'Projects',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people_outline,
                  iconColor: AppColors.info,
                  iconBgColor: AppColors.infoLight,
                  value: referrals.toString(),
                  label: 'Referrals',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.card_giftcard,
                  iconColor: AppColors.warning,
                  iconBgColor: AppColors.warningLight,
                  value: '\u20B9${earned.toStringAsFixed(0)}',
                  label: 'Earned',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADD MONEY BANNER
  // ============================================================

  Widget _buildAddMoneyBanner(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _sageGreenLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _sageGreen.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _sageGreen.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.add, size: 20, color: _sageGreen),
          ),
          const SizedBox(width: 12),
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
                  const Icon(Icons.arrow_outward, size: 14,
                      color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REFERRAL CARD
  // ============================================================

  /// Generates a display-friendly referral code from the user ID.
  /// Takes the first 8 characters of the user ID and uppercases them.
  String _generateFallbackCode(String userId) {
    if (userId.isEmpty) return 'ASSIGNX';
    // Remove dashes/special chars, take first 8 chars, uppercase
    final cleaned = userId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final segment = cleaned.length >= 8 ? cleaned.substring(0, 8) : cleaned;
    return segment.toUpperCase();
  }

  /// Loading placeholder for the referral card.
  Widget _buildReferralCardLoading(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.card_giftcard, size: 20,
                    color: AppColors.warning),
              ),
              const SizedBox(width: 14),
              Text(
                'Refer & Earn',
                style: AppTextStyles.headingSmall.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(
    BuildContext context, {
    required String code,
    required String userId,
    required int referrals,
    required double earned,
  }) {
    // If the API returns an empty code, generate one from user ID
    final displayCode = code.isNotEmpty ? code : _generateFallbackCode(userId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.card_giftcard, size: 20,
                    color: AppColors.warning),
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
                    displayCode,
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
                    Clipboard.setData(ClipboardData(text: displayCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code copied!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Icon(Icons.copy_outlined, size: 20,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: displayCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code copied!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.copy_outlined, size: 16,
                      color: AppColors.textPrimary),
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
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Share.share(
                      'Use my referral code $displayCode to get 20% off your first project on AssignX!',
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
                      fontSize: 13, fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Referral stats
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
                      const Icon(Icons.people_outline, size: 18,
                          color: AppColors.textTertiary),
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
                          fontSize: 12, color: AppColors.textTertiary,
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
                      const Icon(Icons.account_balance_wallet_outlined,
                          size: 18, color: AppColors.textTertiary),
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
                          fontSize: 12, color: AppColors.textTertiary,
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

  // ============================================================
  // SETTINGS NAVIGATION LIST
  // ============================================================

  /// Settings navigation list matching the user website design.
  /// Simple rows with icon + title + description + chevron.
  Widget _buildSettingsNavList(
      BuildContext context, WidgetRef ref, dynamic profile) {
    final currentType = AccountType.fromDbString(
        profile.userType?.toDbString() ?? 'student');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Settings',
            style: AppTextStyles.headingSmall.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Settings card container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
              children: [
                _SettingsNavRow(
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                  subtitle: 'Name, photo, contact details',
                  onTap: () => context.push('/profile/edit'),
                ),
                const _SettingsDivider(),
                _SettingsNavRow(
                  icon: Icons.school_outlined,
                  title: 'Academic Information',
                  subtitle: 'University and course info',
                  onTap: () => context.push('/profile/edit'),
                ),
                const _SettingsDivider(),
                _SettingsNavRow(
                  icon: Icons.security_outlined,
                  title: 'Security',
                  subtitle: 'Password, 2FA, sessions',
                  onTap: () => context.push('/profile/security'),
                ),
                const _SettingsDivider(),
                _SettingsNavRow(
                  icon: Icons.payment_outlined,
                  title: 'Payment Methods',
                  subtitle: 'Manage your payment options',
                  onTap: () => context.push('/profile/payment-methods'),
                ),
                const _SettingsDivider(),
                // Switch Account Type — opens role toggle dialog
                _SettingsNavRow(
                  icon: Icons.auto_awesome,
                  title: 'Switch Account Type',
                  subtitle: 'Manage your roles (Student, Professional, Business)',
                  onTap: () => _showRoleToggleDialog(context, ref, profile),
                ),
                const _SettingsDivider(),
                _SettingsNavRow(
                  icon: Icons.settings_outlined,
                  title: 'App Settings',
                  subtitle: 'Notifications, theme, language',
                  onTap: () => context.push('/settings'),
                ),
                const _SettingsDivider(),
                _SettingsNavRow(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'FAQ, contact us',
                  onTap: () => context.push('/profile/help'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Danger Zone
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.error.withAlpha(60),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Log Out
                _SettingsNavRow(
                  icon: Icons.logout,
                  title: 'Log Out',
                  subtitle: 'Sign out of your account',
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context, ref),
                ),
                const _SettingsDivider(),
                // Delete Account
                _SettingsNavRow(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete all data',
                  isDestructive: true,
                  onTap: () => _showDeleteAccountDialog(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOGS / ACTIONS
  // ============================================================

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
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
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
                  fontSize: 18, fontWeight: FontWeight.w600,
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
                        horizontal: 24, vertical: 14,
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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

// ============================================================
// PRIVATE WIDGETS
// ============================================================

/// Stat card for the 2x2 stats grid.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                if (onTap != null)
                  const Icon(Icons.arrow_outward, size: 14,
                      color: AppColors.textTertiary),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a dialog for toggling user roles (Student, Professional, Business)
/// matching the user-web's "My Roles" dialog.
void _showRoleToggleDialog(BuildContext context, WidgetRef ref, dynamic profile) {
  showDialog(
    context: context,
    builder: (ctx) => _RoleToggleDialog(profile: profile),
  );
}

class _RoleToggleDialog extends ConsumerStatefulWidget {
  final dynamic profile;
  const _RoleToggleDialog({required this.profile});

  @override
  ConsumerState<_RoleToggleDialog> createState() => _RoleToggleDialogState();
}

class _RoleToggleDialogState extends ConsumerState<_RoleToggleDialog> {
  late Set<String> _activeRoles;
  late String _primaryRole;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    // UserProfile uses userType (a UserType enum), not userRoles
    _primaryRole = p.userType?.toDbString() ?? 'professional';
    _activeRoles = {_primaryRole};
  }

  @override
  Widget build(BuildContext context) {
    const roles = [
      ('student', 'Student', 'Access Campus Connect', Icons.school),
      ('professional', 'Professional', 'Access Job Portal', Icons.work_outline),
      ('business', 'Business', 'Access Business Portal & VC', Icons.business),
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.people_outline, size: 22, color: Color(0xFF765341)),
          const SizedBox(width: 10),
          const Text('My Roles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Toggle portal access for your account',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...roles.map((r) {
            final (role, label, desc, icon) = r;
            final isActive = _activeRoles.contains(role);
            final isPrimary = _primaryRole == role;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF765341).withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: const Color(0xFF765341)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            if (isPrimary) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF765341).withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Primary', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF765341))),
                              ),
                            ],
                          ],
                        ),
                        Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Switch(
                    value: isActive,
                    activeColor: const Color(0xFF765341),
                    onChanged: isPrimary ? null : (enabled) {
                      setState(() {
                        if (enabled) {
                          _activeRoles.add(role);
                        } else {
                          _activeRoles.remove(role);
                        }
                      });
                      // TODO: Sync with API (addUserRole/removeUserRole)
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done', style: TextStyle(color: Color(0xFF765341))),
        ),
      ],
    );
  }
}

/// A single row in the settings navigation list.
class _SettingsNavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsNavRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isDestructive ? AppColors.error : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.errorLight
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
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
            Icon(
              Icons.chevron_right,
              color: isDestructive
                  ? AppColors.error.withAlpha(120)
                  : AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin divider for settings list.
class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: AppColors.border.withAlpha(60),
      ),
    );
  }
}
