import '../../../core/network/api_client.dart';
import '../../../core/network/blob_uploader.dart';
import '../../../core/network/paged_result.dart';
import '../../listings/data/listing_repository.dart';
import '../domain/auction.dart';

/// Bộ lọc danh sách phiên công khai (`GET /auctions`).
typedef AuctionListFilter = ({AuctionStatus? status, String? q});

/// Đấu giá (`11-auctions`, `13-auctions-live-delivery`). Đăng ký, trả giá, mua
/// ngay tạo tiền giữ nên bắt buộc `Idempotency-Key`: sinh một lần cho mỗi thao
/// tác của người dùng, gửi lại đúng key khi thử lại do lỗi mạng.
class AuctionRepository {
  AuctionRepository(this._api, [this._uploader]);

  final ApiClient _api;
  final BlobUploader? _uploader;

  PagedResult<T> _paged<T>(
    dynamic data,
    Map<dynamic, dynamic> meta,
    T Function(dynamic) parse, {
    required int page,
    required int pageSize,
  }) => PagedResult(
    items: [for (final j in data as List) parse(j)],
    page: page,
    pageSize: pageSize,
    totalCount: (meta['totalItems'] as num?)?.toInt(),
  );

  // ── Xem ────────────────────────────────────────────────────────────────

  /// Bỏ [AuctionListFilter.status] để lấy nhóm mặc định của server (mở đăng ký,
  /// đã xác nhận, đang diễn ra, đã bán).
  Future<PagedResult<AuctionSummary>> list({
    AuctionListFilter filter = (status: null, q: null),
    String? sort,
    required int page,
    required int pageSize,
  }) => _api.getWithMeta(
    '/auctions',
    query: {
      'status': ?filter.status?.api,
      'q': ?(filter.q?.trim().isEmpty ?? true ? null : filter.q!.trim()),
      'sort': ?sort,
      'page': page,
      'pageSize': pageSize,
    },
    parse: (data, meta) => _paged(
      data,
      meta,
      AuctionSummary.fromJson,
      page: page,
      pageSize: pageSize,
    ),
  );

  Future<Auction> get(String id) =>
      _api.get('/auctions/$id', parse: Auction.fromJson);

  /// Lịch sử trả giá, mới nhất trước.
  Future<PagedResult<Bid>> bids(
    String id, {
    required int page,
    required int pageSize,
  }) => _api.getWithMeta(
    '/auctions/$id/bids',
    query: {'page': page, 'pageSize': pageSize},
    parse: (data, meta) =>
        _paged(data, meta, Bid.fromJson, page: page, pageSize: pageSize),
  );

  Future<PagedResult<AuctionSummary>> mine({
    required AuctionRole role,
    required int page,
    required int pageSize,
  }) => _api.getWithMeta(
    '/me/auctions',
    query: {'role': role.api, 'page': page, 'pageSize': pageSize},
    parse: (data, meta) => _paged(
      data,
      meta,
      AuctionSummary.fromJson,
      page: page,
      pageSize: pageSize,
    ),
  );

  // ── Người chơi ─────────────────────────────────────────────────────────

  Future<Auction> register(String id, {required String idempotencyKey}) =>
      _api.post(
        '/auctions/$id/registration',
        headers: {'Idempotency-Key': idempotencyKey},
        parse: Auction.fromJson,
      );

  Future<Auction> unregister(String id) =>
      _api.delete('/auctions/$id/registration', parse: Auction.fromJson);

  Future<Auction> placeBid(
    String id, {
    required int amount,
    required String idempotencyKey,
  }) => _api.post(
    '/auctions/$id/bids',
    body: {'amount': amount},
    headers: {'Idempotency-Key': idempotencyKey},
    parse: Auction.fromJson,
  );

  Future<Auction> buyNow(String id, {required String idempotencyKey}) =>
      _api.post(
        '/auctions/$id/buy-now',
        headers: {'Idempotency-Key': idempotencyKey},
        parse: Auction.fromJson,
      );

  // ── Người bán ──────────────────────────────────────────────────────────

  /// Tải một ảnh lên container công khai, trả `blobName` để gửi khi tạo phiên.
  Future<String> uploadPhoto(NewPhoto photo) {
    final uploader = _uploader;
    if (uploader == null) {
      throw StateError('AuctionRepository không có BlobUploader');
    }
    return uploader.upload(
      bytes: photo.bytes,
      fileName: photo.fileName,
      contentType: photo.contentType,
    );
  }

  Future<Auction> create(CreateAuctionInput input) =>
      _api.post('/auctions', body: input.toJson(), parse: Auction.fromJson);

  Future<Auction> cancel(String id, {String? reason}) => _api.post(
    '/auctions/$id/cancel',
    body: {'reason': ?(reason?.trim().isEmpty ?? true ? null : reason)},
    parse: Auction.fromJson,
  );

  Future<Auction> fallback(
    String id, {
    required FallbackChoice choice,
    DateTime? startAt,
    int? price,
  }) => _api.post(
    '/auctions/$id/fallback',
    body: {
      'choice': choice.api,
      'startAt': ?startAt?.toUtc().toIso8601String(),
      'price': ?price,
    },
    parse: Auction.fromJson,
  );
}
