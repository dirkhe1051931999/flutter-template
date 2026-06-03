import 'package:flutter/cupertino.dart';

List<TextSpan> buildHupuHighlightSpans(
  String rawText,
  TextStyle baseStyle, {
  Color fallbackHighlightColor = const Color(0xFFC01E2F),
}) {
  final normalized = rawText.trim();
  if (normalized.isEmpty) {
    return const <TextSpan>[TextSpan(text: '')];
  }

  final pattern = RegExp(
    r'''<font\s+color=["']?([^"'>]+)["']?\s*>(.*?)</font>''',
    caseSensitive: false,
    dotAll: true,
  );

  final spans = <TextSpan>[];
  var start = 0;

  for (final match in pattern.allMatches(normalized)) {
    if (match.start > start) {
      spans.add(
        TextSpan(
          text: decodeHupuHtmlText(normalized.substring(start, match.start)),
        ),
      );
    }

    final colorValue = match.group(1);
    final content = decodeHupuHtmlText(match.group(2) ?? '');
    spans.add(
      TextSpan(
        text: content,
        style: baseStyle.copyWith(
          color: _tryParseColor(colorValue) ?? fallbackHighlightColor,
        ),
      ),
    );
    start = match.end;
  }

  if (start < normalized.length) {
    spans.add(TextSpan(text: decodeHupuHtmlText(normalized.substring(start))));
  }

  if (spans.isEmpty) {
    spans.add(TextSpan(text: decodeHupuHtmlText(normalized)));
  }

  return spans;
}

String decodeHupuHtmlText(String value) {
  return const _HupuHtmlUnescape().convert(
    value
        .replaceAll('<br/>', '\n')
        .replaceAll('<br />', '\n')
        .replaceAll('<br>', '\n'),
  );
}

Color? _tryParseColor(String? rawColor) {
  final value = rawColor?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  final hex = value.startsWith('#') ? value.substring(1) : value;
  if (hex.length != 6 && hex.length != 8) {
    return null;
  }

  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) {
    return null;
  }

  return Color(hex.length == 6 ? 0xFF000000 | parsed : parsed);
}

class _HupuHtmlUnescape {
  const _HupuHtmlUnescape();

  String convert(String input) {
    return input
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAllMapped(
          RegExp(r'&#(\d+);'),
          (match) => String.fromCharCode(
            int.tryParse(match.group(1) ?? '') ?? 0,
          ),
        )
        .replaceAllMapped(
          RegExp(r'&#x([0-9a-fA-F]+);'),
          (match) => String.fromCharCode(
            int.tryParse(match.group(1) ?? '', radix: 16) ?? 0,
          ),
        );
  }
}
