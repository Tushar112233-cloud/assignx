import 'package:flutter/material.dart';

import '../../../shared/widgets/dashboard_app_bar.dart';

/// Custom app bar for home screen.
///
/// Re-exports DashboardAppBar for backward compatibility.
/// All dashboard pages now use the unified DashboardAppBar.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardAppBar();
  }
}
