String formatDuration(Duration value, {bool showHoursIfNeeded = true}) {
  final totalSeconds = value.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  if (showHoursIfNeeded && hours > 0) {
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  final totalMinutes = totalSeconds ~/ 60;
  final mm = twoDigits(totalMinutes);
  final ss = twoDigits(seconds);
  return '$mm:$ss';
}
