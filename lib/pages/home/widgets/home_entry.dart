import 'package:flutter/cupertino.dart';

class HomeEntry {
  const HomeEntry({
    required this.title,
    required this.subtitle,
    required this.routeKey,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String routeKey;
  final IconData icon;
}
