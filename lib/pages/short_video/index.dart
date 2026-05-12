import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/short_video/comment_sheet.dart';
import 'package:oolaf_flutted/components/short_video/interaction_overlay.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/short_video/action.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/router/route_observer.dart';
import 'package:oolaf_flutted/utils/video_manager.dart';
import 'package:preload_page_view/preload_page_view.dart';

class ShortVideoPage extends StatelessWidget {
  const ShortVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ShortVideoFeed();
  }
}

class _ShortVideoFeed extends StatefulWidget {
  const _ShortVideoFeed();

  @override
  State<_ShortVideoFeed> createState() => _ShortVideoFeedState();
}

class _ShortVideoFeedState extends State<_ShortVideoFeed>
    with WidgetsBindingObserver, RouteAware {
  final _pageController = PreloadPageController();
  final _videoManager = VideoManager.instance;

  bool _seeded = false;
  bool _isAppActive = true;
  bool _didAutoPlayFirst = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoManager.acquire('short_video');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _videoManager.release('short_video');
    super.dispose();
  }

  @override
  void didPushNext() {
    _videoManager.pauseAll();
  }

  @override
  void didPopNext() {
    _syncAndPlayActive();
  }

  Future<void> _syncAndPlayActive() async {
    final store = StoreProvider.of<AppState>(context);
    final index = store.state.shortVideo.activeIndex;
    final items = store.state.shortVideo.items;
    if (items.isEmpty || index < 0 || index >= items.length) {
      return;
    }

    _videoManager.setSources(
      items.map((e) => (id: e.id, url: e.videoUrl)).toList(),
    );
    await _videoManager.setActiveIndex(index);
    await _videoManager.playActive();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _isAppActive;
    _isAppActive = state == AppLifecycleState.resumed;

    if (_isAppActive && !wasActive) {
      // no-op for now
    } else if (!_isAppActive && wasActive) {
      _videoManager.pauseAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ShortVideoState>(
      distinct: true,
      converter: (store) => store.state.shortVideo,
      onInit: (store) {
        if (_seeded) return;
        _seeded = true;

        // Mock data (WIP). Replace with real API later.
        const items = [
          ShortVideoItem(
            id: 'v1',
            title: 'Video 1',
            videoUrl:
                'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            coverUrl: 'https://picsum.photos/seed/oolaf-video-1/300/500',
          ),
          ShortVideoItem(
            id: 'v2',
            title: 'Video 2',
            videoUrl:
                'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            coverUrl: 'https://picsum.photos/seed/oolaf-video-2/300/500',
          ),
        ];

        store.dispatch(const ShortVideoSetItemsAction(items));
        _videoManager
            .setSources(items.map((e) => (id: e.id, url: e.videoUrl)).toList());
      },
      builder: (context, state) {
        final items = state.items;

        if (!_didAutoPlayFirst && items.isNotEmpty) {
          _didAutoPlayFirst = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            _videoManager.setSources(
              items
                  .map((e) => (id: e.id, url: e.videoUrl))
                  .toList(growable: false),
            );
            await _videoManager.setActiveIndex(state.activeIndex);
            await _videoManager.playActive();
          });
        }

        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.black,
          navigationBar: const CupertinoNavigationBar(
            backgroundColor: Color(0x66000000),
            border: null,
            middle: Text(
              '短视频',
              style: TextStyle(color: CupertinoColors.white),
            ),
          ),
          child: SafeArea(
            top: false,
            child: items.isEmpty
                ? const Center(
                    child: CupertinoActivityIndicator(radius: 14),
                  )
                : PreloadPageView.builder(
                    controller: _pageController,
                    preloadPagesCount: 2,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index) async {
                      final store = StoreProvider.of<AppState>(context);
                      store.dispatch(ShortVideoSetActiveIndexAction(index));

                      _videoManager.setSources(
                        items
                            .map((e) => (id: e.id, url: e.videoUrl))
                            .toList(growable: false),
                      );
                      await _videoManager.setActiveIndex(index);
                      await _videoManager.playActive();
                    },
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final controller = _videoManager.getById(item.id);

                      return RepaintBoundary(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            RepaintBoundary(
                              child: ShortVideoPlayerWrapper(
                                controller: controller,
                                onSingleTap: () async {
                                  final c = _videoManager.getById(item.id);
                                  if (c == null) return;

                                  final isPlaying = c.isPlaying.value;
                                  if (isPlaying) {
                                    await c.pause();
                                  } else {
                                    await c.play();
                                  }
                                },
                                onDoubleTap: () {
                                  // Like (WIP)
                                },
                                onLongPress: () {
                                  // Menu (WIP)
                                },
                              ),
                            ),
                            RepaintBoundary(
                              child: ShortVideoInteractionOverlay(
                                onTapComment: () {
                                  showShortVideoCommentSheet(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
