import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'package:oolaf_flutted/utils/helper.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_cache_proxy.dart';
import 'package:oolaf_flutted/utils/proxy_url.dart';

enum OolafFocusEvent {
  pause,
  resume,
}

enum OolafPlaybackState {
  idle,
  buffering,
  ready,
  playing,
  paused,
  completed,
  disposed,
}

class OolafAudioPlayer {
  OolafAudioPlayer() {
    _bindPlayer(AudioPlayer());
  }

  bool _isHeadsetOrBluetoothOutput(AudioDevice device) {
    if (!device.isOutput) {
      return false;
    }

    final typeName = device.type.toString();
    return typeName.endsWith('.bluetoothA2dp') ||
        typeName.endsWith('.bluetoothSco') ||
        typeName.endsWith('.wiredHeadphones') ||
        typeName.endsWith('.wiredHeadset') ||
        typeName.endsWith('.headsetMic');
  }

  late AudioPlayer _player;
  final StreamController<OolafPlaybackState> _playbackStateController =
      StreamController<OolafPlaybackState>.broadcast();
  final StreamController<OolafFocusEvent> _focusEventController =
      StreamController<OolafFocusEvent>.broadcast();
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<void>? _noisySub;
  StreamSubscription<AudioDevicesChangedEvent>? _devicesSub;
  static const Duration _setUrlTimeout = Duration(seconds: 12);
  bool _sessionConfigured = false;
  bool _hasStarted = false;
  bool _isDisposed = false;
  bool _pausedByFocus = false;
  ProcessingState _lastProcessingState = ProcessingState.idle;
  OolafPlaybackState _lastPlaybackState = OolafPlaybackState.idle;
  String? _currentUrl;
  int _playbackIntentVersion = 0;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<OolafFocusEvent> get focusEventStream => _focusEventController.stream;
  Stream<OolafPlaybackState> get playbackStateStream =>
      _playbackStateController.stream;
  OolafPlaybackState get playbackState => _lastPlaybackState;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Duration get position => _player.position;
  String? get currentUrl => _currentUrl;
  int get playbackIntentVersion => _playbackIntentVersion;
  Stream<void> get completedStream => _player.playerStateStream.where((s) {
        final isCompleted = s.processingState == ProcessingState.completed;
        final isNewCompleted =
            isCompleted && _lastProcessingState != ProcessingState.completed;
        _lastProcessingState = s.processingState;
        return isNewCompleted;
      }).map((_) {});

  void markPlaybackIntent() {
    _playbackIntentVersion += 1;
  }

  void _bindPlayer(AudioPlayer player) {
    _player = player;
    _playerStateSub?.cancel();
    _playerStateSub = _player.playerStateStream.listen(_handlePlayerState);
  }

  Future<void> _recreatePlayer({required String reason}) async {
    if (_isDisposed) {
      return;
    }

    final previousPlayer = _player;
    final previousLoopMode = previousPlayer.loopMode;
    customLogger.log('audio recreate player start: reason=$reason');

    _hasStarted = false;
    _lastProcessingState = ProcessingState.idle;
    _emitPlaybackState(OolafPlaybackState.idle);

    await _playerStateSub?.cancel();
    _playerStateSub = null;
    try {
      await previousPlayer.stop();
    } catch (_) {}
    try {
      await previousPlayer.dispose();
    } catch (_) {}

    final nextPlayer = AudioPlayer();
    _bindPlayer(nextPlayer);
    try {
      await nextPlayer.setLoopMode(previousLoopMode);
    } catch (_) {}
    customLogger.log('audio recreate player ready: reason=$reason');
  }

  Future<void> _runWithSingleRetry(
    Future<void> Function() action, {
    required String reason,
  }) async {
    try {
      await action();
    } catch (error, stackTrace) {
      customLogger.log('audio operation failed, retry after recreate: $error');
      customLogger.log(stackTrace);
      await _recreatePlayer(reason: reason);
      await action();
    }
  }

  Future<void> _ensureAudioSession() async {
    if (kIsWeb) {
      return;
    }
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      return;
    }

    if (_sessionConfigured) {
      return;
    }
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _sessionConfigured = true;

    _interruptionSub = session.interruptionEventStream.listen((event) {
      if (event.begin) {
        if (_player.playing) {
          _pausedByFocus = true;
          _player.pause();
          if (!_focusEventController.isClosed) {
            _focusEventController.add(OolafFocusEvent.pause);
          }
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.pause:
          case AudioInterruptionType.duck:
            if (_pausedByFocus) {
              _pausedByFocus = false;
              _player.play();
              if (!_focusEventController.isClosed) {
                _focusEventController.add(OolafFocusEvent.resume);
              }
            }
          case AudioInterruptionType.unknown:
            _pausedByFocus = false;
        }
      }
    });

    _noisySub = session.becomingNoisyEventStream.listen((_) {
      if (_player.playing) {
        _pausedByFocus = false;
        _player.pause();
        if (!_focusEventController.isClosed) {
          _focusEventController.add(OolafFocusEvent.pause);
        }
      }
    });

    _devicesSub = session.devicesChangedEventStream.listen((event) {
      final removedActive = event.devicesRemoved.any(
        _isHeadsetOrBluetoothOutput,
      );
      final hasReplacementOutput = event.devicesAdded.any(
        _isHeadsetOrBluetoothOutput,
      );
      if (removedActive && !hasReplacementOutput && _player.playing) {
        _pausedByFocus = false;
        _player.pause();
        customLogger.log(
          'audio paused by devicesChangedEvent: active headset/bluetooth output removed without replacement',
        );
        if (!_focusEventController.isClosed) {
          _focusEventController.add(OolafFocusEvent.pause);
        }
      }
    });
  }

  Future<void> _ensureAudioCacheProxy() async {
    if (kIsWeb) {
      return;
    }
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      return;
    }
    await OolafAudioCacheProxy.instance.ensureStarted();
  }

  Future<void> _setLocalFileWithTimeout(
    String filePath, {
    required String source,
  }) async {
    customLogger.log('audio setFilePath start: source=$source path=$filePath');
    await _player.setFilePath(filePath).timeout(
      _setUrlTimeout,
      onTimeout: () {
        throw TimeoutException(
          'audio setFilePath timeout after ${_setUrlTimeout.inSeconds}s '
          '(source=$source, path=$filePath)',
        );
      },
    );
    customLogger.log('audio setFilePath ready: source=$source path=$filePath');
  }

  Future<Uri> _playableUriFor(String remoteUrl) async {
    await _ensureAudioCacheProxy();
    return OolafAudioCacheProxy.instance.proxyUriFor(remoteUrl);
  }

  Map<String, String> _remoteAudioHeaders(String url) {
    final uri = Uri.tryParse(url);
    final headers = <String, String>{
      HttpHeaders.userAgentHeader:
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
              'AppleWebKit/605.1.15 (KHTML, like Gecko) '
              'Version/17.0 Mobile/15E148 Safari/604.1',
      HttpHeaders.acceptHeader: '*/*',
      HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9,en;q=0.8',
    };
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      headers[HttpHeaders.refererHeader] = '${uri.scheme}://${uri.host}/';
    }
    return headers;
  }

  Future<void> _setRemoteUrlWithTimeout(
    String url, {
    required String source,
    Map<String, String>? headers,
  }) async {
    customLogger.log('audio setUrl start: source=$source url=$url');
    await _player
        .setUrl(
      url,
      headers: headers,
    )
        .timeout(
      _setUrlTimeout,
      onTimeout: () {
        throw TimeoutException(
          'audio setUrl timeout after ${_setUrlTimeout.inSeconds}s '
          '(source=$source, url=$url)',
        );
      },
    );
    customLogger.log('audio setUrl ready: source=$source url=$url');
  }

  Future<void> prefetchUrl(String url) async {
    if (_isDisposed) {
      return;
    }

    if (kIsWeb) {
      return;
    }

    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      return;
    }

    try {
      await _ensureAudioCacheProxy();
      final existing = await OolafAudioCacheProxy.instance.getCachedFile(url);
      if (existing != null) {
        return;
      }
      final proxyUri = OolafAudioCacheProxy.instance.proxyUriFor(url);
      final client = HttpClient();
      try {
        final req = await client.getUrl(proxyUri);
        final resp = await req.close();
        await resp.drain<void>();
      } finally {
        client.close(force: true);
      }
    } catch (_) {}
  }

  void _emitPlaybackState(OolafPlaybackState next) {
    if (next == _lastPlaybackState) {
      return;
    }
    _lastPlaybackState = next;
    if (!_playbackStateController.isClosed) {
      _playbackStateController.add(next);
    }
  }

  OolafPlaybackState _mapPlayerState(PlayerState state) {
    if (_isDisposed) {
      return OolafPlaybackState.disposed;
    }

    switch (state.processingState) {
      case ProcessingState.idle:
        return OolafPlaybackState.idle;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return OolafPlaybackState.buffering;
      case ProcessingState.ready:
        if (state.playing) {
          return OolafPlaybackState.playing;
        }
        return _hasStarted
            ? OolafPlaybackState.paused
            : OolafPlaybackState.ready;
      case ProcessingState.completed:
        return OolafPlaybackState.completed;
    }
  }

  void _handlePlayerState(PlayerState state) {
    _emitPlaybackState(_mapPlayerState(state));
  }

  Future<void> setUrl(String url) async {
    await _ensureAudioSession();
    _lastProcessingState = ProcessingState.idle;
    _hasStarted = false;
    _currentUrl = url;

    if (shouldProxyUrl(url)) {
      final proxyUrl = buildProxyUrl(method: 'get', targetUrl: url);
      await _setRemoteUrlWithTimeout(
        proxyUrl,
        source: 'remote-proxy',
        headers: buildProxyHeaders(),
      );
      return;
    }

    if (Platform.isIOS) {
      await _runWithSingleRetry(
        () async {
          try {
            await _setRemoteUrlWithTimeout(
              url,
              source: 'ios-direct',
              headers: _remoteAudioHeaders(url),
            );
            return;
          } catch (error, stackTrace) {
            customLogger.log(
              'setUrl direct iOS url failed, fallback cached file: $error',
            );
            customLogger.log(stackTrace);
          }

          await _ensureAudioCacheProxy();
          final cached =
              await OolafAudioCacheProxy.instance.cacheRemoteFile(url);
          await _setLocalFileWithTimeout(
            cached.path,
            source: 'ios-cached-file',
          );
        },
        reason: 'ios_set_url_retry',
      );
      return;
    }

    if (Platform.isAndroid || Platform.isMacOS) {
      try {
        await _ensureAudioCacheProxy();
        final cached = await OolafAudioCacheProxy.instance.getCachedFile(url);
        if (cached != null) {
          await _player.setFilePath(cached.path);
          return;
        }
      } catch (error, stackTrace) {
        customLogger.log('setUrl with cached file failed: $error');
        customLogger.log(stackTrace);
      }

      try {
        final proxyUri = await _playableUriFor(url);
        await _setRemoteUrlWithTimeout(
          proxyUri.toString(),
          source: 'local-cache-proxy',
        );
        return;
      } catch (error, stackTrace) {
        customLogger
            .log('setUrl via local proxy failed, fallback direct url: $error');
        customLogger.log(stackTrace);
        await _setRemoteUrlWithTimeout(
          url,
          source: 'direct-fallback',
          headers: _remoteAudioHeaders(url),
        );
        return;
      }
    }

    await _setRemoteUrlWithTimeout(
      url,
      source: 'direct',
      headers: _remoteAudioHeaders(url),
    );
  }

  Future<void> playUrl(String url) async {
    await setUrl(url);
    await play();
  }

  Future<void> play() {
    _hasStarted = true;
    unawaited(
      _player.play().catchError((Object error, StackTrace stackTrace) {
        customLogger.log('audio play failed: $error');
        customLogger.log(stackTrace);
      }),
    );
    return Future<void>.value();
  }

  Future<void> pause() => _player.pause();

  Future<void> stop() {
    _hasStarted = false;
    _currentUrl = null;
    return _player.stop();
  }

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

  Future<void> dispose() async {
    _isDisposed = true;
    _currentUrl = null;
    _emitPlaybackState(OolafPlaybackState.disposed);
    await _playerStateSub?.cancel();
    await _interruptionSub?.cancel();
    await _noisySub?.cancel();
    await _devicesSub?.cancel();
    await _player.dispose();
    await _playbackStateController.close();
    await _focusEventController.close();
  }
}

final oolafAudioPlayer = OolafAudioPlayer();
