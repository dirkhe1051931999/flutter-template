import 'package:flutter/cupertino.dart';
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

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Material(
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
                                      ?.copyWith(fontWeight: FontWeight.w600),
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
                                  icon: const Icon(
                                    CupertinoIcons.backward_fill,
                                    color: themeColor,
                                    size: 20,
                                  ),
                                ),
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
                                          ? CupertinoIcons.pause_circle_fill
                                          : CupertinoIcons.play_circle_fill,
                                      color: themeColor,
                                      size: 40,
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
                                  icon: const Icon(
                                    CupertinoIcons.forward_fill,
                                    color: themeColor,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                        final seekRatio =
                                            x / constraints.maxWidth;
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
        );
      },
    );
  }
}
