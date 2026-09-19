import '../../../core/network/api_client.dart';
import '../../../core/network/paged_result.dart';
import '../domain/listing.dart';
import '../domain/listing_enums.dart';
import '../domain/listing_input.dart';
import '../domain/listing_rules.dart';

class ListingRepository {
  ListingRepository(this._api);
  final ApiClient _api;

  Future<ListingRules> rules() =>
      _api.get('/listings/rules', parse: ListingRules.fromJson);

  /// Tạo bản nháp rỗng. Chỉ gọi khi người dùng bấm "Tiếp" ở bước 1.
  Future<Listing> create() => _api.post('/listings', parse: Listing.fromJson);

  Future<Listing> get(String id) =>
      _api.get('/listings/$id', parse: Listing.fromJson);

  Future<Listing> saveBookInfo(String id, BookInfoInput input) => _api.put(
    '/listings/$id/book-info',
    body: input.toJson(),
    parse: Listing.fromJson,
  );

  /// Thứ tự mảng là thứ tự hiển thị.
  Future<Listing> saveImages(
    String id,
    List<({String blobName, ImageType type})> images,
  ) => _api.put(
    '/listings/$id/images',
    body: {
      'images': [
        for (final i in images) {'blobName': i.blobName, 'type': i.type.api},
      ],
    },
    parse: Listing.fromJson,
  );

  Future<Listing> saveSaleMethod(String id, SaleMethodInput input) => _api.put(
    '/listings/$id/sale-method',
    body: input.toJson(),
    parse: Listing.fromJson,
  );

  Future<({Listing listing, SubmitResult result})> submit(String id) =>
      _api.post(
        '/listings/$id/submit',
        parse: (data) {
          final j = data as Map<dynamic, dynamic>;
          return (
            listing: Listing.fromJson(j['listing']),
            result: SubmitResult(
              estimatedProcessingHours:
                  (j['estimatedProcessingHours'] as num?)?.toInt() ?? 24,
            ),
          );
        },
      );

  /// Chỉ với tin Nháp hoặc Bị từ chối.
  Future<void> delete(String id) => _api.deleteNoContent('/listings/$id');

  Future<PagedResult<Listing>> mine({
    ListingStatus? status,
    required int page,
    required int pageSize,
  }) => _api.get(
    '/listings/mine',
    query: {'status': ?status?.api, 'page': page, 'pageSize': pageSize},
    parse: (d) => PagedResult.fromJson(
      d,
      Listing.fromJson,
      page: page,
      pageSize: pageSize,
    ),
  );

  /// Số tin theo trạng thái cho dashboard: `{ counts: { Draft: n, ... } }`.
  Future<Map<ListingStatus, int>> mineSummary() => _api.get(
    '/listings/mine/summary',
    parse: (data) {
      final raw = data is Map
          ? (data['counts'] is Map ? data['counts'] as Map : data)
          : const {};
      return {
        for (final e in raw.entries)
          if (e.value is num &&
              ListingStatus.fromApi(e.key.toString()) != ListingStatus.unknown)
            ListingStatus.fromApi(e.key.toString()): (e.value as num).toInt(),
      };
    },
  );

  /// Tin công khai (Đang bán, Đang đấu giá). `categoryId` gồm cả danh mục con.
  Future<PagedResult<Listing>> browse({
    String? categoryId,
    required int page,
    required int pageSize,
  }) => _api.get(
    '/listings',
    query: {'categoryId': ?categoryId, 'page': page, 'pageSize': pageSize},
    parse: (d) => PagedResult.fromJson(
      d,
      Listing.fromJson,
      page: page,
      pageSize: pageSize,
    ),
  );
}
