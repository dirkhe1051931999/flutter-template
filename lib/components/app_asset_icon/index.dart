import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAssetIcon extends StatelessWidget {
  const AppAssetIcon({
    super.key,
    required this.assetName,
    this.size = 24,
    this.color,
    this.fit = BoxFit.contain,
    this.semanticLabel,
    this.fallbackIcon,
    this.assetDirectory = 'assets/icons',
  });

  final String assetName;
  final double size;
  final Color? color;
  final BoxFit fit;
  final String? semanticLabel;
  final IconData? fallbackIcon;
  final String assetDirectory;

  String get assetPath => '$assetDirectory/$assetName.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      semanticsLabel: semanticLabel,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
      placeholderBuilder: (context) {
        return SizedBox(
          width: size,
          height: size,
          child: fallbackIcon == null
              ? null
              : Icon(
                  fallbackIcon,
                  size: size,
                  color: color,
                ),
        );
      },
    );
  }
}
