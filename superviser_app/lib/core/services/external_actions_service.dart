import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'snackbar_service.dart';

/// Service for handling external actions like URL launching, email, phone, etc.
class ExternalActionsService {
  ExternalActionsService._();

  static final ExternalActionsService _instance = ExternalActionsService._();
  static ExternalActionsService get instance => _instance;

  SnackbarService? _snackbarService;

  void initialize({SnackbarService? snackbarService}) {
    _snackbarService = snackbarService ?? SnackbarService.instance;
  }

  /// Open a URL in the default browser.
  Future<bool> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
      _snackbarService?.showError('Could not open URL');
      return false;
    } catch (e) {
      _snackbarService?.showError('Failed to open URL: $e');
      return false;
    }
  }

  /// Open a URL in an in-app browser.
  Future<bool> openUrlInApp(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
        );
      }
      _snackbarService?.showError('Could not open URL');
      return false;
    } catch (e) {
      _snackbarService?.showError('Failed to open URL: $e');
      return false;
    }
  }

  /// Open email client with pre-filled data.
  Future<bool> sendEmail({
    required String to,
    String? subject,
    String? body,
  }) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: to,
        queryParameters: {
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
        },
      );
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      _snackbarService?.showError('No email app available');
      return false;
    } catch (e) {
      _snackbarService?.showError('Failed to open email: $e');
      return false;
    }
  }

  /// Open phone dialer with number.
  Future<bool> makePhoneCall(String phoneNumber) async {
    try {
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      _snackbarService?.showError('Could not make phone call');
      return false;
    } catch (e) {
      _snackbarService?.showError('Failed to make call: $e');
      return false;
    }
  }

  /// Open SMS app with number.
  Future<bool> sendSms(String phoneNumber, {String? message}) async {
    try {
      final uri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: message != null ? {'body': message} : null,
      );
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      _snackbarService?.showError('Could not open SMS app');
      return false;
    } catch (e) {
      _snackbarService?.showError('Failed to open SMS: $e');
      return false;
    }
  }

  /// Copy text to clipboard.
  Future<void> copyToClipboard(String text, {String? successMessage}) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _snackbarService?.showSuccess(successMessage ?? 'Copied to clipboard');
    } catch (e) {
      _snackbarService?.showError('Failed to copy: $e');
    }
  }

  /// Pick a file from device.
  Future<List<PlatformFile>?> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );
      return result?.files;
    } catch (e) {
      _snackbarService?.showError('Failed to pick file: $e');
      return null;
    }
  }

  /// Pick an image from device.
  Future<PlatformFile?> pickImage() async {
    final files = await pickFiles(type: FileType.image);
    return files?.firstOrNull;
  }

  /// Pick images from device.
  Future<List<PlatformFile>?> pickImages() async {
    return await pickFiles(type: FileType.image, allowMultiple: true);
  }

  /// Open a local file with default app.
  Future<bool> openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type == ResultType.done) {
        return true;
      }
      _snackbarService?.showError('Could not open file: ${result.message}');
      return false;
    } catch (e) {
      _snackbarService?.showError('Failed to open file: $e');
      return false;
    }
  }

  /// Share content using platform share sheet.
  Future<void> shareText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _snackbarService?.showSuccess('Text copied for sharing');
    } catch (e) {
      _snackbarService?.showError('Failed to share: $e');
    }
  }

  /// Open live chat (placeholder - implement with actual chat service).
  Future<bool> openLiveChat() async {
    // This would integrate with your live chat service (Intercom, Zendesk, etc.)
    _snackbarService?.showInfo('Live chat coming soon');
    return false;
  }
}

/// Provider for external actions service.
final externalActionsServiceProvider = Provider<ExternalActionsService>((ref) {
  final service = ExternalActionsService.instance;
  service.initialize(snackbarService: ref.read(snackbarServiceProvider));
  return service;
});

/// Extension for easy access to external actions.
extension ExternalActionsExtension on WidgetRef {
  ExternalActionsService get externalActions => read(externalActionsServiceProvider);
}
