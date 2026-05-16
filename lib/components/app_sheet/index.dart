import 'dart:ui';

import 'package:flutter/material.dart';

enum AppSheetPosition { top, bottom }

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  AppSheetPosition position = AppSheetPosition.bottom,
  String? barrierLabel,
  double? maxHeightFactor,
  Color backgroundColor = Colors.white,
  bool enableBlur = false,
  bool edgeToEdge = false,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: barrierLabel ?? 'sheet',
    barrierColor: Colors.black26,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return AppSheet(
        position: position,
        maxHeightFactor: maxHeightFactor,
        backgroundColor: backgroundColor,
        enableBlur: enableBlur,
        edgeToEdge: edgeToEdge,
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
    this.backgroundColor = Colors.white,
    this.enableBlur = false,
    this.edgeToEdge = false,
  });

  final Widget child;
  final AppSheetPosition position;
  final double? maxHeightFactor;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final bool enableBlur;
  final bool edgeToEdge;

  @override
  Widget build(BuildContext context) {
    final borderRadius = switch (position) {
      AppSheetPosition.top => const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      AppSheetPosition.bottom => const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
    };
    final alignment = switch (position) {
      AppSheetPosition.top => Alignment.topCenter,
      AppSheetPosition.bottom => Alignment.bottomCenter,
    };
    final safeBottom = MediaQuery.of(context).padding.bottom;

    final content = Material(
      color: backgroundColor,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * (maxHeightFactor ?? 0.9),
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
              AppSheetHandle(
                color: backgroundColor.computeLuminance() < 0.35
                    ? const Color(0x66FFFFFF)
                    : const Color(0xFFD1D1D6),
              ),
              const SizedBox(height: 12),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );

    return SafeArea(
      top: position == AppSheetPosition.top,
      bottom: position == AppSheetPosition.bottom,
      child: Align(
        alignment: alignment,
        child: Container(
          width: double.infinity,
          margin: edgeToEdge
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: enableBlur ? 18 : 0,
                sigmaY: enableBlur ? 18 : 0,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({
    super.key,
    this.color = const Color(0xFFD1D1D6),
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
