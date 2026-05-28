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
  bool _isCurrentImageZoomed = false;

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
    if (_isCurrentImageZoomed) {
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
    if (_isCurrentImageZoomed) {
      return;
    }
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
                      physics: _isCurrentImageZoomed
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
                      itemCount: widget.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          _isCurrentImageZoomed = false;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(12, 24, 12, 28),
                          child: _GalleryZoomableImage(
                            imageUrl: widget.imageUrls[index],
                            onInteractionStateChanged: (isZoomed) {
                              if (_currentIndex != index || _isCurrentImageZoomed == isZoomed) {
                                return;
                              }
                              setState(() {
                                _isCurrentImageZoomed = isZoomed;
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
    required this.onInteractionStateChanged,
  });

  final String imageUrl;
  final ValueChanged<bool> onInteractionStateChanged;

  @override
  State<_GalleryZoomableImage> createState() => _GalleryZoomableImageState();
}

class _GalleryZoomableImageState extends State<_GalleryZoomableImage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late final AnimationController _transformAnimationController;
  TapDownDetails? _doubleTapDetails;
  bool _hasImageFrame = false;
  Animation<Matrix4>? _zoomAnimation;
  bool _isZoomed = false;
  Size? _rawImageSize;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  static const double _doubleTapZoomScale = 2.4;
  static const double _minScale = 1;
  static const double _maxScale = 4;

  @override
  void initState() {
    super.initState();
    _transformAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )
      ..addListener(() {
        final animation = _zoomAnimation;
        if (animation == null) {
          return;
        }
        _transformationController.value = animation.value;
        _notifyInteractionState();
      });
    _transformationController.addListener(_notifyInteractionState);
    _resolveImageSize();
  }

  @override
  void didUpdateWidget(covariant _GalleryZoomableImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _rawImageSize = null;
      _transformationController.value = Matrix4.identity();
      _resolveImageSize();
      _notifyInteractionState();
    }
  }

  @override
  void dispose() {
    final imageStreamListener = _imageStreamListener;
    if (imageStreamListener != null) {
      _imageStream?.removeListener(imageStreamListener);
    }
    _transformationController.removeListener(_notifyInteractionState);
    _transformAnimationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _resolveImageSize() {
    final provider = NetworkImage(widget.imageUrl);
    final stream = provider.resolve(const ImageConfiguration());
    _imageStream = stream;
    _imageStreamListener = ImageStreamListener((image, _) {
      final size = Size(
        image.image.width.toDouble(),
        image.image.height.toDouble(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _rawImageSize = size;
      });
    });
    stream.addListener(_imageStreamListener!);
  }

  void _notifyInteractionState() {
    final isZoomed = _transformationController.value.getMaxScaleOnAxis() > 1.01;
    if (_isZoomed == isZoomed) {
      return;
    }
    _isZoomed = isZoomed;
    widget.onInteractionStateChanged(isZoomed);
  }

  void _animateTo(Matrix4 target) {
    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _transformAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _transformAnimationController
      ..stop()
      ..reset()
      ..forward();
  }

  Offset _extractTranslation(Matrix4 matrix) {
    final values = matrix.storage;
    return Offset(values[12], values[13]);
  }

  Matrix4 _matrixFor(double scale, Offset offset) {
    return Matrix4.identity()
      ..translateByDouble(offset.dx, offset.dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  Size _displayedImageSize(Size viewportSize) {
    final imageSize = _rawImageSize;
    if (imageSize == null || imageSize.width <= 0 || imageSize.height <= 0) {
      return viewportSize;
    }
    final imageAspectRatio = imageSize.width / imageSize.height;
    final viewportAspectRatio = viewportSize.width / viewportSize.height;
    if (imageAspectRatio > viewportAspectRatio) {
      return Size(viewportSize.width, viewportSize.width / imageAspectRatio);
    }
    return Size(viewportSize.height * imageAspectRatio, viewportSize.height);
  }

  ({double minDx, double maxDx, double minDy, double maxDy}) _translationBounds(
    Size viewportSize,
    double scale,
  ) {
    final baseSize = _displayedImageSize(viewportSize);
    final scaledWidth = baseSize.width * scale;
    final scaledHeight = baseSize.height * scale;
    final horizontalOverflow = ((scaledWidth - viewportSize.width) / 2).clamp(0.0, double.infinity);
    final verticalOverflow = ((scaledHeight - viewportSize.height) / 2).clamp(0.0, double.infinity);
    return (
      minDx: -horizontalOverflow,
      maxDx: horizontalOverflow,
      minDy: -verticalOverflow,
      maxDy: verticalOverflow,
    );
  }

  Matrix4 _normalizedTransform(Matrix4 current, Size viewportSize) {
    final currentScale = current.getMaxScaleOnAxis();
    final normalizedScale = currentScale.clamp(_minScale, _maxScale);
    final currentOffset = _extractTranslation(current);
    final bounds = _translationBounds(viewportSize, normalizedScale);
    final normalizedOffset = Offset(
      currentOffset.dx.clamp(bounds.minDx, bounds.maxDx),
      currentOffset.dy.clamp(bounds.minDy, bounds.maxDy),
    );
    return _matrixFor(normalizedScale, normalizedOffset);
  }

  void _handleInteractionEnd(Size viewportSize) {
    final normalized = _normalizedTransform(
      _transformationController.value,
      viewportSize,
    );
    if (_transformationController.value != normalized) {
      _animateTo(normalized);
    }
  }

  void _handleDoubleTap() {
    final position = _doubleTapDetails?.localPosition;
    if (position == null) {
      return;
    }

    final isZoomed = _transformationController.value.getMaxScaleOnAxis() > 1.01;
    if (isZoomed) {
      _animateTo(Matrix4.identity());
      return;
    }

    const zoomScale = _doubleTapZoomScale;
    final box = context.findRenderObject() as RenderBox?;
    final viewportSize = box?.size;
    if (viewportSize == null) {
      _animateTo(Matrix4.identity()..scaleByDouble(zoomScale, zoomScale, 1, 1));
      return;
    }
    final displayedSize = _displayedImageSize(viewportSize);
    final imageOrigin = Offset(
      (viewportSize.width - displayedSize.width) / 2,
      (viewportSize.height - displayedSize.height) / 2,
    );
    final normalizedAnchor = Offset(
      ((position.dx - imageOrigin.dx) / displayedSize.width).clamp(0.0, 1.0),
      ((position.dy - imageOrigin.dy) / displayedSize.height).clamp(0.0, 1.0),
    );
    final anchorOnImage = Offset(
      imageOrigin.dx + displayedSize.width * normalizedAnchor.dx,
      imageOrigin.dy + displayedSize.height * normalizedAnchor.dy,
    );
    final zoomedOffset = Offset(
      -anchorOnImage.dx * (zoomScale - 1),
      -anchorOnImage.dy * (zoomScale - 1),
    );
    final zoomed = _normalizedTransform(
      _matrixFor(zoomScale, zoomedOffset),
      viewportSize,
    );
    _animateTo(zoomed);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onDoubleTapDown: (details) {
            _doubleTapDetails = details;
          },
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: _minScale,
            maxScale: _maxScale,
            panEnabled: true,
            scaleEnabled: true,
            constrained: false,
            clipBehavior: Clip.none,
            boundaryMargin: const EdgeInsets.symmetric(
              horizontal: 120,
              vertical: 160,
            ),
            interactionEndFrictionCoefficient: 0.00008,
            trackpadScrollCausesScale: true,
            onInteractionStart: (_) {
              _transformAnimationController.stop();
              _zoomAnimation = null;
            },
            onInteractionEnd: (_) {
              _handleInteractionEnd(
                Size(constraints.maxWidth, constraints.maxHeight),
              );
            },
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
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
            ),
          ),
        );
      },
    );
  }
}
