import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

const Set<PointerDeviceKind> _desktopFriendlyGalleryDragDevices =
    <PointerDeviceKind>{
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.stylus,
      PointerDeviceKind.invertedStylus,
      PointerDeviceKind.unknown,
    };

class _ShortVideoGalleryScrollBehavior extends CupertinoScrollBehavior {
  const _ShortVideoGalleryScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices =>
      _desktopFriendlyGalleryDragDevices;
}

Widget galleryWrapWithDesktopFriendlyScrollBehavior(Widget child) {
  return ScrollConfiguration(
    behavior: const _ShortVideoGalleryScrollBehavior(),
    child: child,
  );
}

Future<void> openShortVideoImageGallery(
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
      builder: (_) => _ShortVideoImageGalleryPage(
        imageUrls: imageUrls,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
      ),
    ),
  );
}

class ShortVideoGalleryPreviewImage extends StatelessWidget {
  const ShortVideoGalleryPreviewImage({
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

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = imageUrl.trim();
    if (normalizedUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        openShortVideoImageGallery(
          context,
          imageUrls: galleryImageUrls,
          initialImageUrl: normalizedUrl,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CustomNetworkImage(
          normalizedUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _ShortVideoImageGalleryPage extends StatefulWidget {
  const _ShortVideoImageGalleryPage({
    required this.imageUrls,
    required this.initialIndex,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_ShortVideoImageGalleryPage> createState() =>
      _ShortVideoImageGalleryPageState();
}

class _ShortVideoImageGalleryPageState extends State<_ShortVideoImageGalleryPage> {
  static const double _dismissDragThreshold = 140;

  late final PageController _pageController;
  late int _currentIndex;
  double _verticalDragOffset = 0;

  double get _backgroundOpacity {
    final progress = (_verticalDragOffset.abs() / 220).clamp(0.0, 0.7).toDouble();
    return 1 - progress;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta;
    if (delta == null) {
      return;
    }
    setState(() {
      _verticalDragOffset += delta;
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldDismiss =
        _verticalDragOffset.abs() > _dismissDragThreshold || velocity.abs() > 900;
    if (shouldDismiss) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _verticalDragOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Color.fromRGBO(0, 0, 0, _backgroundOpacity),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              color: Color.fromRGBO(0, 0, 0, _backgroundOpacity),
              child: Transform.translate(
                offset: Offset(0, _verticalDragOffset),
                child: galleryWrapWithDesktopFriendlyScrollBehavior(
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragUpdate: _handleVerticalDragUpdate,
                    onVerticalDragEnd: _handleVerticalDragEnd,
                    onVerticalDragCancel: () {
                      setState(() {
                        _verticalDragOffset = 0;
                      });
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(12, 24, 12, 28),
                          child: _GalleryZoomableImage(
                            imageUrl: widget.imageUrls[index],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: false,
                child: Opacity(
                  opacity: _backgroundOpacity,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x99000000),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0x55000000),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: CupertinoButton(
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(36, 36),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const AppAssetIcon(
                              assetName: 'close',
                              color: CupertinoColors.white,
                              size: 22,
                              fallbackIcon: CupertinoIcons.clear,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x55000000),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_currentIndex + 1}/${widget.imageUrls.length}',
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: IgnorePointer(
                child: Opacity(
                  opacity: _backgroundOpacity,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x55000000),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '左右切图，双击放大，下滑关闭',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
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

class _GalleryZoomableImage extends StatefulWidget {
  const _GalleryZoomableImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<_GalleryZoomableImage> createState() => _GalleryZoomableImageState();
}

class _GalleryZoomableImageState extends State<_GalleryZoomableImage> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool _hasImageFrame = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final position = _doubleTapDetails?.localPosition;
    if (position == null) {
      return;
    }

    final isZoomed = _transformationController.value != Matrix4.identity();
    if (isZoomed) {
      _transformationController.value = Matrix4.identity();
      return;
    }

    const zoomScale = 2.5;
    final zoomed = Matrix4.identity()
      ..translateByDouble(
        -position.dx * (zoomScale - 1),
        -position.dy * (zoomScale - 1),
        0,
        1,
      )
      ..scaleByDouble(zoomScale, zoomScale, 1, 1);
    _transformationController.value = zoomed;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) {
        _doubleTapDetails = details;
      },
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1,
        maxScale: 4,
        trackpadScrollCausesScale: true,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: _hasImageFrame ? 1 : 0,
              curve: Curves.easeOut,
              child: CustomNetworkImage(
                widget.imageUrl,
                fit: BoxFit.contain,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    if (!_hasImageFrame) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) {
                          return;
                        }
                        setState(() {
                          _hasImageFrame = true;
                        });
                      });
                    }
                  }
                  return child;
                },
                errorBuilder: (_, __, ___) {
                  if (!_hasImageFrame) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) {
                        return;
                      }
                      setState(() {
                        _hasImageFrame = true;
                      });
                    });
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '图片加载失败',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
