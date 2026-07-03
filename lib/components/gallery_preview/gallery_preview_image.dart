import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/gallery_preview/gallery_image_provider.dart';
import 'package:oolaf_flutted/components/gallery_preview/gallery_preview_navigation.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class GalleryPreviewImage extends StatelessWidget {
  const GalleryPreviewImage({
    super.key,
    required this.imageUrl,
    required this.galleryImageUrls,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String imageUrl;
  final List<String> galleryImageUrls;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final double? width;
  final double? height;
  static const double _defaultAspectRatio = 4 / 3;

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = imageUrl.trim();
    if (normalizedUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasExplicitSize = width != null || height != null;
    final image = ClipRRect(
      borderRadius: borderRadius,
      child: isGalleryNetworkImage(normalizedUrl)
          ? CustomNetworkImage(
              normalizedUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            )
          : Image(
              image: resolveGalleryImageProvider(normalizedUrl),
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
    );

    return GestureDetector(
      onTap: () {
        openGalleryPreview(
          context,
          imageUrls: galleryImageUrls,
          initialImageUrl: normalizedUrl,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: hasExplicitSize
          ? image
          : SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: _defaultAspectRatio,
                child: image,
              ),
            ),
    );
  }
}
