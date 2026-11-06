import 'kyc_rules.dart';

/// Thông tin Gemma đọc từ mặt trước CCCD. Trường không đọc được thì `null`.
/// Người dùng luôn xem và sửa lại, admin mới là người quyết định.
class CccdFields {
  const CccdFields({this.fullName, this.idNumber, this.dateOfBirth});

  final String? fullName;

  /// Đúng 12 chữ số.
  final String? idNumber;
  final DateTime? dateOfBirth;

  bool get isEmpty =>
      fullName == null && idNumber == null && dateOfBirth == null;
}

/// Lời nhắc gửi model. Tiếng Anh vì model nhỏ làm theo tốt hơn; từng trường
/// một dòng để [previewCccd] đọc được khi model đang sinh dần.
const cccdPrompt =
    'This is the front of a Vietnamese citizen identity card (CCCD). Read only '
    'what is clearly printed on the card; never guess or invent. Write UNKNOWN '
    'for anything you cannot read. Answer with exactly these lines and nothing '
    'else:\n'
    'FULL_NAME: <full name in capital letters as printed, or UNKNOWN>\n'
    'ID_NUMBER: <the 12-digit identity number, digits only, or UNKNOWN>\n'
    'DATE_OF_BIRTH: <date of birth as dd/MM/yyyy, or UNKNOWN>';

/// Giá trị model hay điền khi không đọc được; coi như không có.
final _emptyValue = RegExp(
  r'^(unknown|none|n/?a|null|nil|-+|không rõ|không có|không biết)\.?$',
  caseSensitive: false,
);

String _clean(String s) => s
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll(RegExp('^["\'“*]+|["\'”*]+\$'), '')
    .trim();

/// Lấy giá trị một dòng `KEY: value`. Dòng chưa xuống dòng là dòng model còn
/// đang viết nên bị bỏ qua, trừ khi [last] (câu trả lời đã xong).
String? _field(String text, String key, {required bool last}) {
  final m = RegExp(
    '^\\W*$key\\s*[:：]\\s*(.*?)(\\n|\$)',
    caseSensitive: false,
    multiLine: true,
  ).firstMatch(text);
  if (m == null) return null;
  if (m.group(2)!.isEmpty && !last) return null;
  final v = _clean(m.group(1)!);
  return v.isEmpty || _emptyValue.hasMatch(v) ? null : v;
}

/// Lấy đúng 12 chữ số, chấp nhận dấu cách hoặc dấu chấm xen giữa. Sai số chữ số
/// thì bỏ (model hay đọc thiếu/thừa một số).
String? _idNumber(String? v) {
  if (v == null) return null;
  final digits = v.replaceAll(RegExp(r'[\s.\-]'), '');
  return isValidIdNumber(digits) ? digits : null;
}

/// Họ tên: bỏ giá trị có chữ số hoặc quá ngắn.
String? _name(String? v) {
  if (v == null || !isValidFullName(v)) return null;
  return v;
}

/// Đọc phần đã sinh ra để hiện dần. [done] cho phép đọc cả dòng cuối chưa xuống
/// dòng. Chịu được chữ thừa quanh các dòng.
CccdFields previewCccd(String raw, {bool done = false, DateTime? now}) {
  return CccdFields(
    fullName: _name(_field(raw, 'full[_ ]?name', last: done)),
    idNumber: _idNumber(
      _field(raw, '(?:id[_ ]?number|id[_ ]?no|number)', last: done),
    ),
    dateOfBirth: parseVnDate(
      _field(raw, '(?:date[_ ]?of[_ ]?birth|dob|birth[_ ]?date)', last: done),
      now: now,
    ),
  );
}

/// Đọc câu trả lời hoàn chỉnh. Trả `null` nếu không đọc được trường nào.
CccdFields? parseCccd(String raw, {DateTime? now}) {
  if (raw.trim().isEmpty) return null;
  final f = previewCccd(raw, done: true, now: now);
  return f.isEmpty ? null : f;
}
