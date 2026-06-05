import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:oolaf_flutted/components/app_vertical_video_feed/controller/app_vertical_video_feed_controller.dart';
import 'package:oolaf_flutted/components/app_vertical_video_feed/widgets/app_vertical_video_feed_empty_state.dart';
import 'package:oolaf_flutted/components/app_vertical_video_feed/widgets/app_vertical_video_feed_page_view.dart';

class AppVerticalVideoFeedItemActions {
  const AppVerticalVideoFeedItemActions({
    required this.showNextPage,
    required this.showPreviousPage,
  });

  final Future<void> Function() showNextPage;
  final Future<void> Function() showPreviousPage;
}

class AppVerticalVideoFeed<T> extends StatefulWidget {
  const AppVerticalVideoFeed({
    super.key,
    required this.controller,
    required this.items,
    required this.dragDevices,
    required this.onPageChanged,
    required this.itemBuilder,
    this.onLoadMoreRequested,
    this.hasMore = false,
    this.loadMoreTriggerRatio = 0.5,
    this.backgroundColor = const Color(0xFF05060A),
    this.emptyTitle = '暂无可播放视频',
    this.emptyMessage = '当前列表里还没有可播放的视频内容。',
    this.emptyActionLabel = '返回',
    this.onEmptyActionPressed,
  });

  final AppVerticalVideoFeedController controller;
  final List<T> items;
  final Set<PointerDeviceKind> dragDevices;
  final Future<void> Function(int index) onPageChanged;
  final Widget Function(
    BuildContext context,
    int index,
    T item,
    AppVerticalVideoFeedItemActions actions,
  ) itemBuilder;
  final Future<void> Function()? onLoadMoreRequested;
  final bool hasMore;
  final double loadMoreTriggerRatio;
  final Color backgroundColor;
  final String emptyTitle;
  final String emptyMessage;
  final String emptyActionLabel;
  final VoidCallback? onEmptyActionPressed;

  @override
  State<AppVerticalVideoFeed<T>> createState() => _AppVerticalVideoFeedState<T>();
}

class _AppVerticalVideoFeedState<T> extends State<AppVerticalVideoFeed<T>>
    implements AppVerticalVideoFeedControllerDelegate {
  bool _isLoadingMore = false;
  int _currentIndex = 0;
  int _lastRequestedItemCount = -1;

  AppVerticalVideoFeedItemActions get _actions {
    return AppVerticalVideoFeedItemActions(
      showNextPage: showNextPage,
      showPreviousPage: showPreviousPage,
    );
  }

  @override
  int get currentIndex => _currentIndex;

  @override
  void initState() {
    super.initState();
    widget.controller.attach(this);
  }

  @override
  void didUpdateWidget(covariant AppVerticalVideoFeed<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.detach(this);
      widget.controller.attach(this);
    }
    if (widget.items.length != oldWidget.items.length && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _maybeRequestMore();
      });
    }
  }

  @override
  void dispose() {
    widget.controller.detach(this);
    super.dispose();
  }

  Future<void> _handlePageChanged(int index) async {
    _currentIndex = index;
    await widget.onPageChanged(index);
    await _maybeRequestMore();
  }

  Future<void> _maybeRequestMore({bool forceAtEnd = false}) async {
    if (_isLoadingMore || !widget.hasMore || widget.onLoadMoreRequested == null) {
      return;
    }
    final itemCount = widget.items.length;
    if (itemCount <= 0) {
      return;
    }

    final triggerIndex = forceAtEnd
        ? itemCount - 1
        : ((itemCount * widget.loadMoreTriggerRatio).ceil() - 1)
            .clamp(0, itemCount - 1);
    if (_currentIndex < triggerIndex) {
      return;
    }
    if (!forceAtEnd && _lastRequestedItemCount == itemCount) {
      return;
    }

    _isLoadingMore = true;
    _lastRequestedItemCount = itemCount;
    try {
      await widget.onLoadMoreRequested!.call();
    } finally {
      _isLoadingMore = false;
    }
  }

  @override
  Future<void> showNextPage() async {
    final targetIndex = _currentIndex + 1;
    if (targetIndex >= widget.items.length) {
      await _maybeRequestMore(forceAtEnd: true);
      if (targetIndex >= widget.items.length) {
        return;
      }
    }
    await widget.controller.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Future<void> showPreviousPage() async {
    final targetIndex = _currentIndex - 1;
    if (targetIndex < 0) {
      return;
    }
    await widget.controller.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: widget.backgroundColor,
      child: widget.items.isEmpty
          ? AppVerticalVideoFeedEmptyState(
              title: widget.emptyTitle,
              message: widget.emptyMessage,
              actionLabel: widget.emptyActionLabel,
              onActionPressed:
                  widget.onEmptyActionPressed ??
                      () => Navigator.of(context).maybePop(),
            )
          : AppVerticalVideoFeedPageView<T>(
              controller: widget.controller,
              items: widget.items,
              dragDevices: widget.dragDevices,
              onPageChanged: _handlePageChanged,
              itemBuilder: (context, index, item) {
                return widget.itemBuilder(context, index, item, _actions);
              },
            ),
    );
  }
}
