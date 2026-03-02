import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../api/api_client.dart';
import '../storage/token_storage.dart';

/// Socket.IO client for real-time communication.
class SocketClient {
  static IO.Socket? _socket;

  /// Get or create a connected socket instance.
  static Future<IO.Socket> getSocket() async {
    if (_socket != null && _socket!.connected) return _socket!;

    final token = await TokenStorage.getAccessToken();
    _socket = IO.io(
      ApiClient.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();
    return _socket!;
  }

  /// Disconnect and dispose the socket.
  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
