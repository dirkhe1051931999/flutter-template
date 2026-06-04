class HupuNbaMatchLiveData {
  const HupuNbaMatchLiveData({
    required this.matchId,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeScore,
    required this.awayScore,
    required this.intervals,
    required this.events,
  });

  final String matchId;
  final String homeTeamName;
  final String awayTeamName;
  final int homeScore;
  final int awayScore;
  final List<HupuNbaMatchLiveInterval> intervals;
  final List<HupuNbaMatchLiveEvent> events;

  List<HupuNbaMatchLiveEntry> get entries {
    final sortedEvents = events.reversed.toList(growable: false);
    final result = <HupuNbaMatchLiveEntry>[];
    String previousTimeLabel = '';
    for (final event in sortedEvents) {
      final timeLabel = event.displayTime(intervals);
      if (timeLabel.isNotEmpty && timeLabel != previousTimeLabel) {
        result.add(HupuNbaMatchLiveEntry.time(timeLabel));
        previousTimeLabel = timeLabel;
      }
      result.add(HupuNbaMatchLiveEntry.event(event));
    }
    return result;
  }

  factory HupuNbaMatchLiveData.fromJson(Map<String, dynamic> json) {
    final result = _asMap(json['result']);
    final xAxis = _asMap(result['x']);
    return HupuNbaMatchLiveData(
      matchId: _stringValue(result['matchId']),
      homeTeamName: _stringValue(result['homeTeamName']),
      awayTeamName: _stringValue(result['awayTeamName']),
      homeScore: _intValue(result['homeScore']),
      awayScore: _intValue(result['awayScore']),
      intervals: _parseIntervals(xAxis['intervals']),
      events: _parseEvents(result['pointsEventList']),
    );
  }
}

class HupuNbaMatchLiveInterval {
  const HupuNbaMatchLiveInterval({
    required this.quarter,
    required this.start,
    required this.end,
  });

  final String quarter;
  final int start;
  final int end;

  bool contains(int time) => time >= start && time <= end;
}

class HupuNbaMatchLiveEvent {
  const HupuNbaMatchLiveEvent({
    required this.time,
    required this.quarter,
    required this.homeScore,
    required this.awayScore,
    required this.event,
  });

  final int time;
  final String quarter;
  final int homeScore;
  final int awayScore;
  final String event;

  String get scoreText => '$homeScore-$awayScore';

  String displayTime(List<HupuNbaMatchLiveInterval> intervals) {
    final interval = intervals.firstWhere(
      (item) => item.contains(time),
      orElse: () => HupuNbaMatchLiveInterval(
        quarter: quarter,
        start: _quarterStart(quarter),
        end: _quarterStart(quarter) + 719,
      ),
    );
    final remaining = interval.end - time;
    if (remaining < 0) {
      return quarter;
    }
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    if (minutes <= 0) {
      return '${interval.quarter}剩$seconds秒';
    }
    return '${interval.quarter}剩$minutes分${seconds.toString().padLeft(2, '0')}秒';
  }

  factory HupuNbaMatchLiveEvent.fromJson(Map<String, dynamic> json) {
    return HupuNbaMatchLiveEvent(
      time: _intValue(json['time']),
      quarter: _stringValue(json['quarter']),
      homeScore: _intValue(json['homeScore']),
      awayScore: _intValue(json['awayScore']),
      event: _stringValue(json['event']),
    );
  }
}

class HupuNbaMatchLiveEntry {
  const HupuNbaMatchLiveEntry._({
    required this.timeLabel,
    required this.event,
  });

  final String timeLabel;
  final HupuNbaMatchLiveEvent? event;

  bool get isTime => timeLabel.isNotEmpty;

  factory HupuNbaMatchLiveEntry.time(String label) {
    return HupuNbaMatchLiveEntry._(timeLabel: label, event: null);
  }

  factory HupuNbaMatchLiveEntry.event(HupuNbaMatchLiveEvent event) {
    return HupuNbaMatchLiveEntry._(timeLabel: '', event: event);
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

List<HupuNbaMatchLiveInterval> _parseIntervals(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuNbaMatchLiveInterval>[];
  }
  return rawItems.whereType<Map>().map((item) {
    final map = Map<String, dynamic>.from(item);
    return HupuNbaMatchLiveInterval(
      quarter: _stringValue(map['quarter']),
      start: _intValue(map['start']),
      end: _intValue(map['end']),
    );
  }).toList(growable: false);
}

List<HupuNbaMatchLiveEvent> _parseEvents(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuNbaMatchLiveEvent>[];
  }
  return rawItems
      .whereType<Map>()
      .map((item) =>
          HupuNbaMatchLiveEvent.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.event.isNotEmpty)
      .toList(growable: false);
}

String _stringValue(dynamic value) => value?.toString() ?? '';

int _intValue(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int _quarterStart(String quarter) {
  final number = RegExp(r'\d+').firstMatch(quarter)?.group(0);
  final quarterNumber = int.tryParse(number ?? '') ?? 1;
  return ((quarterNumber - 1) * 720) + 1;
}
