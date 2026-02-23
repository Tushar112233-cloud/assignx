import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../providers/profile_provider.dart';

/// Provider for CloudinaryService.
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});

/// State for avatar upload.
enum AvatarUploadState {
  idle,
  picking,
  uploading,
  success,
  error,
}

/// Avatar upload dialog for picking and uploading profile pictures.
///
/// Supports both camera and gallery image selection with compression
/// and upload progress indication.
///
/// ## Usage
/// ```dart
/// await showAvatarUploadDialog(context, ref);
/// ```
class AvatarUploadDialog extends ConsumerStatefulWidget {
  const AvatarUploadDialog({super.key});

  @override
  ConsumerState<AvatarUploadDialog> createState() => _AvatarUploadDialogState();
}

class _AvatarUploadDialogState extends ConsumerState<AvatarUploadDialog> {
  AvatarUploadState _state = AvatarUploadState.idle;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change Profile Picture',
                  style: AppTextStyles.headingSmall,
                ),
                IconButton(
                  onPressed: _state == AvatarUploadState.uploading
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content based on state
            _buildContent(),

            const SizedBox(height: 24),

            // Actions
            if (_state == AvatarUploadState.idle ||
                _state == AvatarUploadState.error)
              _buildActions(),

            if (_state == AvatarUploadState.success) _buildSuccessActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case AvatarUploadState.idle:
        return _buildIdleContent();
      case AvatarUploadState.picking:
        return _buildLoadingContent('Opening...');
      case AvatarUploadState.uploading:
        return _buildUploadingContent();
      case AvatarUploadState.success:
        return _buildSuccessContent();
      case AvatarUploadState.error:
        return _buildErrorContent();
    }
  }

  Widget _buildIdleContent() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.camera_alt_outlined,
            size: 40,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Choose a new profile picture',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingContent(String message) {
    return Column(
      children: [
        const SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingContent() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: _uploadProgress > 0 ? _uploadProgress : null,
                strokeWidth: 4,
                backgroundColor: AppColors.surfaceVariant,
              ),
            ),
            Text(
              '${(_uploadProgress * 100).toInt()}%',
              style: AppTextStyles.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Uploading...',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 50,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Profile picture updated!',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            size: 50,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _errorMessage ?? 'Upload failed',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.error,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Camera option
        _buildActionButton(
          icon: Icons.camera_alt_outlined,
          label: 'Take Photo',
          onTap: () => _handleImageSelection(ImageSource.camera),
        ),
        const SizedBox(height: 12),

        // Gallery option
        _buildActionButton(
          icon: Icons.photo_library_outlined,
          label: 'Choose from Gallery',
          onTap: () => _handleImageSelection(ImageSource.gallery),
        ),
        const SizedBox(height: 12),

        // Remove option
        _buildActionButton(
          icon: Icons.delete_outline,
          label: 'Remove Photo',
          isDestructive: true,
          onTap: _handleRemovePhoto,
        ),
      ],
    );
  }

  Widget _buildSuccessActions() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(true),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Done'),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    final bgColor = isDestructive ? AppColors.errorLight : AppColors.surface;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDestructive ? AppColors.error.withValues(alpha: 0.2) : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    setState(() {
      _state = AvatarUploadState.picking;
      _errorMessage = null;
    });

    try {
      final cloudinaryService = ref.read(cloudinaryServiceProvider);

      final result = await cloudinaryService.uploadAvatar(
        source: source,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _state = AvatarUploadState.uploading;
              _uploadProgress = progress;
            });
          }
        },
      );

      if (result == null) {
        // User cancelled or error
        if (mounted) {
          setState(() => _state = AvatarUploadState.idle);
        }
        return;
      }

      // Update profile with new avatar URL
      await ref.read(profileNotifierProvider.notifier).updateProfile(
        avatarUrl: result.url,
      );

      if (mounted) {
        setState(() => _state = AvatarUploadState.success);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = AvatarUploadState.error;
          _errorMessage = _getErrorMessage(e);
        });
      }
    }
  }

  Future<void> _handleRemovePhoto() async {
    setState(() {
      _state = AvatarUploadState.uploading;
      _uploadProgress = 0.5;
    });

    try {
      // Update profile to remove avatar
      await ref.read(profileNotifierProvider.notifier).updateProfile(
        avatarUrl: '',
      );

      if (mounted) {
        setState(() => _state = AvatarUploadState.success);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = AvatarUploadState.error;
          _errorMessage = _getErrorMessage(e);
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final message = error.toString();

    if (message.contains('not authenticated')) {
      return 'Please log in to update your profile picture.';
    }
    if (message.contains('API_BASE_URL')) {
      return 'App configuration error. Please try again later.';
    }
    if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your connection.';
    }

    return 'Failed to update profile picture. Please try again.';
  }
}

/// Shows the avatar upload dialog.
///
/// Returns `true` if the avatar was successfully updated, `null` otherwise.
Future<bool?> showAvatarUploadDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const AvatarUploadDialog(),
  );
}

/// Bottom sheet version for avatar options.
///
/// This provides a simpler interface with just the selection options.
class AvatarOptionsSheet extends ConsumerStatefulWidget {
  const AvatarOptionsSheet({super.key});

  @override
  ConsumerState<AvatarOptionsSheet> createState() => _AvatarOptionsSheetState();
}

class _AvatarOptionsSheetState extends ConsumerState<AvatarOptionsSheet> {
  bool _isLoading = false;
  double _uploadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change Profile Picture',
                  style: AppTextStyles.headingSmall,
                ),
                if (_isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: _uploadProgress > 0 ? _uploadProgress : null,
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Options
          if (!_isLoading) ...[
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Take Photo'),
              subtitle: Text(
                'Use your camera',
                style: AppTextStyles.caption,
              ),
              onTap: () => _handleSelection(ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: Text(
                'Pick from your photos',
                style: AppTextStyles.caption,
              ),
              onTap: () => _handleSelection(ImageSource.gallery),
            ),
            const Divider(indent: 20, endIndent: 20),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
              ),
              title: Text(
                'Remove Photo',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
              ),
              subtitle: Text(
                'Delete your profile picture',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error.withValues(alpha: 0.71),
                ),
              ),
              onTap: _handleRemove,
            ),
          ] else ...[
            // Loading state
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: _uploadProgress > 0 ? _uploadProgress : null,
                          strokeWidth: 3,
                          backgroundColor: AppColors.surfaceVariant,
                        ),
                      ),
                      if (_uploadProgress > 0)
                        Text(
                          '${(_uploadProgress * 100).toInt()}%',
                          style: AppTextStyles.labelMedium,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Uploading your photo...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _handleSelection(ImageSource source) async {
    setState(() {
      _isLoading = true;
      _uploadProgress = 0.0;
    });

    try {
      final cloudinaryService = ref.read(cloudinaryServiceProvider);

      final result = await cloudinaryService.uploadAvatar(
        source: source,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _uploadProgress = progress);
          }
        },
      );

      if (result == null) {
        // User cancelled
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      // Update profile
      await ref.read(profileNotifierProvider.notifier).updateProfile(
        avatarUrl: result.url,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString().split(':').last.trim()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRemove() async {
    setState(() {
      _isLoading = true;
      _uploadProgress = 0.5;
    });

    try {
      await ref.read(profileNotifierProvider.notifier).updateProfile(
        avatarUrl: '',
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: ${e.toString().split(':').last.trim()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Shows the avatar options bottom sheet.
///
/// Returns `true` if the avatar was successfully updated, `null` otherwise.
Future<bool?> showAvatarOptionsSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const AvatarOptionsSheet(),
  );
}
