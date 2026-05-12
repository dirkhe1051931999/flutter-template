import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/action.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';
import 'package:oolaf_flutted/components/oolaf_player/disc.dart';
import 'package:oolaf_flutted/components/oolaf_player/progress_bar.dart';

class OolafPlayerSheet extends StatelessWidget {
  const OolafPlayerSheet({
    super.key,
    required this.onPrev,
    required this.onNext,
    this.onClose,
  });

  final Future<void> Function() onPrev;
  final Future<void> Function() onNext;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, OolafMusicState>(
      distinct: true,
      converter: (store) => store.state.oolafMusic,
      builder: (context, state) {
        final nowPlaying = state.nowPlaying;
        const themeColor = Color(0xFFD43C33);
        const artUrl = 'https://picsum.photos/seed/oolaf-music/512/512';
        final isBuffering =
            state.playbackState == OolafPlaybackState.buffering;
        final statusText = switch (state.playbackState) {
          OolafPlaybackState.buffering => '缓冲中',
          OolafPlaybackState.completed => '播放完成',
          OolafPlaybackState.ready => '就绪',
          OolafPlaybackState.paused => '已暂停',
          OolafPlaybackState.playing => '正在播放',
          OolafPlaybackState.idle => '空闲',
          OolafPlaybackState.disposed => '已释放',
        };

        if (nowPlaying == null) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFEFEF),
                    Color(0xFFFFFFFF),
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onClose != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(36, 36),
                        onPressed: onClose,
                        child: const Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: Color(0xFFB0B0B0),
                          size: 26,
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          artUrl,
                          width: 112,
                          height: 112,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 112,
                              height: 112,
                              color: const Color(0xFFF2F3F4),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nowPlaying.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  state.isPlaying
                                      ? CupertinoIcons.speaker_2_fill
                                      : CupertinoIcons.speaker,
                                  size: 16,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    statusText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  OolafRotatingDisc(
                    isPlaying: state.isPlaying,
                    size: 200,
                    title: nowPlaying.title,
                    showTonearm: true,
                  ),
                  const SizedBox(height: 18),
                  StreamBuilder<Duration>(
                    stream: oolafAudioPlayer.positionStream,
                    builder: (context, posSnap) {
                      return StreamBuilder<Duration?>(
                        stream: oolafAudioPlayer.durationStream,
                        builder: (context, durSnap) {
                          final position = posSnap.data ?? Duration.zero;
                          final duration = durSnap.data ?? Duration.zero;
                          return OolafProgressBar(
                            position: position,
                            duration: duration,
                            onSeek: (to) {
                              oolafAudioPlayer.seek(to);
                            },
                            activeColor: themeColor,
                            sliderPadding:
                                const EdgeInsets.symmetric(horizontal: 6),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          final next = switch (state.loopMode) {
                            OolafLoopMode.off => OolafLoopMode.all,
                            OolafLoopMode.all => OolafLoopMode.one,
                            OolafLoopMode.one => OolafLoopMode.off,
                          };

                          StoreProvider.of<AppState>(context)
                              .dispatch(OolafSetLoopModeAction(next));
                        },
                        icon: Icon(
                          switch (state.loopMode) {
                            OolafLoopMode.off => CupertinoIcons.repeat,
                            OolafLoopMode.all => CupertinoIcons.repeat,
                            OolafLoopMode.one => CupertinoIcons.repeat_1,
                          },
                          color: state.loopMode == OolafLoopMode.off
                              ? const Color(0xFF8E8E93)
                              : themeColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          onPrev();
                        },
                        icon: const Icon(
                          CupertinoIcons.backward_fill,
                          color: themeColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () async {
                          final store = StoreProvider.of<AppState>(context);
                          await oolafAudioPlayer.togglePlayPause();
                          store.dispatch(OolafSetPlayingAction(
                            oolafAudioPlayer.isPlaying,
                          ));
                        },
                        icon: isBuffering
                            ? const SizedBox(
                                width: 52,
                                height: 52,
                                child: CupertinoActivityIndicator(radius: 16),
                              )
                            : Icon(
                                state.isPlaying
                                    ? CupertinoIcons.pause_circle_fill
                                    : CupertinoIcons.play_circle_fill,
                                color: themeColor,
                                size: 64,
                              ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () {
                          onNext();
                        },
                        icon: const Icon(
                          CupertinoIcons.forward_fill,
                          color: themeColor,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
