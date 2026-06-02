import 'package:flutter/cupertino.dart';

class AppSwipeCellAction {
  const AppSwipeCellAction({
    required this.text,
    required this.onTap,
    this.color = const Color(0xFFE5484D),
    this.width = 76,
  });

  final String text;
  final VoidCallback onTap;
  final Color color;
  final double width;
}

class AppSwipeCell extends StatefulWidget {
  const AppSwipeCell({
    super.key,
    required this.child,
    this.leftActions = const <AppSwipeCellAction>[],
    this.rightActions = const <AppSwipeCellAction>[],
  });

  final Widget child;
  final List<AppSwipeCellAction> leftActions;
  final List<AppSwipeCellAction> rightActions;

  @override
  State<AppSwipeCell> createState() => _AppSwipeCellState();
}

class _AppSwipeCellState extends State<AppSwipeCell> {
  double _offsetX = 0;

  double get _leftWidth => widget.leftActions.fold(0, (sum, action) => sum + action.width);
  double get _rightWidth => widget.rightActions.fold(0, (sum, action) => sum + action.width);

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offsetX = (_offsetX + details.delta.dx).clamp(-_rightWidth, _leftWidth);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldOpenLeft = _offsetX > _leftWidth * 0.35 || velocity > 240;
    final shouldOpenRight = _offsetX < -_rightWidth * 0.35 || velocity < -240;

    setState(() {
      if (shouldOpenLeft && _leftWidth > 0) {
        _offsetX = _leftWidth;
      } else if (shouldOpenRight && _rightWidth > 0) {
        _offsetX = -_rightWidth;
      } else {
        _offsetX = 0;
      }
    });
  }

  void _close() {
    setState(() {
      _offsetX = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFEFF3F8)),
        child: Stack(
          children: [
            if (widget.leftActions.isNotEmpty)
              Positioned.fill(
                child: Row(
                  children: widget.leftActions
                      .map(
                        (action) => _SwipeActionButton(
                          action: action,
                          onTap: () {
                            action.onTap();
                            _close();
                          },
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            if (widget.rightActions.isNotEmpty)
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: widget.rightActions
                      .map(
                        (action) => _SwipeActionButton(
                          action: action,
                          onTap: () {
                            action.onTap();
                            _close();
                          },
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              onTap: _offsetX == 0 ? null : _close,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(_offsetX, 0, 0),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    required this.action,
    required this.onTap,
  });

  final AppSwipeCellAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: action.width,
        color: action.color,
        alignment: Alignment.center,
        child: Text(
          action.text,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
