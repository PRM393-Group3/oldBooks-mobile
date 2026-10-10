import '../../../core/network/api_client.dart';
import '../../../core/network/paged_result.dart';
import '../domain/sale_order.dart';

/// Giỏ hàng và đơn bán thường (`09-orders`). Đặt hàng là thao tác tạo tiền nên
/// bắt buộc `Idempotency-Key`.
class OrderRepository {
  OrderRepository(this._api);

  final ApiClient _api;

  // ── Giỏ hàng ────────────────────────────────────────────────────────────

  Future<CartData> cart() => _api.get('/cart', parse: CartData.fromJson);

  /// Thêm trùng thì không đổi gì (vẫn trả giỏ).
  Future<CartData> addToCart(String listingId) => _api.post(
    '/cart/items',
    body: {'listingId': listingId},
    parse: CartData.fromJson,
  );

  /// Không có trong giỏ cũng thành công.
  Future<void> removeFromCart(String listingId) =>
      _api.deleteNoContent('/cart/items/$listingId');

  // ── Đặt hàng ────────────────────────────────────────────────────────────

  /// Mỗi tin một đơn riêng; tất cả hoặc không gì cả. Gửi lại cùng
  /// [idempotencyKey] và cùng nội dung sẽ nhận đúng kết quả cũ.
  Future<List<SaleOrder>> checkout({
    required List<String> listingIds,
    required String addressId,
    required String idempotencyKey,
  }) => _api.post(
    '/orders',
    body: {'listingIds': listingIds, 'addressId': addressId},
    headers: {'Idempotency-Key': idempotencyKey},
    parse: (d) => [for (final j in d as List) SaleOrder.fromJson(j)],
  );

  // ── Xem đơn ─────────────────────────────────────────────────────────────

  /// Bỏ [role] để lấy cả đơn mua và đơn bán.
  Future<PagedResult<SaleOrder>> list({
    OrderRole? role,
    SaleOrderStatus? status,
    required int page,
    required int pageSize,
  }) => _api.getWithMeta(
    '/orders',
    query: {
      'role': ?role?.api,
      'status': ?status?.api,
      'page': page,
      'pageSize': pageSize,
    },
    parse: (data, meta) => PagedResult(
      items: [for (final j in data as List) SaleOrder.fromJson(j)],
      page: page,
      pageSize: pageSize,
      totalCount: (meta['totalItems'] as num?)?.toInt(),
    ),
  );

  Future<SaleOrder> get(String id) =>
      _api.get('/orders/$id', parse: SaleOrder.fromJson);

  // ── Người mua ───────────────────────────────────────────────────────────

  Future<SaleOrder> cancel(String id) => _post(id, 'cancel');

  /// `SHIPPED` sang `DELIVERED`, bắt đầu cửa sổ khiếu nại.
  Future<SaleOrder> confirmReceived(String id) => _post(id, 'received');

  /// "Hài lòng": hoàn tất ngay, người bán được thanh toán.
  Future<SaleOrder> complete(String id) => _post(id, 'complete');

  // ── Người bán ───────────────────────────────────────────────────────────

  Future<SaleOrder> ship(
    String id, {
    required String carrier,
    required String trackingNumber,
  }) => _api.post(
    '/orders/$id/ship',
    body: {'carrier': carrier.trim(), 'trackingNumber': trackingNumber.trim()},
    parse: SaleOrder.fromJson,
  );

  Future<SaleOrder> _post(String id, String action) => _api.post(
    '/orders/$id/$action',
    body: const <String, dynamic>{},
    parse: SaleOrder.fromJson,
  );
}
