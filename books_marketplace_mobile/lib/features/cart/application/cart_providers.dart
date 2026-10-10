import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../orders/application/order_providers.dart';
import '../../orders/domain/sale_order.dart';

/// Giỏ hàng lưu ở server, dùng chung giữa các thiết bị. Thao tác ghi ném
/// `ApiError` (`LISTING_NOT_AVAILABLE`, `CART_OWN_LISTING`, `CART_FULL`) để màn
/// hình hiển thị; state chỉ đổi khi server xác nhận.
class CartNotifier extends AsyncNotifier<CartData> {
  @override
  Future<CartData> build() {
    final authed = ref.watch(
      authControllerProvider.select((s) => s == AuthStatus.authenticated),
    );
    if (!authed) return Future.value(const CartData());
    return ref.read(orderRepositoryProvider).cart();
  }

  Future<void> add(String listingId) async {
    state = AsyncData(
      await ref.read(orderRepositoryProvider).addToCart(listingId),
    );
  }

  Future<void> remove(String listingId) async {
    final repo = ref.read(orderRepositoryProvider);
    await repo.removeFromCart(listingId);
    state = AsyncData(await repo.cart());
  }

  Future<void> reload() async {
    state = await AsyncValue.guard(
      () => ref.read(orderRepositoryProvider).cart(),
    );
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, CartData>(
  CartNotifier.new,
);

final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).value?.items.length ?? 0,
);

/// Sách `listingId` đã có trong giỏ chưa.
final inCartProvider = Provider.family<bool, String>(
  (ref, id) =>
      ref.watch(cartProvider).value?.items.any((i) => i.listingId == id) ??
      false,
);
