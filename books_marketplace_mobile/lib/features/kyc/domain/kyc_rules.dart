import 'kyc_models.dart' show KycState, KycStatus;

/// Tuổi tối thiểu dự phòng khi `/config/public` chưa có `kyc.minAge`.
const kycDefaultMinAge = 18;

/// Số CCCD đúng 12 chữ số.
final _idNumber = RegExp(r'^\d{12}$');

bool isValidIdNumber(String v) => _idNumber.hasMatch(v.trim());

/// Đọc `dd/MM/yyyy` (chấp nhận `-` hoặc `.` làm dấu ngăn). Trả `null` nếu sai
/// định dạng, ngày không tồn tại (31/02), ở tương lai hoặc quá 120 tuổi.
DateTime? parseVnDate(String? v, {DateTime? now}) {
  final m = RegExp(r'^\s*(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})\s*$')
      .firstMatch(v ?? '');
  if (m == null) return null;
  final d = int.parse(m.group(1)!);
  final mo = int.parse(m.group(2)!);
  final y = int.parse(m.group(3)!);
  final date = DateTime.utc(y, mo, d);
  // DateTime tự tràn ngày (31/02 -> 03/03): đối chiếu lại để loại.
  if (date.year != y || date.month != mo || date.day != d) return null;
  final today = now ?? DateTime.now();
  final today0 = DateTime.utc(today.year, today.month, today.day);
  if (date.isAfter(today0)) return null;
  if (y < today0.year - 120) return null;
  return date;
}

String formatVnDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// `yyyy-MM-dd` gửi cho server.
String toApiDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Đủ [minAge] tuổi tính tới ngày [now].
bool isAtLeastAge(DateTime dob, int minAge, {DateTime? now}) {
  final today = now ?? DateTime.now();
  var age = today.year - dob.year;
  if (today.month < dob.month ||
      (today.month == dob.month && today.day < dob.day)) {
    age--;
  }
  return age >= minAge;
}

/// Họ tên hợp lệ: 2 ký tự trở lên, không có chữ số.
bool isValidFullName(String v) {
  final t = v.trim();
  return t.length >= 2 && !RegExp(r'\d').hasMatch(t);
}

/// Cách màn hình hiển thị trạng thái xác minh, tách khỏi widget để test.
enum KycUiPhase {
  /// Chưa gửi hồ sơ nào.
  notStarted,
  pending,
  verified,

  /// Bị từ chối, được gửi lại.
  rejectedCanRetry,

  /// Bị từ chối hoặc đang chờ giới hạn, chưa được gửi.
  blocked,

  /// Đã bị thu hồi (admin gỡ xác minh).
  revoked,
}

KycUiPhase kycUiPhase(KycState s) {
  switch (s.status) {
    case KycStatus.approved:
      return KycUiPhase.verified;
    case KycStatus.pendingReview:
      return KycUiPhase.pending;
    case KycStatus.none:
      return s.canSubmit ? KycUiPhase.notStarted : KycUiPhase.blocked;
    case KycStatus.rejected:
      return s.canSubmit ? KycUiPhase.rejectedCanRetry : KycUiPhase.blocked;
    case KycStatus.revoked:
      return s.canSubmit ? KycUiPhase.revoked : KycUiPhase.blocked;
  }
}

enum KycDobProblem { invalid, underage }

/// Kết quả kiểm tra ba trường nhập tay; `null` là hợp lệ.
class KycFieldsCheck {
  const KycFieldsCheck({
    this.nameInvalid = false,
    this.idInvalid = false,
    this.dob,
  });

  final bool nameInvalid;
  final bool idInvalid;
  final KycDobProblem? dob;

  bool get ok => !nameInvalid && !idInvalid && dob == null;
}

/// Kiểm tra họ tên, số CCCD, ngày sinh (`dd/MM/yyyy`) và tuổi tối thiểu trước
/// khi gửi. Server vẫn kiểm tra lại; đây chỉ để báo lỗi sớm.
KycFieldsCheck checkKycFields({
  required String fullName,
  required String idNumber,
  required String dob,
  required int minAge,
  DateTime? now,
}) {
  final date = parseVnDate(dob, now: now);
  return KycFieldsCheck(
    nameInvalid: !isValidFullName(fullName),
    idInvalid: !isValidIdNumber(idNumber),
    dob: date == null
        ? KycDobProblem.invalid
        : isAtLeastAge(date, minAge, now: now)
        ? null
        : KycDobProblem.underage,
  );
}
