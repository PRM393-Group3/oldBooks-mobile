import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cart_repository.dart';
import '../domain/cart_item.dart';

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => MockCartRepository(),
);

/// Giỏ hàng hiện tại. State là bản sao danh sách của repository để UI rebuild.
class CartNotifier extends Notifier<List<CartItem>> {
  CartRepository get _repo => ref.read(cartRepositoryProvider);

  @override
  List<CartItem> build() => _repo.items;

  /// `false` nếu sách đã có trong giỏ.
  bool add(CartItem item) {
    final added = _repo.add(item);
    state = _repo.items;
    return added;
  }

  void remove(String listingId) {
    _repo.remove(listingId);
    state = _repo.items;
  }

  /// Bỏ các món đã đặt mua khỏi giỏ.
  void removeAll(Iterable<String> listingIds) {
    final ids = listingIds.toSet();
    for (final id in ids) {
      _repo.remove(id);
    }
    state = _repo.items;
  }

  void clear() {
    _repo.clear();
    state = _repo.items;
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).length,
);

/// Sách `listingId` đã có trong giỏ chưa.
final inCartProvider = Provider.family<bool, String>(
  (ref, id) => ref.watch(cartProvider).any((i) => i.listingId == id),
);
