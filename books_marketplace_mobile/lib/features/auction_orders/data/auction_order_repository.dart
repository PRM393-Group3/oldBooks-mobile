import '../../../core/network/api_client.dart';
import '../../../core/network/paged_result.dart';
import '../domain/auction_order.dart';

/// Đơn của người thắng (`/auction-orders`). Các thao tác giữ tiền (phí ship,
/// chọn lưu kho, chọn sau hết hạn) bắt buộc `Idempotency-Key`.
class AuctionOrderRepository {
  AuctionOrderRepository(this._api);

  final ApiClient _api;

  Future<PagedResult<AuctionOrder>> list({
    OrderViewerRole role = OrderViewerRole.buyer,
    AuctionOrderStatus? status,
    required int page,
    required int pageSize,
  }) => _api.getWithMeta(
    '/auction-orders',
    query: {
      'role': role.api,
      'status': ?status?.api,
      'page': page,
      'pageSize': pageSize,
    },
    parse: (data, meta) => PagedResult(
      items: [for (final j in data as List) AuctionOrder.fromJson(j)],
      page: page,
      pageSize: pageSize,
      totalCount: (meta['totalItems'] as num?)?.toInt(),
    ),
  );

  Future<AuctionOrder> get(String id) =>
      _api.get('/auction-orders/$id', parse: AuctionOrder.fromJson);

  /// Chỉ khi sách chưa rời kho.
  Future<AuctionOrder> setAddress(String id, String addressId) => _api.put(
    '/auction-orders/$id/address',
    body: {'addressId': addressId},
    parse: AuctionOrder.fromJson,
  );

  Future<AuctionOrder> payShippingFee(
    String id, {
    required String idempotencyKey,
  }) => _api.post(
    '/auction-orders/$id/shipping-fee',
    headers: {'Idempotency-Key': idempotencyKey},
    parse: AuctionOrder.fromJson,
  );

  Future<AuctionOrder> storageChoice(
    String id,
    CollectionChoice choice, {
    required String idempotencyKey,
  }) => _api.post(
    '/auction-orders/$id/storage-choice',
    body: {'choice': choice.api},
    headers: {'Idempotency-Key': idempotencyKey},
    parse: AuctionOrder.fromJson,
  );

  Future<AuctionOrder> postExpiry(
    String id,
    PostExpiryAction action, {
    required String idempotencyKey,
  }) => _api.post(
    '/auction-orders/$id/post-expiry',
    body: {'action': action.api},
    headers: {'Idempotency-Key': idempotencyKey},
    parse: AuctionOrder.fromJson,
  );
}
