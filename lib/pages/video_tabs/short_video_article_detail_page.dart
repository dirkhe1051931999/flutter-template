import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectionArea, SelectableText;
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    );
  }
}
