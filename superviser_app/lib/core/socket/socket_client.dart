import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../api/api_client.dart';
import '../storage/token_storage.dart';

/// Socket.IO client for real-time features.
///
/// Connects to the Express API server using JWT auth.
class SocketClient {
  static io.Socket? _socket;

  /// Get the Socket.IO instance, creating if needed.
  static Future<io.Socket> getInstance() async {
    if (_socket != null && _socket!.connected) return _socket!;

    final token = await TokenStorage.getAccessToken();

    _socket = io.io(
      ApiClient.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token ?? ''})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      if (kDebugMode) debugPrint('SocketClient connected');
    });

    _socket!.onDisconnect((_) {
      if (kDebugMode) debugPrint('SocketClient disconnected');
    });

    _socket!.onError((err) {
      if (kDebugMode) debugPrint('SocketClient error: $err');
    });

    return _socket!;
  }

  /// Disconnect and dispose the socket.
  static void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
