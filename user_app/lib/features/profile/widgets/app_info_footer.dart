import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_text_styles.dart';

// ============================================================
// DESIGN CONSTANTS
// ============================================================

class _FooterColors {
  static const mutedText = Color(0xFF8B8B8B);
  static const linkText = Color(0xFF6B6B6B);
}

// ============================================================
// WIDGET
// ============================================================

/// App info footer displaying version and legal links.
/// Meant to be placed at the bottom of the profile screen scroll view.
class AppInfoFooter extends StatelessWidget {
  const AppInfoFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Version text
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '1.0.0';
              return Text(
                'AssignX v$version',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  color: _FooterColors.mutedText,
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Legal links row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink(
                text: 'Terms',
                onTap: () => _launchUrl('https://assignx.in/terms'),
              ),
              Text(
                ' \u00B7 ',
                style: AppTextStyles.caption.copyWith(
                  color: _FooterColors.mutedText,
                ),
              ),
              _FooterLink(
                text: 'Privacy',
                onTap: () => _launchUrl('https://assignx.in/privacy'),
              ),
              Text(
                ' \u00B7 ',
                style: AppTextStyles.caption.copyWith(
                  color: _FooterColors.mutedText,
                ),
              ),
              _FooterLink(
                text: 'Help',
                onTap: () => _launchUrl('https://assignx.in/help'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ============================================================
// PRIVATE WIDGETS
// ============================================================

/// A tappable text link for the footer.
class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          fontSize: 12,
          color: _FooterColors.linkText,
          decoration: TextDecoration.underline,
          decorationColor: _FooterColors.linkText,
        ),
      ),
    );
  }
}
