import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../providers/chat_voice_playback_provider.dart';

/// Lazy duration probe per URL (cached) for rows that are not currently playing.
class VoiceDurationCache {
  VoiceDurationCache._();

  static final Map<String, Duration> _cache = {};
  static final Map<String, Future<Duration?>> _inflight = {};

  static Future<Duration?> durationFor(String url) {
    if (_cache.containsKey(url)) {
      return Future.value(_cache[url]);
    }
    return _inflight.putIfAbsent(url, () async {
      try {
        final p = AudioPlayer();
        await p.setAudioSource(AudioSource.uri(Uri.parse(url)));
        final d = await p.durationFuture;
        await p.dispose();
        if (d != null) {
          _cache[url] = d;
        }
        _inflight.remove(url);
        return d;
      } catch (_) {
        _inflight.remove(url);
        return null;
      }
    });
  }
}

/// WhatsApp-style inline voice row: play/pause, scrub, elapsed/total time.
class VoiceMessageBar extends ConsumerWidget {
  final String roomId;
  final String messageId;
  final String audioUrl;
  final Color playIconColor;
  final Color progressBackgroundColor;
  final Color progressForegroundColor;
  final Color timeLabelColor;
  final Color pillBackgroundColor;

  const VoiceMessageBar({
    super.key,
    required this.roomId,
    required this.messageId,
    required this.audioUrl,
    required this.playIconColor,
    required this.progressBackgroundColor,
    required this.progressForegroundColor,
    required this.timeLabelColor,
    required this.pillBackgroundColor,
  });

  static String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(chatVoicePlaybackProvider(roomId));
    final isThis = playback.isThisClip(messageId);
    final playing = isThis && playback.player.playing;

    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: pillBackgroundColor,
        border: Border.all(
          color: progressForegroundColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => playback.toggle(messageId, audioUrl),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 30,
                  color: playIconColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: isThis
                ? StreamBuilder<Duration>(
                    stream: playback.player.positionStream,
                    builder: (context, _) {
                      final pos = playback.player.position;
                      final dur = playback.player.duration ?? Duration.zero;
                      final frac = dur.inMilliseconds > 0
                          ? pos.inMilliseconds / dur.inMilliseconds
                          : 0.0;
                      return LayoutBuilder(
                        builder: (context, c) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: (d) {
                              final w = c.maxWidth;
                              if (w <= 0) return;
                              playback.seekToFraction(d.localPosition.dx / w);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: frac.clamp(0.0, 1.0),
                                    minHeight: 3,
                                    backgroundColor: progressBackgroundColor
                                        .withValues(alpha: 0.5),
                                    color: progressForegroundColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${_fmt(pos)} / ${_fmt(dur)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: timeLabelColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  )
                : FutureBuilder<Duration?>(
                    future: VoiceDurationCache.durationFor(audioUrl),
                    builder: (context, snap) {
                      final dur = snap.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: 0,
                              minHeight: 3,
                              backgroundColor:
                                  progressBackgroundColor.withValues(alpha: 0.5),
                              color: progressForegroundColor.withValues(alpha: 0.35),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              dur != null ? _fmt(dur) : '--:--',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: timeLabelColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
