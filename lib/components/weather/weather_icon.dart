import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherIcon extends StatelessWidget {
  const WeatherIcon({
    super.key,
    required this.iconCode,
    this.size = 28,
    this.color = CupertinoColors.white,
  });

  final String iconCode;
  final double size;
  final Color color;

  String get _assetPath => 'assets/weather/icons/$iconCode.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (context) {
        return SizedBox(
          width: size,
          height: size,
          child: Icon(
            CupertinoIcons.sun_max,
            size: size,
            color: color,
          ),
        );
      },
    );
  }
}
