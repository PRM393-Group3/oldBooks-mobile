import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_notifier.dart';
import '../data/auction_order_repository.dart';
import '../domain/auction_order.dart';

final auctionOrderRepositoryProvider = Provider<AuctionOrderRepository>(
  (ref) => AuctionOrderRepository(ref.watch(apiClientProvider)),
);

/// Nhóm lọc trong danh sách đơn đấu giá.
enum AuctionOrderFilter {
  all,
  needsAction,
  shipping,
  finished;

  bool matches(AuctionOrder o) => switch (this) {
    all => true,
    needsAction =>
      o.status == AuctionOrderStatus.awaitingShippingFee ||
          o.status == AuctionOrderStatus.inStorage ||
          o.status == AuctionOrderStatus.storageExpired,
    shipping =>
      o.status == AuctionOrderStatus.readyToShip ||
          o.status == AuctionOrderStatus.inDelivery ||
          o.status == AuctionOrderStatus.delivered ||
          o.status == AuctionOrderStatus.pickedUp ||
          o.status == AuctionOrderStatus.disputed,
    finished => o.status.isFinished,
  };
}

class AuctionOrdersNotifier extends PagedNotifier<AuctionOrder> {
  AuctionOrdersNotifier(this.role);
  final OrderViewerRole role;

  @override
  Future<PagedResult<AuctionOrder>> fetchPage(int page) => ref
      .read(auctionOrderRepositoryProvider)
      .list(role: role, page: page, pageSize: PagedNotifier.pageSize);
}

final auctionOrdersProvider = AsyncNotifierProvider.autoDispose
    .family<AuctionOrdersNotifier, PagedState<AuctionOrder>, OrderViewerRole>(
      AuctionOrdersNotifier.new,
    );

/// Chi tiết một đơn; mọi thao tác trả về đơn mới và thay thẳng vào state.
class AuctionOrderController extends AsyncNotifier<AuctionOrder> {
  AuctionOrderController(this.orderId);
  final String orderId;

  AuctionOrderRepository get _repo => ref.read(auctionOrderRepositoryProvider);

  @override
  Future<AuctionOrder> build() => _repo.get(orderId);

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  AuctionOrder _set(AuctionOrder o) {
    state = AsyncData(o);
    ref.invalidate(auctionOrdersProvider);
    return o;
  }

  Future<AuctionOrder> setAddress(String addressId) async =>
      _set(await _repo.setAddress(orderId, addressId));

  Future<AuctionOrder> payShippingFee({required String idempotencyKey}) async =>
      _set(await _repo.payShippingFee(orderId, idempotencyKey: idempotencyKey));

  Future<AuctionOrder> storageChoice(
    CollectionChoice choice, {
    required String idempotencyKey,
  }) async => _set(
    await _repo.storageChoice(orderId, choice, idempotencyKey: idempotencyKey),
  );

  Future<AuctionOrder> postExpiry(
    PostExpiryAction action, {
    required String idempotencyKey,
  }) async => _set(
    await _repo.postExpiry(orderId, action, idempotencyKey: idempotencyKey),
  );
}

final auctionOrderProvider = AsyncNotifierProvider.autoDispose
    .family<AuctionOrderController, AuctionOrder, String>(
      AuctionOrderController.new,
    );
