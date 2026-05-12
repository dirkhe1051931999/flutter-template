import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/oolaf_player/player_sheet.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/action.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';
import 'package:oolaf_flutted/utils/oolaf_playback_persistence.dart';

const Color _themeColor = Color(0xFFD43C33);
const String _artUrl = 'https://picsum.photos/seed/oolaf-music/512/512';

class OolafFloatingBall extends StatefulWidget {
  const OolafFloatingBall({
    super.key,
    required this.onPrev,
    required this.onNext,
  });

  final Future<void> Function() onPrev;
  final Future<void> Function() onNext;

  @override
  State<OolafFloatingBall> createState() => _OolafFloatingBallState();
}

class _OolafFloatingBallState extends State<OolafFloatingBall>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  Future<void> _handleClose() async {
    final store = StoreProvider.of<AppState>(context);
    try {
      await oolafAudioPlayer.stop();
    } catch (_) {}
    if (!mounted) return;
    store.dispatch(const OolafResetPlaybackAction());
    store.dispatch(const OolafSetPlaybackStateAction(OolafPlaybackState.idle));
    await OolafPlaybackPersistence.clear();
    if (!mounted) return;
    setState(() {
      _expanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, OolafMusicState>(
      distinct: true,
      converter: (store) => store.state.oolafMusic,
      builder: (context, state) {
        if (state.nowPlaying == null) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            if (_expanded)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _expanded = false),
                  child: ColoredBox(
                    color: const Color(0x66000000),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Center(
                          child: SingleChildScrollView(
                            child: GestureDetector(
                              onTap: () {},
                              child: OolafPlayerSheet(
                                onPrev: widget.onPrev,
                                onNext: widget.onNext,
                                onClose: _handleClose,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (!_expanded)
              Positioned(
                right: 16,
                bottom: 24,
                child: _CollapsedBall(
                  state: state,
                  onTap: () => setState(() => _expanded = true),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CollapsedBall extends StatelessWidget {
  const _CollapsedBall({
    required this.state,
    required this.onTap,
  });

  final OolafMusicState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const ballSize = 64.0;
    const innerSize = 50.0;
    final isBuffering = state.playbackState == OolafPlaybackState.buffering;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: ballSize,
        height: ballSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: ballSize,
              height: ballSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            ClipOval(
              child: Image.network(
                _artUrl,
                width: innerSize,
                height: innerSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: innerSize,
                    height: innerSize,
                    color: const Color(0xFFF2F3F4),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.music_note,
                      color: _themeColor,
                      size: 22,
                    ),
                  );
                },
              ),
            ),
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
                    return SizedBox(
                      width: ballSize,
                      height: ballSize,
                      child: CircularProgressIndicator(
                        value: ratio,
                        strokeWidth: 3,
                        backgroundColor: const Color(0x22000000),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(_themeColor),
                      ),
                    );
                  },
                );
              },
            ),
            if (isBuffering)
              Container(
                width: innerSize,
                height: innerSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x66000000),
                ),
                alignment: Alignment.center,
                child: const CupertinoActivityIndicator(
                  radius: 10,
                  color: Colors.white,
                ),
              ),
            if (!isBuffering && !state.isPlaying)
              const Positioned(
                right: 4,
                bottom: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      CupertinoIcons.play_fill,
                      size: 12,
                      color: _themeColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
