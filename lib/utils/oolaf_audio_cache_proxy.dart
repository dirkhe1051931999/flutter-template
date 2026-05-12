import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

class OolafAudioCacheProxy {
  OolafAudioCacheProxy._();

  static final OolafAudioCacheProxy instance = OolafAudioCacheProxy._();

  final Map<String, Completer<void>> _downloadLocks = <String, Completer<void>>{};

  HttpServer? _server;
  int? _port;
  bool _starting = false;

  Future<void> ensureStarted() async {
    if (_server != null) {
      return;
    }
    if (_starting) {
      while (_server == null) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      return;
    }

    _starting = true;
    try {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _server = server;
      _port = server.port;
      unawaited(_serve(server));
    } finally {
      _starting = false;
    }
  }

  Uri proxyUriFor(String remoteUrl) {
    final port = _port;
    if (port == null) {
      throw StateError('OolafAudioCacheProxy is not started');
    }
    return Uri(
      scheme: 'http',
      host: InternetAddress.loopbackIPv4.address,
      port: port,
      path: '/audio',
      queryParameters: <String, String>{
        'u': base64UrlEncode(utf8.encode(remoteUrl)),
      },
    );
  }

  Future<File?> getCachedFile(String remoteUrl) async {
    final file = await _cacheFile(remoteUrl);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<void> dispose() async {
    final server = _server;
    _server = null;
    _port = null;
    if (server != null) {
      await server.close(force: true);
    }
  }

  Future<void> _serve(HttpServer server) async {
    await for (final request in server) {
      unawaited(_handleRequest(request));
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (request.method != 'GET' && request.method != 'HEAD') {
      request.response.statusCode = HttpStatus.methodNotAllowed;
      await request.response.close();
      return;
    }

    if (request.uri.path != '/audio') {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final encoded = request.uri.queryParameters['u'];
    if (encoded == null || encoded.isEmpty) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }

    late final String remoteUrl;
    try {
      remoteUrl = utf8.decode(base64Url.decode(encoded));
    } catch (_) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }

    final cacheFile = await _cacheFile(remoteUrl);
    final partFile = File('${cacheFile.path}.part');

    final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);
    final range = rangeHeader == null ? null : _parseRange(rangeHeader);

    if (await cacheFile.exists()) {
      await _serveFile(request, cacheFile, range: range);
      return;
    }

    final isSeekRange = range != null && range.start > 0;

    if (!isSeekRange) {
      final lock = _downloadLocks[remoteUrl];
      if (lock != null) {
        await lock.future;
        if (await cacheFile.exists()) {
          await _serveFile(request, cacheFile, range: range);
          return;
        }
      }
    }

    await partFile.create(recursive: true);
    await _proxyAndCache(
      request,
      remoteUrl,
      partFile,
      finalFile: cacheFile,
      range: range,
      isSeekRange: isSeekRange,
    );
  }

  Future<void> _serveFile(
    HttpRequest request,
    File file, {
    _ByteRange? range,
  }) async {
    final length = await file.length();

    request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
    request.response.headers.contentType = ContentType.binary;

    if (range == null) {
      request.response.statusCode = HttpStatus.ok;
      request.response.contentLength = length;
      if (request.method == 'HEAD') {
        await request.response.close();
        return;
      }
      await request.response.addStream(file.openRead());
      await request.response.close();
      return;
    }

    final start = range.start;
    final end = (range.endInclusive ?? (length - 1)).clamp(0, length - 1);
    if (start >= length || start > end) {
      request.response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
      request.response.headers
          .set(HttpHeaders.contentRangeHeader, 'bytes */$length');
      await request.response.close();
      return;
    }

    final bytesToSend = end - start + 1;
    request.response.statusCode = HttpStatus.partialContent;
    request.response.contentLength = bytesToSend;
    request.response.headers.set(
      HttpHeaders.contentRangeHeader,
      'bytes $start-$end/$length',
    );

    if (request.method == 'HEAD') {
      await request.response.close();
      return;
    }

    await request.response.addStream(file.openRead(start, end + 1));
    await request.response.close();
  }

  Future<void> _proxyAndCache(
    HttpRequest request,
    String remoteUrl,
    File partFile, {
    required File finalFile,
    _ByteRange? range,
    required bool isSeekRange,
  }) async {
    final client = HttpClient();
    Completer<void>? lockCompleter;
    var createdLock = false;
    RandomAccessFile? cacheWriter;
    var streamSucceeded = false;
    try {
      if (!isSeekRange) {
        if (_downloadLocks.containsKey(remoteUrl)) {
          lockCompleter = _downloadLocks[remoteUrl];
        } else {
          lockCompleter = Completer<void>();
          _downloadLocks[remoteUrl] = lockCompleter;
          createdLock = true;
        }
      }

      final upstream = await client.getUrl(Uri.parse(remoteUrl));
      upstream.headers.set(HttpHeaders.userAgentHeader, 'oolaf-audio-proxy');
      if (isSeekRange) {
        upstream.headers.set(HttpHeaders.rangeHeader, range!.toHeaderValue());
      }

      final upstreamResp = await upstream.close();
      final status = upstreamResp.statusCode;
      if (status != HttpStatus.ok && status != HttpStatus.partialContent) {
        request.response.statusCode = status;
        await request.response.close();
        return;
      }

      request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
      final upstreamCt = upstreamResp.headers.contentType;
      if (upstreamCt != null) {
        request.response.headers.contentType = upstreamCt;
      }

      final upstreamLen = upstreamResp.contentLength;

      if (isSeekRange) {
        request.response.statusCode = status;
        if (upstreamLen >= 0) {
          request.response.contentLength = upstreamLen;
        }
        final cr =
            upstreamResp.headers.value(HttpHeaders.contentRangeHeader);
        if (cr != null) {
          request.response.headers.set(HttpHeaders.contentRangeHeader, cr);
        }
        if (request.method == 'HEAD') {
          await request.response.close();
          return;
        }
        await request.response.addStream(upstreamResp);
        await request.response.close();
        return;
      }

      final totalLen = upstreamLen >= 0 ? upstreamLen : -1;
      if (range != null && totalLen > 0) {
        request.response.statusCode = HttpStatus.partialContent;
        request.response.contentLength = totalLen;
        request.response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes 0-${totalLen - 1}/$totalLen',
        );
      } else {
        request.response.statusCode = HttpStatus.ok;
        if (totalLen > 0) {
          request.response.contentLength = totalLen;
        }
      }

      if (request.method == 'HEAD') {
        await request.response.close();
        return;
      }

      cacheWriter = await partFile.open(mode: FileMode.write);
      try {
        await for (final chunk in upstreamResp) {
          request.response.add(chunk);
          await cacheWriter.writeFrom(chunk);
        }
        streamSucceeded = true;
      } finally {
        await cacheWriter.close();
        cacheWriter = null;
      }

      if (streamSucceeded && !await finalFile.exists()) {
        try {
          await partFile.rename(finalFile.path);
        } catch (_) {}
      }

      await request.response.close();
    } catch (_) {
      try {
        request.response.statusCode = HttpStatus.badGateway;
        await request.response.close();
      } catch (_) {}
    } finally {
      try {
        await cacheWriter?.close();
      } catch (_) {}
      if (!streamSucceeded) {
        try {
          if (await partFile.exists()) {
            await partFile.delete();
          }
        } catch (_) {}
      }
      if (createdLock && lockCompleter != null) {
        if (identical(_downloadLocks[remoteUrl], lockCompleter)) {
          _downloadLocks.remove(remoteUrl);
        }
        if (!lockCompleter.isCompleted) {
          lockCompleter.complete();
        }
      }
      client.close(force: true);
    }
  }

  Future<File> _cacheFile(String remoteUrl) async {
    final dir = await _cacheDir();
    final hash = sha1.convert(utf8.encode(remoteUrl)).toString();
    return File('${dir.path}/$hash.bin');
  }

  Future<Directory> _cacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/oolaf_audio_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  _ByteRange? _parseRange(String header) {
    final trimmed = header.trim();
    if (!trimmed.startsWith('bytes=')) {
      return null;
    }
    final value = trimmed.substring('bytes='.length);
    final parts = value.split('-');
    if (parts.length != 2) {
      return null;
    }

    final startRaw = parts[0].trim();
    final endRaw = parts[1].trim();

    final start = int.tryParse(startRaw);
    final end = endRaw.isEmpty ? null : int.tryParse(endRaw);

    if (start == null || start < 0) {
      return null;
    }

    if (end != null && end < start) {
      return null;
    }

    return _ByteRange(start: start, endInclusive: end);
  }
}

class _ByteRange {
  const _ByteRange({required this.start, this.endInclusive});

  final int start;
  final int? endInclusive;

  String toHeaderValue() {
    final end = endInclusive;
    return end == null ? 'bytes=$start-' : 'bytes=$start-$end';
  }
}
