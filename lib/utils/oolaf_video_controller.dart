import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum OolafVideoOutputStatus {
  normal,
  codecUnsupported,
  loadFailed,
  loadTimeout,
}

abstract class OolafVideoController {
  ValueListenable<bool> get isInitialized;
  ValueListenable<bool> get isPlaying;
  ValueListenable<bool> get isBuffering;

  ValueListenable<Duration> get position;
  ValueListenable<Duration> get duration;

  ValueListenable<Size?> get videoSize;
  ValueListenable<OolafVideoOutputStatus> get videoOutputStatus;

  Future<void> initialize();
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> setLooping(bool looping);
  Future<void> setPlaybackRate(double rate);

  Widget buildView({BoxFit fit = BoxFit.cover});

  Future<void> dispose();
}
