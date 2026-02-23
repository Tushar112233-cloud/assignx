import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/services/external_actions_service.dart';
import '../../../../core/theme/app_colors.dart';

/// WebView screen for external tools.
///
/// Loads external URLs like plagiarism checkers and AI detectors.
class ToolWebViewScreen extends StatefulWidget {
  const ToolWebViewScreen({
    super.key,
    required this.url,
    required this.title,
    this.toolColor,
  });

  /// URL to load.
  final String url;

  /// Screen title.
  final String title;

  /// Optional color for the tool.
  final Color? toolColor;

  @override
  State<ToolWebViewScreen> createState() => _ToolWebViewScreenState();
}

class _ToolWebViewScreenState extends State<ToolWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onProgress: (progress) {
            setState(() => _loadingProgress = progress / 100);
          },
          onWebResourceError: (error) {
            setState(() {
              _error = 'Failed to load: ${error.description}';
              _isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            // Allow navigation within the same domain
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final toolColor = widget.toolColor ?? AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'open_browser',
                child: Row(
                  children: [
                    Icon(Icons.open_in_browser, size: 20),
                    SizedBox(width: 12),
                    Text('Open in Browser'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy_url',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20),
                    SizedBox(width: 12),
                    Text('Copy URL'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: toolColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(toolColor),
                ),
              )
            : null,
      ),
      body: _error != null
          ? _ErrorView(
              error: _error!,
              onRetry: () {
                setState(() => _error = null);
                _controller.reload();
              },
            )
          : WebViewWidget(controller: _controller),
    );
  }

  void _handleMenuAction(String action) {
    final externalActions = ExternalActionsService.instance;

    switch (action) {
      case 'open_browser':
        externalActions.openUrl(widget.url);
        break;
      case 'copy_url':
        externalActions.copyToClipboard(widget.url, successMessage: 'URL copied to clipboard');
        break;
    }
  }
}

/// Plagiarism checker screen.
class PlagiarismCheckerScreen extends StatelessWidget {
  const PlagiarismCheckerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ToolWebViewScreen(
      url: 'https://www.turnitin.com',
      title: 'Plagiarism Checker',
      toolColor: Colors.red,
    );
  }
}

/// AI detector screen.
class AIDetectorScreen extends StatelessWidget {
  const AIDetectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ToolWebViewScreen(
      url: 'https://gptzero.me',
      title: 'AI Detector',
      toolColor: Colors.purple,
    );
  }
}

/// Error view for WebView.
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
