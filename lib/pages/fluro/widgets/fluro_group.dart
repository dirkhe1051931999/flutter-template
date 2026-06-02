class FluroGroup {
  const FluroGroup({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<FluroActionItem> items;
}

class FluroActionItem {
  const FluroActionItem({
    required this.title,
    required this.detail,
    required this.keyValue,
  });

  final String title;
  final String detail;
  final String keyValue;
}
