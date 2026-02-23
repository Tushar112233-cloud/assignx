import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../widgets/role_card.dart';

/// Represents a selectable role option in the onboarding flow.
///
/// Maps to UserType (student/professional) and optionally ProfessionalType.
enum RoleOption {
  student,
  jobSeeker,
  business;

  /// Display name for the role option.
  String get displayName {
    switch (this) {
      case RoleOption.student:
        return 'Student';
      case RoleOption.jobSeeker:
        return 'Job Seeker';
      case RoleOption.business:
        return 'Business / Creator';
    }
  }

  /// Description for the role option.
  String get description {
    switch (this) {
      case RoleOption.student:
        return 'Currently pursuing education at a university or college';
      case RoleOption.jobSeeker:
        return 'Looking for job opportunities or freelance work';
      case RoleOption.business:
        return 'Running a business or working as a content creator';
    }
  }

  /// Convert to UserType enum.
  UserType get userType {
    switch (this) {
      case RoleOption.student:
        return UserType.student;
      case RoleOption.jobSeeker:
      case RoleOption.business:
        return UserType.professional;
    }
  }

  /// Get the corresponding ProfessionalType (null for students).
  ProfessionalType? get professionalType {
    switch (this) {
      case RoleOption.student:
        return null;
      case RoleOption.jobSeeker:
        return ProfessionalType.jobSeeker;
      case RoleOption.business:
        return ProfessionalType.business;
    }
  }
}

/// Role selection screen after Google sign-in.
///
/// Redesigned with gradient background, glass morphism cards,
/// and smooth staggered animations to match Dashboard aesthetic.
class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  RoleOption? _selectedRole;

  void _selectRole(RoleOption role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _continue() {
    if (_selectedRole == null) return;

    final authNotifier = ref.read(authStateProvider.notifier);

    // Store selected user type
    authNotifier.setSelectedUserType(_selectedRole!.userType);

    // Store professional type if applicable
    if (_selectedRole!.professionalType != null) {
      authNotifier.setSelectedProfessionalType(_selectedRole!.professionalType!);
    }

    // Navigate based on role
    if (_selectedRole == RoleOption.student) {
      context.go(RouteNames.studentProfile);
    } else {
      context.go(RouteNames.professionalProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final displayName = user?.userMetadata?['full_name'] as String? ??
        user?.email?.split('@').first ??
        'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.topLeft,
        colors: [
          AppColors.meshBlue,
          AppColors.meshPurple,
          AppColors.meshPink,
        ],
        opacity: 0.4,
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Header with glass container
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey $displayName! 👋',
                        style: AppTextStyles.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tell us about yourself',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "This helps us personalize your experience.",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(
                      begin: -0.1,
                      end: 0,
                      duration: 400.ms,
                    ),

                const SizedBox(height: 32),

                // Role cards
                Expanded(
                  child: ListView(
                    children: [
                      // Student
                      RoleCard(
                        icon: Icons.school_outlined,
                        title: RoleOption.student.displayName,
                        description: RoleOption.student.description,
                        isSelected: _selectedRole == RoleOption.student,
                        onTap: () => _selectRole(RoleOption.student),
                      ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideX(
                            begin: -0.2,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 16),

                      // Job Seeker
                      RoleCard(
                        icon: Icons.work_outline,
                        title: RoleOption.jobSeeker.displayName,
                        description: RoleOption.jobSeeker.description,
                        isSelected: _selectedRole == RoleOption.jobSeeker,
                        onTap: () => _selectRole(RoleOption.jobSeeker),
                      ).animate(delay: 350.ms).fadeIn(duration: 500.ms).slideX(
                            begin: -0.2,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 16),

                      // Business/Creator
                      RoleCard(
                        icon: Icons.rocket_launch_outlined,
                        title: RoleOption.business.displayName,
                        description: RoleOption.business.description,
                        isSelected: _selectedRole == RoleOption.business,
                        onTap: () => _selectRole(RoleOption.business),
                      ).animate(delay: 500.ms).fadeIn(duration: 500.ms).slideX(
                            begin: -0.2,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                ),

                // Continue button with glass effect
                GlassContainer(
                  padding: const EdgeInsets.all(4),
                  child: AppButton(
                    label: 'Continue',
                    onPressed: _selectedRole != null ? _continue : null,
                    icon: Icons.arrow_forward,
                  ),
                ).animate(delay: 650.ms).fadeIn(duration: 400.ms).slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 400.ms,
                    ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
