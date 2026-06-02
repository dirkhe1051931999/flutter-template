enum AppPickerMode { single, multiple, cascade }

class AppPickerOption {
  const AppPickerOption({
    required this.text,
    required this.value,
    this.children = const <AppPickerOption>[],
  });

  final String text;
  final String value;
  final List<AppPickerOption> children;
}

class AppPickerColumn {
  const AppPickerColumn({
    required this.key,
    required this.options,
  });

  final String key;
  final List<AppPickerOption> options;
}

class AppPickerResult {
  const AppPickerResult({
    required this.values,
    required this.texts,
  });

  final List<String> values;
  final List<String> texts;

  String get summary {
    if (texts.isEmpty) {
      return '未选择';
    }
    return texts.join(' / ');
  }
}
