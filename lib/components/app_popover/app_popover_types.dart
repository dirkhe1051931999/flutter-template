enum AppPopoverPlacement {
  top,
  bottom,
}

class AppPopoverAction {
  const AppPopoverAction({
    required this.text,
    this.icon,
    this.disabled = false,
  });

  final String text;
  final String? icon;
  final bool disabled;
}
