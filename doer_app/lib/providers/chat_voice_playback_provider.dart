import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';

/// Shared [AudioPlayer] per chat room — only one voice note plays at a time (WhatsApp-style).
class ChatVoicePlayback extends ChangeNotifier {
  ChatVoicePlayback() {
    _player.playingStream.listen((_) {
      notifyListeners();
    });
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
        notifyListeners();
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  String? _activeMessageId;
  bool _isToggling = false;
  String? _togglingMessageId;

  AudioPlayer get player => _player;
  bool get isToggling => _isToggling;
  bool isBusyFor(String messageId) => _isToggling && _togglingMessageId == messageId;

  bool isThisClip(String messageId) => _activeMessageId == messageId;

  Future<void> toggle(String messageId, String url) async {
    if (_isToggling) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    _isToggling = true;
    _togglingMessageId = messageId;
    notifyListeners();
    try {
      if (_activeMessageId == messageId && _player.playing) {
        await _player.pause();
        return;
      }

      if (_activeMessageId != messageId) {
        await _player.stop();
        await _player.setAudioSource(AudioSource.uri(uri));
        _activeMessageId = messageId;
      }
      await _player.play();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatVoicePlayback.toggle: $e');
      }
    } finally {
      _isToggling = false;
      _togglingMessageId = null;
      notifyListeners();
    }
  }

  Future<void> seekToFraction(double fraction) async {
    final total = _player.duration;
    if (total == null || total.inMilliseconds <= 0) return;
    final f = fraction.clamp(0.0, 1.0);
    await _player.seek(
      Duration(milliseconds: (total.inMilliseconds * f).round()),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final chatVoicePlaybackProvider =
    ChangeNotifierProvider.autoDispose.family<ChatVoicePlayback, String>(
  (ref, roomId) => ChatVoicePlayback(),
);
