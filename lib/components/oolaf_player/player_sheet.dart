import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/action.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';
import 'package:oolaf_flutted/components/oolaf_player/disc.dart';
import 'package:oolaf_flutted/components/oolaf_player/progress_bar.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

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

        const sheetBackground = Color(0xFFFAF7F5);
        final bodyTextStyle = CupertinoTheme.of(context).textTheme.textStyle;
        final titleBlockStyle = bodyTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1C1C1E),
          height: 1.16,
        );
        final filenameStyle = bodyTextStyle.copyWith(
          fontSize: 10,
          color: const Color(0x7A1C1C1E),
        );
        final statusTextStyle = bodyTextStyle.copyWith(
          fontSize: 11,
          color: const Color(0x8A1C1C1E),
        );
        const controlBackground = Color(0x14D43C33);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: sheetBackground,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 26,
                    offset: Offset(0, 14),
                  ),
                ],
                border: Border.all(
                  color: const Color(0x66FFFFFF),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onClose != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(28, 28),
                          onPressed: onClose,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0x1F000000),
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.xmark,
                                  color: Color(0xFF8E8E93),
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CustomNetworkImage(
                            artUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 72,
                                height: 72,
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
                                style: titleBlockStyle,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                nowPlaying.cdnUrl.split('/').last,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: filenameStyle,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    state.isPlaying
                                        ? CupertinoIcons.speaker_2_fill
                                        : CupertinoIcons.speaker,
                                    size: 14,
                                    color: const Color(0x8A000000),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      statusText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: statusTextStyle,
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
                      size: 188,
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
                              sliderPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlButton(
                          onPressed: () {
                            final next = switch (state.loopMode) {
                              OolafLoopMode.off => OolafLoopMode.all,
                              OolafLoopMode.all => OolafLoopMode.one,
                              OolafLoopMode.one => OolafLoopMode.off,
                            };

                            StoreProvider.of<AppState>(context)
                                .dispatch(OolafSetLoopModeAction(next));
                          },
                          backgroundColor: controlBackground,
                          child: AppAssetIcon(
                            assetName: state.loopMode == OolafLoopMode.one
                                ? 'repeat-1'
                                : 'repeat',
                            color: state.loopMode == OolafLoopMode.off
                                ? const Color(0xFF8E8E93)
                                : themeColor,
                            fallbackIcon: switch (state.loopMode) {
                              OolafLoopMode.off => CupertinoIcons.repeat,
                              OolafLoopMode.all => CupertinoIcons.repeat,
                              OolafLoopMode.one => CupertinoIcons.repeat_1,
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildControlButton(
                          onPressed: () {
                            onPrev();
                          },
                          backgroundColor: controlBackground,
                          child: const AppAssetIcon(
                            assetName: 'play-skip-back',
                            color: themeColor,
                            size: 26,
                            fallbackIcon: CupertinoIcons.backward_fill,
                          ),
                        ),
                        const SizedBox(width: 16),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(54, 54),
                          onPressed: () async {
                            final store = StoreProvider.of<AppState>(context);
                            await oolafAudioPlayer.togglePlayPause();
                            store.dispatch(
                              OolafSetPlayingAction(oolafAudioPlayer.isPlaying),
                            );
                          },
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x33D43C33),
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: isBuffering
                                    ? const CupertinoActivityIndicator(
                                        radius: 14,
                                        color: CupertinoColors.white,
                                      )
                                    : AppAssetIcon(
                                        assetName: state.isPlaying
                                            ? 'pause'
                                            : 'play',
                                        color: CupertinoColors.white,
                                        size: 24,
                                        fallbackIcon: state.isPlaying
                                            ? CupertinoIcons.pause_fill
                                            : CupertinoIcons.play_fill,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildControlButton(
                          onPressed: () {
                            onNext();
                          },
                          backgroundColor: controlBackground,
                          child: const AppAssetIcon(
                            assetName: 'play-skip-forward',
                            color: themeColor,
                            size: 26,
                            fallbackIcon: CupertinoIcons.forward_fill,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required Widget child,
    required Color backgroundColor,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(40, 40),
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: child),
        ),
      ),
    );
  }
}
