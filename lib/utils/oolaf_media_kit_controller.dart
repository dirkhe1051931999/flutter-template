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
  final ValueNotifier<OolafVideoOutputStatus> _videoOutputStatus =
      ValueNotifier<OolafVideoOutputStatus>(OolafVideoOutputStatus.normal);

  static const Duration _blackScreenDetectDelay = Duration(seconds: 3);
  static const Duration _blackScreenMinProgress = Duration(milliseconds: 900);
  static const Duration _bufferingTimeout = Duration(seconds: 15);

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<bool>? _bufferingSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<VideoParams>? _videoParamsSub;
  StreamSubscription<String>? _errorSub;

  Timer? _blackScreenTimer;
  Timer? _bufferingTimeoutTimer;
  Duration _blackScreenStartPosition = Duration.zero;
  bool _firstFrameRendered = false;
  int _firstFrameMonitorToken = 0;

  bool _initialized = false;
  bool _disposed = false;

  bool get _isAlive => !_disposed;

  static VideoControllerConfiguration _createVideoConfiguration() {
    if (kIsWeb) {
      return const VideoControllerConfiguration();
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return const VideoControllerConfiguration(
        vo: 'gpu',
        hwdec: 'no',
        enableHardwareAcceleration: false,
        androidAttachSurfaceAfterVideoParameters: false,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.windows) {
      return const VideoControllerConfiguration(
        vo: 'libmpv',
        hwdec: 'no',
        enableHardwareAcceleration: false,
      );
    }

    return const VideoControllerConfiguration(
      vo: 'gpu',
      hwdec: 'auto-safe',
      enableHardwareAcceleration: true,
    );
  }

  static Future<OolafMediaKitController> fromUrl(String url) async {
    final videoConfiguration = _createVideoConfiguration();
    final player = Player(
      configuration: PlayerConfiguration(
        vo: videoConfiguration.vo,
      ),
    );
    final videoController = VideoController(
      player,
      configuration: videoConfiguration,
    );

    final controller = OolafMediaKitController._(
      player: player,
      videoController: videoController,
    );

    await controller._open(url);
    return controller;
  }

  Future<void> _open(String url) async {
    if (!_isAlive) {
      return;
    }
    _firstFrameMonitorToken++;
    _firstFrameRendered = false;
    _videoOutputStatus.value = OolafVideoOutputStatus.normal;
    _cancelBlackScreenTimer();
    await WidgetsBinding.instance.endOfFrame;
    if (!_isAlive) {
      return;
    }
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
  ValueListenable<OolafVideoOutputStatus> get videoOutputStatus =>
      _videoOutputStatus;

  bool get _hasRenderableVideo {
    final size = _videoSize.value;
    if (size == null) {
      return false;
    }
    return size.width > 0 && size.height > 0;
  }

  bool get _hasVideoOutput => _hasRenderableVideo || _firstFrameRendered;

  void _startFirstFrameMonitor() {
    if (_firstFrameRendered || !_isAlive) {
      return;
    }

    final token = ++_firstFrameMonitorToken;
    _videoController.waitUntilFirstFrameRendered.then((_) {
      if (token != _firstFrameMonitorToken || !_isAlive) {
        return;
      }
      _firstFrameRendered = true;
      _videoOutputStatus.value = OolafVideoOutputStatus.normal;
      _cancelBlackScreenTimer();
    }).catchError((_) {});
  }

  void _cancelBlackScreenTimer() {
    _blackScreenTimer?.cancel();
    _blackScreenTimer = null;
  }

  void _cancelBufferingTimeoutTimer() {
    _bufferingTimeoutTimer?.cancel();
    _bufferingTimeoutTimer = null;
  }

  void _startBufferingTimeoutIfNeeded() {
    if (!_isAlive || !_isBuffering.value) {
      return;
    }
    if (_bufferingTimeoutTimer != null) {
      return;
    }
    _bufferingTimeoutTimer = Timer(_bufferingTimeout, () async {
      if (!_isAlive || !_isBuffering.value) {
        return;
      }
      _bufferingTimeoutTimer = null;
      _videoOutputStatus.value = OolafVideoOutputStatus.loadTimeout;
      await _player.pause();
    });
  }

  void _startBlackScreenDetectionIfNeeded() {
    if (!_isAlive) {
      return;
    }
    if (!_isPlaying.value) {
      return;
    }
    if (_hasVideoOutput) {
      _cancelBlackScreenTimer();
      return;
    }
    if (_blackScreenTimer != null) {
      return;
    }

    _blackScreenStartPosition = _position.value;
    _blackScreenTimer = Timer(_blackScreenDetectDelay, () async {
      if (!_isAlive) {
        return;
      }
      _blackScreenTimer = null;

      final progressed = (_position.value - _blackScreenStartPosition) >=
          _blackScreenMinProgress;
      if (!_isPlaying.value || _hasVideoOutput || !progressed) {
        return;
      }

      _videoOutputStatus.value = OolafVideoOutputStatus.codecUnsupported;
      await _player.pause();
    });
  }

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    _playingSub = _player.stream.playing.listen((value) {
      if (!_isAlive) {
        return;
      }
      _isPlaying.value = value;
      if (value) {
        _startBlackScreenDetectionIfNeeded();
      } else {
        _cancelBlackScreenTimer();
      }
    });
    _bufferingSub = _player.stream.buffering.listen((value) {
      if (!_isAlive) {
        return;
      }
      _isBuffering.value = value;
      if (value) {
        _startBufferingTimeoutIfNeeded();
      } else {
        _cancelBufferingTimeoutTimer();
      }
    });
    _positionSub = _player.stream.position.listen((value) {
      if (!_isAlive) {
        return;
      }
      _position.value = value;
      _startBlackScreenDetectionIfNeeded();
    });
    _durationSub = _player.stream.duration.listen((value) {
      if (!_isAlive) {
        return;
      }
      _duration.value = value;
    });
    _videoParamsSub = _player.stream.videoParams.listen((params) {
      if (!_isAlive) {
        return;
      }
      final w = params.w;
      final h = params.h;
      if (w == null || h == null) {
        _videoSize.value = null;
        _startBlackScreenDetectionIfNeeded();
        return;
      }
      _videoSize.value = Size(w.toDouble(), h.toDouble());
      _videoOutputStatus.value = OolafVideoOutputStatus.normal;
      _cancelBlackScreenTimer();
    });
    _errorSub = _player.stream.error.listen((_) {
      if (!_isAlive) {
        return;
      }
      _cancelBufferingTimeoutTimer();
      _videoOutputStatus.value = OolafVideoOutputStatus.loadFailed;
    });

    _isInitialized.value = true;
  }

  @override
  Future<void> play() async {
    if (!_isAlive) {
      return;
    }
    _cancelBufferingTimeoutTimer();
    _videoOutputStatus.value = OolafVideoOutputStatus.normal;
    _startFirstFrameMonitor();
    await _player.play();
    _startBlackScreenDetectionIfNeeded();
  }

  @override
  Future<void> pause() async {
    if (!_isAlive) {
      return;
    }
    _cancelBlackScreenTimer();
    _cancelBufferingTimeoutTimer();
    await _player.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    if (!_isAlive) {
      return;
    }
    await _player.seek(position);
  }

  @override
  Future<void> setLooping(bool looping) async {
    if (!_isAlive) {
      return;
    }
    await _player.setPlaylistMode(
      looping ? PlaylistMode.single : PlaylistMode.none,
    );
  }

  @override
  Future<void> setPlaybackRate(double rate) async {
    if (!_isAlive) {
      return;
    }
    await _player.setRate(rate);
  }

  @override
  Widget buildView({BoxFit fit = BoxFit.cover}) {
    if (!_isAlive) {
      return const SizedBox.shrink();
    }
    return SizedBox.expand(
      child: Video(
        controller: _videoController,
        fit: fit,
        controls: (state) => const SizedBox.shrink(),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _firstFrameMonitorToken++;
    _cancelBlackScreenTimer();
    _cancelBufferingTimeoutTimer();

    await _playingSub?.cancel();
    await _bufferingSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _videoParamsSub?.cancel();
    await _errorSub?.cancel();

    _playingSub = null;
    _bufferingSub = null;
    _positionSub = null;
    _durationSub = null;
    _videoParamsSub = null;
    _errorSub = null;

    final dynamic dynamicVideoController = _videoController;
    try {
      final disposeResult = dynamicVideoController.dispose();
      if (disposeResult is Future<void>) {
        await disposeResult;
      }
    } catch (_) {}

    await _player.dispose();

    _isInitialized.dispose();
    _isPlaying.dispose();
    _isBuffering.dispose();
    _position.dispose();
    _duration.dispose();
    _videoSize.dispose();
    _videoOutputStatus.dispose();
  }
}
