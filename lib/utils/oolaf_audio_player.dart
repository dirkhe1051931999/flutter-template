import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class OolafAudioPlayer {
  OolafAudioPlayer() : _player = AudioPlayer();

  final AudioPlayer _player;
  bool _sessionConfigured = false;
  ProcessingState _lastProcessingState = ProcessingState.idle;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<void> get completedStream => _player.playerStateStream.where((s) {
        final isCompleted = s.processingState == ProcessingState.completed;
        final isNewCompleted =
            isCompleted && _lastProcessingState != ProcessingState.completed;
        _lastProcessingState = s.processingState;
        return isNewCompleted;
      }).map((_) {});

  Future<void> _ensureAudioSession() async {
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      return;
    }

    if (_sessionConfigured) {
      return;
    }
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _sessionConfigured = true;
  }

  Future<void> setUrl(String url) async {
    await _ensureAudioSession();
    _lastProcessingState = ProcessingState.idle;
    await _player.setUrl(url);
  }

  Future<void> playUrl(String url) async {
    await setUrl(url);
    await _player.play();
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> stop() => _player.stop();

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);

  LoopMode get loopMode => _player.loopMode;

  bool get isPlaying => _player.playing;

  Future<void> dispose() => _player.dispose();
}

final oolafAudioPlayer = OolafAudioPlayer();
