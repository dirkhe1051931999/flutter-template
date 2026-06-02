enum AppStepsDirection {
  horizontal,
  vertical,
}

enum AppStepStatus {
  finish,
  process,
  waiting,
}

class AppStepItem {
  const AppStepItem({
    required this.title,
    this.description,
  });

  final String title;
  final String? description;
}
