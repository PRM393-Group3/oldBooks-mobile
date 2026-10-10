import 'dart:math';

import 'package:books_marketplace_mobile/core/util/clock.dart';
import 'package:books_marketplace_mobile/features/auctions/domain/auction.dart';
import 'package:books_marketplace_mobile/features/cart/domain/cart_item.dart';
import 'package:books_marketplace_mobile/features/orders/domain/order.dart';
import 'package:books_marketplace_mobile/features/sim/application/sim_controller.dart';
import 'package:books_marketplace_mobile/features/sim/application/sim_state.dart';
import 'package:books_marketplace_mobile/features/wallet/domain/wallet_txn.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Random xác định: `nextDouble` luôn nhỏ (đối thủ luôn trả giá) và `nextInt`
/// luôn 0 (chọn đối thủ đầu tiên).
class _AlwaysRandom implements Random {
  @override
  bool nextBool() => true;
  @override
  double nextDouble() => 0;
  @override
  int nextInt(int max) => 0;
}

class _Env {
  _Env({bool rivals = false}) {
    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(() => now),
        simulateRivalsProvider.overrideWithValue(rivals),
        randomProvider.overrideWithValue(rivals ? _AlwaysRandom() : Random(1)),
      ],
    );
    // Dựng kho ngay để dữ liệu mẫu tính từ giờ ban đầu, không phải giờ đã tua.
    container.read(simProvider);
  }

  // 2026-10-05 là thứ Hai.
  DateTime now = DateTime(2026, 10, 5, 10);
  late final ProviderContainer container;

  SimController get sim => container.read(simProvider.notifier);
  SimState get s => container.read(simProvider);
  void advance(Duration d) {
    now = now.add(d);
    sim.tick();
  }

  Order order(String id) => s.orders.firstWhere((o) => o.id == id);
  Auction auction(String id) => s.auctions.firstWhere((a) => a.id == id);
}

const _book = CartItem(
  listingId: 'L1',
  title: 'Sapiens',
  price: 95000,
  sellerName: 'Quang Huy',
);

void main() {
  late _Env env;
  setUp(() => env = _Env());
  tearDown(() => env.container.dispose());

  group('đặt hàng', () {
    test('trừ ví, giữ tiền, tạo đơn và khóa tin', () {
      final before = env.s;
      final outcome = env.sim.placeOrder([_book]);

      expect(outcome, isA<SimOk>());
      expect(env.s.available, before.available - 120000);
      expect(env.s.held, before.held + 120000);
      expect(env.s.orders.first.status, OrderStatus.paidAwaitingShipment);
      expect(env.s.orders.first.total, 120000);
      expect(env.s.reservedListingIds, {'L1'});
      expect(env.s.txns.first.type, TxnType.hold);
      expect(env.s.txns.first.amount, -120000);
    });

    test('thiếu tiền thì báo số còn thiếu và không đổi gì', () {
      env.sim.withdraw(1250000 - 100000); // còn 100.000 khả dụng
      final before = env.s;
      final outcome = env.sim.placeOrder([_book]);

      expect(outcome, isA<SimInsufficient>());
      expect((outcome as SimInsufficient).needed, 20000);
      expect(env.s.orders.length, before.orders.length);
      expect(env.s.available, before.available);
    });

    test('tin đã có người đặt thì bị bỏ qua, hết món thì từ chối', () {
      env.sim.placeOrder([_book]);
      final outcome = env.sim.placeOrder([_book]);
      expect(outcome, isA<SimRejected>());
      expect((outcome as SimRejected).reason, SimRejectReason.noBooksAvailable);
    });

    test('hủy đơn hoàn đủ tiền và mở lại tin', () {
      final start = env.s.available;
      env.sim.placeOrder([_book]);
      final id = env.s.orders.first.id;

      expect(env.sim.cancelOrder(id), isA<SimOk>());
      expect(env.s.available, start);
      expect(env.order(id).status, OrderStatus.cancelledByBuyer);
      expect(env.s.reservedListingIds, isEmpty);
      expect(env.s.txns.first.type, TxnType.release);
    });

    test('không hủy được khi người bán đã gửi', () {
      env.sim.placeOrder([_book]);
      final id = env.s.orders.first.id;
      env.sim.simSellerShip(id);
      expect(env.sim.cancelOrder(id), isA<SimRejected>());
    });
  });

  group('vòng đời đơn bán thường', () {
    String placeAndShip() {
      env.sim.placeOrder([_book]);
      final id = env.s.orders.first.id;
      env.sim.simSellerShip(id);
      env.sim.markReceived(id);
      return id;
    }

    test('nhận hàng rồi hoàn tất: chốt từ tiền giữ, không đổi khả dụng', () {
      final id = placeAndShip();
      final availableBefore = env.s.available;
      final heldBefore = env.s.held;

      expect(env.sim.completeOrder(id), isA<SimOk>());
      expect(env.order(id).status, OrderStatus.completed);
      expect(env.s.available, availableBefore);
      expect(env.s.held, heldBefore - 120000);
      expect(env.s.txns.first.type, TxnType.capture);
      expect(env.s.txns.first.captured, 120000);
    });

    test('đánh giá chỉ khi đã hoàn tất', () {
      final id = placeAndShip();
      expect(env.sim.rate(id, 5), isA<SimRejected>());
      env.sim.completeOrder(id);
      expect(env.sim.rate(id, 5), isA<SimOk>());
      expect(env.order(id).stars, 5);
    });

    test('quá hạn người bán gửi thì tự hủy và hoàn tiền', () {
      env.sim.placeOrder([_book]);
      final id = env.s.orders.first.id;

      env.advance(const Duration(days: 1));
      expect(env.order(id).status, OrderStatus.paidAwaitingShipment);

      env.advance(const Duration(days: 3)); // thứ Hai + 2 ngày làm việc đã qua
      expect(env.order(id).status, OrderStatus.cancelledByBuyer);
      final refund = env.s.txns.firstWhere(
        (t) => t.reason == TxnReason.releaseOrderCancelled,
      );
      expect(refund.amount, 120000);
      expect(refund.arg, id);
      expect(env.s.reservedListingIds, isEmpty);
    });

    test('hết cửa sổ khiếu nại thì tự hoàn tất', () {
      final id = placeAndShip();
      env.advance(const Duration(days: 2));
      expect(env.order(id).status, OrderStatus.delivered);
      env.advance(const Duration(days: 2));
      expect(env.order(id).status, OrderStatus.completed);
    });
  });

  group('khiếu nại', () {
    String delivered() {
      env.sim.placeOrder([_book]);
      final id = env.s.orders.first.id;
      env.sim.simSellerShip(id);
      env.sim.markReceived(id);
      return id;
    }

    test('chỉ mở được khi đã nhận sách', () {
      env.sim.placeOrder([_book]);
      final id = env.s.orders.first.id;
      expect(
        env.sim.openComplaint(id, ComplaintReason.damaged),
        isA<SimRejected>(),
      );
    });

    test('người bán đề xuất, người mua chấp nhận: hoàn một phần', () {
      final id = delivered();
      final availableBefore = env.s.available;
      final heldBefore = env.s.held;
      env.sim.openComplaint(id, ComplaintReason.damaged);
      expect(env.order(id).status, OrderStatus.disputed);
      expect(env.order(id).complaint!.status, ComplaintStatus.open);

      env.sim.simSellerOffer(id);
      expect(env.order(id).complaint!.offer, 47500); // 50% tiền sách

      env.sim.acceptOffer(id);
      expect(env.order(id).status, OrderStatus.partiallyRefunded);
      expect(env.s.available, availableBefore + 47500);
      expect(env.s.held, heldBefore - 120000);
    });

    test('từ chối thì chuyển Oldbook, admin phán hoàn 100%', () {
      final id = delivered();
      final availableBefore = env.s.available;
      env.sim.openComplaint(id, ComplaintReason.wrongItem);
      env.sim.simSellerOffer(id);
      env.sim.escalateComplaint(id);
      expect(env.order(id).complaint!.status, ComplaintStatus.escalated);

      env.sim.simAdminResolve(id);
      expect(env.order(id).status, OrderStatus.refunded);
      expect(env.s.available, availableBefore + 120000);
    });

    test('khiếu nại đơn đấu giá chuyển thẳng cho Oldbook', () {
      env.sim.simDeliverySucceeded('AU-1043');
      env.sim.openComplaint('AU-1043', ComplaintReason.notAsDescribed);
      expect(env.order('AU-1043').complaint!.status, ComplaintStatus.escalated);
    });
  });

  group('giao đơn đấu giá', () {
    test('giao thất bại 4 lần tăng lần giao, lần 5 vào lưu kho', () {
      // Seed: AU-1043 đang ở lần giao 2.
      env.sim.simDeliveryFailed('AU-1043');
      expect(env.order('AU-1043').attempt, 3);
      env.sim.simDeliveryFailed('AU-1043');
      expect(env.order('AU-1043').attempt, 4);
      env.sim.simDeliveryFailed('AU-1043');
      expect(env.order('AU-1043').status, OrderStatus.inStorage);
      expect(env.order('AU-1043').attempt, 5);
    });

    test('lưu kho: giao lại tốn thêm phí ship và đặt lại lần giao', () {
      for (var i = 0; i < 3; i++) {
        env.sim.simDeliveryFailed('AU-1043');
      }
      final availableBefore = env.s.available;
      expect(env.sim.redeliver('AU-1043'), isA<SimOk>());
      expect(env.order('AU-1043').status, OrderStatus.inDelivery);
      expect(env.order('AU-1043').attempt, 1);
      expect(env.order('AU-1043').ship, 60000);
      expect(env.s.available, availableBefore - 30000);
    });

    test('hoàn tất đơn đấu giá hoàn cọc về ví', () {
      env.sim.simDeliverySucceeded('AU-1043');
      final availableBefore = env.s.available;
      env.sim.completeOrder('AU-1043');
      expect(env.s.available, availableBefore + 30000);
      expect(env.s.txns.first.reason, TxnReason.releaseAuctionDeposit);
    });
  });

  group('ví', () {
    test('nạp tiền cộng khả dụng, ghi giao dịch và thông báo', () {
      final before = env.s;
      env.sim.topUp(200000);
      expect(env.s.available, before.available + 200000);
      expect(env.s.txns.first.type, TxnType.topup);
      expect(env.s.notifications.length, before.notifications.length + 1);
      expect(env.s.toast!.kind, SimToastKind.topupOk);
    });

    test(
      'rút tiền: tối thiểu 50.000, không quá khả dụng, chuyển sang đang giữ',
      () {
        expect(env.sim.withdraw(49999), isA<SimRejected>());
        expect(env.sim.withdraw(env.s.available + 1), isA<SimRejected>());
        final before = env.s;
        expect(env.sim.withdraw(100000), isA<SimOk>());
        expect(env.s.available, before.available - 100000);
        expect(env.s.held, before.held + 100000);
      },
    );
  });

  group('đấu giá', () {
    test('đăng ký giữ phí cộng cọc; thiếu tiền thì báo', () {
      final before = env.s;
      expect(env.sim.registerForAuction('a3'), isA<SimOk>());
      expect(env.s.available, before.available - 40000);
      expect(env.s.held, before.held + 40000);
      expect(env.auction('a3').registered, isTrue);
      expect(env.auction('a3').participants, 3);

      env.sim.withdraw(env.s.available - 10000);
      final outcome = env.sim.registerForAuction('a6');
      expect(outcome, isA<SimInsufficient>());
    });

    test('hủy đăng ký hoàn đủ', () {
      env.sim.registerForAuction('a3');
      final afterRegister = env.s.available;
      env.sim.unregisterFromAuction('a3');
      expect(env.s.available, afterRegister + 40000);
      expect(env.auction('a3').registered, isFalse);
    });

    test('trả giá phải đạt giá tối thiểu và giữ đúng số tiền', () {
      // a1: đang 280.000, bước 10.000, đang do đối thủ dẫn đầu.
      expect(env.auction('a1').minBid, 290000);
      expect(env.sim.placeBid('a1', 285000), isA<SimRejected>());

      final before = env.s;
      expect(env.sim.placeBid('a1', 300000), isA<SimOk>());
      expect(env.auction('a1').iAmLeading, isTrue);
      expect(env.auction('a1').current, 300000);
      expect(env.auction('a1').myHold, 300000);
      expect(env.s.available, before.available - 300000);
      expect(env.s.held, before.held + 300000);
    });

    test('đang dẫn đầu thì không trả giá tiếp', () {
      env.sim.placeBid('a1', 300000);
      expect(env.sim.placeBid('a1', 320000), isA<SimRejected>());
    });

    test('trả giá trong 2 phút cuối gia hạn phiên thêm 2 phút', () {
      env.advance(const Duration(minutes: 5, seconds: 30)); // còn 50 giây
      final a = env.auction('a1');
      expect(a.endsAt!.difference(env.now).inSeconds, lessThan(120));

      env.sim.placeBid('a1', 300000);
      expect(env.auction('a1').endsAt, env.now.add(const Duration(minutes: 2)));
      expect(env.auction('a1').extendedAt, env.now);
    });

    test('mua ngay chuyển sang đếm ngược 30 phút, hạn cứng 24 giờ', () {
      expect(env.auction('a1').buyNowAvailable, isTrue);
      env.sim.placeBid('a1', 450000, buyNow: true);
      final a = env.auction('a1');
      expect(a.status, AuctionStatus.buyNowCountdown);
      expect(a.countdownEndsAt, env.now.add(const Duration(minutes: 30)));
      expect(a.hardEndsAt, env.now.add(const Duration(hours: 24)));
      expect(a.buyNowAvailable, isFalse);
    });

    test('mua ngay chỉ đúng giá mua ngay', () {
      expect(env.sim.placeBid('a1', 400000, buyNow: true), isA<SimRejected>());
    });

    test('phiên đã kết thúc thì từ chối trả giá', () {
      env.advance(const Duration(minutes: 10));
      expect(env.auction('a1').status.isEnded, isTrue);
      final outcome = env.sim.placeBid('a1', 400000);
      expect((outcome as SimRejected).reason, SimRejectReason.auctionEnded);
    });

    test('thắng phiên: tạo đơn giao hàng, thu phí ship, nhả tiền trả giá', () {
      env.sim.placeBid('a1', 300000);
      final ordersBefore = env.s.orders.length;
      env.advance(const Duration(minutes: 10));

      final a = env.auction('a1');
      expect(a.status, AuctionStatus.endedSold);
      expect(a.won, isTrue);
      expect(env.s.orders.length, ordersBefore + 1);
      final won = env.s.orders.first;
      expect(won.type, OrderType.auction);
      expect(won.status, OrderStatus.readyToShip);
      expect(won.price, 300000);
      expect(won.ship, 30000);
      expect(won.deposit, a.deposit);
      expect(env.s.toast!.kind, SimToastKind.auctionWon);
    });

    test('thua phiên: cọc về ví', () {
      // Đối thủ đang dẫn đầu a1, mình đã đăng ký.
      final before = env.s;
      env.advance(const Duration(minutes: 10));
      expect(env.auction('a1').won, isFalse);
      expect(env.s.available, before.available + env.auction('a1').deposit);
    });

    test('phiên Đã đủ người tự chạy khi tới giờ', () {
      expect(env.auction('a4').status, AuctionStatus.confirmed);
      env.advance(const Duration(hours: 5));
      expect(env.auction('a4').status, AuctionStatus.live);
    });
  });

  group('đối thủ ảo', () {
    test('trả giá vượt mình, nhả tiền giữ và báo vượt giá', () {
      final e = _Env(rivals: true);
      addTearDown(e.container.dispose);
      e.sim.placeBid('a1', 300000);
      final availableAfterBid = e.s.available;

      e.advance(const Duration(seconds: 1));

      final a = e.auction('a1');
      expect(a.iAmLeading, isFalse);
      expect(a.current, 310000);
      expect(a.myHold, 0);
      expect(e.s.available, availableAfterBid + 300000);
      expect(e.s.toast!.kind, SimToastKind.outbid);
      expect(e.s.notifications.first.amount, 310000);
    });
  });
}
