import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../widgets/profile_hero.dart';
import '../widgets/profile_scorecard.dart';
import '../widgets/profile_tabs.dart';
import '../../../core/translation/translation_extensions.dart';

/// Profile screen showing user profile with hero section, scorecard, and tabs.
///
/// Redesigned to match the doer-web profile page with:
/// - Gradient hero section with avatar, name, badges
/// - Floating scorecard overlapping hero bottom
/// - Tabbed content (Overview, Skills, Payments)
///
/// ## Navigation
/// - Entry: From bottom nav or dashboard
/// - Settings: Navigates to [SettingsScreen]
/// - Edit Profile: Navigates to [EditProfileScreen]
/// - Payment History: Navigates to [PaymentHistoryScreen]
/// - Bank Details: Navigates to [BankDetailsScreen]
/// - Notifications: Navigates to [NotificationsScreen]
///
/// ## State Management
/// Uses [ProfileProvider] for profile data.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LoadingOverlay(
        isLoading: profileState.isLoading,
        child: profile == null
            ? Center(child: Text('Profile not found'.tr(context)))
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(profileProvider.notifier).refresh(),
                edgeOffset: 120,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Hero section with gradient background
                      ProfileHero(
                        profile: profile,
                        onEditProfile: () => context.push('/profile/edit'),
                      ),

                      // Floating scorecard - overlaps hero bottom
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: ProfileScorecard(profile: profile),
                      ),

                      // Tabs section
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: ProfileTabs(
                          profile: profile,
                          tabController: _tabController,
                          paymentHistory: profileState.paymentHistory,
                          bankDetails: profileState.bankDetails,
                        ),
                      ),

                      // Bottom padding for floating nav bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
