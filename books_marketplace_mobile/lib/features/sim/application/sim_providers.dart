import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auctions/domain/auction.dart';
import '../../notifications/domain/sim_notification.dart';
import '../../orders/domain/order.dart';
import '../../wallet/domain/wallet_txn.dart';
import 'sim_controller.dart';

export 'sim_controller.dart'
    show
        SimController,
        randomProvider,
        simProvider,
        simTickIntervalProvider,
        simulateRivalsProvider;

/// Giờ của kho mô phỏng, cập nhật mỗi giây khi có `SimTicker` đang chạy.
final simNowProvider = Provider<DateTime>(
  (ref) => ref.watch(simProvider.select((s) => s.now)),
);

final availableBalanceProvider = Provider<int>(
  (ref) => ref.watch(simProvider.select((s) => s.available)),
);

final heldBalanceProvider = Provider<int>(
  (ref) => ref.watch(simProvider.select((s) => s.held)),
);

final walletTxnsProvider = Provider<List<WalletTxn>>(
  (ref) => ref.watch(simProvider.select((s) => s.txns)),
);

final ordersProvider = Provider<List<Order>>(
  (ref) => ref.watch(simProvider.select((s) => s.orders)),
);

/// Đơn theo mã; `null` nếu không có.
final orderProvider = Provider.family<Order?, String>((ref, id) {
  for (final o in ref.watch(ordersProvider)) {
    if (o.id == id) return o;
  }
  return null;
});

/// Số đơn còn phải theo dõi ("Đơn đang mua").
final openOrderCountProvider = Provider<int>(
  (ref) => ref.watch(ordersProvider).where((o) => o.status.isOpen).length,
);

final auctionsProvider = Provider<List<Auction>>(
  (ref) => ref.watch(simProvider.select((s) => s.auctions)),
);

final auctionProvider = Provider.family<Auction?, String>((ref, id) {
  for (final a in ref.watch(auctionsProvider)) {
    if (a.id == id) return a;
  }
  return null;
});

final simNotificationsProvider = Provider<List<SimNotification>>(
  (ref) => ref.watch(simProvider.select((s) => s.notifications)),
);

final simUnreadCountProvider = Provider<int>(
  (ref) => ref.watch(simNotificationsProvider).where((n) => !n.read).length,
);

/// Tin thật đã có người đặt mua trong phiên này.
final reservedListingIdsProvider = Provider<Set<String>>(
  (ref) => ref.watch(simProvider.select((s) => s.reservedListingIds)),
);
