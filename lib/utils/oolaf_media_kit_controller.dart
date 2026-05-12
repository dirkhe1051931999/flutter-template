import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';

class OolafMediaKitController implements OolafVideoController {
  OolafMediaKitController._({
    required Player player,
    required VideoController videoController,
  })  : _player = player,
        _videoController = videoController;

  final Player _player;
  final VideoController _videoController;

  final ValueNotifier<bool> _isInitialized = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isBuffering = ValueNotifier<bool>(false);
  final ValueNotifier<Duration> _position =
      ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<Duration> _duration =
      ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<Size?> _videoSize = ValueNotifier<Size?>(null);

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _bufferingSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<VideoParams>? _videoParamsSub;

  bool _initialized = false;

  static Future<OolafMediaKitController> fromUrl(String url) async {
    final player = Player();
    final videoController = VideoController(player);

    final controller = OolafMediaKitController._(
      player: player,
      videoController: videoController,
    );

    await controller._open(url);
    return controller;
  }

  Future<void> _open(String url) async {
    await _player.open(Media(url), play: false);
  }

  @override
  ValueListenable<bool> get isInitialized => _isInitialized;

  @override
  ValueListenable<bool> get isPlaying => _isPlaying;

  @override
  ValueListenable<bool> get isBuffering => _isBuffering;

  @override
  ValueListenable<Duration> get position => _position;

  @override
  ValueListenable<Duration> get duration => _duration;

  @override
  ValueListenable<Size?> get videoSize => _videoSize;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    _playingSub = _player.stream.playing.listen((value) {
      _isPlaying.value = value;
    });
    _bufferingSub = _player.stream.buffering.listen((value) {
      _isBuffering.value = value;
    });
    _positionSub = _player.stream.position.listen((value) {
      _position.value = value;
    });
    _durationSub = _player.stream.duration.listen((value) {
      _duration.value = value;
    });
    _videoParamsSub = _player.stream.videoParams.listen((params) {
      final w = params.w;
      final h = params.h;
      if (w == null || h == null) {
        _videoSize.value = null;
        return;
      }
      _videoSize.value = Size(w.toDouble(), h.toDouble());
    });

    _isInitialized.value = true;
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> setLooping(bool looping) async {
    await _player.setPlaylistMode(
      looping ? PlaylistMode.single : PlaylistMode.none,
    );
  }

  @override
  Widget buildView({BoxFit fit = BoxFit.cover}) {
    return SizedBox.expand(
      child: Video(
        controller: _videoController,
        fit: fit,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await _playingSub?.cancel();
    await _bufferingSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _videoParamsSub?.cancel();

    _playingSub = null;
    _bufferingSub = null;
    _positionSub = null;
    _durationSub = null;
    _videoParamsSub = null;

    await _player.dispose();

    _isInitialized.dispose();
    _isPlaying.dispose();
    _isBuffering.dispose();
    _position.dispose();
    _duration.dispose();
    _videoSize.dispose();
  }
}
