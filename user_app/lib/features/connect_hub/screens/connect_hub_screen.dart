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

    // Fallback: if roles haven't loaded yet (empty set), show a loading indicator
    if (tabs.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF765341)));
    }

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

        // Clean segmented tab switcher
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(40),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            dividerHeight: 0,
            labelStyle: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            labelPadding: EdgeInsets.zero,
            tabs: _tabs.map((tab) {
              return Tab(
                height: 38,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab.icon, size: 16),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        tab.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
