import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Read-only WebView for viewing live drafts (Google Docs, etc.).
///
/// Security measures implemented:
/// - Only HTTPS URLs are allowed
/// - Domain whitelist enforced (Google Docs, Figma, etc.)
/// - Navigation restricted to allowed domains only
class LiveDraftWebview extends StatefulWidget {
  final String projectId;
  final String? draftUrl;

  const LiveDraftWebview({
    super.key,
    required this.projectId,
    this.draftUrl,
  });

  @override
  State<LiveDraftWebview> createState() => _LiveDraftWebviewState();
}

class _LiveDraftWebviewState extends State<LiveDraftWebview> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _error;
  int _progress = 0;

  /// Allowed domains for draft viewing.
  /// Only these domains and their subdomains are permitted.
  static const List<String> _allowedDomains = [
    'google.com',
    'docs.google.com',
    'sheets.google.com',
    'slides.google.com',
    'drive.google.com',
    'figma.com',
    'www.figma.com',
    'notion.so',
    'www.notion.so',
  ];

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  /// Validates if a URL is allowed based on security rules.
  ///
  /// Requirements:
  /// - Must be a valid URL
  /// - Must use HTTPS scheme (not http, javascript, file, data, etc.)
  /// - Must be from an allowed domain
  bool _isAllowedUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Only allow HTTPS - reject http, javascript:, file:, data:, etc.
      if (uri.scheme != 'https') {
        debugPrint('WebView security: Blocked non-HTTPS URL: $url');
        return false;
      }

      final host = uri.host.toLowerCase();

      // Check if host matches an allowed domain or is a subdomain of one
      for (final domain in _allowedDomains) {
        if (host == domain || host.endsWith('.$domain')) {
          return true;
        }
      }

      debugPrint('WebView security: Blocked URL from untrusted domain: $host');
      return false;
    } catch (e) {
      debugPrint('WebView security: Failed to parse URL: $url');
      return false;
    }
  }

  void _initWebView() {
    final url = widget.draftUrl;

    // Check if URL is provided
    if (url == null || url.isEmpty) {
      setState(() {
        _error = 'No draft URL available';
        _isLoading = false;
      });
      return;
    }

    // Validate URL before loading (security check)
    if (!_isAllowedUrl(url)) {
      setState(() {
        _error = 'This URL is not allowed for security reasons. '
            'Only Google Docs, Figma, and Notion links are supported.';
        _isLoading = false;
      });
      return;
    }

    final controller = WebViewController()
      // JavaScript is required for Google Docs/Figma to function
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _progress = progress;
            });
          },
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _error = 'Failed to load document. Please check your connection.';
            });
          },
          onNavigationRequest: (request) {
            // Validate every navigation request
            if (_isAllowedUrl(request.url)) {
              return NavigationDecision.navigate;
            }
            // Block navigation to disallowed URLs
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Draft'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller != null ? () => _controller!.reload() : null,
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress / 100,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _ErrorView(
        error: _error!,
        onRetry: () {
          setState(() {
            _error = null;
            _isLoading = true;
          });
          _controller?.reload();
        },
      );
    }

    if (widget.draftUrl == null) {
      return const _NoUrlView();
    }

    return Stack(
      children: [
        if (_controller != null) WebViewWidget(controller: _controller!),

        // Read-only overlay banner
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.visibility_outlined,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Only Mode',
                        style: AppTextStyles.labelMedium,
                      ),
                      Text(
                        'You can view but not edit this document',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoUrlView extends StatelessWidget {
  const _NoUrlView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description_outlined,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Draft Available',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The live draft for this project is not yet available. Check back later.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
