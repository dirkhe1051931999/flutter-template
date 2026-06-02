import 'package:flutter/cupertino.dart';

class AppIndexBarSection {
  const AppIndexBarSection({
    required this.index,
    required this.title,
    required this.children,
  });

  final String index;
  final String title;
  final List<Widget> children;
}
