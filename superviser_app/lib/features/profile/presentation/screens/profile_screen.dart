import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../common/data/models/subject.dart';
import '../../../common/presentation/providers/subjects_provider.dart';
import '../../data/models/profile_model.dart';
import '../providers/profile_provider.dart';

/// Profile screen showing user profile with edit functionality.
/// This is a TAB screen: transparent background, bottom padding 100.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final authUser = ref.watch(currentUserProvider);

    // Build an effective profile: use API profile if available, otherwise
    // fall back to a basic profile constructed from auth state user data.
    final effectiveProfile = profileState.profile ??
        (authUser != null
            ? SupervisorProfile(
                id: authUser.id,
                userId: authUser.id,
                fullName: authUser.fullName ?? authUser.email,
                email: authUser.email,
                avatarUrl: authUser.avatarUrl,
                phone: authUser.phone,
                isVerified: authUser.isVerified,
              )
            : null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Profile'.tr(context)),
        actions: [
          if (effectiveProfile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEdit(context, effectiveProfile),
            ),
        ],
      ),
      body: profileState.isLoading && effectiveProfile == null
          ? const Center(child: CircularProgressIndicator())
          : effectiveProfile == null
              ? Center(child: Text('Failed to load profile'.tr(context)))
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(profileProvider.notifier).loadProfile(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _ProfileContent(
                      profile: effectiveProfile,
                      onAvatarTap: () =>
                          _showAvatarOptions(context, ref),
                    ),
                  ),
                ),
    );
  }

  void _navigateToEdit(BuildContext context, SupervisorProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: profile),
      ),
    );
  }

  void _showAvatarOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AvatarOptionsSheet(
        onImageSelected: (file) async {
          Navigator.pop(context);
          await ref.read(profileProvider.notifier).uploadAvatar(file);
        },
      ),
    );
  }
}

/// Profile content widget.
class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    this.onAvatarTap,
  });

  final SupervisorProfile profile;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Glass hero card with avatar/name/stats
        GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(24),
          blur: 20,
          opacity: 0.85,
          elevation: 3,
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.accent.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? Text(
                              profile.initials,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile.fullName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (profile.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified'.tr(context),
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (profile.rating ?? 0).toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Supervisor'.tr(context),
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Glass stat row
        GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          blur: 15,
          opacity: 0.7,
          elevation: 2,
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: profile.totalProjects.toString(),
                  label: 'Total Projects'.tr(context),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.textSecondaryLight.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _StatItem(
                  value: profile.completedProjects.toString(),
                  label: 'Completed'.tr(context),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.textSecondaryLight.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _StatItem(
                  value: '${profile.completionRate.toStringAsFixed(0)}%',
                  label: 'Success Rate'.tr(context),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Bio
        if (profile.bio != null && profile.bio!.isNotEmpty)
          _GlassProfileSection(
            title: 'About'.tr(context),
            child: Text(
              profile.bio!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

        // Specializations
        if (profile.specializations.isNotEmpty)
          _GlassProfileSection(
            title: 'Specializations'.tr(context),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.specializations.map((spec) {
                return Chip(
                  label: Text(spec),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),

        // Qualifications
        if (profile.qualifications.isNotEmpty)
          _GlassProfileSection(
            title: 'Qualifications'.tr(context),
            child: Column(
              children: profile.qualifications.map((qual) {
                return _QualificationItem(qualification: qual);
              }).toList(),
            ),
          ),

        // Languages
        if (profile.languages.isNotEmpty)
          _GlassProfileSection(
            title: 'Languages'.tr(context),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.languages.map((lang) {
                return Chip(
                  avatar: const Icon(Icons.language, size: 16),
                  label: Text(lang),
                );
              }).toList(),
            ),
          ),

        // Contact Info
        _GlassProfileSection(
          title: 'Contact Information'.tr(context),
          child: Column(
            children: [
              if (profile.phone != null)
                _InfoRow(
                  icon: Icons.phone,
                  label: 'Phone'.tr(context),
                  value: profile.phone!,
                ),
              _InfoRow(
                icon: Icons.email,
                label: 'Email'.tr(context),
                value: profile.email,
              ),
              if (profile.timezone != null)
                _InfoRow(
                  icon: Icons.access_time,
                  label: 'Timezone'.tr(context),
                  value: profile.timezone!,
                ),
            ],
          ),
        ),

        // Availability
        _GlassProfileSection(
          title: 'Availability'.tr(context),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currently Available'.tr(context),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${'Max'.tr(context)} ${profile.maxConcurrentProjects} ${'concurrent projects'.tr(context)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: profile.isAvailable
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  profile.isAvailable ? 'Available'.tr(context) : 'Unavailable'.tr(context),
                  style: TextStyle(
                    color: profile.isAvailable
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile Menu
        const _ProfileMenu(),

        // Bottom padding for tab screen
        const SizedBox(height: 100),
      ],
    );
  }
}

/// Glass profile section card.
class _GlassProfileSection extends StatelessWidget {
  const _GlassProfileSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      blur: 12,
      opacity: 0.7,
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Profile menu with navigation items and logout button.
class _ProfileMenu extends ConsumerWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.zero,
      blur: 12,
      opacity: 0.7,
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Menu'.tr(context),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.bar_chart, color: AppColors.accent),
            title: Text('Stats Dashboard'.tr(context)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => context.go(RoutePaths.earnings),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Icon(Icons.rate_review, color: AppColors.accent),
            title: Text('My Reviews'.tr(context)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => context.goNamed(RouteNames.reviews),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Icon(Icons.people_outline, color: AppColors.accent),
            title: Text('My Doers'.tr(context)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => context.go(RoutePaths.doers),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Icon(Icons.group_outlined, color: AppColors.accent),
            title: Text('Users'.tr(context)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => context.go(RoutePaths.users),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Icon(Icons.build_outlined, color: AppColors.accent),
            title: Text('Resources'.tr(context)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => context.go(RoutePaths.resources),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Icon(Icons.notifications_outlined, color: AppColors.accent),
            title: Text('Notifications'.tr(context)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => context.go(RoutePaths.notifications),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Icon(Icons.block, color: AppColors.accent),
            title: Text('Doer Blacklist'.tr(context)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => context.goNamed(RouteNames.blacklist),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Icon(Icons.support_agent, color: AppColors.accent),
            title: Text('Support Contact'.tr(context)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => context.goNamed(RouteNames.support),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Icon(Icons.settings, color: AppColors.accent),
            title: Text('Settings'.tr(context)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => context.go(RoutePaths.settings),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Logout'.tr(ctx)),
                      content: Text(
                        'Are you sure you want to logout?'.tr(ctx),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('Cancel'.tr(ctx)),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('Logout'.tr(ctx)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    ref.read(authProvider.notifier).signOut();
                    context.go(RoutePaths.login);
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'Logout'.tr(context),
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
        ),
      ],
    );
  }
}

class _QualificationItem extends StatelessWidget {
  const _QualificationItem({required this.qualification});

  final Qualification qualification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.school,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${qualification.degree} in ${qualification.field}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    if (qualification.isVerified)
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.success,
                      ),
                  ],
                ),
                if (qualification.institution != null)
                  Text(
                    qualification.institution!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                if (qualification.year != null)
                  Text(
                    qualification.year.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

/// Avatar options bottom sheet.
class _AvatarOptionsSheet extends StatelessWidget {
  const _AvatarOptionsSheet({required this.onImageSelected});

  final void Function(File) onImageSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('Take Photo'.tr(context)),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Choose from Gallery'.tr(context)),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      onImageSelected(File(image.path));
    }
  }
}

/// Edit profile screen.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final SupervisorProfile profile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _timezoneController;
  late List<String> _specializations;
  late List<String> _languages;
  late bool _isAvailable;
  late int _maxProjects;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _timezoneController = TextEditingController(text: widget.profile.timezone ?? '');
    _specializations = List.from(widget.profile.specializations);
    _languages = List.from(widget.profile.languages);
    _isAvailable = widget.profile.isAvailable;
    _maxProjects = widget.profile.maxConcurrentProjects;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'.tr(context)),
        actions: [
          TextButton(
            onPressed: profileState.isSaving ? null : _saveProfile,
            child: profileState.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Save'.tr(context)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name'.tr(context),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name'.tr(context);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number'.tr(context),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio'.tr(context),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // Timezone
            TextFormField(
              controller: _timezoneController,
              decoration: InputDecoration(
                labelText: 'Timezone'.tr(context),
                prefixIcon: Icon(Icons.access_time),
                hintText: 'e.g., America/New_York',
              ),
            ),
            const SizedBox(height: 24),

            // Availability
            GlassCard(
              blur: 12,
              opacity: 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Availability Settings'.tr(context),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Available for Projects'.tr(context)),
                    subtitle: Text('Allow new project assignments'.tr(context)),
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() => _isAvailable = value);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Max Concurrent Projects'.tr(context)),
                            Text(
                              '$_maxProjects ${'projects'.tr(context)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _maxProjects > 1
                                ? () => setState(() => _maxProjects--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            _maxProjects.toString(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            onPressed: _maxProjects < 20
                                ? () => setState(() => _maxProjects++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Specializations
            _SubjectChipSelector(
              title: 'Specializations',
              selectedNames: _specializations,
              onAdd: (value) {
                if (value.isNotEmpty && !_specializations.contains(value)) {
                  setState(() => _specializations.add(value));
                }
              },
              onRemove: (value) {
                setState(() => _specializations.remove(value));
              },
            ),
            const SizedBox(height: 16),

            // Languages
            _ChipInputSection(
              title: 'Languages',
              chips: _languages,
              onAdd: (value) {
                if (value.isNotEmpty && !_languages.contains(value)) {
                  setState(() => _languages.add(value));
                }
              },
              onRemove: (value) {
                setState(() => _languages.remove(value));
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updated = widget.profile.copyWith(
        fullName: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        timezone: _timezoneController.text.isEmpty ? null : _timezoneController.text,
        specializations: _specializations,
        languages: _languages,
        isAvailable: _isAvailable,
        maxConcurrentProjects: _maxProjects,
      );

      final success = await ref.read(profileProvider.notifier).updateProfile(updated);

      if (mounted && success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'.tr(context)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

/// Chip input section for tags (used for free-form items like languages).
class _ChipInputSection extends StatefulWidget {
  const _ChipInputSection({
    required this.title,
    required this.chips,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final List<String> chips;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  @override
  State<_ChipInputSection> createState() => _ChipInputSectionState();
}

class _ChipInputSectionState extends State<_ChipInputSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '${'Add'.tr(context)} ${widget.title.toLowerCase()}',
                  isDense: true,
                ),
                onSubmitted: (value) {
                  widget.onAdd(value.trim());
                  _controller.clear();
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                widget.onAdd(_controller.text.trim());
                _controller.clear();
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.chips.map((chip) {
            return Chip(
              label: Text(chip),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => widget.onRemove(chip),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Subject chip selector that fetches subjects from the API.
///
/// Displays selected subjects as chips with a button to open a searchable
/// bottom sheet for adding more. Replaces manual text input with a
/// curated list from [subjectsProvider].
class _SubjectChipSelector extends ConsumerWidget {
  const _SubjectChipSelector({
    required this.title,
    required this.selectedNames,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final List<String> selectedNames;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        // Add button opens the searchable subject sheet.
        GestureDetector(
          onTap: () => _showSubjectPicker(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '${'Add'.tr(context)} ${title.toLowerCase()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Selected chips.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedNames.map((name) {
            return Chip(
              label: Text(name),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => onRemove(name),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showSubjectPicker(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.read(subjectsProvider);

    subjectsAsync.when(
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loading subjects...'.tr(context))),
        );
      },
      error: (err, _) {
        ref.invalidate(subjectsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load subjects. Retrying...'.tr(context))),
        );
      },
      data: (subjects) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _SearchableSubjectSheet(
            subjects: subjects,
            selectedNames: selectedNames,
            onSelected: (subject) {
              onAdd(subject.name);
            },
          ),
        );
      },
    );
  }
}

/// Bottom sheet with search filtering for selecting subjects.
class _SearchableSubjectSheet extends StatefulWidget {
  const _SearchableSubjectSheet({
    required this.subjects,
    required this.selectedNames,
    required this.onSelected,
  });

  final List<Subject> subjects;
  final List<String> selectedNames;
  final ValueChanged<Subject> onSelected;

  @override
  State<_SearchableSubjectSheet> createState() => _SearchableSubjectSheetState();
}

class _SearchableSubjectSheetState extends State<_SearchableSubjectSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<Subject> get _filteredSubjects {
    if (_searchQuery.isEmpty) return widget.subjects;
    final query = _searchQuery.toLowerCase();
    return widget.subjects
        .where((s) => s.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Subjects'.tr(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search subjects...'.tr(context),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 8),

          // Subject list
          Expanded(
            child: _filteredSubjects.isEmpty
                ? Center(
                    child: Text(
                      'No subjects found'.tr(context),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: bottomPadding + 16),
                    itemCount: _filteredSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = _filteredSubjects[index];
                      final isSelected =
                          widget.selectedNames.contains(subject.name);

                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: subject.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            subject.icon,
                            size: 18,
                            color: subject.color,
                          ),
                        ),
                        title: Text(
                          subject.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : null,
                              ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle,
                                color: AppColors.primary, size: 22)
                            : null,
                        onTap: () {
                          if (!isSelected) {
                            widget.onSelected(subject);
                          }
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
