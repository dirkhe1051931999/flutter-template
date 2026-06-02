import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:oolaf_flutted/components/gallery_preview/gallery_preview_page.dart';

const Set<PointerDeviceKind> _desktopFriendlyGalleryDragDevices =
    <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown,
};

class GalleryPreviewScrollBehavior extends CupertinoScrollBehavior {
  const GalleryPreviewScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => _desktopFriendlyGalleryDragDevices;
}

Widget wrapWithGalleryPreviewScrollBehavior(Widget child) {
  return ScrollConfiguration(
    behavior: const GalleryPreviewScrollBehavior(),
    child: child,
  );
}

Future<void> openGalleryPreview(
  BuildContext context, {
  required List<String> imageUrls,
  required String initialImageUrl,
}) async {
  if (imageUrls.isEmpty) {
    return;
  }

  final initialIndex = imageUrls.indexOf(initialImageUrl);
  await Navigator.of(context, rootNavigator: true).push<void>(
    CupertinoPageRoute<void>(
      builder: (_) => GalleryPreviewPage(
        imageUrls: imageUrls,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
      ),
    ),
  );
}
