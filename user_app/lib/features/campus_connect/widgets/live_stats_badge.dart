import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
/// Each badge has a pulse glow animation and glass-morphism styling.
/// Data is fetched from Supabase campus_posts and colleges tables.
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatBadge(
          icon: Icons.local_fire_department_rounded,
          value: '${_stats.postsPerHour}',
          label: 'posts/hr',
          iconColor: const Color(0xFFFFD700),
        ),
        const SizedBox(width: 10),
        _StatBadge(
          icon: Icons.people_rounded,
          value: '${_stats.onlineUsers}',
          label: 'online',
          iconColor: const Color(0xFF4ADE80),
        ),
        const SizedBox(width: 10),
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

/// Individual animated stat badge with glass-morphism styling and pulse glow.
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
    return Animate(
      onPlay: (controller) => controller.repeat(reverse: true),
      effects: [
        BoxShadowEffect(
          begin: BoxShadow(
            color: Colors.white.withValues(alpha: 0.0),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          end: BoxShadow(
            color: Colors.white.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          duration: 2500.ms,
          curve: Curves.easeInOut,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Text(
              value,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
