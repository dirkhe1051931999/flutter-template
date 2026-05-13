import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:oolaf_flutted/utils/oolaf_media_kit_controller.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';

/// Legacy compatibility layer.
///
/// NOTE: Despite the name, this class no longer uses the official `video_player`
/// plugin. It delegates to the media_kit based implementation.
class OolafVideoPlayerController implements OolafVideoController {
  OolafVideoPlayerController._(this._delegate);

  final OolafMediaKitController _delegate;

  static Future<OolafVideoPlayerController> fromUrl(String url) async {
    final c = await OolafMediaKitController.fromUrl(url);
    return OolafVideoPlayerController._(c);
  }

  @override
  ValueListenable<bool> get isInitialized => _delegate.isInitialized;

  @override
  ValueListenable<bool> get isPlaying => _delegate.isPlaying;

  @override
  ValueListenable<bool> get isBuffering => _delegate.isBuffering;

  @override
  ValueListenable<Duration> get position => _delegate.position;

  @override
  ValueListenable<Duration> get duration => _delegate.duration;

  @override
  ValueListenable<Size?> get videoSize => _delegate.videoSize;

  @override
  ValueListenable<OolafVideoOutputStatus> get videoOutputStatus =>
      _delegate.videoOutputStatus;

  @override
  Future<void> initialize() => _delegate.initialize();

  @override
  Future<void> play() => _delegate.play();

  @override
  Future<void> pause() => _delegate.pause();

  @override
  Future<void> seekTo(Duration position) => _delegate.seekTo(position);

  @override
  Future<void> setLooping(bool looping) => _delegate.setLooping(looping);

  @override
  Widget buildView({BoxFit fit = BoxFit.cover}) =>
      _delegate.buildView(fit: fit);

  @override
  Future<void> dispose() => _delegate.dispose();
}
