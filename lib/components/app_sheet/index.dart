import 'package:flutter/material.dart';

enum AppSheetPosition { top, bottom }

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  AppSheetPosition position = AppSheetPosition.bottom,
  String? barrierLabel,
  double? maxHeightFactor,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: barrierLabel ?? 'sheet',
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return AppSheet(
        position: position,
        maxHeightFactor: maxHeightFactor,
        child: builder(context),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final begin = switch (position) {
        AppSheetPosition.top => const Offset(0, -1),
        AppSheetPosition.bottom => const Offset(0, 1),
      };
      return SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
  );
}

class AppSheet extends StatelessWidget {
  const AppSheet({
    super.key,
    required this.child,
    this.position = AppSheetPosition.bottom,
    this.maxHeightFactor,
    this.padding,
  });

  final Widget child;
  final AppSheetPosition position;
  final double? maxHeightFactor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final borderRadius = switch (position) {
      AppSheetPosition.top => const BorderRadius.vertical(
          bottom: Radius.circular(18),
        ),
      AppSheetPosition.bottom => const BorderRadius.vertical(
          top: Radius.circular(18),
        ),
    };
    final alignment = switch (position) {
      AppSheetPosition.top => Alignment.topCenter,
      AppSheetPosition.bottom => Alignment.bottomCenter,
    };
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: position == AppSheetPosition.top,
      bottom: position == AppSheetPosition.bottom,
      child: Align(
        alignment: alignment,
        child: Material(
          color: Colors.white,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height * (maxHeightFactor ?? 0.9),
            ),
            child: Padding(
              padding: padding ??
                  EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    position == AppSheetPosition.bottom ? safeBottom + 18 : 18,
                  ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppSheetHandle(),
                  const SizedBox(height: 12),
                  Flexible(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E2),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
