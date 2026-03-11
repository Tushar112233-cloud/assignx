library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/dashboard_app_bar.dart';
import '../../business_hub/screens/business_hub_screen.dart';
import '../../campus_connect/screens/campus_connect_screen.dart';
import '../../pro_network/screens/pro_network_screen.dart';
import '../../profile/widgets/subscription_card.dart';

/// Maps PortalRole (from subscription toggles) to a connect hub tab.
enum ConnectType {
  campusConnect('Campus Connect', Icons.school_outlined),
  proNetwork('Pro Network', Icons.hub_outlined),
  businessHub('Business Hub', Icons.business_center_outlined);

  final String label;
  final IconData icon;

  const ConnectType(this.label, this.icon);
}

ConnectType _roleToTab(PortalRole role) => switch (role) {
      PortalRole.student => ConnectType.campusConnect,
      PortalRole.professional => ConnectType.proNetwork,
      PortalRole.business => ConnectType.businessHub,
    };

/// ConnectHub screen - shows community tabs based on user's active role toggles.
///
/// The tabs are driven by [userRolesProvider] from the profile subscription card.
/// If the user has toggled Student + Professional, they see Campus Connect + Pro Network.
class ConnectHubScreen extends ConsumerStatefulWidget {
  const ConnectHubScreen({super.key});

  @override
  ConsumerState<ConnectHubScreen> createState() => _ConnectHubScreenState();
}

class _ConnectHubScreenState extends ConsumerState<ConnectHubScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<ConnectType> _tabs = [];

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _updateTabs(List<ConnectType> newTabs) {
    if (_tabs.length != newTabs.length ||
        !_tabs.every((t) => newTabs.contains(t))) {
      final oldIndex = _tabController?.index ?? 0;
      final oldController = _tabController;
      _tabs = newTabs;
      if (_tabs.length > 1) {
        _tabController = TabController(
          length: _tabs.length,
          vsync: this,
          initialIndex: oldIndex.clamp(0, _tabs.length - 1),
        );
      } else {
        _tabController = null;
      }
      // Dispose old controller after the current frame completes to avoid
      // "used after being disposed" errors from the previous widget tree.
      if (oldController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          oldController.dispose();
        });
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
    final activeRoles = ref.watch(userRolesProvider);

    // Convert active roles to tabs, preserving order
    final tabs = [
      if (activeRoles.contains(PortalRole.student))
        _roleToTab(PortalRole.student),
      if (activeRoles.contains(PortalRole.professional))
        _roleToTab(PortalRole.professional),
      if (activeRoles.contains(PortalRole.business))
        _roleToTab(PortalRole.business),
    ];

    // Fallback to Campus Connect if somehow empty
    if (tabs.isEmpty) tabs.add(ConnectType.campusConnect);

    _updateTabs(tabs);

    // Single tab - show directly without TabBar
    if (_tabs.length == 1) {
      return Column(
        children: [
          const DashboardAppBar(),
          Expanded(child: _buildScreenForType(_tabs.first)),
        ],
      );
    }

    // Multiple tabs
    return Column(
      children: [
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
  }
}
