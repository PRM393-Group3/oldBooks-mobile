/// Định dạng số giây thành `mm:ss`.
String formatMmSs(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  final mm = (s ~/ 60).toString().padLeft(2, '0');
  final ss = (s % 60).toString().padLeft(2, '0');
  return '$mm:$ss';
}
