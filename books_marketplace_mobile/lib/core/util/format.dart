import 'package:intl/intl.dart';

/// Tiền Việt Nam Đồng: số nguyên, không phần thập phân. Ví dụ `120.000 ₫`.
String formatVnd(int amount, String localeName) =>
    '${NumberFormat.decimalPattern(localeName).format(amount)} ₫';

String formatDate(DateTime utc, String localeName) =>
    DateFormat.yMMMd(localeName).format(utc.toLocal());

String formatDateTime(DateTime utc, String localeName) =>
    DateFormat.yMMMd(localeName).add_Hm().format(utc.toLocal());

/// `mm:ss` cho đồng hồ đếm ngược.
String formatCountdown(Duration d) {
  final total = d.isNegative ? 0 : d.inSeconds;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// Giờ và ngày ngắn gọn, ví dụ `14:30, 05/10`.
String formatShortDateTime(DateTime t) =>
    DateFormat('HH:mm, dd/MM').format(t.toLocal());

/// Thời gian còn lại: `mm:ss`, `h:mm:ss`, hoặc `{n} ngày {h} giờ` từ một ngày
/// trở lên. [daysHours] dựng chuỗi theo ngôn ngữ cho trường hợp dài.
String formatRemaining(
  Duration d, {
  required String Function(int days, int hours) daysHours,
}) {
  final total = d.isNegative ? 0 : d.inSeconds;
  final days = total ~/ 86400;
  if (days >= 1) return daysHours(days, total % 86400 ~/ 3600);
  return formatCountdown(d);
}
