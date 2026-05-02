import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/profile_provider.dart';

/// Roles the user can toggle on/off (matches user-web "My Roles" section).
enum PortalRole {
  student,
  professional,
  business;

  String get label => switch (this) {
        student => 'Student',
        professional => 'Professional',
        business => 'Business',
      };

  String get description => switch (this) {
        student => 'Access Campus Connect',
        professional => 'Access Job Portal',
        business => 'Access Business Portal & VC Funding',
      };

  IconData get icon => switch (this) {
        student => Icons.school_outlined,
        professional => Icons.work_outline,
        business => Icons.business_outlined,
      };
}

/// Provider that persists user's active roles locally (like user-web's Zustand store).
final userRolesProvider =
    StateNotifierProvider<UserRolesNotifier, Set<PortalRole>>((ref) {
  return UserRolesNotifier(ref);
});

class UserRolesNotifier extends StateNotifier<Set<PortalRole>> {
  final Ref ref;

  UserRolesNotifier(this.ref) : super({}) {
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    // 1. Get the primary role from DB profile (source of truth)
    PortalRole primary = PortalRole.student;
    try {
      final profile = await ref.read(userProfileProvider.future);
      final userType = profile?.userType?.toDbString();
      if (userType == 'business') primary = PortalRole.business;
      else if (userType == 'professional') primary = PortalRole.professional;
    } catch (_) {}

    // 2. Try to fetch saved roles from API (MongoDB)
    try {
      final response = await ApiClient.get('/users/me/preferences');
      final data = response as Map<String, dynamic>? ?? {};
      final rolesMap = data['roles'] as Map<String, dynamic>?;
      if (rolesMap != null) {
        final roles = <PortalRole>{primary}; // always include primary
        if (rolesMap['student'] == true) roles.add(PortalRole.student);
        if (rolesMap['professional'] == true) roles.add(PortalRole.professional);
        if (rolesMap['business'] == true) roles.add(PortalRole.business);
        state = roles;
        return;
      }
    } catch (_) {}

    // 3. Fallback: just the primary role
    state = {primary};
  }

  PortalRole get primaryRole {
    final profile = ref.read(userProfileProvider).valueOrNull;
    final userType = profile?.userType?.toDbString();
    if (userType == 'business') return PortalRole.business;
    if (userType == 'professional') return PortalRole.professional;
    return PortalRole.student;
  }

  Future<void> toggleRole(PortalRole role, bool enabled) async {
    if (role == primaryRole && !enabled) return;

    final newRoles = Set<PortalRole>.from(state);
    if (enabled) {
      newRoles.add(role);
    } else {
      if (newRoles.length <= 1) return;
      newRoles.remove(role);
    }
    state = newRoles;

    // Save to MongoDB via API
    try {
      await ApiClient.put('/users/me/preferences', {
        'roles': {
          'student': newRoles.contains(PortalRole.student),
          'professional': newRoles.contains(PortalRole.professional),
          'business': newRoles.contains(PortalRole.business),
        },
      });
    } catch (e) {
      debugPrint('Failed to save roles: $e');
    }
  }
}

/// A card widget that displays toggle switches for user roles,
/// matching the user-web's "My Roles" section in Settings.
class SubscriptionCard extends ConsumerWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (_) => _buildRolesCard(context, ref),
      loading: () => _buildLoadingCard(),
      error: (_, _) => _buildRolesCard(context, ref),
    );
  }

  Widget _buildRolesCard(BuildContext context, WidgetRef ref) {
    final activeRoles = ref.watch(userRolesProvider);
    final notifier = ref.read(userRolesProvider.notifier);
    final primary = notifier.primaryRole;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'My Roles',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Manage your portal access',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ),

          const SizedBox(height: 4),
          const Divider(height: 1),

          // Role toggles
          ...PortalRole.values.map((role) {
            final isActive = activeRoles.contains(role);
            final isPrimary = role == primary;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      role.icon,
                      size: 18,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Label & description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              role.label,
                              style: AppTextStyles.labelMedium.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            if (isPrimary) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Primary',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          role.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Toggle switch
                  CupertinoSwitch(
                    value: isActive,
                    onChanged: isPrimary
                        ? null
                        : (val) => notifier.toggleRole(role, val),
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
