import 'package:flutter/cupertino.dart';

enum AppTabsType {
  line,
  card,
}

class AppTabItemData {
  const AppTabItemData({
    required this.title,
    required this.child,
    this.disabled = false,
    this.name,
  });

  final String title;
  final Widget child;
  final bool disabled;
  final String? name;
}
