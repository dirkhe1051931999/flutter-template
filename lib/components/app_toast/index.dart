import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_toast/widgets/app_toast_card.dart';
import 'package:oolaf_flutted/router/config.dart';

enum AppToastType { text, success, fail, loading }

enum AppToastPosition { top, middle, bottom }

class AppToast {
  AppToast._();

  static OverlayEntry? _maskEntry;
  static OverlayEntry? _toastEntry;
  static Timer? _dismissTimer;

  static void show({
    required String message,
    AppToastType type = AppToastType.text,
    Duration duration = const Duration(milliseconds: 2000),
    AppToastPosition position = AppToastPosition.middle,
    bool forbidClick = false,
  }) {
    _showInternal(
      message: message,
      type: type,
      duration: duration,
      position: position,
      forbidClick: forbidClick,
      persistent: false,
    );
  }

  static void showText(
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
    AppToastPosition position = AppToastPosition.middle,
    bool forbidClick = false,
  }) {
    show(
      message: message,
      duration: duration,
      position: position,
      forbidClick: forbidClick,
    );
  }

  static void showSuccess(
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
    AppToastPosition position = AppToastPosition.middle,
    bool forbidClick = false,
  }) {
    show(
      message: message,
      type: AppToastType.success,
      duration: duration,
      position: position,
      forbidClick: forbidClick,
    );
  }

  static void showFail(
    String message, {
    Duration duration = const Duration(milliseconds: 2200),
    AppToastPosition position = AppToastPosition.middle,
    bool forbidClick = false,
  }) {
    show(
      message: message,
      type: AppToastType.fail,
      duration: duration,
      position: position,
      forbidClick: forbidClick,
    );
  }

  static void showLoading(
    String message, {
    AppToastPosition position = AppToastPosition.middle,
    bool forbidClick = true,
  }) {
    _showInternal(
      message: message,
      type: AppToastType.loading,
      duration: const Duration(milliseconds: 0),
      position: position,
      forbidClick: forbidClick,
      persistent: true,
    );
  }

  static void clear() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _toastEntry?.remove();
    _maskEntry?.remove();
    _toastEntry = null;
    _maskEntry = null;
  }

  static void _showInternal({
    required String message,
    required AppToastType type,
    required Duration duration,
    required AppToastPosition position,
    required bool forbidClick,
    required bool persistent,
  }) {
    final overlay = Application.navigatorKey.currentState?.overlay;
    if (overlay == null) {
      return;
    }

    clear();

    if (forbidClick) {
      _maskEntry = OverlayEntry(
        builder: (context) {
          return const Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x00111827),
                ),
              ),
            ),
          );
        },
      );
      overlay.insert(_maskEntry!);
    }

    _toastEntry = OverlayEntry(
      builder: (context) {
        final topPadding = MediaQuery.of(context).padding.top;
        return Positioned.fill(
          child: IgnorePointer(
            child: SafeArea(
              child: Stack(
                children: [
                  Align(
                    alignment: _alignmentFor(position),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: position == AppToastPosition.top
                            ? topPadding + 18
                            : 0,
                        bottom: position == AppToastPosition.bottom ? 88 : 0,
                        left: 24,
                        right: 24,
                      ),
                      child: AppToastCard(
                        message: message,
                        icon: _iconFor(type),
                        showLoading: type == AppToastType.loading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_toastEntry!);

    if (!persistent) {
      _dismissTimer = Timer(duration, clear);
    }
  }

  static Alignment _alignmentFor(AppToastPosition position) {
    return switch (position) {
      AppToastPosition.top => Alignment.topCenter,
      AppToastPosition.middle => Alignment.center,
      AppToastPosition.bottom => Alignment.bottomCenter,
    };
  }

  static IconData? _iconFor(AppToastType type) {
    return switch (type) {
      AppToastType.success => CupertinoIcons.check_mark_circled_solid,
      AppToastType.fail => CupertinoIcons.xmark_circle_fill,
      _ => null,
    };
  }
}
