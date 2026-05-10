import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/translation/translation_extensions.dart';

/// Launches WhatsApp support with the given phone number and message.
///
/// Shows a SnackBar with error message if launch fails.
Future<void> launchWhatsAppSupport(
  BuildContext context, {
  String phoneNumber = AppConfig.supportPhone,
  String? message,
}) async {
  final encodedMessage = Uri.encodeComponent(
    message ?? AppConfig.defaultSupportMessage,
  );
  final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
  final whatsappUrl = Uri.parse(
    'https://wa.me/$digits?text=$encodedMessage',
  );

  try {
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open WhatsApp. Please install WhatsApp.'.tr(context)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('Failed to launch WhatsApp: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open support. Please try again.'.tr(context)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Floating action button for accessing support.
///
/// Shows on onboarding and auth screens, opens WhatsApp support.
class SupportFAB extends StatelessWidget {
  /// WhatsApp phone number (with country code).
  final String phoneNumber;

  /// Pre-filled message.
  final String? message;

  const SupportFAB({
    super.key,
    this.phoneNumber = AppConfig.supportPhone,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => launchWhatsAppSupport(
        context,
        phoneNumber: phoneNumber,
        message: message,
      ),
      backgroundColor: AppColors.success,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.support_agent_outlined),
      label: Text(
        'Get Support'.tr(context),
        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Mini support button for inline use.
class SupportButton extends StatelessWidget {
  /// WhatsApp phone number (with country code).
  final String phoneNumber;

  /// Pre-filled message.
  final String? message;

  const SupportButton({
    super.key,
    this.phoneNumber = AppConfig.supportPhone,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => launchWhatsAppSupport(
        context,
        phoneNumber: phoneNumber,
        message: message,
      ),
      icon: const Icon(Icons.support_agent_outlined, size: 20),
      label: Text('Need Help?'.tr(context)),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.success,
      ),
    );
  }
}
