import 'package:flutter/cupertino.dart';

class CustomNetworkImage extends StatefulWidget {
  const CustomNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.low,
    this.errorBuilder,
    this.loadingBuilder,
    this.frameBuilder,
    this.color,
    this.colorBlendMode,
    this.repeat = ImageRepeat.noRepeat,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.enableDeferredLoading = true,
    this.showSkeleton = true,
    this.skeletonBaseColor = const Color(0xFFE9EAEE),
    this.skeletonHighlightColor = const Color(0xFFF6F7F9),
    this.skeletonBorderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final FilterQuality filterQuality;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageFrameBuilder? frameBuilder;
  final Color? color;
  final BlendMode? colorBlendMode;
  final ImageRepeat repeat;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final bool enableDeferredLoading;
  final bool showSkeleton;
  final Color skeletonBaseColor;
  final Color skeletonHighlightColor;
  final BorderRadius? skeletonBorderRadius;

  @override
  State<CustomNetworkImage> createState() => _CustomNetworkImageState();
}

class _CustomNetworkImageState extends State<CustomNetworkImage>
    with SingleTickerProviderStateMixin {
  bool _shouldRenderImage = false;
  bool _deferredCheckScheduled = false;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureImageReady();
  }

  @override
  void didUpdateWidget(covariant CustomNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.enableDeferredLoading != widget.enableDeferredLoading) {
      _shouldRenderImage = false;
      _deferredCheckScheduled = false;
      _ensureImageReady();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _ensureImageReady() {
    final normalizedUrl = widget.url.trim();
    if (normalizedUrl.isEmpty) {
      _shouldRenderImage = false;
      return;
    }

    final shouldDefer = widget.enableDeferredLoading &&
        Scrollable.recommendDeferredLoadingForContext(context);
    if (!shouldDefer) {
      if (!_shouldRenderImage && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _shouldRenderImage = true;
          });
        });
      }
      return;
    }

    if (_deferredCheckScheduled) {
      return;
    }
    _deferredCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) {
        return;
      }
      _deferredCheckScheduled = false;
      _ensureImageReady();
    });
  }

  Widget _buildDefaultError(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE5E5EA),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: Icon(
            CupertinoIcons.photo,
            color: Color(0xFF8E8E93),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    final skeleton = AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerPosition = _shimmerController.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.skeletonBorderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1.8 + shimmerPosition * 2.8, -0.35),
              end: Alignment(-0.8 + shimmerPosition * 2.8, 0.35),
              colors: [
                widget.skeletonBaseColor,
                widget.skeletonHighlightColor,
                widget.skeletonBaseColor,
              ],
              stops: const [0.18, 0.5, 0.82],
            ),
          ),
          child: child,
        );
      },
      child: SizedBox(
        width: widget.width,
        height: widget.height,
      ),
    );

    if (widget.skeletonBorderRadius == null) {
      return skeleton;
    }
    return ClipRRect(
      borderRadius: widget.skeletonBorderRadius!,
      child: skeleton,
    );
  }

  Widget _buildDefaultLoading(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) {
      return child;
    }
    if (widget.showSkeleton) {
      return _buildSkeleton();
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: const Center(
        child: CupertinoActivityIndicator(radius: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = widget.url.trim();
    if (normalizedUrl.isEmpty) {
      return _buildDefaultError(context);
    }

    _ensureImageReady();

    if (!_shouldRenderImage) {
      return widget.showSkeleton
          ? _buildSkeleton()
          : SizedBox(
              width: widget.width,
              height: widget.height,
            );
    }

    return Image.network(
      normalizedUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      filterQuality: widget.filterQuality,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      repeat: widget.repeat,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      matchTextDirection: widget.matchTextDirection,
      gaplessPlayback: widget.gaplessPlayback,
      frameBuilder: widget.frameBuilder,
      loadingBuilder: widget.loadingBuilder ?? _buildDefaultLoading,
      errorBuilder: widget.errorBuilder ??
          (context, error, stackTrace) {
            return _buildDefaultError(context);
          },
    );
  }
}
