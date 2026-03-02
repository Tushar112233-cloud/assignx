import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

import '../../../core/constants/app_text_styles.dart';

// ============================================================
// DESIGN CONSTANTS
// ============================================================

class _RolesColors {
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B6B6B);
  static const mutedText = Color(0xFF8B8B8B);
  static const toggleOn = Color(0xFF5D3A3A);
  static const toggleOff = Color(0xFFE0E0E0);
  static const iconBackground = Color(0xFFF5F0E8);
}

// ============================================================
// ROLES STATE
// ============================================================

/// State class for user roles.
class RolesState {
  final bool student;
  final bool professional;
  final bool business;
  final bool isLoading;
  final bool isSaving;

  const RolesState({
    this.student = true,
    this.professional = false,
    this.business = false,
    this.isLoading = true,
    this.isSaving = false,
  });

  RolesState copyWith({
    bool? student,
    bool? professional,
    bool? business,
    bool? isLoading,
    bool? isSaving,
  }) {
    return RolesState(
      student: student ?? this.student,
      professional: professional ?? this.professional,
      business: business ?? this.business,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  /// Convert to JSON map for API storage.
  Map<String, dynamic> toJson() => {
        'student': student,
        'professional': professional,
        'business': business,
      };
}

// ============================================================
// ROLES NOTIFIER
// ============================================================

/// StateNotifier for managing user roles via the API.
class RolesNotifier extends StateNotifier<RolesState> {
  RolesNotifier() : super(const RolesState()) {
    _loadRoles();
  }

  /// Load roles from the API.
  Future<void> _loadRoles() async {
    try {
      final response = await ApiClient.get('/profiles/me/preferences');
      if (response == null) {
        state = const RolesState(isLoading: false);
        return;
      }

      final data = response as Map<String, dynamic>;
      final roles = data['roles'] as Map<String, dynamic>?;

      if (roles != null) {
        state = RolesState(
          student: roles['student'] ?? true,
          professional: roles['professional'] ?? false,
          business: roles['business'] ?? false,
          isLoading: false,
        );
      } else {
        state = const RolesState(isLoading: false);
      }
    } catch (e) {
      state = const RolesState(isLoading: false);
    }
  }

  /// Toggle a specific role and save to the API.
  Future<void> toggleRole(String role, bool value) async {
    // Optimistic update
    switch (role) {
      case 'student':
        state = state.copyWith(student: value, isSaving: true);
        break;
      case 'professional':
        state = state.copyWith(professional: value, isSaving: true);
        break;
      case 'business':
        state = state.copyWith(business: value, isSaving: true);
        break;
    }

    try {
      await ApiClient.put('/profiles/me/preferences', {
        'roles': state.toJson(),
      });
      state = state.copyWith(isSaving: false);
    } catch (e) {
      // Revert on error
      switch (role) {
        case 'student':
          state = state.copyWith(student: !value, isSaving: false);
          break;
        case 'professional':
          state = state.copyWith(professional: !value, isSaving: false);
          break;
        case 'business':
          state = state.copyWith(business: !value, isSaving: false);
          break;
      }
    }
  }
}

// ============================================================
// PROVIDER
// ============================================================

/// Provider for user roles state.
final rolesProvider =
    StateNotifierProvider<RolesNotifier, RolesState>((ref) {
  return RolesNotifier();
});

// ============================================================
// WIDGET
// ============================================================

/// My Roles section card for the settings screen.
/// Displays toggle switches for Student, Professional, and Business roles.
class MyRolesSection extends ConsumerWidget {
  const MyRolesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(rolesProvider);

    if (roles.isLoading) {
      return _buildLoadingCard();
    }

    return Container(
      decoration: BoxDecoration(
        color: _RolesColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _RolesColors.iconBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    size: 20,
                    color: _RolesColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Roles',
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _RolesColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manage your portal access',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          color: _RolesColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (roles.isSaving)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Role Toggles
            _RoleToggleItem(
              title: 'Student',
              subtitle: 'Access Campus Connect',
              icon: Icons.school_outlined,
              value: roles.student,
              onChanged: (value) =>
                  ref.read(rolesProvider.notifier).toggleRole('student', value),
            ),
            _RoleToggleItem(
              title: 'Professional',
              subtitle: 'Access Job Portal',
              icon: Icons.work_outline,
              value: roles.professional,
              onChanged: (value) =>
                  ref.read(rolesProvider.notifier).toggleRole('professional', value),
            ),
            _RoleToggleItem(
              title: 'Business',
              subtitle: 'Access Business Portal & VC Funding',
              icon: Icons.business_outlined,
              value: roles.business,
              onChanged: (value) =>
                  ref.read(rolesProvider.notifier).toggleRole('business', value),
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: _RolesColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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

// ============================================================
// PRIVATE WIDGETS
// ============================================================

/// Toggle item for a role with icon, title, subtitle, and switch.
class _RoleToggleItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _RoleToggleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: _RolesColors.secondaryText,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _RolesColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: _RolesColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _CustomToggle(value: value, onChanged: onChanged),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Colors.grey.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}

/// Custom toggle switch matching design spec.
class _CustomToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomToggle({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          color: value ? _RolesColors.toggleOn : _RolesColors.toggleOff,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
