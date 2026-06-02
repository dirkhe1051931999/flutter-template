import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class GalleryZoomableImage extends StatefulWidget {
  const GalleryZoomableImage({
    required this.imageUrl,
    required this.onInteractionStateChanged,
    required this.onVerticalGestureHandlingChanged,
    super.key,
  });

  final String imageUrl;
  final ValueChanged<bool> onInteractionStateChanged;
  final ValueChanged<bool> onVerticalGestureHandlingChanged;

  @override
  State<GalleryZoomableImage> createState() => _GalleryZoomableImageState();
}

class _GalleryZoomableImageState extends State<GalleryZoomableImage>
    with SingleTickerProviderStateMixin {
  static const double _longImageThresholdRatio = 1.85;
  final TransformationController _transformationController =
      TransformationController();
  late final AnimationController _transformAnimationController;
  TapDownDetails? _doubleTapDetails;
  bool _hasImageFrame = false;
  Animation<Matrix4>? _zoomAnimation;
  bool _isZoomed = false;
  bool _isHandlingVerticalDrag = false;
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
    )..addListener(() {
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
  void didUpdateWidget(covariant GalleryZoomableImage oldWidget) {
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
    final imageStreamListener = _imageStreamListener;
    if (imageStreamListener != null) {
      _imageStream?.removeListener(imageStreamListener);
    }

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
    setState(() {
      _isZoomed = isZoomed;
    });
    widget.onInteractionStateChanged(isZoomed);
  }

  bool _isLongImage(Size viewportSize) {
    final imageSize = _rawImageSize;
    if (imageSize == null || imageSize.width <= 0 || imageSize.height <= 0) {
      return false;
    }

    final widthFittedHeight =
        viewportSize.width * imageSize.height / imageSize.width;
    return widthFittedHeight > viewportSize.height * _longImageThresholdRatio;
  }

  Size _contentSize(Size viewportSize) {
    final imageSize = _rawImageSize;
    if (imageSize == null || imageSize.width <= 0 || imageSize.height <= 0) {
      return viewportSize;
    }

    if (_isLongImage(viewportSize)) {
      return Size(
        viewportSize.width,
        viewportSize.width * imageSize.height / imageSize.width,
      );
    }

    final imageAspectRatio = imageSize.width / imageSize.height;
    final viewportAspectRatio = viewportSize.width / viewportSize.height;
    if (imageAspectRatio > viewportAspectRatio) {
      return Size(viewportSize.width, viewportSize.width / imageAspectRatio);
    }
    return Size(viewportSize.height * imageAspectRatio, viewportSize.height);
  }

  void _notifyVerticalGestureHandling(Size viewportSize) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final contentSize = _contentSize(viewportSize);
    final shouldHandle =
        scale > 1.01 || contentSize.height > viewportSize.height + 0.5;
    if (_isHandlingVerticalDrag == shouldHandle) {
      return;
    }
    _isHandlingVerticalDrag = shouldHandle;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onVerticalGestureHandlingChanged(shouldHandle);
    });
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

  ({double minDx, double maxDx, double minDy, double maxDy}) _translationBounds(
    Size viewportSize,
    double scale,
  ) {
    final baseSize = _contentSize(viewportSize);
    final scaledWidth = baseSize.width * scale;
    final scaledHeight = baseSize.height * scale;
    final isLongImage = _isLongImage(viewportSize);

    final horizontalInset = scaledWidth <= viewportSize.width
        ? (viewportSize.width - scaledWidth) / 2
        : 0.0;
    final verticalInset = scaledHeight <= viewportSize.height
        ? (isLongImage ? 0.0 : (viewportSize.height - scaledHeight) / 2)
        : 0.0;

    return (
      minDx: scaledWidth <= viewportSize.width
          ? horizontalInset
          : viewportSize.width - scaledWidth,
      maxDx: scaledWidth <= viewportSize.width ? horizontalInset : 0.0,
      minDy: scaledHeight <= viewportSize.height
          ? verticalInset
          : viewportSize.height - scaledHeight,
      maxDy: scaledHeight <= viewportSize.height ? verticalInset : 0.0,
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
      _animateTo(
        Matrix4.identity()..scaleByDouble(zoomScale, zoomScale, 1, 1),
      );
      return;
    }
    final displayedSize = _contentSize(viewportSize);
    final baseBounds = _translationBounds(viewportSize, 1);
    final imageOrigin = Offset(baseBounds.minDx, baseBounds.minDy);
    final normalizedAnchor = Offset(
      ((position.dx - imageOrigin.dx) / displayedSize.width).clamp(0.0, 1.0),
      ((position.dy - imageOrigin.dy) / displayedSize.height).clamp(0.0, 1.0),
    );
    final localAnchor = Offset(
      displayedSize.width * normalizedAnchor.dx,
      displayedSize.height * normalizedAnchor.dy,
    );
    final zoomedOffset = Offset(
      position.dx - localAnchor.dx * zoomScale,
      position.dy - localAnchor.dy * zoomScale,
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
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        final contentSize = _contentSize(viewportSize);
        final isLongImage = _isLongImage(viewportSize);
        _notifyVerticalGestureHandling(viewportSize);
        final useScrollableLongImage = isLongImage && !_isZoomed;

        final imageContent = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: _hasImageFrame ? 1 : 0,
            curve: Curves.easeOut,
            child: SizedBox(
              width: contentSize.width,
              height: contentSize.height,
              child: CustomNetworkImage(
                widget.imageUrl,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                frameBuilder: (
                  context,
                  child,
                  frame,
                  wasSynchronouslyLoaded,
                ) {
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
        );

        return GestureDetector(
          onDoubleTapDown: (details) {
            _doubleTapDetails = details;
          },
          onDoubleTap: _handleDoubleTap,
          child: useScrollableLongImage
              ? SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: viewportSize.width,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: imageContent,
                    ),
                  ),
                )
              : InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: _minScale,
                  maxScale: _maxScale,
                  panEnabled: _isZoomed,
                  scaleEnabled: true,
                  constrained: false,
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  boundaryMargin: EdgeInsets.zero,
                  interactionEndFrictionCoefficient: 0.00008,
                  trackpadScrollCausesScale: true,
                  onInteractionStart: (_) {
                    _transformAnimationController.stop();
                    _zoomAnimation = null;
                  },
                  onInteractionEnd: (_) {
                    _handleInteractionEnd(viewportSize);
                  },
                  child: imageContent,
                ),
        );
      },
    );
  }
}
