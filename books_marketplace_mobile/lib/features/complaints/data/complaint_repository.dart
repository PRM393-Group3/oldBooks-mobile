import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/network/blob_uploader.dart';
import '../../../core/network/paged_result.dart';
import '../domain/complaint_case.dart';

/// Tệp bằng chứng chờ tải lên. Sau khi tải xong, [blobName] được ghi lại để lần
/// thử lại không tải lại.
class EvidenceFile {
  EvidenceFile({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;
  String? blobName;

  bool get isVideo => contentType.startsWith('video/');
}

/// Khiếu nại (`10-complaints`). Bằng chứng tải lên kho RIÊNG TƯ bằng đường quen
/// thuộc rồi gửi `blobName`; mỗi tệp chỉ gắn vào một nơi.
class ComplaintRepository {
  ComplaintRepository(this._api, [this._uploader]);

  final ApiClient _api;
  final BlobUploader? _uploader;

  /// Tải các tệp chưa có `blobName` lên kho riêng tư rồi trả về mọi `blobName`.
  Future<List<String>> uploadEvidence(
    List<EvidenceFile> files, {
    void Function(int done, int total)? onProgress,
  }) async {
    final uploader = _uploader;
    final pending = [
      for (final f in files)
        if (f.blobName == null) f,
    ];
    if (pending.isNotEmpty && uploader == null) {
      throw StateError('ComplaintRepository không có BlobUploader');
    }
    var done = 0;
    onProgress?.call(0, pending.length);
    for (final f in pending) {
      f.blobName = await uploader!.upload(
        bytes: f.bytes,
        fileName: f.fileName,
        contentType: f.contentType,
        visibility: BlobVisibility.private,
      );
      onProgress?.call(++done, pending.length);
    }
    return [for (final f in files) f.blobName!];
  }

  /// Người mua mở khiếu nại: 1 đến 10 tệp bằng chứng, mô tả 10 đến 2.000 ký tự.
  Future<ComplaintCase> open({
    required String orderId,
    required CaseReason reason,
    required String description,
    required List<String> attachments,
  }) => _api.post(
    '/complaints',
    body: {
      'orderId': orderId,
      'reason': reason.api,
      'description': description.trim(),
      'attachments': attachments,
    },
    parse: ComplaintCase.fromJson,
  );

  Future<ComplaintCase> get(String id) =>
      _api.get('/complaints/$id', parse: ComplaintCase.fromJson);

  Future<PagedResult<ComplaintCase>> list({
    String? role,
    CaseStatus? status,
    required int page,
    required int pageSize,
  }) => _api.getWithMeta(
    '/complaints',
    query: {
      'role': ?role,
      'status': ?status?.api,
      'page': page,
      'pageSize': pageSize,
    },
    parse: (data, meta) => PagedResult(
      items: [for (final j in data as List) ComplaintCase.fromJson(j)],
      page: page,
      pageSize: pageSize,
      totalCount: (meta['totalItems'] as num?)?.toInt(),
    ),
  );

  /// Người bán phản hồi khi `OPEN`. [amount] cho `PROPOSE_PARTIAL` (1 đến
  /// `giá − 1`), [reason] cho `REJECT` (từ 10 ký tự).
  Future<ComplaintCase> sellerResponse(
    String id, {
    required SellerAction action,
    int? amount,
    String? reason,
    List<String> attachments = const [],
  }) => _api.post(
    '/complaints/$id/seller-response',
    body: {
      'action': action.api,
      'amount': ?amount,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      'attachments': attachments,
    },
    parse: ComplaintCase.fromJson,
  );

  /// Người mua quyết định khi `SELLER_RESPONDED`. `ACCEPT` thực hiện tiền ngay.
  Future<ComplaintCase> buyerDecision(
    String id, {
    required bool accept,
    String? note,
  }) => _api.post(
    '/complaints/$id/buyer-decision',
    body: {
      'decision': accept ? 'ACCEPT' : 'REJECT',
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    },
    parse: ComplaintCase.fromJson,
  );

  /// Cần ít nhất nội dung hoặc một tệp; không sửa/xóa được sau khi gửi.
  Future<ComplaintCase> message(
    String id, {
    String? body,
    List<String> attachments = const [],
  }) => _api.post(
    '/complaints/$id/messages',
    body: {
      if (body != null && body.trim().isNotEmpty) 'body': body.trim(),
      'attachments': attachments,
    },
    parse: ComplaintCase.fromJson,
  );
}
