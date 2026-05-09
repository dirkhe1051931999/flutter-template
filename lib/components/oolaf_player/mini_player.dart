import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_template_start/store/index.dart';
import 'package:flutter_template_start/store/oolaf_music/action.dart';
import 'package:flutter_template_start/store/oolaf_music/state.dart';
import 'package:flutter_template_start/utils/oolaf_audio_player.dart';
import 'package:flutter_template_start/components/oolaf_player/disc.dart';

class OolafMiniPlayer extends StatelessWidget {
  const OolafMiniPlayer({
    super.key,
    required this.onOpenPlayer,
  });

  final VoidCallback onOpenPlayer;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, OolafMusicState>(
      distinct: true,
      converter: (store) => store.state.oolafMusic,
      builder: (context, state) {
        final nowPlaying = state.nowPlaying;
        if (nowPlaying == null) {
          return const SizedBox.shrink();
        }

        const themeColor = Color(0xFFD43C33);

        return Material(
          color: Colors.white,
          child: InkWell(
            onTap: onOpenPlayer,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE9E9E9)),
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          OolafRotatingDisc(isPlaying: state.isPlaying),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              nowPlaying.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(width: 6),
                          StoreConnector<AppState, Future<void> Function()>(
                            converter: (store) {
                              return () async {
                                await oolafAudioPlayer.togglePlayPause();
                                store.dispatch(
                                  OolafSetPlayingAction(
                                    oolafAudioPlayer.isPlaying,
                                  ),
                                );
                              };
                            },
                            builder: (context, onToggle) {
                              return IconButton(
                                onPressed: () {
                                  onToggle();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 44,
                                  minHeight: 44,
                                ),
                                icon: Icon(
                                  state.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: themeColor,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    StreamBuilder<Duration>(
                      stream: oolafAudioPlayer.positionStream,
                      builder: (context, posSnap) {
                        return StreamBuilder<Duration?>(
                          stream: oolafAudioPlayer.durationStream,
                          builder: (context, durSnap) {
                            final position = posSnap.data ?? Duration.zero;
                            final duration = durSnap.data ?? Duration.zero;
                            final totalMs = duration.inMilliseconds;
                            final ratio = totalMs <= 0
                                ? 0.0
                                : (position.inMilliseconds / totalMs)
                                    .clamp(0.0, 1.0);

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (details) {
                                    if (totalMs <= 0) {
                                      return;
                                    }
                                    final x = details.localPosition.dx
                                        .clamp(0.0, constraints.maxWidth);
                                    final seekRatio = x / constraints.maxWidth;
                                    oolafAudioPlayer.seek(
                                      Duration(
                                        milliseconds:
                                            (totalMs * seekRatio).round(),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(99),
                                    child: LinearProgressIndicator(
                                      minHeight: 2,
                                      value: ratio,
                                      backgroundColor: const Color(0xFFE9E9E9),
                                      valueColor: const AlwaysStoppedAnimation(
                                        themeColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
