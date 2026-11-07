import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/network/blob_uploader.dart';
import '../domain/cccd_analysis.dart';
import '../domain/kyc_models.dart';

/// Ảnh KYC chờ tải lên. Sau khi tải xong, [blobName] được ghi lại để lần thử
/// lại không tải lại.
class KycImage {
  KycImage(this.bytes, {required this.fileName});

  /// JPEG đã xoay thẳng, đã xóa EXIF.
  final Uint8List bytes;
  final String fileName;
  String? blobName;
}

/// eKYC (`GET /me/kyc`, `POST /me/kyc/submissions`). Ảnh giấy tờ và selfie tải
/// lên kho RIÊNG TƯ bằng đường quen thuộc rồi gửi `blobName`.
class KycRepository {
  KycRepository(this._api, [this._uploader]);

  final ApiClient _api;
  final BlobUploader? _uploader;

  Future<KycState> getState() => _api.get('/me/kyc', parse: KycState.fromJson);

  /// Tải lên các ảnh chưa có `blobName` và trả `blobName` của từng ảnh theo
  /// đúng thứ tự [images].
  Future<List<String>> uploadImages(
    List<KycImage> images, {
    void Function(int done, int total)? onProgress,
  }) async {
    final uploader = _uploader;
    final pending = [
      for (final i in images)
        if (i.blobName == null) i,
    ];
    if (pending.isNotEmpty && uploader == null) {
      throw StateError('KycRepository không có BlobUploader');
    }
    var done = 0;
    onProgress?.call(0, pending.length);
    for (final i in pending) {
      i.blobName = await uploader!.upload(
        bytes: i.bytes,
        fileName: i.fileName,
        contentType: 'image/jpeg',
        visibility: BlobVisibility.private,
      );
      onProgress?.call(++done, pending.length);
    }
    return [for (final i in images) i.blobName!];
  }

  /// Claude đọc mặt trước CCCD đã tải lên kho riêng tư (`POST /me/kyc/extract`).
  /// Có thể ném `AI_UNAVAILABLE`, `KYC_AI_FAILED`, `RATE_LIMITED`,
  /// `KYC_IMAGE_INVALID`; UI gọi qua `extractWithFallback`.
  Future<CccdFields> extractCccd(String frontBlobName) => _api.post(
    '/me/kyc/extract',
    body: {'frontBlobName': frontBlobName},
    parse: CccdFields.fromJson,
  );

  /// Claude kiểm tra chất lượng selfie đã tải lên (`POST /me/kyc/check-selfie`).
  /// UI gọi qua `checkSelfieWithFallback`.
  Future<SelfieCheck> checkSelfie(String selfieBlobName) => _api.post(
    '/me/kyc/check-selfie',
    body: {'selfieBlobName': selfieBlobName},
    parse: SelfieCheck.fromJson,
  );

  Future<KycSubmission> submit(
    KycSubmitRequest request, {
    required String idempotencyKey,
  }) => _api.post(
    '/me/kyc/submissions',
    body: request.toJson(),
    headers: {'Idempotency-Key': idempotencyKey},
    parse: KycSubmission.fromJson,
  );
}
