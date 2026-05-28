import 'package:flutter/material.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class HupuMediaBlock extends StatelessWidget {
  const HupuMediaBlock({
    required this.imageUrl,
    required this.imageCount,
    required this.video,
    super.key,
  });

  final String imageUrl;
  final int imageCount;
  final HupuVideoItem? video;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: video == null ? 1.42 : 0.74,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomNetworkImage(
              imageUrl,
              fit: BoxFit.cover,
              skeletonBorderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xB3000000),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  video != null
                      ? '${video!.duration}  ${video!.playCount}'
                      : imageCount > 1
                          ? '$imageCount 图'
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
      ),
    );
  }
}
