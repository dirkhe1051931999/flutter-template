class DanmakuItem {
  const DanmakuItem({
    required this.atMs,
    required this.text,
    required this.type,
    required this.color,
    required this.priority,
  });

  final int atMs;
  final String text;
  final String type;
  final String color;
  final int priority;

  factory DanmakuItem.fromJson(Map<String, dynamic> json) {
    return DanmakuItem(
      atMs: _toInt(json['atMs']) ?? _toInt(json['at_ms']) ?? 0,
      text: _toString(json['text']) ?? '',
      type: _toString(json['type']) ?? 'normal',
      color: _toString(json['color']) ?? '#FFFFFF',
      priority: _toInt(json['priority']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'atMs': atMs,
      'text': text,
      'type': type,
      'color': color,
      'priority': priority,
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static String? _toString(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }
}
