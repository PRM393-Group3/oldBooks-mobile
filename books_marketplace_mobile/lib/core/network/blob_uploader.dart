import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'api_client.dart';
import 'api_error.dart';

/// `PUBLIC` cho ảnh hiển thị công khai (ảnh đại diện, ảnh tin), `PRIVATE` cho tệp
/// riêng (giấy tờ, bằng chứng khiếu nại; cho phép thêm PDF).
enum BlobVisibility {
  public('PUBLIC'),
  private('PRIVATE');

  const BlobVisibility(this.apiValue);

  final String apiValue;
}

/// Tải một tệp lên Blob Storage theo 2 bước: xin URL upload rồi PUT bytes.
///
/// PUT dùng Dio không interceptor để không kèm `Authorization`. Trả về
/// `blobName` để bước xác nhận của từng tính năng (avatar, ảnh tin đăng) dùng.
class BlobUploader {
  BlobUploader(this._api, this._plainDio);

  final ApiClient _api;
  final Dio _plainDio;

  Future<String> upload({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    BlobVisibility visibility = BlobVisibility.public,
    String? ticketPath,
  }) async {
    // Ảnh của tin dùng endpoint riêng (không có `visibility`): server biết tin
    // nào đang nhận ảnh và kiểm tra trạng thái.
    final ticket = await _api.post(
      ticketPath ?? '/storage/upload-url',
      body: {
        'fileName': fileName,
        'contentType': contentType,
        if (ticketPath == null) 'visibility': visibility.apiValue,
      },
      parse: (data) {
        final j = data as Map<String, dynamic>;
        return (
          blobName: j['blobName'] as String,
          uploadUrl: j['uploadUrl'] as String,
          headers: {
            for (final e in (j['requiredHeaders'] as Map).entries)
              e.key.toString(): e.value.toString(),
          },
        );
      },
    );

    try {
      await _plainDio.put<dynamic>(
        ticket.uploadUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            ...ticket.headers,
            Headers.contentLengthHeader: bytes.length,
          },
        ),
      );
    } on DioException {
      throw const ApiError.uploadFailed();
    }
    return ticket.blobName;
  }
}

/// URL đọc tệp `PRIVATE`, hiệu lực 15 phút: không lưu lâu, gọi lại khi cần. Chỉ
/// chủ tệp (hoặc admin) đọc được, người khác nhận `403 FORBIDDEN`.
Future<String> fetchPrivateReadUrl(ApiClient api, String blobName) => api.get(
  '/storage/read-url',
  query: {'blobName': blobName},
  parse: (data) => (data as Map)['readUrl'] as String,
);
