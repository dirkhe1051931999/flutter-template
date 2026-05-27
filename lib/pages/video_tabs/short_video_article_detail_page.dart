import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectionArea, SelectableText;
import 'package:oolaf_flutted/components/article/article_comment_input_sheet.dart';
import 'package:oolaf_flutted/components/article/article_detail_bottom_action_bar.dart';
import 'package:oolaf_flutted/components/article/article_share_sheet.dart';
import 'package:oolaf_flutted/components/article/doc_comment_section.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_article_body_helper.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_gallery_preview.dart'
    show ShortVideoGalleryPreviewImage, galleryWrapWithDesktopFriendlyScrollBehavior;
import 'package:flutter/services.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';

Future<void> openShortVideoArticleDetailPage(
  BuildContext context, {
  required HeadlineNewsDocDetail detail,
  required String coverUrl,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    CupertinoPageRoute<void>(
      builder: (_) => ShortVideoArticleDetailPage(
        detail: detail,
        coverUrl: coverUrl,
      ),
    ),
  );
}

Widget wrapWithDesktopFriendlyScrollBehavior(Widget child) {
  return galleryWrapWithDesktopFriendlyScrollBehavior(child);
}

class ShortVideoArticleDetailPage extends StatefulWidget {
  const ShortVideoArticleDetailPage({
    super.key,
    required this.detail,
    required this.coverUrl,
  });

  final HeadlineNewsDocDetail detail;
  final String coverUrl;

  @override
  State<ShortVideoArticleDetailPage> createState() =>
      _ShortVideoArticleDetailPageState();
}

class _ShortVideoArticleDetailPageState extends State<ShortVideoArticleDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentSectionKey = GlobalKey();

  bool _showArticleIcon = false;
  bool _isCollected = false;
  bool _isLiked = false;
  int _commentsCount = 0;

  String get _commentBadgeText {
    if (_commentsCount <= 0) {
      return '';
    }
    if (_commentsCount > 9999) {
      return '1w+';
    }
    return '$_commentsCount';
  }

  @override
  void initState() {
    super.initState();
    _commentsCount = int.tryParse(widget.detail.commentsCount) ?? 0;
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final commentContext = _commentSectionKey.currentContext;
    if (commentContext == null) {
      return;
    }
    final renderObject = commentContext.findRenderObject();
    if (renderObject is! RenderBox) {
      return;
    }
    final commentTop = renderObject.localToGlobal(Offset.zero).dy;
    final shouldShowArticleIcon = commentTop <= 160;
    if (_showArticleIcon == shouldShowArticleIcon || !mounted) {
      return;
    }
    setState(() {
      _showArticleIcon = shouldShowArticleIcon;
    });
  }

  Future<void> _jumpToComments() async {
    final commentContext = _commentSectionKey.currentContext;
    if (commentContext == null) {
      return;
    }
    await Scrollable.ensureVisible(
      commentContext,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: 0,
    );
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) {
      return;
    }
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _copyAll(
    BuildContext context, {
    required String plainText,
  }) async {
    await Clipboard.setData(ClipboardData(text: plainText));
    if (!context.mounted) {
      return;
    }
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('已复制'),
        content: const Text('文章全文已复制到剪贴板。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final articleBody = ShortVideoArticleBodyHelper.parse(
      title: widget.detail.title,
      source: widget.detail.source,
      updateTime: widget.detail.updateTime,
      htmlText: widget.detail.htmlText,
      coverUrl: widget.coverUrl,
    );
    final articleBodyWidgets = ShortVideoArticleBodyHelper.buildWidgets(
      context: context,
      nodes: articleBody.nodes,
      galleryImageUrls: articleBody.imageUrls,
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.detail.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () {
            _copyAll(
              context,
              plainText: articleBody.plainText,
            );
          },
          child: const AppAssetIcon(
            assetName: 'copy',
            size: 20,
            fallbackIcon: CupertinoIcons.doc_on_doc,
          ),
        ),
        previousPageTitle: '返回',
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 64),
              child: wrapWithDesktopFriendlyScrollBehavior(
                SelectionArea(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                widget.detail.title,
                                style: const TextStyle(
                                  color: Color(0xFF1C1C1E),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                '${widget.detail.source}  ${widget.detail.updateTime}'.trim(),
                                style: const TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 13,
                                ),
                              ),
                              if (widget.coverUrl.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                ShortVideoGalleryPreviewImage(
                                  imageUrl: widget.coverUrl,
                                  galleryImageUrls: articleBody.imageUrls,
                                ),
                              ],
                              if (articleBodyWidgets.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                ...articleBodyWidgets,
                              ],
                              const SizedBox(height: 24),
                              DocCommentSection(
                                docId: widget.detail.id,
                                initialCommentsCount: widget.detail.commentsCount,
                                scrollController: _scrollController,
                                sectionKey: _commentSectionKey,
                                onCommentsCountChanged: (count) {
                                  if (_commentsCount == count || !mounted) {
                                    return;
                                  }
                                  setState(() {
                                    _commentsCount = count;
                                  });
                                },
                                onTapReply: (_) {
                                  showArticleCommentInputSheet(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ArticleDetailBottomActionBar(
                isCommentMode: !_showArticleIcon,
                commentCountText: _commentBadgeText,
                isCollected: _isCollected,
                isLiked: _isLiked,
                onTapPlaceholder: () {
                  showArticleCommentInputSheet(context);
                },
                onTapModeToggle: () {
                  if (_showArticleIcon) {
                    _scrollToTop();
                    return;
                  }
                  _jumpToComments();
                },
                onTapCollect: () {
                  setState(() {
                    _isCollected = !_isCollected;
                  });
                },
                onTapLike: () {
                  setState(() {
                    _isLiked = !_isLiked;
                  });
                },
                onTapShare: () {
                  showArticleShareSheet(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
