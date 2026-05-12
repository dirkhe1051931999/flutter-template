import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class OolafVideoController {
  ValueListenable<bool> get isInitialized;
  ValueListenable<bool> get isPlaying;
  ValueListenable<bool> get isBuffering;

  ValueListenable<Duration> get position;
  ValueListenable<Duration> get duration;

  ValueListenable<Size?> get videoSize;

  Future<void> initialize();
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> setLooping(bool looping);

  Widget buildView({BoxFit fit = BoxFit.cover});

  Future<void> dispose();
}
