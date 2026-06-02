import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material;
import 'package:oolaf_flutted/components/app_popover/app_popover_types.dart';

class AppPopoverController {
  _AppPopoverState? _state;

  void _bind(_AppPopoverState state) {
    _state = state;
  }

  void _unbind(_AppPopoverState state) {
    if (_state == state) {
      _state = null;
    }
  }

  void show() => _state?._show();
  void hide() => _state?._hide();
  void toggle() => _state?._toggle();
}

class AppPopover extends StatefulWidget {
  const AppPopover({
    super.key,
    required this.actions,
    required this.child,
    this.show = false,
    this.controller,
    this.onSelect,
    this.onVisibilityChanged,
    this.placement = AppPopoverPlacement.bottom,
    this.offset = 10,
  });

  final List<AppPopoverAction> actions;
  final Widget child;
  final bool show;
  final AppPopoverController? controller;
  final ValueChanged<int>? onSelect;
  final ValueChanged<bool>? onVisibilityChanged;
  final AppPopoverPlacement placement;
  final double offset;

  @override
  State<AppPopover> createState() => _AppPopoverState();
}

class _AppPopoverState extends State<AppPopover> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _entry;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._bind(this);
    if (widget.show) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    }
  }

  @override
  void didUpdateWidget(covariant AppPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._unbind(this);
      widget.controller?._bind(this);
    }
    if (oldWidget.show != widget.show) {
      widget.show ? _show() : _hide();
    }
  }

  @override
  void dispose() {
    widget.controller?._unbind(this);
    _hide();
    super.dispose();
  }

  void _toggle() {
    _visible ? _hide() : _show();
  }

  void _show() {
    if (_visible || !mounted) {
      return;
    }
    _entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hide,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: widget.placement == AppPopoverPlacement.bottom
                ? Offset(0, widget.offset)
                : Offset(0, -widget.offset),
            targetAnchor: widget.placement == AppPopoverPlacement.bottom
                ? Alignment.bottomLeft
                : Alignment.topLeft,
            followerAnchor: widget.placement == AppPopoverPlacement.bottom
                ? Alignment.topLeft
                : Alignment.bottomLeft,
            child: _PopoverMenu(
              actions: widget.actions,
              placement: widget.placement,
              onSelect: (index) {
                widget.onSelect?.call(index);
                _hide();
              },
            ),
          ),
        ],
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
    _visible = true;
    widget.onVisibilityChanged?.call(true);
  }

  void _hide() {
    if (!_visible) {
      return;
    }
    _entry?.remove();
    _entry = null;
    _visible = false;
    widget.onVisibilityChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: widget.child,
      ),
    );
  }
}

class _PopoverMenu extends StatelessWidget {
  const _PopoverMenu({
    required this.actions,
    required this.placement,
    required this.onSelect,
  });

  final List<AppPopoverAction> actions;
  final AppPopoverPlacement placement;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x00000000),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PopoverArrow(placement: placement),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(actions.length, (index) {
                  final action = actions[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: action.disabled ? null : () => onSelect(index),
                    child: Opacity(
                      opacity: action.disabled ? 0.4 : 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (action.icon != null) ...[
                              Text(
                                action.icon!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              action.text,
                              style: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopoverArrow extends StatelessWidget {
  const _PopoverArrow({
    required this.placement,
  });

  final AppPopoverPlacement placement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18),
      child: CustomPaint(
        size: const Size(18, 8),
        painter: _PopoverArrowPainter(
          upsideDown: placement == AppPopoverPlacement.top,
        ),
      ),
    );
  }
}

class _PopoverArrowPainter extends CustomPainter {
  const _PopoverArrowPainter({
    required this.upsideDown,
  });

  final bool upsideDown;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF111827);
    final path = Path();
    if (upsideDown) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0);
    } else {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PopoverArrowPainter oldDelegate) {
    return upsideDown != oldDelegate.upsideDown;
  }
}
