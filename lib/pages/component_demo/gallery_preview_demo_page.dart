import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_button/index.dart';
import 'package:oolaf_flutted/components/gallery_preview/index.dart';

class GalleryPreviewDemoPage extends StatelessWidget {
  const GalleryPreviewDemoPage({super.key});

  static const List<String> galleryImageUrls = <String>[
    'https://picsum.photos/id/237/1200/800',
    'https://picsum.photos/id/1025/960/1440',
    'https://picsum.photos/id/1062/900/2200',
    'https://picsum.photos/id/1074/1280/720',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _DemoSection(
          title: '缩略图入口',
          subtitle: '点击缩略图进入预览，左右切图，双击放大。',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: galleryImageUrls
                .map(
                  (url) => GalleryPreviewImage(
                    imageUrl: url,
                    galleryImageUrls: galleryImageUrls,
                    width: 106,
                    height: 126,
                    borderRadius: BorderRadius.circular(18),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '长图模式',
          subtitle: '第三张是长图，适合验证顶部定位、左右切图和双击缩放。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GalleryPreviewImage(
                imageUrl: galleryImageUrls[2],
                galleryImageUrls: galleryImageUrls,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(20),
              ),
              const SizedBox(height: 10),
              const Text(
                '点击后可以重点看两件事：\n1. 默认是否还会莫名贴顶\n2. 左右是否还能顺畅切到下一张',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '直接打开预览',
          subtitle: '不依赖缩略图，直接从按钮拉起 gallery。',
          child: AppButton(
            block: true,
            onPressed: () {
              openGalleryPreview(
                context,
                imageUrls: galleryImageUrls,
                initialImageUrl: galleryImageUrls[1],
              );
            },
            child: const Text('打开 Gallery Preview'),
          ),
        ),
      ],
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF8F96A3),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
