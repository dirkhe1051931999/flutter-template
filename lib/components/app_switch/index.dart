import 'package:flutter/cupertino.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.loading = false,
    this.disabled = false,
    this.size = 30,
    this.activeColor = const Color(0xFF2563EB),
    this.inactiveColor = const Color(0xFFD5DAE3),
    this.activeValue = true,
    this.inactiveValue = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool loading;
  final bool disabled;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool activeValue;
  final bool inactiveValue;

  @override
  Widget build(BuildContext context) {
    final scale = size / 30;
    final effectiveDisabled = disabled || loading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: effectiveDisabled ? 0.56 : 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: scale,
            child: CupertinoSwitch(
              value: value == activeValue,
              activeTrackColor: activeColor,
              inactiveTrackColor: inactiveColor,
              thumbColor: const Color(0xFFFFFFFF),
              onChanged: effectiveDisabled
                  ? null
                  : (nextValue) {
                      onChanged(nextValue ? activeValue : inactiveValue);
                    },
            ),
          ),
          if (loading)
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x66FFFFFF),
                borderRadius: BorderRadius.circular(size),
              ),
              child: SizedBox(
                width: size * 1.7,
                height: size,
                child: const Center(
                  child: CupertinoActivityIndicator(radius: 7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
