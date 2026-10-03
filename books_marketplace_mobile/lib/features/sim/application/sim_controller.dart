import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/util/clock.dart';
import '../../auctions/domain/auction.dart';
import '../../cart/domain/cart_item.dart';
import '../../notifications/domain/sim_notification.dart';
import '../../orders/domain/order.dart';
import '../../wallet/domain/wallet_txn.dart';
import '../domain/rules.dart';
import 'sim_seed.dart';
import 'sim_state.dart';

/// Nguồn ngẫu nhiên của mô phỏng (đối thủ ảo, mã vận đơn). Test ghi đè bằng
/// `Random(seed)`.
final randomProvider = Provider<Random>((ref) => Random());

/// Nhịp đẩy đồng hồ của `SimTicker`. Test đặt rất dài để `pumpAndSettle` kết thúc.
final simTickIntervalProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 1),
);

/// Bật tắt đối thủ ảo tự trả giá. Test tắt để kết quả xác định.
final simulateRivalsProvider = Provider<bool>((ref) => true);

const _rivals = ['Tr***g', 'La***n', 'Ph***c', 'Ho***a', 'Qu***h', 'Kh***i'];

/// Kho dữ liệu mô phỏng cho ví, đơn hàng, đấu giá và thông báo. Mọi thao tác
/// trả về [SimOutcome]; thông báo nổi do [SimState.toast] phát ra.
class SimController extends Notifier<SimState> {
  DateTime get _now => ref.read(clockProvider)();
  Random get _rng => ref.read(randomProvider);

  @override
  SimState build() => seedSimState(_now);

  // ── Tiện ích nội bộ ──────────────────────────────────────────────────────

  SimState _withToast(
    SimState s,
    SimToastKind kind, {
    int? amount,
    String? text,
  }) {
    final id = s.toastSeq + 1;
    return s.copyWith(
      toastSeq: id,
      toast: SimToast(id: id, kind: kind, amount: amount, text: text),
    );
  }

  int _clamp(int v) => v < 0 ? 0 : v;

  Order? _order(String id) {
    for (final o in state.orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  Auction? _auction(String id) {
    for (final a in state.auctions) {
      if (a.id == id) return a;
    }
    return null;
  }

  SimState _putOrder(SimState s, Order o) =>
      s.copyWith(orders: [for (final x in s.orders) x.id == o.id ? o : x]);

  SimState _putAuction(SimState s, Auction a) =>
      s.copyWith(auctions: [for (final x in s.auctions) x.id == a.id ? a : x]);

  SimState _txn(
    SimState s,
    TxnType type,
    TxnReason reason,
    int amount, {
    String? arg,
    int? captured,
  }) => s.copyWith(
    txns: [
      WalletTxn(
        type: type,
        reason: reason,
        arg: arg,
        amount: amount,
        captured: captured,
        time: s.now,
      ),
      ...s.txns,
    ],
  );

  SimState _note(
    SimState s,
    SimNotificationKind kind, {
    String? arg,
    int? amount,
  }) => s.copyWith(
    notifications: [
      SimNotification(kind: kind, arg: arg, amount: amount, time: s.now),
      ...s.notifications,
    ],
  );

  String _tracking() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';
    return 'GHN${List.generate(7, (_) => chars[_rng.nextInt(chars.length)]).join()}';
  }

  SimOutcome _rejected(SimRejectReason r) => SimRejected(r);

  // ── Đồng hồ ──────────────────────────────────────────────────────────────

  /// Đẩy đồng hồ mô phỏng tới giờ hiện tại và xử lý mọi chuyển trạng thái theo
  /// thời gian: phiên bắt đầu và kết thúc, đối thủ ảo trả giá, đơn quá hạn.
  void tick() {
    final now = _now;
    var s = state.copyWith(now: now);

    final updated = <Auction>[];
    for (final a0 in s.auctions) {
      var a = a0;
      if (a.status == AuctionStatus.confirmed &&
          a.startsAt != null &&
          !now.isBefore(a.startsAt!)) {
        a = a.copyWith(
          status: AuctionStatus.live,
          endsAt: a.startsAt!.add(auctionRunDuration),
        );
        updated.add(a);
        continue;
      }
      if (!a.status.isRunning) {
        updated.add(a);
        continue;
      }
      final end = a.deadline;
      if (end != null && !now.isBefore(end)) {
        s = _endAuction(s, a, updated);
        continue;
      }
      if (ref.read(simulateRivalsProvider)) {
        final p = a.iAmLeading ? 0.07 : 0.02;
        if (_rng.nextDouble() < p) {
          final result = _rivalBid(s, a);
          s = result.$1;
          a = result.$2;
        }
      }
      updated.add(a);
    }
    s = s.copyWith(auctions: updated);

    s = _autoSettleOrders(s);
    state = s;
  }

  SimState _endAuction(SimState s, Auction a, List<Auction> out) {
    var ended = a.copyWith(
      status: a.hasBids ? AuctionStatus.endedSold : AuctionStatus.endedNoBid,
      endedAt: s.now,
    );
    if (a.iAmLeading) {
      ended = ended.copyWith(won: true, myHold: 0);
      final orderNo = 1044 + s.orders.length;
      final order = Order(
        id: 'AU-$orderNo',
        type: OrderType.auction,
        title: a.title,
        author: a.author,
        coverHue: a.coverHue,
        seller: 'Kho Oldbook',
        price: a.current,
        ship: shippingFeeAuction,
        status: OrderStatus.readyToShip,
        placedAt: s.now,
        deposit: a.deposit,
      );
      s = s.copyWith(
        held: _clamp(s.held - a.myHold + shippingFeeAuction),
        available: _clamp(s.available - shippingFeeAuction),
        orders: [order, ...s.orders],
      );
      s = _note(
        s,
        SimNotificationKind.auctionWon,
        arg: a.title,
        amount: a.current,
      );
      s = _withToast(
        s,
        SimToastKind.auctionWon,
        text: a.title,
        amount: a.current,
      );
    } else if (a.registered) {
      s = s.copyWith(
        available: s.available + a.deposit,
        held: _clamp(s.held - a.deposit),
      );
    }
    out.add(ended);
    return s;
  }

  (SimState, Auction) _rivalBid(SimState s, Auction a) {
    final amount = a.hasBids ? a.current + a.step : a.startingPrice;
    final pool = _rivals.where((r) => r != a.leaderName).toList();
    final who = pool[_rng.nextInt(pool.length)];

    var next = a.copyWith(
      current: amount,
      bids: [
        Bid(who: who, amount: amount, time: s.now),
        ...a.bids,
      ],
    );
    if (a.iAmLeading) {
      s = s.copyWith(
        available: s.available + a.myHold,
        held: _clamp(s.held - a.myHold),
      );
      next = next.copyWith(myHold: 0);
      s = _note(s, SimNotificationKind.outbid, arg: a.title, amount: amount);
      s = _withToast(s, SimToastKind.outbid, text: a.title, amount: amount);
    }
    return (s, _applyTiming(next, s.now));
  }

  /// Chống bắn tỉa (phiên thường) hoặc đặt lại đếm ngược (mua ngay).
  Auction _applyTiming(Auction a, DateTime now) {
    if (a.status == AuctionStatus.live && a.endsAt != null) {
      final end = extendedEnd(now, a.endsAt!);
      if (end != null) return a.copyWith(endsAt: end, extendedAt: now);
    }
    if (a.status == AuctionStatus.buyNowCountdown && a.hardEndsAt != null) {
      return a.copyWith(
        countdownEndsAt: resetBuyNowCountdown(now, a.hardEndsAt!),
      );
    }
    return a;
  }

  /// Quá hạn người bán gửi thì tự hủy hoàn tiền; hết cửa sổ khiếu nại thì tự
  /// hoàn tất.
  SimState _autoSettleOrders(SimState s) {
    for (final o in s.orders) {
      if (o.status == OrderStatus.paidAwaitingShipment &&
          s.now.isAfter(o.shipDeadline)) {
        s = _cancel(s, o, toast: false);
      } else if (o.status.isReceived &&
          o.complaintDeadlineAt != null &&
          s.now.isAfter(o.complaintDeadlineAt!)) {
        s = _complete(s, o, toast: false);
      }
    }
    return s;
  }

  // ── Đơn hàng ─────────────────────────────────────────────────────────────

  /// Đặt hàng cho các món trong giỏ; mỗi cuốn một đơn. Món đã bị đặt trước
  /// đó bị bỏ qua.
  SimOutcome placeOrder(List<CartItem> items) {
    final s = state;
    final ok = [
      for (final i in items)
        if (!s.reservedListingIds.contains(i.listingId)) i,
    ];
    if (ok.isEmpty) {
      state = _withToast(s, SimToastKind.noBooksAvailable);
      return _rejected(SimRejectReason.noBooksAvailable);
    }
    final total = ok.fold<int>(
      0,
      (t, i) => t + i.price + shippingFeeFixedPrice,
    );
    if (s.available < total) return SimInsufficient(total - s.available);

    final orders = <Order>[
      for (var i = 0; i < ok.length; i++)
        Order(
          id: 'OB-${24900 + s.orders.length + i}',
          type: OrderType.sale,
          listingId: ok[i].listingId,
          title: ok[i].title,
          author: ok[i].author,
          coverUrl: ok[i].coverUrl,
          seller: ok[i].sellerName ?? '',
          price: ok[i].price,
          ship: shippingFeeFixedPrice,
          status: OrderStatus.paidAwaitingShipment,
          placedAt: s.now,
        ),
    ];
    var next = s.copyWith(
      available: s.available - total,
      held: s.held + total,
      orders: [...orders, ...s.orders],
      reservedListingIds: {
        ...s.reservedListingIds,
        for (final i in ok) i.listingId,
      },
    );
    next = _txn(
      next,
      TxnType.hold,
      TxnReason.holdOrders,
      -total,
      arg: '${orders.length}',
    );
    state = next;
    return const SimOk();
  }

  SimState _cancel(SimState s, Order o, {bool toast = true}) {
    var next = s.copyWith(
      available: s.available + o.total,
      held: _clamp(s.held - o.total),
      reservedListingIds: {
        for (final id in s.reservedListingIds)
          if (id != o.listingId) id,
      },
    );
    next = _putOrder(next, o.copyWith(status: OrderStatus.cancelledByBuyer));
    next = _txn(
      next,
      TxnType.release,
      TxnReason.releaseOrderCancelled,
      o.total,
      arg: o.id,
    );
    return toast
        ? _withToast(next, SimToastKind.orderCancelled, amount: o.total)
        : next;
  }

  SimOutcome cancelOrder(String id) {
    final o = _order(id);
    if (o == null) return _rejected(SimRejectReason.notFound);
    if (o.status != OrderStatus.paidAwaitingShipment) {
      return _rejected(SimRejectReason.invalidState);
    }
    state = _cancel(state, o);
    return const SimOk();
  }

  SimOutcome _transition(
    String id,
    bool Function(Order o) allowed,
    Order Function(Order o, DateTime now) apply, {
    SimToastKind? toast,
    int? toastAmount,
  }) {
    final o = _order(id);
    if (o == null) return _rejected(SimRejectReason.notFound);
    if (!allowed(o)) return _rejected(SimRejectReason.invalidState);
    var s = _putOrder(state, apply(o, state.now));
    if (toast != null) s = _withToast(s, toast, amount: toastAmount);
    state = s;
    return const SimOk();
  }

  /// Mô phỏng: người bán nhập mã vận đơn.
  SimOutcome simSellerShip(String id) => _transition(
    id,
    (o) => o.status == OrderStatus.paidAwaitingShipment,
    (o, now) => o.copyWith(
      status: OrderStatus.shipped,
      shippedAt: now,
      carrier: 'GHN',
      tracking: _tracking(),
    ),
    toast: SimToastKind.sellerShipped,
  );

  SimOutcome markReceived(String id) => _transition(
    id,
    (o) => o.status == OrderStatus.shipped,
    (o, now) => o.copyWith(status: OrderStatus.delivered, deliveredAt: now),
  );

  /// Mô phỏng: kho Oldbook xuất hàng (đơn đấu giá).
  SimOutcome simWarehouseShip(String id) => _transition(
    id,
    (o) => o.status == OrderStatus.readyToShip,
    (o, now) => o.copyWith(
      status: OrderStatus.inDelivery,
      attempt: 1,
      shippedAt: now,
      carrier: 'GHN',
      tracking: _tracking(),
    ),
  );

  SimOutcome simDeliverySucceeded(String id) => _transition(
    id,
    (o) => o.status == OrderStatus.inDelivery,
    (o, now) => o.copyWith(status: OrderStatus.delivered, deliveredAt: now),
  );

  SimOutcome simDeliveryFailed(String id) {
    final o = _order(id);
    if (o == null) return _rejected(SimRejectReason.notFound);
    if (o.status != OrderStatus.inDelivery) {
      return _rejected(SimRejectReason.invalidState);
    }
    if (o.attempt >= maxDeliveryAttempts - 1) {
      state = _withToast(
        _putOrder(
          state,
          o.copyWith(
            status: OrderStatus.inStorage,
            attempt: maxDeliveryAttempts,
            storageAt: state.now,
          ),
        ),
        SimToastKind.movedToStorage,
      );
    } else {
      state = _withToast(
        _putOrder(state, o.copyWith(attempt: o.attempt + 1)),
        SimToastKind.deliveryFailed,
        amount: o.attempt,
      );
    }
    return const SimOk();
  }

  SimOutcome pickUpAtWarehouse(String id) => _transition(
    id,
    (o) => o.status == OrderStatus.inStorage,
    (o, now) => o.copyWith(status: OrderStatus.pickedUp, deliveredAt: now),
  );

  /// Giao lại sau khi sách vào lưu kho, trả thêm một lần phí ship đấu giá.
  SimOutcome redeliver(String id) {
    final o = _order(id);
    if (o == null) return _rejected(SimRejectReason.notFound);
    if (o.status != OrderStatus.inStorage) {
      return _rejected(SimRejectReason.invalidState);
    }
    final s = state;
    if (s.available < shippingFeeAuction) {
      return SimInsufficient(shippingFeeAuction - s.available);
    }
    var next = s.copyWith(
      available: s.available - shippingFeeAuction,
      held: s.held + shippingFeeAuction,
    );
    next = _putOrder(
      next,
      o.copyWith(
        status: OrderStatus.inDelivery,
        attempt: 1,
        ship: o.ship + shippingFeeAuction,
      ),
    );
    state = _txn(
      next,
      TxnType.hold,
      TxnReason.holdRedeliveryFee,
      -shippingFeeAuction,
      arg: o.id,
    );
    return const SimOk();
  }

  SimState _complete(SimState s, Order o, {bool toast = true}) {
    final captured = o.isAuction ? o.ship : o.total;
    var next = s.copyWith(held: _clamp(s.held - captured));
    next = _putOrder(
      next,
      o.copyWith(status: OrderStatus.completed, completedAt: s.now),
    );
    next = _txn(
      next,
      TxnType.capture,
      TxnReason.captureOrder,
      0,
      arg: o.id,
      captured: captured,
    );
    if (o.isAuction && o.deposit > 0) {
      next = next.copyWith(
        available: next.available + o.deposit,
        held: _clamp(next.held - o.deposit),
      );
      next = _txn(
        next,
        TxnType.release,
        TxnReason.releaseAuctionDeposit,
        o.deposit,
        arg: o.title,
      );
    }
    return toast ? _withToast(next, SimToastKind.orderCompleted) : next;
  }

  SimOutcome completeOrder(String id) {
    final o = _order(id);
    if (o == null) return _rejected(SimRejectReason.notFound);
    if (!o.status.isReceived) return _rejected(SimRejectReason.invalidState);
    state = _complete(state, o);
    return const SimOk();
  }

  SimOutcome rate(String id, int stars) {
    final o = _order(id);
    if (o == null) return _rejected(SimRejectReason.notFound);
    if (o.status != OrderStatus.completed || o.isAuction) {
      return _rejected(SimRejectReason.invalidState);
    }
    state = _withToast(
      _putOrder(state, o.copyWith(stars: stars.clamp(1, 5))),
      SimToastKind.rated,
      amount: stars,
    );
    return const SimOk();
  }

  // ── Khiếu nại ────────────────────────────────────────────────────────────

  SimOutcome openComplaint(String id, ComplaintReason reason) {
    final o = _order(id);
    if (o == null) return _rejected(SimRejectReason.notFound);
    if (!o.status.isReceived) return _rejected(SimRejectReason.invalidState);
    state = _withToast(
      _putOrder(
        state,
        o.copyWith(
          status: OrderStatus.disputed,
          complaint: Complaint(
            // Khiếu nại đấu giá chuyển thẳng cho Oldbook.
            status: o.isAuction
                ? ComplaintStatus.escalated
                : ComplaintStatus.open,
            reason: reason,
          ),
        ),
      ),
      SimToastKind.complaintOpened,
    );
    return const SimOk();
  }

  /// Mô phỏng: người bán đề xuất hoàn 50% tiền sách.
  SimOutcome simSellerOffer(String id) {
    final o = _order(id);
    final c = o?.complaint;
    if (o == null || c == null) return _rejected(SimRejectReason.notFound);
    if (c.status != ComplaintStatus.open) {
      return _rejected(SimRejectReason.invalidState);
    }
    state = _putOrder(
      state,
      o.copyWith(
        complaint: c.copyWith(
          status: ComplaintStatus.sellerResponded,
          offer: o.price ~/ 2,
        ),
      ),
    );
    return const SimOk();
  }

  SimOutcome acceptOffer(String id) {
    final o = _order(id);
    final c = o?.complaint;
    if (o == null || c == null) return _rejected(SimRejectReason.notFound);
    if (c.status != ComplaintStatus.sellerResponded || c.offer == null) {
      return _rejected(SimRejectReason.invalidState);
    }
    final offer = c.offer!;
    var s = state.copyWith(
      available: state.available + offer,
      held: _clamp(state.held - o.total),
    );
    s = _putOrder(
      s,
      o.copyWith(
        status: OrderStatus.partiallyRefunded,
        completedAt: s.now,
        complaint: c.copyWith(status: ComplaintStatus.agreed),
      ),
    );
    s = _txn(s, TxnType.refund, TxnReason.refundAgreement, offer, arg: o.id);
    state = _withToast(s, SimToastKind.offerAccepted, amount: offer);
    return const SimOk();
  }

  SimOutcome escalateComplaint(String id) {
    final o = _order(id);
    final c = o?.complaint;
    if (o == null || c == null) return _rejected(SimRejectReason.notFound);
    if (c.status != ComplaintStatus.sellerResponded) {
      return _rejected(SimRejectReason.invalidState);
    }
    state = _putOrder(
      state,
      o.copyWith(complaint: c.copyWith(status: ComplaintStatus.escalated)),
    );
    return const SimOk();
  }

  /// Mô phỏng: admin phán hoàn 100%.
  SimOutcome simAdminResolve(String id) {
    final o = _order(id);
    final c = o?.complaint;
    if (o == null || c == null) return _rejected(SimRejectReason.notFound);
    if (c.status != ComplaintStatus.escalated) {
      return _rejected(SimRejectReason.invalidState);
    }
    var s = state.copyWith(
      available: state.available + o.total,
      held: _clamp(state.held - o.total),
    );
    s = _putOrder(
      s,
      o.copyWith(
        status: OrderStatus.refunded,
        completedAt: s.now,
        complaint: c.copyWith(status: ComplaintStatus.resolved),
      ),
    );
    state = _txn(
      s,
      TxnType.refund,
      TxnReason.refundVerdict,
      o.total,
      arg: o.id,
    );
    return const SimOk();
  }

  // ── Ví ───────────────────────────────────────────────────────────────────

  SimOutcome topUp(int amount) {
    if (amount <= 0) return _rejected(SimRejectReason.invalidAmount);
    var s = state.copyWith(available: state.available + amount);
    s = _txn(s, TxnType.topup, TxnReason.topupVietQr, amount);
    s = _note(s, SimNotificationKind.topupOk, amount: amount);
    state = _withToast(s, SimToastKind.topupOk, amount: amount);
    return const SimOk();
  }

  SimOutcome withdraw(int amount) {
    if (amount < minWithdrawal || amount > state.available) {
      return _rejected(SimRejectReason.invalidAmount);
    }
    var s = state.copyWith(
      available: state.available - amount,
      held: state.held + amount,
    );
    s = _txn(s, TxnType.withdraw, TxnReason.withdrawRequest, -amount);
    state = _withToast(s, SimToastKind.withdrawRequested, amount: amount);
    return const SimOk();
  }

  // ── Thông báo ────────────────────────────────────────────────────────────

  void markAllNotificationsRead() => state = state.copyWith(
    notifications: [for (final n in state.notifications) n.markRead()],
  );

  // ── Đấu giá ──────────────────────────────────────────────────────────────

  SimOutcome registerForAuction(String id) {
    final a = _auction(id);
    if (a == null) return _rejected(SimRejectReason.notFound);
    if (a.status != AuctionStatus.registrationOpen || a.registered) {
      return _rejected(SimRejectReason.invalidState);
    }
    final hold = a.registrationHold;
    final s = state;
    if (s.available < hold) return SimInsufficient(hold - s.available);
    var next = s.copyWith(available: s.available - hold, held: s.held + hold);
    next = _putAuction(
      next,
      a.copyWith(registered: true, participants: a.participants + 1),
    );
    next = _txn(
      next,
      TxnType.hold,
      TxnReason.holdAuctionRegistration,
      -hold,
      arg: a.title,
    );
    next = _note(
      next,
      SimNotificationKind.auctionRegistered,
      arg: a.title,
      amount: hold,
    );
    state = _withToast(next, SimToastKind.registered, amount: hold);
    return const SimOk();
  }

  SimOutcome unregisterFromAuction(String id) {
    final a = _auction(id);
    if (a == null) return _rejected(SimRejectReason.notFound);
    if (a.status != AuctionStatus.registrationOpen || !a.registered) {
      return _rejected(SimRejectReason.invalidState);
    }
    final hold = a.registrationHold;
    var next = state.copyWith(
      available: state.available + hold,
      held: _clamp(state.held - hold),
    );
    next = _putAuction(
      next,
      a.copyWith(registered: false, participants: a.participants - 1),
    );
    next = _txn(
      next,
      TxnType.release,
      TxnReason.releaseAuctionUnregistered,
      hold,
      arg: a.title,
    );
    state = _withToast(next, SimToastKind.unregistered, amount: hold);
    return const SimOk();
  }

  /// Trả giá thường, hoặc mua ngay khi [buyNow] (khi đó [amount] là giá mua ngay).
  SimOutcome placeBid(String id, int amount, {bool buyNow = false}) {
    final a = _auction(id);
    if (a == null) return _rejected(SimRejectReason.notFound);
    final s = state;
    final end = a.deadline;
    if (!a.status.isRunning || (end != null && !s.now.isBefore(end))) {
      return _rejected(SimRejectReason.auctionEnded);
    }
    if (!a.registered || a.iAmLeading) {
      return _rejected(SimRejectReason.invalidState);
    }
    if (buyNow) {
      if (!a.buyNowAvailable || amount != a.buyNow) {
        return _rejected(SimRejectReason.invalidState);
      }
    } else if (amount < a.minBid) {
      return _rejected(SimRejectReason.bidTooLow);
    }
    if (s.available < amount) return SimInsufficient(amount - s.available);

    var next = a.copyWith(
      current: amount,
      myHold: amount,
      bids: [
        Bid(who: '', amount: amount, time: s.now, mine: true),
        ...a.bids,
      ],
    );
    if (buyNow) {
      next = next.copyWith(
        status: AuctionStatus.buyNowCountdown,
        countdownEndsAt: s.now.add(buyNowCountdown),
        hardEndsAt: s.now.add(buyNowHardLimit),
      );
    } else {
      next = _applyTiming(next, s.now);
    }
    var out = s.copyWith(
      available: s.available - amount,
      held: s.held + amount,
    );
    out = _putAuction(out, next);
    out = _txn(
      out,
      TxnType.hold,
      buyNow ? TxnReason.holdBuyNow : TxnReason.holdBid,
      -amount,
      arg: a.title,
    );
    state = _withToast(
      out,
      buyNow ? SimToastKind.buyNowStarted : SimToastKind.leading,
      amount: amount,
    );
    return const SimOk();
  }
}

final simProvider = NotifierProvider<SimController, SimState>(
  SimController.new,
);
