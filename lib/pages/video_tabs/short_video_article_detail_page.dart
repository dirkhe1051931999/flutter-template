import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectionArea, SelectableText;
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

class ShortVideoArticleDetailPage extends StatelessWidget {
  const ShortVideoArticleDetailPage({
    super.key,
    required this.detail,
    required this.coverUrl,
  });

  final HeadlineNewsDocDetail detail;
  final String coverUrl;

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
      title: detail.title,
      source: detail.source,
      updateTime: detail.updateTime,
      htmlText: detail.htmlText,
      coverUrl: coverUrl,
    );
    final articleBodyWidgets = ShortVideoArticleBodyHelper.buildWidgets(
      context: context,
      nodes: articleBody.nodes,
      galleryImageUrls: articleBody.imageUrls,
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          detail.title,
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
          child: const Icon(CupertinoIcons.doc_on_doc, size: 20),
        ),
        previousPageTitle: '返回',
      ),
      child: SafeArea(
        child: wrapWithDesktopFriendlyScrollBehavior(
          SelectionArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
              children: [
                SelectableText(
                  detail.title,
                  style: const TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  '${detail.source}  ${detail.updateTime}'.trim(),
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                  ),
                ),
                if (coverUrl.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ShortVideoGalleryPreviewImage(
                    imageUrl: coverUrl,
                    galleryImageUrls: articleBody.imageUrls,
                  ),
                ],
                if (articleBodyWidgets.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ...articleBodyWidgets,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
