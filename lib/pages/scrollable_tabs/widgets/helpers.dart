import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';

String linkedTabSourceText(LinkedTabChangeSource source) {
  switch (source) {
    case LinkedTabChangeSource.tap:
      return '点击';
    case LinkedTabChangeSource.swipe:
      return '滑动';
    case LinkedTabChangeSource.programmatic:
      return '程序切换';
  }
}

Color parseLinkedTabColor(String hex) {
  final normalized = hex.replaceAll('#', '').trim();
  final value = normalized.length == 6 ? 'FF$normalized' : normalized;
  return Color(int.parse(value, radix: 16));
}

IconData linkedTabIconFromName(String name) {
  switch (name) {
    case 'arrow.left.and.right.square':
      return CupertinoIcons.arrow_left_right_square;
    case 'sparkles':
      return CupertinoIcons.sparkles;
    case 'arrow.clockwise':
      return CupertinoIcons.arrow_clockwise;
    case 'wand.and.stars':
      return CupertinoIcons.wand_stars;
    case 'doc.text':
      return CupertinoIcons.doc_text;
    case 'clock.arrow.circlepath':
      return CupertinoIcons.refresh_circled;
    case 'chart.bar.doc.horizontal':
      return CupertinoIcons.chart_bar_alt_fill;
    case 'hand.tap':
      return CupertinoIcons.hand_raised;
    case 'paperplane':
      return CupertinoIcons.paperplane;
    case 'square.grid.2x2':
    default:
      return CupertinoIcons.square_grid_2x2;
  }
}
