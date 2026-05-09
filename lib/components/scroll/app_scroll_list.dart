import 'package:flutter/material.dart';

class AppScrollList extends StatelessWidget {
  const AppScrollList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.controller,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
