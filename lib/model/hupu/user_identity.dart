String resolveHupuPuid({
  List<dynamic> directValues = const <dynamic>[],
  List<String> schemaCandidates = const <String>[],
}) {
  for (final value in directValues) {
    final direct = _normalizeNumeric(value);
    if (direct.isNotEmpty) {
      return direct;
    }
  }

  for (final candidate in schemaCandidates) {
    final puid = _extractPuidFromText(candidate);
    if (puid.isNotEmpty) {
      return puid;
    }
  }

  return '';
}

String _normalizeNumeric(dynamic value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) {
    return '';
  }
  return RegExp(r'^\d+$').hasMatch(text) ? text : '';
}

String _extractPuidFromText(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  final userPathMatch =
      RegExp(r'(?:^|[/:?&=#])user(?:/index)?/(\d+)(?:[/?&#]|$)')
          .firstMatch(trimmed);
  if (userPathMatch != null) {
    return userPathMatch.group(1) ?? '';
  }

  final puidQueryMatch = RegExp(r'[?&]puid=(\d+)').firstMatch(trimmed);
  if (puidQueryMatch != null) {
    return puidQueryMatch.group(1) ?? '';
  }

  final puidPathMatch = RegExp(r'(?:^|[/:?&=#])puid/(\d+)(?:[/?&#]|$)')
      .firstMatch(trimmed);
  if (puidPathMatch != null) {
    return puidPathMatch.group(1) ?? '';
  }

  return '';
}
