import '../../../core/network/api_error.dart';
import '../../../core/util/json_read.dart';
import 'kyc_rules.dart';

/// Thông tin Claude đọc từ mặt trước CCCD (`POST /me/kyc/extract`). Trường
/// không đọc được thì `null`. Người dùng luôn xem và sửa lại, admin mới là
/// người quyết định.
class CccdFields {
  const CccdFields({this.fullName, this.idNumber, this.dateOfBirth});

  /// Đọc `data` của `/me/kyc/extract`. Giá trị sai định dạng bị bỏ (coi như
  /// không đọc được) để người dùng tự nhập, không làm hỏng form.
  factory CccdFields.fromJson(dynamic json) {
    if (json is! Map) return const CccdFields();
    final name = readString(json, 'fullName')?.trim();
    final id = readString(json, 'idNumber')?.replaceAll(RegExp(r'\s'), '');
    final dob = readString(json, 'dateOfBirth');
    return CccdFields(
      fullName: name != null && isValidFullName(name) ? name : null,
      idNumber: id != null && isValidIdNumber(id) ? id : null,
      dateOfBirth: _parseApiDate(dob),
    );
  }

  final String? fullName;

  /// Đúng 12 chữ số.
  final String? idNumber;
  final DateTime? dateOfBirth;

  bool get isEmpty =>
      fullName == null && idNumber == null && dateOfBirth == null;
}

/// `yyyy-MM-dd` -> ngày, `null` nếu sai định dạng hoặc ngày không có thật.
DateTime? _parseApiDate(String? v) {
  if (v == null) return null;
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(v.trim());
  if (m == null) return null;
  final y = int.parse(m.group(1)!);
  final mo = int.parse(m.group(2)!);
  final d = int.parse(m.group(3)!);
  final date = DateTime(y, mo, d);
  if (date.year != y || date.month != mo || date.day != d) return null;
  return date;
}

/// Vì sao OCR không điền được gì, để UI báo đúng. Mọi trường hợp đều quay về
/// nhập tay.
enum KycAiNotice {
  /// Không báo gì (AI tắt, Claude lỗi, mất mạng): im lặng chuyển sang nhập tay.
  none,

  /// Đọc xong nhưng không trường nào dùng được.
  nothingRead,

  /// Quá giới hạn tần suất (429).
  rateLimited,
}

/// Kết quả một lần đọc CCCD, đã áp dụng quy tắc fallback.
class CccdExtraction {
  const CccdExtraction(this.fields, [this.notice = KycAiNotice.none]);

  /// `null` khi phải nhập tay.
  final CccdFields? fields;
  final KycAiNotice notice;

  /// Có trường nào từ Claude: ocrSource gửi đi là CLAUDE, ngược lại MANUAL.
  bool get hasFields => fields != null && !fields!.isEmpty;
}

/// Chạy [call] (gọi `/me/kyc/extract`) và không bao giờ ném lỗi: mọi lỗi
/// (`AI_UNAVAILABLE`, `KYC_AI_FAILED`, `KYC_IMAGE_INVALID`, mạng, lạ) đều về
/// nhập tay; riêng `RATE_LIMITED` kèm [KycAiNotice.rateLimited].
Future<CccdExtraction> extractWithFallback(
  Future<CccdFields> Function() call,
) async {
  try {
    final fields = await call();
    if (fields.isEmpty) {
      return const CccdExtraction(null, KycAiNotice.nothingRead);
    }
    return CccdExtraction(fields);
  } on ApiError catch (e) {
    return CccdExtraction(
      null,
      e.code == ApiErrorCode.rateLimited
          ? KycAiNotice.rateLimited
          : KycAiNotice.none,
    );
  } catch (_) {
    return const CccdExtraction(null);
  }
}

/// Lỗi chất lượng selfie backend trả trong `issues`.
enum SelfieIssue {
  noFace('NO_FACE'),
  multipleFaces('MULTIPLE_FACES'),
  faceCovered('FACE_COVERED'),
  blurryOrDark('BLURRY_OR_DARK'),
  screenOrPrint('SCREEN_OR_PRINT');

  const SelfieIssue(this.api);
  final String api;

  static SelfieIssue? fromApi(String? v) {
    for (final i in values) {
      if (i.api == v) return i;
    }
    return null;
  }
}

/// Kết quả `POST /me/kyc/check-selfie`.
class SelfieCheck {
  const SelfieCheck({required this.usable, this.issues = const []});

  /// `usable` thiếu thì coi là dùng được (không chặn người dùng vì dữ liệu lạ).
  factory SelfieCheck.fromJson(dynamic json) {
    if (json is! Map) return const SelfieCheck(usable: true);
    final raw = json['issues'];
    return SelfieCheck(
      usable: readBool(json, 'usable') ?? true,
      issues: [
        if (raw is List)
          for (final v in raw) ?SelfieIssue.fromApi(v is String ? v : null),
      ],
    );
  }

  final bool usable;

  /// Chỉ gồm mã đã biết; mã lạ bị bỏ (UI dùng câu chung nếu danh sách rỗng).
  final List<SelfieIssue> issues;
}

/// Chạy [call] (gọi `/me/kyc/check-selfie`). Trả `null` = bỏ qua kiểm tra và
/// cho đi tiếp: AI tắt, Claude lỗi, hết lượt, mất mạng hay lỗi lạ đều không
/// được chặn người dùng. Riêng `KYC_IMAGE_INVALID` nghĩa là ảnh không dùng
/// được nên bắt chụp lại.
Future<SelfieCheck?> checkSelfieWithFallback(
  Future<SelfieCheck> Function() call,
) async {
  try {
    return await call();
  } on ApiError catch (e) {
    if (e.code == ApiErrorCode.kycImageInvalid) {
      return const SelfieCheck(usable: false);
    }
    return null;
  } catch (_) {
    return null;
  }
}
