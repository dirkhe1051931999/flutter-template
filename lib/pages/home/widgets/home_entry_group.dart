import 'package:oolaf_flutted/pages/home/widgets/home_entry.dart';

class HomeEntryGroup {
  const HomeEntryGroup({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<HomeEntry> items;
}
