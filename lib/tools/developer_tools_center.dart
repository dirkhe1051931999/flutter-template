import 'package:flutter/widgets.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';

class DeveloperRequestLog {
  const DeveloperRequestLog({
    required this.time,
    required this.method,
    required this.url,
    required this.statusCode,
    required this.durationMs,
    required this.requestSummary,
    required this.responseSummary,
    required this.errorMessage,
  });

  final DateTime time;
  final String method;
  final String url;
  final int? statusCode;
  final int? durationMs;
  final String requestSummary;
  final String responseSummary;
  final String errorMessage;
}

class DeveloperErrorLog {
  const DeveloperErrorLog({
    required this.time,
    required this.source,
    required this.message,
    required this.stackTrace,
  });

  final DateTime time;
  final String source;
  final String message;
  final String stackTrace;
}

class DeveloperRouteLog {
  const DeveloperRouteLog({
    required this.time,
    required this.event,
    required this.routeName,
    required this.previousRouteName,
  });

  final DateTime time;
  final String event;
  final String routeName;
  final String previousRouteName;
}

class DeveloperVideoStatus {
  const DeveloperVideoStatus({
    required this.time,
    required this.source,
    required this.controllerHash,
    required this.isInitialized,
    required this.isPlaying,
    required this.isBuffering,
    required this.position,
    required this.duration,
    required this.outputStatus,
    required this.videoSize,
  });

  final DateTime time;
  final String source;
  final String controllerHash;
  final bool isInitialized;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final OolafVideoOutputStatus outputStatus;
  final Size? videoSize;
}

class DeveloperToolsCenter extends ChangeNotifier {
  DeveloperToolsCenter._();

  static final DeveloperToolsCenter instance = DeveloperToolsCenter._();

  static const int _maxRequestLogs = 60;
  static const int _maxErrorLogs = 60;
  static const int _maxRouteLogs = 60;

  List<DeveloperRequestLog> _requestLogs = const <DeveloperRequestLog>[];
  List<DeveloperErrorLog> _errorLogs = const <DeveloperErrorLog>[];
  List<DeveloperRouteLog> _routeLogs = const <DeveloperRouteLog>[];
  DeveloperVideoStatus? _latestVideoStatus;

  List<DeveloperRequestLog> get requestLogs => _requestLogs;
  List<DeveloperErrorLog> get errorLogs => _errorLogs;
  List<DeveloperRouteLog> get routeLogs => _routeLogs;
  DeveloperVideoStatus? get latestVideoStatus => _latestVideoStatus;

  void recordRequest(DeveloperRequestLog log) {
    _requestLogs = _pushCapped(
      current: _requestLogs,
      next: log,
      maxCount: _maxRequestLogs,
    );
    notifyListeners();
  }

  void recordError({
    required String source,
    required Object error,
    StackTrace? stackTrace,
  }) {
    final stack = stackTrace?.toString() ?? '';
    _errorLogs = _pushCapped(
      current: _errorLogs,
      next: DeveloperErrorLog(
        time: DateTime.now(),
        source: source,
        message: error.toString(),
        stackTrace: stack,
      ),
      maxCount: _maxErrorLogs,
    );
    notifyListeners();
  }

  void recordFlutterError(FlutterErrorDetails details) {
    final stack = details.stack?.toString() ?? '';
    _errorLogs = _pushCapped(
      current: _errorLogs,
      next: DeveloperErrorLog(
        time: DateTime.now(),
        source: details.library ?? 'FlutterError',
        message: details.exceptionAsString(),
        stackTrace: stack,
      ),
      maxCount: _maxErrorLogs,
    );
    notifyListeners();
  }

  void recordRoute({
    required String event,
    required String routeName,
    required String previousRouteName,
  }) {
    _routeLogs = _pushCapped(
      current: _routeLogs,
      next: DeveloperRouteLog(
        time: DateTime.now(),
        event: event,
        routeName: routeName,
        previousRouteName: previousRouteName,
      ),
      maxCount: _maxRouteLogs,
    );
    notifyListeners();
  }

  void updateVideoStatus(DeveloperVideoStatus status) {
    _latestVideoStatus = status;
    notifyListeners();
  }

  void clearRequestLogs() {
    _requestLogs = const <DeveloperRequestLog>[];
    notifyListeners();
  }

  void clearErrorLogs() {
    _errorLogs = const <DeveloperErrorLog>[];
    notifyListeners();
  }

  void clearRouteLogs() {
    _routeLogs = const <DeveloperRouteLog>[];
    notifyListeners();
  }

  List<T> _pushCapped<T>({
    required List<T> current,
    required T next,
    required int maxCount,
  }) {
    final nextItems = <T>[next, ...current];
    if (nextItems.length > maxCount) {
      return List<T>.unmodifiable(nextItems.take(maxCount));
    }
    return List<T>.unmodifiable(nextItems);
  }
}
