library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/professional_data.dart';
import '../../../data/models/professional_type.dart';
import '../../../data/models/user_type.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/dashboard_app_bar.dart';
import '../../business_hub/screens/business_hub_screen.dart';
import '../../campus_connect/screens/campus_connect_screen.dart';
import '../../pro_network/screens/pro_network_screen.dart';

/// Provider for fetching the current user's professional data.
final professionalDataProvider =
    FutureProvider.autoDispose<ProfessionalData?>((ref) async {
  try {
    final response = await ApiClient.get('/profiles/me/professional');
    if (response == null) return null;
    return ProfessionalData.fromJson(response as Map<String, dynamic>);
  } catch (e) {
    return null;
  }
});

/// Determines which community tabs a user can access.
enum ConnectType {
  campusConnect('Campus Connect', Icons.school_outlined),
  proNetwork('Pro Network', Icons.hub_outlined),
  businessHub('Business Hub', Icons.business_center_outlined);

  final String label;
  final IconData icon;

  const ConnectType(this.label, this.icon);
}

/// ConnectHub screen - wrapper that shows the right community based on user role.
///
/// Role mapping:
/// - student: Campus Connect only (no tabs)
/// - professional + jobSeeker: Campus Connect + Pro Network
/// - professional + business: Campus Connect + Business Hub
/// - professional + creator: Campus Connect + Pro Network + Business Hub (all three)
class ConnectHubScreen extends ConsumerStatefulWidget {
  const ConnectHubScreen({super.key});

  @override
  ConsumerState<ConnectHubScreen> createState() => _ConnectHubScreenState();
}

class _ConnectHubScreenState extends ConsumerState<ConnectHubScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<ConnectType> _tabs = [];

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  List<ConnectType> _getTabsForUser(
      UserType? userType, ProfessionalType? professionalType) {
    if (userType == null || userType == UserType.student) {
      return [ConnectType.campusConnect];
    }

    // Professional user
    switch (professionalType) {
      case ProfessionalType.jobSeeker:
        return [ConnectType.campusConnect, ConnectType.proNetwork];
      case ProfessionalType.business:
        return [ConnectType.campusConnect, ConnectType.businessHub];
      case ProfessionalType.creator:
        return [
          ConnectType.campusConnect,
          ConnectType.proNetwork,
          ConnectType.businessHub,
        ];
      case null:
        // Default for professional without specific type
        return [ConnectType.campusConnect, ConnectType.proNetwork];
    }
  }

  void _updateTabs(List<ConnectType> newTabs) {
    if (_tabs.length != newTabs.length ||
        !_tabs.every((t) => newTabs.contains(t))) {
      _tabController?.dispose();
      _tabs = newTabs;
      if (_tabs.length > 1) {
        _tabController = TabController(length: _tabs.length, vsync: this);
      } else {
        _tabController = null;
      }
    }
  }

  Widget _buildScreenForType(ConnectType type) {
    switch (type) {
      case ConnectType.campusConnect:
        return const CampusConnectScreen();
      case ConnectType.proNetwork:
        return const ProNetworkScreen();
      case ConnectType.businessHub:
        return const BusinessHubScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final professionalAsync = ref.watch(professionalDataProvider);

    return profileAsync.when(
      data: (profile) {
        final userType = profile.userType;

        // Get professional type from the professionals table
        ProfessionalType? professionalType;
        if (userType == UserType.professional) {
          professionalType = professionalAsync.valueOrNull?.professionalType;
        }

        final tabs = _getTabsForUser(userType, professionalType);
        _updateTabs(tabs);

        // Single tab - show directly without TabBar, but with DashboardAppBar
        if (_tabs.length == 1) {
          return Column(
            children: [
              const DashboardAppBar(),
              Expanded(child: _buildScreenForType(_tabs.first)),
            ],
          );
        }

        // Multiple tabs - show DashboardAppBar + TabBar + TabBarView
        return Column(
          children: [
            // Dashboard header
            const DashboardAppBar(),

            // Tab bar
            Container(
              color: AppColors.background,
              child: TabBar(
                controller: _tabController,
                isScrollable: _tabs.length > 2,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textTertiary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                dividerColor: AppColors.border.withAlpha(50),
                tabs: _tabs.map((tab) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tab.icon, size: 18),
                        const SizedBox(width: 6),
                        Text(tab.label),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children:
                    _tabs.map((tab) => _buildScreenForType(tab)).toList(),
              ),
            ),
          ],
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) {
        // Default to Campus Connect on error
        return const CampusConnectScreen();
      },
    );
  }
}
