import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/api/aphelios_client/post.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';
import 'package:oolaf_flutted/model/client_post/client_post.dart';
import 'package:oolaf_flutted/pages/client_post/client_post_api_key_gate.dart';
import 'package:oolaf_flutted/pages/client_post/client_post_feed_cache.dart';
import 'package:oolaf_flutted/pages/client_post/widgets/client_post_card.dart';
import 'package:oolaf_flutted/utils/oolaf_video_player_controller.dart';

class ClientPostFeedPage extends StatefulWidget {
  const ClientPostFeedPage({super.key});

  @override
  State<ClientPostFeedPage> createState() => _ClientPostFeedPageState();
}

class _ClientPostFeedPageState extends State<ClientPostFeedPage> {
  static const int _pageSize = 10;

  final ScrollController _scrollController = ScrollController();
  final Set<String> _expandedPostIds = <String>{};
  List<ClientPostItem> _posts = const <ClientPostItem>[];
  int _page = 0;
  int _total = 0;
  bool _loading = false;
  bool _loadingMore = false;
  String _clientApiKey = '';
  String? _playingPostId;
  OolafVideoPlayerController? _videoController;

  bool get _hasMore => _posts.length < _total;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _ensureApiKeyAndLoad();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _disposeVideo();
    super.dispose();
  }

  void _restoreCache() {
    _posts = ClientPostFeedCache.list;
    _page = ClientPostFeedCache.page;
    _total = ClientPostFeedCache.total;
  }

  Future<void> _ensureApiKeyAndLoad() async {
    final apiKey = await requireClientPostApiKey(context);
    if (!mounted) {
      return;
    }
    if (apiKey == null || apiKey.isEmpty) {
      Navigator.of(context).maybePop();
      return;
    }
    _clientApiKey = apiKey;
    if (ClientPostFeedCache.hasData) {
      setState(_restoreCache);
      return;
    }
    await _loadFirstPage();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _loadingMore ||
        _loading ||
        !_hasMore) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels > position.maxScrollExtent - 360) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() => _loading = true);
    await _disposeVideo();
    try {
      final result = await fetchClientPosts(
          page: 1, pageSize: _pageSize, apiKey: _clientApiKey);
      ClientPostFeedCache.replace(result);
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = result.list;
        _page = result.page;
        _total = result.total;
      });
    } catch (error) {
      AppToast.showFail('动态加载失败');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final result = await fetchClientPosts(
          page: _page + 1, pageSize: _pageSize, apiKey: _clientApiKey);
      ClientPostFeedCache.append(result);
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = ClientPostFeedCache.list;
        _page = result.page;
        _total = result.total;
      });
    } catch (error) {
      AppToast.showFail('加载更多失败');
    } finally {
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }

  Future<void> _toggleVideo(ClientPostItem post) async {
    final video = post.video;
    if (video == null) {
      return;
    }
    if (_playingPostId == post.id && _videoController != null) {
      if (_videoController!.isPlaying.value) {
        await _videoController!.pause();
      } else {
        await _videoController!.play();
      }
      return;
    }
    await _disposeVideo();
    final controller = await OolafVideoPlayerController.fromUrl(video.url);
    await controller.initialize();
    await controller.play();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _playingPostId = post.id;
      _videoController = controller;
    });
  }

  Future<void> _disposeVideo() async {
    final controller = _videoController;
    _videoController = null;
    _playingPostId = null;
    await controller?.dispose();
  }

  void _toggleText(String id) {
    setState(() {
      if (_expandedPostIds.contains(id)) {
        _expandedPostIds.remove(id);
      } else {
        _expandedPostIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset =
        MediaQuery.paddingOf(context).top + kMinInteractiveDimensionCupertino;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      navigationBar: const CupertinoNavigationBar(middle: Text('动态')),
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad
          },
        ),
        child: RefreshIndicator(
          onRefresh: _loadFirstPage,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topInset)),
              if (_loading && _posts.isEmpty)
                const SliverFillRemaining(
                    child:
                        Center(child: CupertinoActivityIndicator(radius: 14)))
              else if (_posts.isEmpty)
                const SliverFillRemaining(child: Center(child: Text('暂无动态')))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _posts.length) {
                        return _LoadMoreFooter(
                            loading: _loadingMore, hasMore: _hasMore);
                      }
                      final post = _posts[index];
                      return ClientPostCard(
                        post: post,
                        expanded: _expandedPostIds.contains(post.id),
                        onToggleExpanded: () => _toggleText(post.id),
                        activeVideoController:
                            _playingPostId == post.id ? _videoController : null,
                        onTapVideo: _toggleVideo,
                      );
                    },
                    childCount: _posts.length + 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.loading, required this.hasMore});

  final bool loading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: loading
            ? const CupertinoActivityIndicator(radius: 11)
            : Text(hasMore ? '上拉加载更多' : '没有更多了',
                style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
      ),
    );
  }
}
