String prettyDuration(Duration dur) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  final String h = twoDigits(dur.inHours.remainder(24));
  final String m = twoDigits(dur.inMinutes.remainder(60));
  final String s = twoDigits(dur.inSeconds.remainder(60));
  return "$h:$m:$s";
}

String prettySize(int byte) {
  if (byte < 1024) {
    return "$byte B";
  }
  if (byte < (1 << 20)) {
    return "${(byte/(1<<10)).toStringAsFixed(2)} KB";
  }
  if (byte < (1 << 30)) {
    return "${(byte/(1<<20)).toStringAsFixed(2)} MB";
  }
  return "${(byte/(1<<30)).toStringAsFixed(2)} GB";
}
