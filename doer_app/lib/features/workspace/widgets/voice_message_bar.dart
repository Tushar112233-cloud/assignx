import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/chat_voice_playback_provider.dart';

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
    final isBusy = playback.isBusyFor(messageId);
    final pos = isThis ? playback.player.position : Duration.zero;
    final dur = isThis ? (playback.player.duration ?? Duration.zero) : Duration.zero;
    final frac = dur.inMilliseconds > 0
        ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final durationLabel = isThis && dur > Duration.zero
        ? (playing || pos > Duration.zero ? _fmt(pos) : _fmt(dur))
        : '--:--';

    return Container(
      constraints: const BoxConstraints(minWidth: 210, maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: pillBackgroundColor,
        border: Border.all(
          color: progressForegroundColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: progressForegroundColor.withValues(alpha: 0.2),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: isBusy ? null : () => playback.toggle(messageId, audioUrl),
                child: Icon(
                  isBusy
                      ? Icons.hourglass_top_rounded
                      : (playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  size: 24,
                  color: playIconColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: StreamBuilder<Duration>(
              stream: isThis ? playback.player.positionStream : null,
              builder: (context, _) {
                final livePos = isThis ? playback.player.position : Duration.zero;
                final liveDur = isThis ? (playback.player.duration ?? Duration.zero) : Duration.zero;
                final liveFrac = liveDur.inMilliseconds > 0
                    ? (livePos.inMilliseconds / liveDur.inMilliseconds).clamp(0.0, 1.0)
                    : frac;
                final liveDurationLabel = isThis && liveDur > Duration.zero
                    ? (playing || livePos > Duration.zero ? _fmt(livePos) : _fmt(liveDur))
                    : durationLabel;
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
                          _WaveformBar(
                            progress: liveFrac,
                            playedColor: progressForegroundColor,
                            idleColor: progressBackgroundColor.withValues(alpha: 0.65),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            liveDurationLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: timeLabelColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformBar extends StatelessWidget {
  final double progress;
  final Color playedColor;
  final Color idleColor;

  const _WaveformBar({
    required this.progress,
    required this.playedColor,
    required this.idleColor,
  });

  @override
  Widget build(BuildContext context) {
    const heights = <double>[4, 6, 5, 8, 6, 10, 7, 5, 9, 6, 8, 5, 7, 6, 9, 5, 8, 6, 7, 5, 9, 6, 8, 5];
    return LayoutBuilder(
      builder: (context, c) {
        final clamped = progress.clamp(0.0, 1.0);
        final playedBars = (heights.length * clamped).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(heights.length, (i) {
            return Container(
              width: 2,
              height: heights[i],
              decoration: BoxDecoration(
                color: i < playedBars ? playedColor : idleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
