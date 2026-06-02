import 'package:flutter/cupertino.dart';

class AppPasswordInput extends StatelessWidget {
  const AppPasswordInput({
    super.key,
    required this.value,
    this.length = 6,
    this.gutter = 10,
    this.mask = true,
    this.focused = false,
    this.errorInfo,
    this.info,
    this.onTap,
  });

  final String value;
  final int length;
  final double gutter;
  final bool mask;
  final bool focused;
  final String? errorInfo;
  final String? info;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cells = List<Widget>.generate(length, (index) {
      final hasValue = index < value.length;
      final isActive = focused && index == value.length.clamp(0, length - 1);
      final displayValue = hasValue ? value[index] : '';

      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xCCFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: errorInfo != null && errorInfo!.isNotEmpty
                  ? const Color(0x33FF3B30)
                  : isActive
                      ? const Color(0x332563EB)
                      : const Color(0x12000000),
            ),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x142563EB),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: hasValue
                ? Text(
                    mask ? '•' : displayValue,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : isActive
                    ? Container(
                        width: 2,
                        height: 22,
                        color: const Color(0xFF2563EB),
                      )
                    : const SizedBox.shrink(),
          ),
        ),
      );
    });

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: _withSpacing(cells, gutter),
          ),
          if (info != null && info!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              info!,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (errorInfo != null && errorInfo!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errorInfo!,
              style: const TextStyle(
                color: Color(0xFFFF3B30),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

List<Widget> _withSpacing(List<Widget> children, double spacing) {
  if (children.length < 2) {
    return children;
  }
  final result = <Widget>[];
  for (var index = 0; index < children.length; index++) {
    result.add(children[index]);
    if (index == children.length - 1) {
      continue;
    }
    result.add(SizedBox(width: spacing));
  }
  return result;
}
