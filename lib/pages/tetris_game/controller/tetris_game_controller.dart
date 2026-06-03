import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

const int tetrisBoardColumns = 10;
const int tetrisBoardRows = 20;

enum TetrisPieceType { i, o, t, s, z, j, l }

class TetrisCellVisual {
  const TetrisCellVisual({
    required this.fillColor,
    required this.isGhost,
  });

  final Color fillColor;
  final bool isGhost;
}

class TetrisGameSnapshot {
  const TetrisGameSnapshot({
    required this.board,
    required this.nextPreview,
    required this.score,
    required this.lines,
    required this.level,
    required this.isRunning,
    required this.isPaused,
    required this.isGameOver,
    required this.statusText,
  });

  final List<List<TetrisCellVisual?>> board;
  final List<List<Color?>> nextPreview;
  final int score;
  final int lines;
  final int level;
  final bool isRunning;
  final bool isPaused;
  final bool isGameOver;
  final String statusText;
}

class TetrisGameController extends ChangeNotifier {
  TetrisGameController({Random? random}) : _random = random ?? Random() {
    _snapshot = _buildSnapshot(
      board: _createEmptyBoard(),
      nextType: _randomPieceType(),
      score: 0,
      lines: 0,
      level: 1,
      statusText: '按开始进入游戏',
      isRunning: false,
      isPaused: false,
      isGameOver: false,
    );
  }

  final Random _random;

  late TetrisGameSnapshot _snapshot;
  Timer? _gravityTimer;
  List<List<Color?>> _lockedBoard = _createEmptyBoard();
  _FallingPiece? _activePiece;
  late TetrisPieceType _nextPieceType;
  int _score = 0;
  int _lines = 0;
  int _level = 1;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isGameOver = false;

  TetrisGameSnapshot get snapshot => _snapshot;

  void startNewGame() {
    _gravityTimer?.cancel();
    _lockedBoard = _createEmptyBoard();
    _score = 0;
    _lines = 0;
    _level = 1;
    _isRunning = true;
    _isPaused = false;
    _isGameOver = false;
    _nextPieceType = _randomPieceType();
    _spawnNextPiece();
    _restartGravityTimer();
    _publishSnapshot();
  }

  void pause() {
    if (!_isRunning || _isPaused || _isGameOver) {
      return;
    }
    _isPaused = true;
    _gravityTimer?.cancel();
    _publishSnapshot();
  }

  void resume() {
    if (!_isRunning || !_isPaused || _isGameOver) {
      return;
    }
    _isPaused = false;
    _restartGravityTimer();
    _publishSnapshot();
  }

  void togglePause() {
    if (_isPaused) {
      resume();
    } else {
      pause();
    }
  }

  KeyEventResult handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      moveLeft();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      moveRight();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      softDrop();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      rotate();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.space) {
      hardDrop();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyP) {
      if (_isRunning && !_isGameOver) {
        togglePause();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      startNewGame();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void moveLeft() {
    _moveHorizontally(-1);
  }

  void moveRight() {
    _moveHorizontally(1);
  }

  void softDrop() {
    if (!_canAcceptInput()) {
      return;
    }
    if (_tryMove(rowDelta: 1, columnDelta: 0)) {
      _score += 1;
      _publishSnapshot();
      return;
    }
    _lockActivePiece();
  }

  void hardDrop() {
    if (!_canAcceptInput()) {
      return;
    }
    var dropDistance = 0;
    while (_tryMove(rowDelta: 1, columnDelta: 0)) {
      dropDistance += 1;
    }
    _score += dropDistance * 2;
    _lockActivePiece();
  }

  void rotate() {
    if (!_canAcceptInput() || _activePiece == null) {
      return;
    }

    final currentPiece = _activePiece!;
    final rotated = currentPiece.rotateClockwise();
    const wallKickOffsets = <int>[0, -1, 1, -2, 2];
    for (final columnOffset in wallKickOffsets) {
      final candidate = rotated.copyWith(
        column: rotated.column + columnOffset,
      );
      if (_canPlacePiece(candidate)) {
        _activePiece = candidate;
        _publishSnapshot();
        return;
      }
    }
  }

  @override
  void dispose() {
    _gravityTimer?.cancel();
    super.dispose();
  }

  void _moveHorizontally(int delta) {
    if (!_canAcceptInput()) {
      return;
    }
    if (_tryMove(rowDelta: 0, columnDelta: delta)) {
      _publishSnapshot();
    }
  }

  bool _canAcceptInput() {
    return _isRunning && !_isPaused && !_isGameOver && _activePiece != null;
  }

  void _restartGravityTimer() {
    _gravityTimer?.cancel();
    _gravityTimer = Timer.periodic(_gravityDuration, (_) => _tick());
  }

  Duration get _gravityDuration {
    final milliseconds = max(120, 720 - ((_level - 1) * 55));
    return Duration(milliseconds: milliseconds);
  }

  void _tick() {
    if (!_canAcceptInput()) {
      return;
    }
    if (_tryMove(rowDelta: 1, columnDelta: 0)) {
      _publishSnapshot();
      return;
    }
    _lockActivePiece();
  }

  bool _tryMove({
    required int rowDelta,
    required int columnDelta,
  }) {
    final current = _activePiece;
    if (current == null) {
      return false;
    }
    final candidate = current.copyWith(
      row: current.row + rowDelta,
      column: current.column + columnDelta,
    );
    if (!_canPlacePiece(candidate)) {
      return false;
    }
    _activePiece = candidate;
    return true;
  }

  void _lockActivePiece() {
    final current = _activePiece;
    if (current == null) {
      return;
    }

    for (final cell in current.cells) {
      if (cell.row < 0) {
        _finishGame();
        return;
      }
      _lockedBoard[cell.row][cell.column] = current.color;
    }

    final clearedLines = _clearFullRows();
    if (clearedLines > 0) {
      _lines += clearedLines;
      _score += _scoreForClearedLines(clearedLines) * _level;
      _level = (_lines ~/ 10) + 1;
      _restartGravityTimer();
    }

    _spawnNextPiece();
    _publishSnapshot();
  }

  void _spawnNextPiece() {
    final pieceType = _nextPieceType;
    _nextPieceType = _randomPieceType();
    final piece = _FallingPiece.spawn(pieceType);
    if (!_canPlacePiece(piece)) {
      _activePiece = null;
      _finishGame();
      return;
    }
    _activePiece = piece;
  }

  void _finishGame() {
    _gravityTimer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _isGameOver = true;
    _publishSnapshot();
  }

  int _clearFullRows() {
    final remainingRows = _lockedBoard
        .where((row) => row.any((cell) => cell == null))
        .map((row) => List<Color?>.from(row))
        .toList(growable: true);

    final cleared = tetrisBoardRows - remainingRows.length;
    if (cleared <= 0) {
      return 0;
    }

    for (var index = 0; index < cleared; index += 1) {
      remainingRows.insert(0, List<Color?>.filled(tetrisBoardColumns, null));
    }
    _lockedBoard = remainingRows;
    return cleared;
  }

  bool _canPlacePiece(_FallingPiece piece) {
    for (final cell in piece.cells) {
      if (cell.column < 0 || cell.column >= tetrisBoardColumns) {
        return false;
      }
      if (cell.row >= tetrisBoardRows) {
        return false;
      }
      if (cell.row >= 0 && _lockedBoard[cell.row][cell.column] != null) {
        return false;
      }
    }
    return true;
  }

  void _publishSnapshot() {
    _snapshot = _buildSnapshot(
      board: _lockedBoard,
      activePiece: _activePiece,
      nextType: _nextPieceType,
      score: _score,
      lines: _lines,
      level: _level,
      isRunning: _isRunning,
      isPaused: _isPaused,
      isGameOver: _isGameOver,
      statusText: _statusText,
    );
    notifyListeners();
  }

  String get _statusText {
    if (_isGameOver) {
      return '游戏结束，按 R 重新开始';
    }
    if (_isPaused) {
      return '游戏已暂停，按 P 继续';
    }
    if (!_isRunning) {
      return '按开始进入游戏';
    }
    return '方向键控制移动，空格直落';
  }

  TetrisGameSnapshot _buildSnapshot({
    required List<List<Color?>> board,
    _FallingPiece? activePiece,
    required TetrisPieceType nextType,
    required int score,
    required int lines,
    required int level,
    required bool isRunning,
    required bool isPaused,
    required bool isGameOver,
    required String statusText,
  }) {
    final visibleBoard = board
        .map((row) => row.map((cell) {
              if (cell == null) {
                return null;
              }
              return TetrisCellVisual(
                fillColor: cell,
                isGhost: false,
              );
            }).toList(growable: false))
        .toList(growable: false);

    if (activePiece != null) {
      final ghostPiece = _buildGhostPiece(activePiece);
      for (final cell in ghostPiece.cells) {
        if (cell.row >= 0 &&
            cell.row < tetrisBoardRows &&
            cell.column >= 0 &&
            cell.column < tetrisBoardColumns &&
            visibleBoard[cell.row][cell.column] == null) {
          visibleBoard[cell.row][cell.column] = TetrisCellVisual(
            fillColor: ghostPiece.color.withValues(alpha: 0.22),
            isGhost: true,
          );
        }
      }

      for (final cell in activePiece.cells) {
        if (cell.row >= 0 &&
            cell.row < tetrisBoardRows &&
            cell.column >= 0 &&
            cell.column < tetrisBoardColumns) {
          visibleBoard[cell.row][cell.column] = TetrisCellVisual(
            fillColor: activePiece.color,
            isGhost: false,
          );
        }
      }
    }

    return TetrisGameSnapshot(
      board: visibleBoard,
      nextPreview: _buildPreview(nextType),
      score: score,
      lines: lines,
      level: level,
      isRunning: isRunning,
      isPaused: isPaused,
      isGameOver: isGameOver,
      statusText: statusText,
    );
  }

  _FallingPiece _buildGhostPiece(_FallingPiece source) {
    var ghost = source;
    while (true) {
      final candidate = ghost.copyWith(row: ghost.row + 1);
      if (!_canPlacePiece(candidate)) {
        return ghost;
      }
      ghost = candidate;
    }
  }

  List<List<Color?>> _buildPreview(TetrisPieceType pieceType) {
    final preview = List<List<Color?>>.generate(
      4,
      (_) => List<Color?>.filled(4, null),
      growable: false,
    );
    final piece = _FallingPiece.spawn(pieceType).copyWith(row: 0, column: 0);
    final cells = piece.cells;
    final minRow = cells.map((cell) => cell.row).reduce(min);
    final minColumn = cells.map((cell) => cell.column).reduce(min);
    for (final cell in cells) {
      final previewRow = cell.row - minRow;
      final previewColumn = cell.column - minColumn;
      if (previewRow >= 0 &&
          previewRow < preview.length &&
          previewColumn >= 0 &&
          previewColumn < preview[previewRow].length) {
        preview[previewRow][previewColumn] = piece.color;
      }
    }
    return preview;
  }

  int _scoreForClearedLines(int lines) {
    switch (lines) {
      case 1:
        return 100;
      case 2:
        return 300;
      case 3:
        return 500;
      case 4:
        return 800;
      default:
        return 0;
    }
  }

  TetrisPieceType _randomPieceType() {
    const values = TetrisPieceType.values;
    return values[_random.nextInt(values.length)];
  }

  static List<List<Color?>> _createEmptyBoard() {
    return List<List<Color?>>.generate(
      tetrisBoardRows,
      (_) => List<Color?>.filled(tetrisBoardColumns, null),
      growable: false,
    );
  }
}

class _GridOffset {
  const _GridOffset(this.row, this.column);

  final int row;
  final int column;
}

class _BoardCell {
  const _BoardCell({
    required this.row,
    required this.column,
  });

  final int row;
  final int column;
}

class _FallingPiece {
  const _FallingPiece({
    required this.type,
    required this.rotation,
    required this.row,
    required this.column,
  });

  final TetrisPieceType type;
  final int rotation;
  final int row;
  final int column;

  Color get color => _pieceColorMap[type]!;

  List<_BoardCell> get cells {
    final shape = _pieceRotations[type]![rotation];
    return shape
        .map(
          (offset) => _BoardCell(
            row: row + offset.row,
            column: column + offset.column,
          ),
        )
        .toList(growable: false);
  }

  _FallingPiece copyWith({
    int? rotation,
    int? row,
    int? column,
  }) {
    return _FallingPiece(
      type: type,
      rotation: rotation ?? this.rotation,
      row: row ?? this.row,
      column: column ?? this.column,
    );
  }

  _FallingPiece rotateClockwise() {
    final rotations = _pieceRotations[type]!;
    return copyWith(rotation: (rotation + 1) % rotations.length);
  }

  factory _FallingPiece.spawn(TetrisPieceType type) {
    return _FallingPiece(
      type: type,
      rotation: 0,
      row: 0,
      column: 3,
    );
  }
}

const Map<TetrisPieceType, Color> _pieceColorMap = {
  TetrisPieceType.i: Color(0xFF5FD6FF),
  TetrisPieceType.o: Color(0xFFFFD76A),
  TetrisPieceType.t: Color(0xFFB58CFF),
  TetrisPieceType.s: Color(0xFF69D98E),
  TetrisPieceType.z: Color(0xFFFF7F8A),
  TetrisPieceType.j: Color(0xFF6E95FF),
  TetrisPieceType.l: Color(0xFFFFAA63),
};

const Map<TetrisPieceType, List<List<_GridOffset>>> _pieceRotations = {
  TetrisPieceType.i: [
    [
      _GridOffset(1, 0),
      _GridOffset(1, 1),
      _GridOffset(1, 2),
      _GridOffset(1, 3),
    ],
    [
      _GridOffset(0, 2),
      _GridOffset(1, 2),
      _GridOffset(2, 2),
      _GridOffset(3, 2),
    ],
  ],
  TetrisPieceType.o: [
    [
      _GridOffset(0, 1),
      _GridOffset(0, 2),
      _GridOffset(1, 1),
      _GridOffset(1, 2),
    ],
  ],
  TetrisPieceType.t: [
    [
      _GridOffset(0, 1),
      _GridOffset(1, 0),
      _GridOffset(1, 1),
      _GridOffset(1, 2),
    ],
    [
      _GridOffset(0, 1),
      _GridOffset(1, 1),
      _GridOffset(1, 2),
      _GridOffset(2, 1),
    ],
    [
      _GridOffset(1, 0),
      _GridOffset(1, 1),
      _GridOffset(1, 2),
      _GridOffset(2, 1),
    ],
    [
      _GridOffset(0, 1),
      _GridOffset(1, 0),
      _GridOffset(1, 1),
      _GridOffset(2, 1),
    ],
  ],
  TetrisPieceType.s: [
    [
      _GridOffset(0, 1),
      _GridOffset(0, 2),
      _GridOffset(1, 0),
      _GridOffset(1, 1),
    ],
    [
      _GridOffset(0, 1),
      _GridOffset(1, 1),
      _GridOffset(1, 2),
      _GridOffset(2, 2),
    ],
  ],
  TetrisPieceType.z: [
    [
      _GridOffset(0, 0),
      _GridOffset(0, 1),
      _GridOffset(1, 1),
      _GridOffset(1, 2),
    ],
    [
      _GridOffset(0, 2),
      _GridOffset(1, 1),
      _GridOffset(1, 2),
      _GridOffset(2, 1),
    ],
  ],
  TetrisPieceType.j: [
    [
      _GridOffset(0, 0),
      _GridOffset(1, 0),
      _GridOffset(1, 1),
      _GridOffset(1, 2),
    ],
    [
      _GridOffset(0, 1),
      _GridOffset(0, 2),
      _GridOffset(1, 1),
      _GridOffset(2, 1),
    ],
    [
      _GridOffset(1, 0),
      _GridOffset(1, 1),
      _GridOffset(1, 2),
      _GridOffset(2, 2),
    ],
    [
      _GridOffset(0, 1),
      _GridOffset(1, 1),
      _GridOffset(2, 0),
      _GridOffset(2, 1),
    ],
  ],
  TetrisPieceType.l: [
    [
      _GridOffset(0, 2),
      _GridOffset(1, 0),
      _GridOffset(1, 1),
      _GridOffset(1, 2),
    ],
    [
      _GridOffset(0, 1),
      _GridOffset(1, 1),
      _GridOffset(2, 1),
      _GridOffset(2, 2),
    ],
    [
      _GridOffset(1, 0),
      _GridOffset(1, 1),
      _GridOffset(1, 2),
      _GridOffset(2, 0),
    ],
    [
      _GridOffset(0, 0),
      _GridOffset(0, 1),
      _GridOffset(1, 1),
      _GridOffset(2, 1),
    ],
  ],
};
