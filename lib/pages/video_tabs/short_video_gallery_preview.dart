import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/gallery_preview/index.dart';

@Deprecated('Use GalleryPreviewImage from lib/components/gallery_preview')
typedef ShortVideoGalleryPreviewImage = GalleryPreviewImage;

@Deprecated(
  'Use wrapWithGalleryPreviewScrollBehavior from lib/components/gallery_preview',
)
Widget galleryWrapWithDesktopFriendlyScrollBehavior(Widget child) {
  return wrapWithGalleryPreviewScrollBehavior(child);
}

@Deprecated('Use openGalleryPreview from lib/components/gallery_preview')
Future<void> openShortVideoImageGallery(
  BuildContext context, {
  required List<String> imageUrls,
  required String initialImageUrl,
}) {
  return openGalleryPreview(
    context,
    imageUrls: imageUrls,
    initialImageUrl: initialImageUrl,
  );
}
