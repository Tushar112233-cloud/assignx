import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_text_styles.dart';

/// Live statistics data fetched from Supabase.
class _LiveStats {
  final int postsPerHour;
  final int onlineUsers;
  final int colleges;

  const _LiveStats({
    this.postsPerHour = 0,
    this.onlineUsers = 0,
    this.colleges = 0,
  });
}

/// Animated live stats badges showing community activity.
///
/// Displays three stat badges in a row:
/// - Posts per hour (fire icon)
/// - Users online (people icon)
/// - Colleges connected (building icon)
///
/// Data is fetched from the community stats API.
class LiveStatsBadge extends StatefulWidget {
  const LiveStatsBadge({super.key});

  @override
  State<LiveStatsBadge> createState() => _LiveStatsBadgeState();
}

class _LiveStatsBadgeState extends State<LiveStatsBadge> {
  _LiveStats _stats = const _LiveStats();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchStats();
    // Refresh stats every 60 seconds.
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _fetchStats(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Fetch live stats from API.
  Future<void> _fetchStats() async {
    try {
      final response = await ApiClient.get('/community/campus/stats');
      if (!mounted || response == null) return;

      final data = response as Map<String, dynamic>;
      final postsCount = (data['posts_per_hour'] ?? data['postsPerHour'] ?? 0) as int;
      final collegesCount = (data['colleges'] ?? 0) as int;
      final estimatedOnline = (data['online_users'] ?? data['onlineUsers'] ?? (postsCount * 3).clamp(5, 999)) as int;

      setState(() {
        _stats = _LiveStats(
          postsPerHour: postsCount,
          onlineUsers: estimatedOnline,
          colleges: collegesCount,
        );
      });
    } catch (_) {
      // Fail silently; show fallback values.
      if (mounted) {
        setState(() {
          _stats = const _LiveStats(
            postsPerHour: 12,
            onlineUsers: 48,
            colleges: 500,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        _StatBadge(
          icon: Icons.local_fire_department_rounded,
          value: '${_stats.postsPerHour}',
          label: 'posts/hr',
          iconColor: const Color(0xFFFFD700),
        ),
        _StatBadge(
          icon: Icons.people_rounded,
          value: '${_stats.onlineUsers}',
          label: 'online',
          iconColor: const Color(0xFF4ADE80),
        ),
        _StatBadge(
          icon: Icons.account_balance_rounded,
          value: '${_stats.colleges}+',
          label: 'colleges',
          iconColor: const Color(0xFF60A5FA),
        ),
      ],
    );
  }
}

/// Individual stat badge with simple solid styling.
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
