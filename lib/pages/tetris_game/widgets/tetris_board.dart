import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/pages/tetris_game/controller/tetris_game_controller.dart';

class TetrisBoard extends StatelessWidget {
  const TetrisBoard({
    super.key,
    required this.board,
  });

  final List<List<TetrisCellVisual?>> board;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: tetrisBoardColumns / tetrisBoardRows,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xF2FFFFFF),
              Color(0xC9EFF4FB),
            ],
          ),
          border: Border.all(
            color: const Color(0x99FFFFFF),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1E2A4F77),
              blurRadius: 30,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF102338),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF2B4761),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomPaint(
              painter: _TetrisBoardPainter(board: board),
            ),
          ),
        ),
      ),
    );
  }
}

class _TetrisBoardPainter extends CustomPainter {
  const _TetrisBoardPainter({
    required this.board,
  });

  final List<List<TetrisCellVisual?>> board;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / tetrisBoardColumns;
    final cellHeight = size.height / tetrisBoardRows;
    final gap = math.min(cellWidth, cellHeight) * 0.12;
    final radius = Radius.circular(math.min(cellWidth, cellHeight) * 0.18);

    final emptyFillPaint = Paint()..color = const Color(0xFF17324A);
    final emptyStrokePaint = Paint()
      ..color = const Color(0xFF29445C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var rowIndex = 0; rowIndex < tetrisBoardRows; rowIndex += 1) {
      for (var columnIndex = 0;
          columnIndex < tetrisBoardColumns;
          columnIndex += 1) {
        final left = columnIndex * cellWidth + gap;
        final top = rowIndex * cellHeight + gap;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left,
            top,
            cellWidth - (gap * 2),
            cellHeight - (gap * 2),
          ),
          radius,
        );

        final cell = board[rowIndex][columnIndex];
        if (cell == null) {
          canvas.drawRRect(rect, emptyFillPaint);
          canvas.drawRRect(rect, emptyStrokePaint);
          continue;
        }

        final fillPaint = Paint()..color = cell.fillColor;
        final strokePaint = Paint()
          ..color = CupertinoColors.white.withValues(
            alpha: cell.isGhost ? 0.22 : 0.42,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = cell.isGhost ? 0.9 : 1.1;

        canvas.drawShadow(
          Path()..addRRect(rect),
          cell.fillColor.withValues(alpha: cell.isGhost ? 0.18 : 0.34),
          cell.isGhost ? 2 : 4,
          false,
        );
        canvas.drawRRect(rect, fillPaint);
        canvas.drawRRect(rect, strokePaint);

        if (!cell.isGhost) {
          final highlightRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              left + (cellWidth * 0.08),
              top + (cellHeight * 0.08),
              cellWidth * 0.36,
              cellHeight * 0.22,
            ),
            Radius.circular(radius.x * 0.8),
          );
          canvas.drawRRect(
            highlightRect,
            Paint()..color = CupertinoColors.white.withValues(alpha: 0.20),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TetrisBoardPainter oldDelegate) {
    return oldDelegate.board != board;
  }
}
