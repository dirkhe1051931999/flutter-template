import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/oolaf_player/player_sheet.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/action.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';
import 'package:oolaf_flutted/utils/oolaf_playback_persistence.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

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
  bool _miniVisible = false;
  bool _miniMounted = false;
  late final AnimationController _miniController;
  late final Animation<double> _miniWidthAnimation;
  late final Animation<double> _miniOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _miniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _miniWidthAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _miniController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    _miniOpacityAnimation = Tween<double>(
      begin: 0.35,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _miniController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _miniController.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    final store = StoreProvider.of<AppState>(context);
    await oolafAudioPlayer.togglePlayPause();
    if (!mounted) {
      return;
    }
    store.dispatch(OolafSetPlayingAction(oolafAudioPlayer.isPlaying));
  }

  Future<void> _openMiniPlayer() async {
    if (!mounted) {
      return;
    }
    if (_miniMounted && _miniVisible && _miniController.isCompleted) {
      return;
    }
    setState(() {
      _miniVisible = true;
      _miniMounted = true;
    });
    await _miniController.forward();
  }

  void _openPlayerSheet() {
    setState(() {
      _expanded = true;
      _miniVisible = false;
      _miniMounted = false;
    });
    _miniController.value = 0;
  }

  Future<void> _collapseMiniPlayer() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _miniVisible = false;
      _expanded = false;
    });
    await _miniController.reverse();
    if (!mounted) {
      return;
    }
    if (!_miniVisible) {
      setState(() {
        _miniMounted = false;
      });
    }
  }

  void _closePlayerSheet() {
    if (!mounted) {
      return;
    }
    setState(() {
      _expanded = false;
    });
    _openMiniPlayer();
  }

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
      _miniVisible = false;
      _miniMounted = false;
    });
    _miniController.value = 0;
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
                  onTap: _closePlayerSheet,
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
                                onClose: _closePlayerSheet,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (!_expanded && !_miniMounted)
              Positioned(
                right: 16,
                bottom: 24,
                child: _CollapsedBall(
                  state: state,
                  onTap: _openMiniPlayer,
                ),
              ),
            if (_miniMounted)
              Positioned(
                left: 22,
                right: 22,
                bottom: 22,
                child: IgnorePointer(
                  ignoring: !_miniVisible,
                  child: ClipRect(
                    child: SizeTransition(
                      sizeFactor: _miniWidthAnimation,
                      axis: Axis.horizontal,
                      axisAlignment: 1,
                      child: FadeTransition(
                        opacity: _miniOpacityAnimation,
                        child: _BottomMiniPlayer(
                          state: state,
                          onTogglePlayPause: _togglePlayPause,
                          onOpenPlayerSheet: _openPlayerSheet,
                          onNext: widget.onNext,
                          onCollapse: _collapseMiniPlayer,
                          onClose: _handleClose,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BottomMiniPlayer extends StatelessWidget {
  const _BottomMiniPlayer({
    required this.state,
    required this.onTogglePlayPause,
    required this.onOpenPlayerSheet,
    required this.onNext,
    required this.onCollapse,
    required this.onClose,
  });

  final OolafMusicState state;
  final Future<void> Function() onTogglePlayPause;
  final VoidCallback onOpenPlayerSheet;
  final Future<void> Function() onNext;
  final VoidCallback onCollapse;
  final Future<void> Function() onClose;

  @override
  Widget build(BuildContext context) {
    final nowPlaying = state.nowPlaying;
    if (nowPlaying == null) {
      return const SizedBox.shrink();
    }

    final isBuffering = state.playbackState == OolafPlaybackState.buffering;
    final statusText = state.isPlaying ? '正在播放' : '已暂停';

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CupertinoColors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
        border: const Border.fromBorderSide(
          BorderSide(
            color: Color(0x123C3C43),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 76,
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SizedBox(
                  height: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0x33D43C33),
                          Color(0x1AD43C33),
                          Color(0x00D43C33),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        alignment: Alignment.centerLeft,
                        onPressed: onOpenPlayerSheet,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nowPlaying.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              statusText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(34, 34),
                      onPressed: () {
                        onTogglePlayPause();
                      },
                      child: isBuffering
                          ? const CupertinoActivityIndicator(radius: 10)
                          : Icon(
                              state.isPlaying
                                  ? CupertinoIcons.pause
                                  : CupertinoIcons.play,
                              color: _themeColor,
                              size: 20,
                            ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(34, 34),
                      onPressed: () {
                        onNext();
                      },
                      child: const Icon(
                        CupertinoIcons.forward,
                        color: _themeColor,
                        size: 20,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(34, 34),
                      onPressed: onCollapse,
                      child: const Icon(
                        CupertinoIcons.chevron_down,
                        color: Color(0xFF8E8E93),
                        size: 18,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(34, 34),
                      onPressed: () {
                        onClose();
                      },
                      child: const Icon(
                        CupertinoIcons.xmark,
                        color: Color(0xFF8E8E93),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
              child: CustomNetworkImage(
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
                        : (position.inMilliseconds / totalMs).clamp(0.0, 1.0);
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
