import 'package:flutter/material.dart';

class OolafPlayingNoteIcon extends StatefulWidget {
  const OolafPlayingNoteIcon({
    super.key,
    required this.color,
    this.size = 22,
  });

  final Color color;
  final double size;

  @override
  State<OolafPlayingNoteIcon> createState() => _OolafPlayingNoteIconState();
}

class _OolafPlayingNoteIconState extends State<OolafPlayingNoteIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final a = (0.6 + 0.4 * t).clamp(0.0, 1.0);
          return Opacity(
            opacity: a,
            child: Transform.translate(
              offset: Offset(0, -1.5 * t),
              child: Icon(
                Icons.music_note,
                size: widget.size,
                color: widget.color,
              ),
            ),
          );
        },
      ),
    );
  }
}
