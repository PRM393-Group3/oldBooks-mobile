import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_notifier.dart';
import '../../auth/application/auth_controller.dart';
import '../data/order_repository.dart';
import '../domain/sale_order.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(apiClientProvider)),
);

/// Bộ lọc danh sách đơn. Record nên so sánh theo giá trị (khóa family).
typedef OrderFilter = ({OrderRole? role, SaleOrderStatus? status});

class SaleOrdersNotifier extends PagedNotifier<SaleOrder> {
  SaleOrdersNotifier(this.filter);
  final OrderFilter filter;

  @override
  Future<PagedResult<SaleOrder>> fetchPage(int page) => ref
      .read(orderRepositoryProvider)
      .list(
        role: filter.role,
        status: filter.status,
        page: page,
        pageSize: PagedNotifier.pageSize,
      );
}

final saleOrdersProvider = AsyncNotifierProvider.autoDispose
    .family<SaleOrdersNotifier, PagedState<SaleOrder>, OrderFilter>(
      SaleOrdersNotifier.new,
    );

final saleOrderProvider = FutureProvider.autoDispose.family<SaleOrder, String>(
  (ref, id) => ref.watch(orderRepositoryProvider).get(id),
);

/// Số đơn mua còn đang theo dõi, cho ô số liệu ở tab Tôi (từ `meta.totalItems`).
final openBuyOrderCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final authed = ref.watch(
    authControllerProvider.select((s) => s == AuthStatus.authenticated),
  );
  if (!authed) return 0;
  final repo = ref.watch(orderRepositoryProvider);
  var total = 0;
  for (final s in [
    SaleOrderStatus.paidAwaitingShipment,
    SaleOrderStatus.shipped,
    SaleOrderStatus.delivered,
    SaleOrderStatus.disputed,
  ]) {
    final page = await repo.list(
      role: OrderRole.buyer,
      status: s,
      page: 1,
      pageSize: 1,
    );
    total += page.totalCount ?? page.items.length;
  }
  return total;
});

/// Làm mới mọi danh sách đơn và số liệu sau khi đặt hoặc đổi trạng thái đơn.
void refreshOrders(WidgetRef ref, {String? orderId}) {
  ref.invalidate(saleOrdersProvider);
  ref.invalidate(openBuyOrderCountProvider);
  if (orderId != null) ref.invalidate(saleOrderProvider(orderId));
}
