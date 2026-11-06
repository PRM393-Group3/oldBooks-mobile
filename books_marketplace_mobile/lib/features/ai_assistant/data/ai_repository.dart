import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/network/blob_uploader.dart';
import '../../../core/network/paged_result.dart';
import '../domain/ai_models.dart';

/// Số ảnh tối đa mỗi lần gọi (`ai.maxImagesPerRequest` của backend).
const aiMaxImages = 4;

/// Ảnh gửi cho AI: bytes đã chọn, tải lên kho công khai rồi tham chiếu bằng
/// `blobName`.
class AiImage {
  const AiImage({
    required this.bytes,
    required this.fileName,
    this.contentType = 'image/jpeg',
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;
}

/// Trợ lý AI chạy bằng Claude ở backend (`/me/ai/*`).
class AiRepository {
  AiRepository(this._api, [this._uploader]);

  final ApiClient _api;
  final BlobUploader? _uploader;

  Future<AiStatus> status() => _api.get('/me/ai', parse: AiStatus.fromJson);

  Future<AiStatus> subscribe({required String idempotencyKey}) => _api.post(
    '/me/ai/subscription',
    headers: {'Idempotency-Key': idempotencyKey},
    parse: AiStatus.fromJson,
  );

  /// Tải ảnh lên (PUBLIC, agent sau đó gắn chính các blob này vào tin; không xóa phía client) qua `POST /storage/upload-url`, trả
  /// `blobName` theo đúng thứ tự.
  Future<List<String>> uploadImages(List<AiImage> images) async {
    final uploader = _uploader;
    if (images.isNotEmpty && uploader == null) {
      throw StateError('AiRepository không có BlobUploader');
    }
    return [
      for (final i in images)
        await uploader!.upload(
          bytes: i.bytes,
          fileName: i.fileName,
          contentType: i.contentType,
          visibility: BlobVisibility.public,
        ),
    ];
  }

  /// Tải ảnh lên rồi trích thông tin sách (tối đa [aiMaxImages] ảnh).
  Future<AiExtractResult> extractFromImages(List<AiImage> images) async =>
      extract(await uploadImages(images.take(aiMaxImages).toList()));

  Future<AiExtractResult> extract(List<String> blobNames) => _api.post(
    '/me/ai/extract',
    body: {'blobNames': blobNames},
    parse: AiExtractResult.fromJson,
  );

  Future<String> createConversation() => _api.post(
    '/me/ai/conversations',
    parse: (data) => (data as Map)['id'].toString(),
  );

  Future<PagedResult<AiConversation>> conversations({
    required int page,
    required int pageSize,
  }) => _api.getWithMeta(
    '/me/ai/conversations',
    query: {'page': page, 'pageSize': pageSize},
    parse: (data, meta) {
      final total = meta['totalItems'];
      return PagedResult(
        items: [
          for (final c in (data as List? ?? const []))
            AiConversation.fromJson(c),
        ],
        page: page,
        pageSize: pageSize,
        totalCount: total is num ? total.toInt() : null,
      );
    },
  );

  /// Tin nhắn của hội thoại. Chấp nhận `data` là mảng tin nhắn hoặc object có
  /// `messages`.
  Future<List<AiMessage>> messages(String id) async =>
      (await conversation(id)).messages;

  /// Tin nhắn kèm thẻ câu hỏi còn mở (nếu có).
  Future<AiConversationDetail> conversation(String id) => _api.get(
    '/me/ai/conversations/$id',
    parse: AiConversationDetail.fromJson,
  );

  Future<void> deleteConversation(String id) =>
      _api.deleteNoContent('/me/ai/conversations/$id');

  Future<AiAgentReply> sendMessage(
    String conversationId, {
    required String text,
    List<String> blobNames = const [],
    List<AiAnswer> answers = const [],
    required String idempotencyKey,
  }) => _api.post(
    '/me/ai/conversations/$conversationId/messages',
    body: {
      'text': text,
      'blobNames': blobNames,
      if (answers.isNotEmpty) 'answers': [for (final a in answers) a.toJson()],
    },
    headers: {'Idempotency-Key': idempotencyKey},
    parse: AiAgentReply.fromJson,
  );
}
