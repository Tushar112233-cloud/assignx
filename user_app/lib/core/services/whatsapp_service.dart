import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_text_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// WhatsApp notification type mapping
const Map<String, String> whatsappTemplates = {
  'quote_ready': 'quote_ready_notification',
  'payment_received': 'payment_confirmed',
  'project_started': 'project_started',
  'project_delivered': 'project_delivered',
  'revision_requested': 'revision_in_progress',
  'project_completed': 'project_completed',
  'auto_approval_reminder': 'review_reminder',
  'new_message': 'new_message',
};

/// WhatsApp Service
/// Handles WhatsApp integration for customer support
/// Implements U40 from feature spec
class WhatsAppService {
  /// AssignX support number
  static const String supportNumber = '919876543210'; // Replace with actual number

  /// Open WhatsApp with support
  static Future<bool> openWhatsAppSupport({
    String? message,
    String? projectNumber,
  }) async {
    final text = message ?? _buildSupportMessage(projectNumber);
    return openWhatsApp(supportNumber, text);
  }

  /// Build default support message
  static String _buildSupportMessage(String? projectNumber) {
    if (projectNumber != null) {
      return 'Hi, I need help with my project $projectNumber';
    }
    return 'Hi, I need help with AssignX';
  }

  /// Open WhatsApp with a specific number
  static Future<bool> openWhatsApp(String phoneNumber, String message) async {
    // Clean phone number
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Encode message
    final encodedMessage = Uri.encodeComponent(message);

    // Build WhatsApp URL
    final uri = Uri.parse('https://wa.me/$cleanedNumber?text=$encodedMessage');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        debugPrint('Could not launch WhatsApp');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      return false;
    }
  }

  /// Send WhatsApp notification via server (for backend use)
  /// This would be called from the backend, not directly from the app
  static Future<bool> sendNotification({
    required String phone,
    required String templateName,
    required Map<String, String> templateParams,
    String? apiBaseUrl,
    String? apiKey,
  }) async {
    final baseUrl = apiBaseUrl ?? 'https://api.assignx.com'; // Replace with actual URL

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications/whatsapp'),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'x-api-key': apiKey,
        },
        body: jsonEncode({
          'phone': phone,
          'templateName': templateName,
          'templateParams': templateParams,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }

      debugPrint('WhatsApp notification failed: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('WhatsApp notification error: $e');
      return false;
    }
  }

  /// Format phone number for India
  static String formatPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // If starts with 0, assume India and replace with 91
    if (cleaned.startsWith('0')) {
      cleaned = '91${cleaned.substring(1)}';
    }

    // If 10 digits, assume India
    if (cleaned.length == 10) {
      cleaned = '91$cleaned';
    }

    return cleaned;
  }

  /// Get quick support options
  static List<WhatsAppQuickOption> getQuickOptions({String? projectNumber}) {
    return [
      WhatsAppQuickOption(
        title: 'General Inquiry',
        message: 'Hi, I have a question about AssignX',
        icon: Icons.help_outline,
      ),
      if (projectNumber != null)
        WhatsAppQuickOption(
          title: 'Project Help',
          message: 'Hi, I need help with my project $projectNumber',
          icon: Icons.assignment,
        ),
      WhatsAppQuickOption(
        title: 'Payment Issue',
        message: projectNumber != null
            ? 'Hi, I have a payment issue with project $projectNumber'
            : 'Hi, I have a payment issue',
        icon: Icons.payment,
      ),
      WhatsAppQuickOption(
        title: 'Revision Request',
        message: projectNumber != null
            ? 'Hi, I need to request a revision for project $projectNumber'
            : 'Hi, I need to request a revision',
        icon: Icons.refresh,
      ),
      WhatsAppQuickOption(
        title: 'Report Issue',
        message: projectNumber != null
            ? 'Hi, I want to report an issue with project $projectNumber'
            : 'Hi, I want to report an issue',
        icon: Icons.report_problem,
      ),
    ];
  }
}

/// Quick option for WhatsApp support
class WhatsAppQuickOption {
  final String title;
  final String message;
  final IconData icon;

  WhatsAppQuickOption({
    required this.title,
    required this.message,
    required this.icon,
  });
}

/// WhatsApp Support Bottom Sheet Widget
class WhatsAppSupportSheet extends StatelessWidget {
  final String? projectNumber;

  const WhatsAppSupportSheet({
    super.key,
    this.projectNumber,
  });

  @override
  Widget build(BuildContext context) {
    final options = WhatsAppService.getQuickOptions(projectNumber: projectNumber);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat,
                  color: Color(0xFF25D366),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WhatsApp Support',
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Get help instantly via WhatsApp',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Options
          ...options.map((option) => _buildOption(context, option)),

          const SizedBox(height: 16),

          // Custom Message
          OutlinedButton.icon(
            onPressed: () => _openCustomMessage(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit),
            label: const Text('Write Custom Message'),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, WhatsAppQuickOption option) {
    return ListTile(
      onTap: () async {
        Navigator.pop(context);
        final success = await WhatsAppService.openWhatsAppSupport(
          message: option.message,
        );
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open WhatsApp'),
            ),
          );
        }
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(option.icon, size: 20),
      ),
      title: Text(option.title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  void _openCustomMessage(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => _CustomMessageDialog(projectNumber: projectNumber),
    );
  }
}

/// Custom message dialog
class _CustomMessageDialog extends StatefulWidget {
  final String? projectNumber;

  const _CustomMessageDialog({this.projectNumber});

  @override
  State<_CustomMessageDialog> createState() => _CustomMessageDialogState();
}

class _CustomMessageDialogState extends State<_CustomMessageDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.projectNumber != null) {
      _controller.text = 'Regarding project ${widget.projectNumber}: ';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Message'),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Type your message...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context);
            if (_controller.text.isNotEmpty) {
              await WhatsAppService.openWhatsAppSupport(
                message: _controller.text,
              );
            }
          },
          icon: const Icon(Icons.send, size: 18),
          label: const Text('Send'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Show WhatsApp support bottom sheet
void showWhatsAppSupportSheet(BuildContext context, {String? projectNumber}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => WhatsAppSupportSheet(projectNumber: projectNumber),
  );
}
