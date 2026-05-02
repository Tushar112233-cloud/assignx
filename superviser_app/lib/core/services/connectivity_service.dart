import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'snackbar_service.dart';

/// Connection status enum.
enum ConnectionStatus {
  online,
  offline,
  unknown,
}

/// Connectivity state.
class ConnectivityState {
  const ConnectivityState({
    this.status = ConnectionStatus.unknown,
    this.connectionTypes = const [],
    this.isConnected = true,
  });

  final ConnectionStatus status;
  final List<ConnectivityResult> connectionTypes;
  final bool isConnected;

  ConnectivityState copyWith({
    ConnectionStatus? status,
    List<ConnectivityResult>? connectionTypes,
    bool? isConnected,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      connectionTypes: connectionTypes ?? this.connectionTypes,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  /// Check if on WiFi.
  bool get isWifi => connectionTypes.contains(ConnectivityResult.wifi);

  /// Check if on mobile data.
  bool get isMobile => connectionTypes.contains(ConnectivityResult.mobile);

  /// Check if on ethernet.
  bool get isEthernet => connectionTypes.contains(ConnectivityResult.ethernet);

  /// Get connection type description.
  String get connectionDescription {
    if (!isConnected) return 'No internet connection';
    if (isWifi) return 'Connected via WiFi';
    if (isMobile) return 'Connected via Mobile Data';
    if (isEthernet) return 'Connected via Ethernet';
    return 'Connected';
  }
}

/// Connectivity service notifier.
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier({
    Connectivity? connectivity,
    SnackbarService? snackbarService,
  })  : _connectivity = connectivity ?? Connectivity(),
        _snackbarService = snackbarService,
        super(const ConnectivityState()) {
    _init();
  }

  final Connectivity _connectivity;
  final SnackbarService? _snackbarService;
  StreamSubscription<ConnectivityResult>? _subscription;
  bool _wasOffline = false;

  void _init() {
    // Check initial connectivity
    _checkConnectivity();

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityChange([result]);
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _handleConnectivityChange([result]);
    } catch (e) {
      state = state.copyWith(
        status: ConnectionStatus.unknown,
        isConnected: true, // Assume connected if check fails
      );
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isConnected = results.isNotEmpty && !results.contains(ConnectivityResult.none);

    final newStatus = isConnected ? ConnectionStatus.online : ConnectionStatus.offline;

    // Show snackbar on connectivity changes
    if (_wasOffline && isConnected) {
      _snackbarService?.showSuccess('Back online');
    } else if (!_wasOffline && !isConnected) {
      _snackbarService?.showWarning(
        'No internet connection',
        actionLabel: 'Retry',
        onAction: refresh,
      );
    }

    _wasOffline = !isConnected;

    state = ConnectivityState(
      status: newStatus,
      connectionTypes: results,
      isConnected: isConnected,
    );
  }

  /// Refresh connectivity status.
  Future<void> refresh() async {
    await _checkConnectivity();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider for connectivity service.
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  final snackbarService = ref.watch(snackbarServiceProvider);
  return ConnectivityNotifier(snackbarService: snackbarService);
});

/// Provider for checking if app is online.
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).isConnected;
});

/// Provider for connection status.
final connectionStatusProvider = Provider<ConnectionStatus>((ref) {
  return ref.watch(connectivityProvider).status;
});

/// Offline banner widget.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({
    super.key,
    this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);

    if (connectivityState.isConnected) {
      return const SizedBox.shrink();
    }

    return MaterialBanner(
      backgroundColor: Colors.red.shade50,
      leading: const Icon(Icons.wifi_off, color: Colors.red),
      content: const Text(
        'No internet connection',
        style: TextStyle(color: Colors.red),
      ),
      actions: [
        TextButton(
          onPressed: onRetry ?? () => ref.read(connectivityProvider.notifier).refresh(),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

/// Offline indicator widget for AppBar.
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Offline',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper that shows offline UI when not connected.
class OfflineWrapper extends ConsumerWidget {
  const OfflineWrapper({
    super.key,
    required this.child,
    this.offlineWidget,
    this.showBanner = true,
  });

  final Widget child;
  final Widget? offlineWidget;
  final bool showBanner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    if (!isOnline && offlineWidget != null) {
      return offlineWidget!;
    }

    return Column(
      children: [
        if (showBanner) const OfflineBanner(),
        Expanded(child: child),
      ],
    );
  }
}

/// Mixin for handling offline state in screens.
mixin OfflineAwareMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Whether the widget should react to connectivity changes.
  bool get reactToConnectivity => true;

  /// Called when connection is restored.
  void onConnectionRestored() {}

  /// Called when connection is lost.
  void onConnectionLost() {}

  bool _wasOnline = true;

  @override
  void initState() {
    super.initState();
    if (reactToConnectivity) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _wasOnline = ref.read(isOnlineProvider);
      });
    }
  }

  void checkConnectivityChange() {
    if (!reactToConnectivity) return;

    final isOnline = ref.read(isOnlineProvider);
    if (!_wasOnline && isOnline) {
      onConnectionRestored();
    } else if (_wasOnline && !isOnline) {
      onConnectionLost();
    }
    _wasOnline = isOnline;
  }
}

/// Extension for running operations only when online.
extension OnlineOperationExtension on WidgetRef {
  /// Execute operation only if online.
  Future<T?> runOnline<T>(Future<T> Function() operation) async {
    final isOnline = read(isOnlineProvider);
    if (!isOnline) {
      read(snackbarServiceProvider).showWarning('No internet connection');
      return null;
    }
    return operation();
  }

  /// Execute operation with offline fallback.
  Future<T> runWithOfflineFallback<T>(
    Future<T> Function() onlineOperation,
    T Function() offlineFallback,
  ) async {
    final isOnline = read(isOnlineProvider);
    if (!isOnline) {
      return offlineFallback();
    }
    return onlineOperation();
  }
}
