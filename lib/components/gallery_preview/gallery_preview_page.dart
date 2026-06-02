import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/gallery_preview/gallery_preview_navigation.dart';
import 'package:oolaf_flutted/components/gallery_preview/gallery_zoomable_image.dart';

class GalleryPreviewPage extends StatefulWidget {
  const GalleryPreviewPage({
    required this.imageUrls,
    required this.initialIndex,
    super.key,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<GalleryPreviewPage> createState() => _GalleryPreviewPageState();
}

class _GalleryPreviewPageState extends State<GalleryPreviewPage> {
  static const double _dismissDragThreshold = 140;

  late final PageController _pageController;
  late int _currentIndex;
  double _verticalDragOffset = 0;
  bool _isCurrentImageZoomed = false;
  bool _isCurrentImageHandlingVerticalDrag = false;

  double get _backgroundOpacity {
    final progress = (_verticalDragOffset.abs() / 220).clamp(0.0, 0.7);
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
    if (_isCurrentImageHandlingVerticalDrag) {
      return;
    }
    final delta = details.primaryDelta;
    if (delta == null) {
      return;
    }
    setState(() {
      _verticalDragOffset += delta;
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_isCurrentImageHandlingVerticalDrag) {
      return;
    }
    final velocity = details.primaryVelocity ?? 0;
    final shouldDismiss = _verticalDragOffset.abs() > _dismissDragThreshold ||
        velocity.abs() > 900;
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
                child: wrapWithGalleryPreviewScrollBehavior(
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onVerticalDragUpdate: _isCurrentImageZoomed
                        ? null
                        : _handleVerticalDragUpdate,
                    onVerticalDragEnd:
                        _isCurrentImageZoomed ? null : _handleVerticalDragEnd,
                    onVerticalDragCancel: () {
                      if (_isCurrentImageZoomed) {
                        return;
                      }
                      setState(() {
                        _verticalDragOffset = 0;
                      });
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      physics: _isCurrentImageZoomed
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
                      itemCount: widget.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          _isCurrentImageZoomed = false;
                          _isCurrentImageHandlingVerticalDrag = false;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(12, 24, 12, 28),
                          child: GalleryZoomableImage(
                            imageUrl: widget.imageUrls[index],
                            onInteractionStateChanged: (isZoomed) {
                              if (_currentIndex != index ||
                                  _isCurrentImageZoomed == isZoomed) {
                                return;
                              }
                              setState(() {
                                _isCurrentImageZoomed = isZoomed;
                              });
                            },
                            onVerticalGestureHandlingChanged:
                                (isHandlingVerticalDrag) {
                              if (_currentIndex != index ||
                                  _isCurrentImageHandlingVerticalDrag ==
                                      isHandlingVerticalDrag) {
                                return;
                              }
                              setState(() {
                                _isCurrentImageHandlingVerticalDrag =
                                    isHandlingVerticalDrag;
                              });
                            },
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
                        DecoratedBox(
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
                      child: Text(
                        _isCurrentImageZoomed
                            ? '缩放中可拖动画面，双指合拢退出'
                            : '左右切图，双击放大，下滑关闭',
                        style: const TextStyle(
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
