import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/network/blob_uploader.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/paging/cursor_notifier.dart';
import '../domain/listing.dart';
import '../domain/listing_enums.dart';
import '../domain/listing_query.dart';

/// Ảnh mới chọn từ máy, chờ tải lên.
class NewPhoto {
  const NewPhoto({
    required this.bytes,
    required this.fileName,
    required this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String contentType;
}

/// Tin đăng bán sách (`08-listings`): tạo/sửa, ảnh, gửi duyệt, gỡ, tìm kiếm.
class ListingRepository {
  ListingRepository(this._api, [this._uploader]);

  final ApiClient _api;
  final BlobUploader? _uploader;

  /// Tìm kiếm tin `PUBLISHED`, phân trang cursor. Bộ lọc và `sort` của các trang
  /// sau phải giống trang đầu.
  Future<CursorPage<Listing>> search(
    ListingQuery query, {
    String? cursor,
    int pageSize = 20,
  }) => _api.getWithMeta(
    '/listings',
    query: query.toQuery(cursor: cursor, pageSize: pageSize),
    parse: (data, meta) => CursorPage.fromJson(data, meta, Listing.fromJson),
  );

  /// Tin công khai ai cũng xem được; tin khác chỉ chủ tin và admin (gửi kèm
  /// `Authorization`), người khác nhận `404 LISTING_NOT_FOUND`.
  Future<Listing> get(String id) =>
      _api.get('/listings/$id', parse: Listing.fromJson);

  Future<Listing> create(ListingDraftInput input) =>
      _api.post('/listings', body: input.toJson(), parse: Listing.fromJson);

  Future<Listing> update(String id, ListingDraftInput input) => _api.patch(
    '/listings/$id',
    body: input.toJson(),
    parse: Listing.fromJson,
  );

  /// Tải từng ảnh mới lên kho (mỗi ảnh một URL ký sẵn) rồi trả về `blobName`
  /// theo thứ tự đầu vào.
  Future<List<String>> uploadPhotos(String id, List<NewPhoto> photos) async {
    final uploader = _uploader;
    if (uploader == null) {
      throw StateError('ListingRepository không có BlobUploader');
    }
    return [
      for (final p in photos)
        await uploader.upload(
          bytes: p.bytes,
          fileName: p.fileName,
          contentType: p.contentType,
          ticketPath: '/listings/$id/photos/upload-url',
        ),
    ];
  }

  /// Đặt lại TOÀN BỘ danh sách ảnh theo thứ tự (ảnh đầu là ảnh bìa). Muốn giữ
  /// ảnh đã có thì gửi lại đúng `blobName` của chúng; bỏ ảnh nào là xóa ảnh đó.
  ///
  /// [volumePhotos] (bộ sách): số tập -> tên blob các ảnh của tập đó.
  Future<List<ListingPhoto>> setPhotos(
    String id,
    List<String> blobNames, {
    Map<int, List<String>>? volumePhotos,
  }) => _api.put(
    '/listings/$id/photos',
    body: {
      'blobNames': blobNames,
      if (volumePhotos != null)
        'volumePhotos': [
          for (final e in volumePhotos.entries)
            {'volumeNo': e.key, 'blobNames': e.value},
        ],
    },
    parse: (data) => [
      for (final j in data as List)
        ListingPhoto.fromJson(j as Map<dynamic, dynamic>),
    ],
  );

  Future<Listing> submit(String id) =>
      _api.post('/listings/$id/submit', parse: Listing.fromJson);

  /// Chủ tin gỡ không cần body.
  Future<Listing> unpublish(String id) => _api.post(
    '/listings/$id/unpublish',
    body: const <String, dynamic>{},
    parse: Listing.fromJson,
  );

  /// Tin của tôi, mới cập nhật trước.
  Future<PagedResult<Listing>> mine({
    ListingStatus? status,
    required int page,
    required int pageSize,
  }) => _api.getWithMeta(
    '/me/listings',
    query: {'status': ?status?.api, 'page': page, 'pageSize': pageSize},
    parse: (data, meta) => PagedResult(
      items: [for (final j in data as List) Listing.fromJson(j)],
      page: page,
      pageSize: pageSize,
      totalCount: (meta['totalItems'] as num?)?.toInt(),
    ),
  );
}
