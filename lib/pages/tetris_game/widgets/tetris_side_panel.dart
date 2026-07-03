import 'package:flutter/cupertino.dart';

class TetrisSidePanel extends StatelessWidget {
  const TetrisSidePanel({
    super.key,
    required this.score,
    required this.lines,
    required this.level,
    required this.statusText,
    required this.nextPreview,
    required this.isPaused,
    required this.isGameOver,
    required this.onStartOrRestart,
    required this.onTogglePause,
    this.isCompact = false,
  });

  final int score;
  final int lines;
  final int level;
  final String statusText;
  final List<List<Color?>> nextPreview;
  final bool isPaused;
  final bool isGameOver;
  final VoidCallback onStartOrRestart;
  final VoidCallback onTogglePause;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return isCompact
        ? _CompactSidePanel(
            score: score,
            lines: lines,
            level: level,
            statusText: statusText,
            nextPreview: nextPreview,
            isPaused: isPaused,
            isGameOver: isGameOver,
            onStartOrRestart: onStartOrRestart,
            onTogglePause: onTogglePause,
          )
        : _RegularSidePanel(
            score: score,
            lines: lines,
            level: level,
            statusText: statusText,
            nextPreview: nextPreview,
            isPaused: isPaused,
            isGameOver: isGameOver,
            onStartOrRestart: onStartOrRestart,
            onTogglePause: onTogglePause,
          );
  }
}

class _RegularSidePanel extends StatelessWidget {
  const _RegularSidePanel({
    required this.score,
    required this.lines,
    required this.level,
    required this.statusText,
    required this.nextPreview,
    required this.isPaused,
    required this.isGameOver,
    required this.onStartOrRestart,
    required this.onTogglePause,
  });

  final int score;
  final int lines;
  final int level;
  final String statusText;
  final List<List<Color?>> nextPreview;
  final bool isPaused;
  final bool isGameOver;
  final VoidCallback onStartOrRestart;
  final VoidCallback onTogglePause;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '俄罗斯方块',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10263D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                statusText,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Color(0xFF627488),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: isGameOver || score > 0 || lines > 0 ? '重开' : '开始',
                      isPrimary: true,
                      onPressed: onStartOrRestart,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: isPaused ? '继续' : '暂停',
                      onPressed: onTogglePause,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '数据',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10263D),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatChip(label: '得分', value: '$score'),
                  _StatChip(label: '消行', value: '$lines'),
                  _StatChip(label: '等级', value: '$level'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _GlassPanel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '下一个',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10263D),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PreviewCard(
                    preview: nextPreview,
                    size: 108,
                  ),
                ],
              ),
              const SizedBox(width: 14),
              const Expanded(child: _KeyboardHint()),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactSidePanel extends StatelessWidget {
  const _CompactSidePanel({
    required this.score,
    required this.lines,
    required this.level,
    required this.statusText,
    required this.nextPreview,
    required this.isPaused,
    required this.isGameOver,
    required this.onStartOrRestart,
    required this.onTogglePause,
  });

  final int score;
  final int lines;
  final int level;
  final String statusText;
  final List<List<Color?>> nextPreview;
  final bool isPaused;
  final bool isGameOver;
  final VoidCallback onStartOrRestart;
  final VoidCallback onTogglePause;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 124,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '俄罗斯方块',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10263D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '分 $score   行 $lines   级 $level',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF17324A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: isGameOver || score > 0 || lines > 0
                              ? '重开'
                              : '开始',
                          isPrimary: true,
                          compact: true,
                          onPressed: onStartOrRestart,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          label: isPaused ? '继续' : '暂停',
                          compact: true,
                          onPressed: onTogglePause,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF627488),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '下一个',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10263D),
                ),
              ),
              const SizedBox(height: 8),
              _PreviewCard(
                preview: nextPreview,
                size: 68,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyboardHint extends StatelessWidget {
  const _KeyboardHint();

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 14,
      color: Color(0xFF627488),
    );

    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '键盘',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF10263D),
          ),
        ),
        SizedBox(height: 12),
        Text('↑ 旋转  ·  ↓ 加速下落', style: textStyle),
        SizedBox(height: 6),
        Text('← → 横向移动  ·  Space 直落', style: textStyle),
        SizedBox(height: 6),
        Text('P 暂停/继续  ·  R 重开', style: textStyle),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.preview,
    required this.size,
  });

  final List<List<Color?>> preview;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF11283F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF2B4761),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: CustomPaint(
            painter: _TetrisPreviewPainter(preview: preview),
          ),
        ),
      ),
    );
  }
}

class _TetrisPreviewPainter extends CustomPainter {
  const _TetrisPreviewPainter({
    required this.preview,
  });

  final List<List<Color?>> preview;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = preview.length;
    final columns = rows == 0 ? 0 : preview.first.length;
    if (rows == 0 || columns == 0) {
      return;
    }

    final cellSize = size.shortestSide / 4;
    final totalWidth = cellSize * columns;
    final totalHeight = cellSize * rows;
    final startX = (size.width - totalWidth) / 2;
    final startY = (size.height - totalHeight) / 2;
    final gap = cellSize * 0.10;
    final radius = Radius.circular(cellSize * 0.16);

    final emptyFillPaint = Paint()..color = const Color(0xFF17324A);
    final emptyStrokePaint = Paint()
      ..color = const Color(0xFF29445C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var rowIndex = 0; rowIndex < rows; rowIndex += 1) {
      for (var columnIndex = 0; columnIndex < columns; columnIndex += 1) {
        final left = startX + (columnIndex * cellSize) + gap;
        final top = startY + (rowIndex * cellSize) + gap;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left,
            top,
            cellSize - (gap * 2),
            cellSize - (gap * 2),
          ),
          radius,
        );

        final color = preview[rowIndex][columnIndex];
        if (color == null) {
          canvas.drawRRect(rect, emptyFillPaint);
          canvas.drawRRect(rect, emptyStrokePaint);
          continue;
        }

        canvas.drawShadow(
          Path()..addRRect(rect),
          color.withValues(alpha: 0.34),
          3,
          false,
        );
        canvas.drawRRect(rect, Paint()..color = color);
        canvas.drawRRect(
          rect,
          Paint()
            ..color = CupertinoColors.white.withValues(alpha: 0.42)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TetrisPreviewPainter oldDelegate) {
    return oldDelegate.preview != preview;
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xECFFFFFF),
            Color(0xD5F3F6FB),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xA8FFFFFF),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1633587E),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 94,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFDCE7F2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF718399),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF14314A),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.compact = false,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool compact;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 8 : 12,
      ),
      borderRadius: BorderRadius.circular(18),
      color: isPrimary ? const Color(0xFF2E7EF7) : const Color(0xFFE8EEF6),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 13 : 15,
          fontWeight: FontWeight.w600,
          color: isPrimary ? CupertinoColors.white : const Color(0xFF17324A),
        ),
      ),
    );
  }
}
