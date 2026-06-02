class AppSidebarItemData {
  const AppSidebarItemData({
    required this.title,
    this.badge,
    this.dot = false,
    this.disabled = false,
  });

  final String title;
  final String? badge;
  final bool dot;
  final bool disabled;
}
