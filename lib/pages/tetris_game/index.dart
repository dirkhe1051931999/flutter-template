import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/pages/tetris_game/controller/tetris_game_controller.dart';
import 'package:oolaf_flutted/pages/tetris_game/widgets/tetris_board.dart';
import 'package:oolaf_flutted/pages/tetris_game/widgets/tetris_side_panel.dart';
import 'package:oolaf_flutted/router/config.dart';
import 'package:oolaf_flutted/router/routes.dart';

class TetrisGamePage extends StatefulWidget {
  const TetrisGamePage({super.key});

  @override
  State<TetrisGamePage> createState() => _TetrisGamePageState();
}

class _TetrisGamePageState extends State<TetrisGamePage> {
  late final TetrisGameController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TetrisGameController()..startNewGame();
    _focusNode = FocusNode(debugLabel: 'tetris-game-focus');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (_, event) => _controller.handleKeyEvent(event),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _focusNode.requestFocus,
        child: Container(
          color: const Color(0x00000000),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final snapshot = _controller.snapshot;
              return DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF4F7FB),
                      Color(0xFFEAF0F8),
                    ],
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const horizontalPadding = 16.0;
                    const topPadding = 12.0;
                    const bottomPadding = 16.0;
                    const panelGap = 18.0;
                    const entryHeight = 44.0;
                    const entryGap = 12.0;
                    const boardAspectRatio =
                        tetrisBoardColumns / tetrisBoardRows;

                    final contentWidth =
                        constraints.maxWidth - (horizontalPadding * 2);
                    final contentHeight =
                        constraints.maxHeight -
                            topPadding -
                            bottomPadding -
                            entryHeight -
                            entryGap;
                    final preferredPanelWidth = contentWidth.clamp(
                      188.0,
                      320.0,
                    );
                    final boardHeightByRow = contentHeight;
                    final boardWidthByRow = boardHeightByRow * boardAspectRatio;
                    final canUseRowLayout = contentWidth >=
                        boardWidthByRow + preferredPanelWidth + panelGap;

                    final board = TetrisBoard(board: snapshot.board);
                    final sidePanel = TetrisSidePanel(
                      score: snapshot.score,
                      lines: snapshot.lines,
                      level: snapshot.level,
                      statusText: snapshot.statusText,
                      nextPreview: snapshot.nextPreview,
                      isPaused: snapshot.isPaused,
                      isGameOver: snapshot.isGameOver,
                      onStartOrRestart: () {
                        _focusNode.requestFocus();
                        _controller.startNewGame();
                      },
                      onTogglePause: () {
                        _focusNode.requestFocus();
                        if (!snapshot.isRunning && !snapshot.isGameOver) {
                          _controller.startNewGame();
                          return;
                        }
                        _controller.togglePause();
                      },
                      isCompact: !canUseRowLayout,
                    );

                    return SafeArea(
                      top: false,
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          horizontalPadding,
                          topPadding,
                          horizontalPadding,
                          bottomPadding,
                        ),
                        child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1180),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: entryHeight,
                                    child: _CreatePostEntry(
                                      onPressed: () {
                                        Application.router.navigateTo(
                                          context,
                                          Routes.clientPostEditor,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: entryGap),
                                  Expanded(
                                    child: canUseRowLayout
                                        ? _WideTetrisLayout(
                                            availableWidth: contentWidth,
                                            availableHeight: contentHeight,
                                            sidePanel: sidePanel,
                                            board: board,
                                          )
                                        : _CompactTetrisLayout(
                                            availableHeight: contentHeight,
                                            sidePanel: sidePanel,
                                            board: board,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CreatePostEntry extends StatelessWidget {
  const _CreatePostEntry({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: BorderRadius.circular(16),
      color: const Color(0xFF25406A),
      onPressed: onPressed,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.add_circled, size: 18, color: CupertinoColors.white),
          SizedBox(width: 8),
          Text('新增动态', style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _WideTetrisLayout extends StatelessWidget {
  const _WideTetrisLayout({
    required this.availableWidth,
    required this.availableHeight,
    required this.board,
    required this.sidePanel,
  });

  final double availableWidth;
  final double availableHeight;
  final Widget board;
  final Widget sidePanel;

  @override
  Widget build(BuildContext context) {
    const panelGap = 18.0;
    const boardAspectRatio = tetrisBoardColumns / tetrisBoardRows;

    final sidePanelWidth = (availableWidth * 0.28).clamp(188.0, 320.0);
    final maxBoardWidth = availableWidth - sidePanelWidth - panelGap;
    final boardHeightFromWidth = maxBoardWidth / boardAspectRatio;
    final boardHeight = boardHeightFromWidth.clamp(0.0, availableHeight);
    final boardWidth = boardHeight * boardAspectRatio;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: boardWidth,
          height: boardHeight,
          child: board,
        ),
        const SizedBox(width: panelGap),
        SizedBox(
          width: sidePanelWidth,
          height: availableHeight,
          child: sidePanel,
        ),
      ],
    );
  }
}

class _CompactTetrisLayout extends StatelessWidget {
  const _CompactTetrisLayout({
    required this.availableHeight,
    required this.board,
    required this.sidePanel,
  });

  final double availableHeight;
  final Widget board;
  final Widget sidePanel;

  @override
  Widget build(BuildContext context) {
    const verticalGap = 14.0;
    const boardAspectRatio = tetrisBoardColumns / tetrisBoardRows;
    const sidePanelHeight = 152.0;

    final boardHeight = (availableHeight - sidePanelHeight - verticalGap).clamp(
      160.0,
      availableHeight,
    );
    final boardWidth = boardHeight * boardAspectRatio;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: boardWidth,
          height: boardHeight,
          child: board,
        ),
        const SizedBox(height: verticalGap),
        SizedBox(
          height: sidePanelHeight,
          width: double.infinity,
          child: ClipRect(
            child: sidePanel,
          ),
        ),
      ],
    );
  }
}
