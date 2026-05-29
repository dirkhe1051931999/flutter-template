import 'package:flutter/material.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';

const double _hupuMediaPreviewMaxHeight = 220;

class HupuMediaBlock extends StatelessWidget {
  const HupuMediaBlock({
    required this.images,
    required this.video,
    this.onTap,
    super.key,
  });

  final List<HupuImageItem> images;
  final HupuVideoItem? video;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final previewImages = images.take(4).toList(growable: false);
    final imageUrl = video?.cover.isNotEmpty == true
        ? video!.cover
        : (previewImages.isNotEmpty ? previewImages.first.url : '');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final aspectRatio = video?.aspectRatio ??
                _imageGridAspectRatio(previewImages.length);
            final maxWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width;
            final rawHeight = maxWidth / aspectRatio;
            final height = rawHeight.clamp(0.0, _hupuMediaPreviewMaxHeight);

            return SizedBox(
              width: double.infinity,
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Colors.black),
                  if (video != null)
                    CustomNetworkImage(
                      imageUrl,
                      fit: BoxFit.cover,
                      skeletonBorderRadius: BorderRadius.circular(12),
                    )
                  else
                    _ImageGrid(
                      images: previewImages,
                      totalCount: images.length,
                    ),
                  if (video != null)
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x14000000),
                            Color(0x4D000000),
                          ],
                        ),
                      ),
                    ),
                  if (video != null)
                    const Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xB3000000),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xB3000000),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        video != null
                            ? '${video!.duration}  ${video!.playCount}'
                            : images.length > 1
                                ? '${images.length} 图'
                                : '图片',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

double _imageGridAspectRatio(int count) {
  if (count <= 1) {
    return 1.08;
  }
  if (count == 2) {
    return 1.28;
  }
  return 1.0;
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({
    required this.images,
    required this.totalCount,
  });

  final List<HupuImageItem> images;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const ColoredBox(color: Color(0xFFF1F2F5));
    }
    if (images.length == 1) {
      return CustomNetworkImage(
        images.first.url,
        fit: BoxFit.cover,
        skeletonBorderRadius: BorderRadius.circular(12),
      );
    }
    if (images.length == 2) {
      return Row(
        children: [
          for (int i = 0; i < images.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              child: CustomNetworkImage(
                images[i].url,
                fit: BoxFit.cover,
                skeletonBorderRadius: BorderRadius.circular(0),
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomNetworkImage(
                  images[0].url,
                  fit: BoxFit.cover,
                  skeletonBorderRadius: BorderRadius.circular(0),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: CustomNetworkImage(
                        images[1].url,
                        fit: BoxFit.cover,
                        skeletonBorderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomNetworkImage(
                            images[2].url,
                            fit: BoxFit.cover,
                            skeletonBorderRadius: BorderRadius.circular(0),
                          ),
                          if (totalCount > 3)
                            Container(
                              color: const Color(0x66000000),
                              alignment: Alignment.center,
                              child: Text(
                                '+${totalCount - 3}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
