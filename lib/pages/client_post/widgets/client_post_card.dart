import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/gallery_preview/index.dart';
import 'package:oolaf_flutted/model/client_post/client_post.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';

class ClientPostCard extends StatelessWidget {
  const ClientPostCard({
    super.key,
    required this.post,
    required this.expanded,
    required this.onToggleExpanded,
    required this.activeVideoController,
    required this.onTapVideo,
  });

  final ClientPostItem post;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final OolafVideoController? activeVideoController;
  final ValueChanged<ClientPostItem> onTapVideo;

  @override
  Widget build(BuildContext context) {
    final images = post.imageUrls;
    final video = post.video;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border:
            Border(bottom: BorderSide(color: Color(0xFFEDEDED), width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Avatar(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Oolaf',
                    style: TextStyle(
                        color: Color(0xFF576B95),
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                if (post.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _ExpandableText(
                      text: post.text,
                      expanded: expanded,
                      onToggle: onToggleExpanded),
                ],
                if (images.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _ImageGrid(urls: images),
                ],
                if (video != null) ...[
                  const SizedBox(height: 10),
                  _VideoBox(
                      post: post,
                      video: video,
                      controller: activeVideoController,
                      onTap: () => onTapVideo(post)),
                ],
                if (post.link != null) ...[
                  const SizedBox(height: 10),
                  _LinkCard(link: post.link!),
                ],
                const SizedBox(height: 8),
                Text(_formatTime(post.publishedAt),
                    style: const TextStyle(
                        color: Color(0xFF9A9A9A), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? value) {
    if (value == null) {
      return '';
    }
    final now = DateTime.now();
    final diff = now.difference(value);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
          color: const Color(0xFF07C160),
          borderRadius: BorderRadius.circular(6)),
      child: const Center(
          child: Text('O',
              style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800))),
    );
  }
}

class _ExpandableText extends StatelessWidget {
  const _ExpandableText(
      {required this.text, required this.expanded, required this.onToggle});

  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isLong = text.length > 110;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: expanded ? null : 6,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: const TextStyle(
              color: Color(0xFF1F1F1F), fontSize: 16, height: 1.42),
        ),
        if (isLong)
          CupertinoButton(
            minimumSize: Size.zero,
            padding: const EdgeInsets.only(top: 4),
            onPressed: onToggle,
            child: Text(expanded ? '收起' : '全文',
                style: const TextStyle(
                    color: Color(0xFF576B95), fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final columns = urls.length == 1 ? 1 : (urls.length <= 4 ? 2 : 3);
    final size = urls.length == 1 ? 190.0 : 88.0;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: urls
          .map(
            (url) => GestureDetector(
              onTap: () => openGalleryPreview(context,
                  imageUrls: urls, initialImageUrl: url),
              child: SizedBox(
                width: columns == 1 ? size : 88,
                height: columns == 1 ? size : 88,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(url, fit: BoxFit.cover)),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _VideoBox extends StatelessWidget {
  const _VideoBox(
      {required this.post,
      required this.video,
      required this.controller,
      required this.onTap});

  final ClientPostItem post;
  final ClientPostMediaItem video;
  final OolafVideoController? controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 180,
        height: 240,
        child: DecoratedBox(
          decoration: BoxDecoration(
              color: CupertinoColors.black,
              borderRadius: BorderRadius.circular(4)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (controller != null)
                ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: controller!.buildView(fit: BoxFit.cover))
              else
                const Center(
                    child: Icon(CupertinoIcons.play_circle_fill,
                        color: CupertinoColors.white, size: 46)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.link});

  final ClientPostLink link;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(4)),
      child: Row(
        children: [
          const Icon(CupertinoIcons.link, color: Color(0xFF576B95), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              link.title.isEmpty ? link.url : link.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF1F1F1F), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
