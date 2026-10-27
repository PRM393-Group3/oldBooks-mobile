import 'dart:typed_data';

import '../../../core/util/json_read.dart';

/// Trạng thái xác minh tài khoản (`GET /me/kyc`). Mã lạ rơi vào [none] để
/// không crash khi server thêm trạng thái mới.
enum KycStatus {
  none('NONE'),
  pendingReview('PENDING_REVIEW'),
  approved('APPROVED'),
  rejected('REJECTED'),
  revoked('REVOKED');

  const KycStatus(this.api);
  final String api;

  static KycStatus fromApi(String? v) =>
      values.firstWhere((s) => s.api == v, orElse: () => none);
}

/// Một hồ sơ đã gửi. Số CCCD chỉ có dạng che (`********1234`).
class KycSubmission {
  const KycSubmission({
    required this.id,
    required this.status,
    required this.fullName,
    required this.idNumberMasked,
    this.submittedAt,
    this.reviewedAt,
    this.rejectReason,
    this.dateOfBirth,
  });

  factory KycSubmission.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    return KycSubmission(
      id: readString(j, 'id') ?? '',
      status: KycStatus.fromApi(readString(j, 'status')),
      submittedAt: readDate(j, 'submittedAt'),
      reviewedAt: readDate(j, 'reviewedAt'),
      rejectReason: readString(j, 'rejectReason'),
      fullName: readString(j, 'fullName') ?? '',
      idNumberMasked: readString(j, 'idNumberMasked') ?? '',
      dateOfBirth: readString(j, 'dateOfBirth'),
    );
  }

  final String id;
  final KycStatus status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? rejectReason;
  final String fullName;
  final String idNumberMasked;

  /// `yyyy-MM-dd`.
  final String? dateOfBirth;
}

/// `GET /me/kyc`.
class KycState {
  const KycState({
    required this.status,
    this.isVerified = false,
    this.verifiedAt,
    this.canSubmit = true,
    this.retryAfter,
    this.latest,
  });

  factory KycState.fromJson(dynamic json) {
    final j = json as Map<dynamic, dynamic>;
    final latest = readMap(j, 'latest');
    return KycState(
      status: KycStatus.fromApi(readString(j, 'status')),
      isVerified: readBool(j, 'isVerified') ?? false,
      verifiedAt: readDate(j, 'verifiedAt'),
      canSubmit: readBool(j, 'canSubmit') ?? false,
      retryAfter: readDate(j, 'retryAfter'),
      latest: latest == null ? null : KycSubmission.fromJson(latest),
    );
  }

  final KycStatus status;
  final bool isVerified;
  final DateTime? verifiedAt;
  final bool canSubmit;

  /// Chỉ có khi `canSubmit` là false vì đang bị giới hạn số lần gửi.
  final DateTime? retryAfter;
  final KycSubmission? latest;
}

/// Thử thách liveness. `api` là mã gửi trong `clientInfo.livenessChallenges`.
enum LivenessChallenge {
  blink('BLINK'),
  turnLeft('TURN_LEFT'),
  turnRight('TURN_RIGHT');

  const LivenessChallenge(this.api);
  final String api;
}

enum OcrSource {
  ai('AI'),
  manual('MANUAL');

  const OcrSource(this.api);
  final String api;
}

/// `clientInfo` của hồ sơ: chỉ để gợi ý cho admin, server không tin để duyệt.
class KycClientInfo {
  const KycClientInfo({
    required this.ocrSource,
    required this.livenessChallenges,
    this.faceMatchScore,
    this.modelVersion,
  });

  /// 0..1, `null` khi không tìm thấy mặt trên CCCD hoặc không có model.
  final double? faceMatchScore;
  final OcrSource ocrSource;
  final String? modelVersion;
  final List<LivenessChallenge> livenessChallenges;

  Map<String, dynamic> toJson() => {
    'faceMatchScore': faceMatchScore,
    'ocrSource': ocrSource.api,
    'modelVersion': modelVersion,
    'livenessChallenges': [for (final c in livenessChallenges) c.api],
  };
}

/// Body của `POST /me/kyc/submissions`. Ảnh đã tải lên kho riêng tư, ở đây chỉ
/// còn tên blob.
class KycSubmitRequest {
  const KycSubmitRequest({
    required this.fullName,
    required this.idNumber,
    required this.dateOfBirth,
    required this.frontBlobName,
    required this.backBlobName,
    required this.selfieBlobName,
    required this.livenessBlobNames,
    required this.clientInfo,
  });

  final String fullName;
  final String idNumber;

  /// `yyyy-MM-dd`.
  final String dateOfBirth;
  final String frontBlobName;
  final String backBlobName;
  final String selfieBlobName;
  final List<String> livenessBlobNames;
  final KycClientInfo clientInfo;

  Map<String, dynamic> toJson() => {
    'fullName': fullName.trim(),
    'idNumber': idNumber,
    'dateOfBirth': dateOfBirth,
    'frontBlobName': frontBlobName,
    'backBlobName': backBlobName,
    'selfieBlobName': selfieBlobName,
    'livenessBlobNames': livenessBlobNames,
    'consentAccepted': true,
    'clientInfo': clientInfo.toJson(),
  };
}

/// Kết quả chụp selfie có liveness: ảnh selfie, các khung theo từng thử thách
/// đã hoàn thành (cùng thứ tự [challenges]).
class LivenessResult {
  const LivenessResult({
    required this.selfie,
    required this.frames,
    required this.challenges,
  });

  final Uint8List selfie;
  final List<Uint8List> frames;
  final List<LivenessChallenge> challenges;
}
