import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/action.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';
import 'package:oolaf_flutted/components/oolaf_player/disc.dart';

class OolafMiniPlayer extends StatelessWidget {
  const OolafMiniPlayer({
    super.key,
    required this.onOpenPlayer,
    this.onPrev,
    this.onNext,
  });

  final VoidCallback onOpenPlayer;
  final Future<void> Function()? onPrev;
  final Future<void> Function()? onNext;

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

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 1,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                  color: Color(0x1F3C3C43),
                ),
              ),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 22,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: onOpenPlayer,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      nowPlaying.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (onPrev != null)
                                    IconButton(
                                      onPressed: () {
                                        onPrev?.call();
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      icon: const AppAssetIcon(
                                        assetName: 'play-skip-back',
                                        color: themeColor,
                                        size: 20,
                                        fallbackIcon: CupertinoIcons.backward_fill,
                                      ),
                                    ),
                                  StoreConnector<AppState,
                                      Future<void> Function()>(
                                    converter: (store) {
                                      return () async {
                                        await oolafAudioPlayer
                                            .togglePlayPause();
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
                                        icon: isBuffering
                                            ? const SizedBox(
                                                width: 36,
                                                height: 36,
                                                child:
                                                    CupertinoActivityIndicator(
                                                  radius: 12,
                                                ),
                                              )
                                            : AppAssetIcon(
                                                assetName: state.isPlaying
                                                    ? 'pause-circle'
                                                    : 'play-circle',
                                                color: themeColor,
                                                size: 40,
                                                fallbackIcon: state.isPlaying
                                                    ? CupertinoIcons.pause_circle_fill
                                                    : CupertinoIcons.play_circle_fill,
                                              ),
                                      );
                                    },
                                  ),
                                  if (onNext != null)
                                    IconButton(
                                      onPressed: () {
                                        onNext?.call();
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      icon: const AppAssetIcon(
                                        assetName: 'play-skip-forward',
                                        color: themeColor,
                                        size: 20,
                                        fallbackIcon: CupertinoIcons.forward_fill,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
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
                            const SizedBox(height: 6),
                            StreamBuilder<Duration>(
                              stream: oolafAudioPlayer.positionStream,
                              builder: (context, posSnap) {
                                return StreamBuilder<Duration?>(
                                  stream: oolafAudioPlayer.durationStream,
                                  builder: (context, durSnap) {
                                    final position =
                                        posSnap.data ?? Duration.zero;
                                    final duration =
                                        durSnap.data ?? Duration.zero;
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
                                                .clamp(
                                                    0.0, constraints.maxWidth);
                                            final seekRatio =
                                                x / constraints.maxWidth;
                                            oolafAudioPlayer.seek(
                                              Duration(
                                                milliseconds:
                                                    (totalMs * seekRatio)
                                                        .round(),
                                              ),
                                            );
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(99),
                                            child: LinearProgressIndicator(
                                              minHeight: 2,
                                              value: ratio,
                                              backgroundColor:
                                                  const Color(0xFFE9E9E9),
                                              valueColor:
                                                  const AlwaysStoppedAnimation(
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
