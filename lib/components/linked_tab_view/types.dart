import 'package:flutter/cupertino.dart';

enum LinkedTabChangeSource {
  tap,
  swipe,
  programmatic,
}

enum LinkedTabRefreshState {
  idle,
  pulling,
  armed,
  refreshing,
  complete,
}

typedef LinkedTabIndexChanged = void Function(
  int index,
  LinkedTabChangeSource source,
);

typedef LinkedTabRefreshIndicatorBuilder = Widget Function(
  BuildContext context,
  LinkedTabRefreshState state,
  double progress,
);

class LinkedTabRefreshConfig {
  const LinkedTabRefreshConfig({
    required this.onRefresh,
    this.triggerOffset = 92,
    this.completeDisplayDuration = const Duration(milliseconds: 280),
    this.indicatorBuilder,
  });

  final Future<void> Function() onRefresh;
  final double triggerOffset;
  final Duration completeDisplayDuration;
  final LinkedTabRefreshIndicatorBuilder? indicatorBuilder;
}

class LinkedTabItem {
  const LinkedTabItem({
    required this.id,
    required this.label,
    required this.child,
    this.keepAlive = true,
    this.swipeEnabled = true,
    this.refreshConfig,
  });

  final String id;
  final String label;
  final Widget child;
  final bool keepAlive;
  final bool swipeEnabled;
  final LinkedTabRefreshConfig? refreshConfig;
}
