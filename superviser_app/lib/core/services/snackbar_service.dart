import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';

/// Snackbar types for different message contexts.
enum SnackbarType {
  success,
  error,
  warning,
  info,
}

/// Snackbar configuration.
class SnackbarConfig {
  const SnackbarConfig({
    required this.message,
    this.type = SnackbarType.info,
    this.duration = const Duration(seconds: 4),
    this.action,
    this.actionLabel,
    this.onAction,
    this.dismissible = true,
  });

  final String message;
  final SnackbarType type;
  final Duration duration;
  final SnackBarAction? action;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool dismissible;
}

/// Global snackbar service for showing notifications.
class SnackbarService {
  SnackbarService._();

  static final SnackbarService _instance = SnackbarService._();
  static SnackbarService get instance => _instance;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Show a success snackbar.
  void showSuccess(String message, {String? actionLabel, VoidCallback? onAction}) {
    _show(SnackbarConfig(
      message: message,
      type: SnackbarType.success,
      actionLabel: actionLabel,
      onAction: onAction,
    ));
  }

  /// Show an error snackbar.
  void showError(String message, {String? actionLabel, VoidCallback? onAction}) {
    _show(SnackbarConfig(
      message: message,
      type: SnackbarType.error,
      duration: const Duration(seconds: 6),
      actionLabel: actionLabel,
      onAction: onAction,
    ));
  }

  /// Show a warning snackbar.
  void showWarning(String message, {String? actionLabel, VoidCallback? onAction}) {
    _show(SnackbarConfig(
      message: message,
      type: SnackbarType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
    ));
  }

  /// Show an info snackbar.
  void showInfo(String message, {String? actionLabel, VoidCallback? onAction}) {
    _show(SnackbarConfig(
      message: message,
      type: SnackbarType.info,
      actionLabel: actionLabel,
      onAction: onAction,
    ));
  }

  /// Show a snackbar with custom configuration.
  void show(SnackbarConfig config) {
    _show(config);
  }

  /// Hide the current snackbar.
  void hide() {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }

  /// Clear all snackbars.
  void clearAll() {
    scaffoldMessengerKey.currentState?.clearSnackBars();
  }

  void _show(SnackbarConfig config) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    // Clear previous snackbar
    messenger.hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIcon(config.type),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              config.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getBackgroundColor(config.type),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      duration: config.duration,
      dismissDirection:
          config.dismissible ? DismissDirection.horizontal : DismissDirection.none,
      action: config.action ??
          (config.actionLabel != null && config.onAction != null
              ? SnackBarAction(
                  label: config.actionLabel!,
                  textColor: Colors.white,
                  onPressed: config.onAction!,
                )
              : null),
    );

    messenger.showSnackBar(snackBar);
  }

  IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.warning:
        return Icons.warning_amber_outlined;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }

  Color _getBackgroundColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return AppColors.success;
      case SnackbarType.error:
        return AppColors.error;
      case SnackbarType.warning:
        return AppColors.warning;
      case SnackbarType.info:
        return AppColors.info;
    }
  }
}

/// Provider for snackbar service.
final snackbarServiceProvider = Provider<SnackbarService>((ref) {
  return SnackbarService.instance;
});

/// Extension to easily access snackbar service from WidgetRef.
extension SnackbarRefExtension on WidgetRef {
  SnackbarService get snackbar => read(snackbarServiceProvider);
}
