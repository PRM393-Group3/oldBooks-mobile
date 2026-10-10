import 'package:books_marketplace_mobile/features/orders/domain/order.dart';
import 'package:books_marketplace_mobile/features/orders/domain/order_timeline.dart';
import 'package:books_marketplace_mobile/features/sim/domain/rules.dart';
import 'package:flutter_test/flutter_test.dart';

Order _order(OrderStatus status, {OrderType type = OrderType.sale}) => Order(
  id: 'X',
  type: type,
  title: 'T',
  seller: 'S',
  price: 100000,
  ship: 25000,
  status: status,
  placedAt: DateTime(2026, 10, 5),
);

void main() {
  group('phí và cọc đấu giá', () {
    test('phí 2% giá khởi điểm, kẹp 10.000 đến 100.000', () {
      expect(auctionRegistrationFee(200000), 10000); // 2% = 4.000 → sàn
      expect(auctionRegistrationFee(600000), 12000);
      expect(auctionRegistrationFee(1000000), 20000);
      expect(auctionRegistrationFee(50000000), 100000); // trần
    });

    test('cọc 10%, tạm giữ là phí cộng cọc', () {
      expect(auctionDeposit(300000), 30000);
      expect(auctionRegistrationHold(300000), 40000);
      expect(auctionRegistrationHold(1000000), 120000);
    });
  });

  group('ngày làm việc', () {
    test('bỏ thứ Bảy và Chủ nhật', () {
      // 2026-10-02 là thứ Sáu.
      final friday = DateTime(2026, 10, 2, 9);
      expect(friday.weekday, DateTime.friday);
      expect(addWorkDays(friday, 2), DateTime(2026, 10, 6, 9)); // thứ Ba
      expect(addWorkDays(friday, 1), DateTime(2026, 10, 5, 9)); // thứ Hai
      expect(addWorkDays(friday, 0), friday);
    });

    test('hạn gửi hàng 2 ngày làm việc, hạn khiếu nại 3 ngày', () {
      final placed = DateTime(2026, 10, 5, 8); // thứ Hai
      expect(sellerShipDeadline(placed), DateTime(2026, 10, 7, 8));
      expect(
        complaintDeadline(DateTime(2026, 10, 5, 8)),
        DateTime(2026, 10, 8, 8),
      );
    });
  });

  group('chống bắn tỉa và đếm ngược mua ngay', () {
    final now = DateTime(2026, 10, 5, 12);

    test('trả giá trong 2 phút cuối thì gia hạn tới now + 2 phút', () {
      expect(
        extendedEnd(now, now.add(const Duration(seconds: 90))),
        now.add(const Duration(minutes: 2)),
      );
      expect(extendedEnd(now, now.add(const Duration(minutes: 5))), isNull);
      expect(extendedEnd(now, now.add(const Duration(minutes: 2))), isNull);
    });

    test('đặt lại đếm ngược 30 phút nhưng không quá hạn cứng', () {
      final far = now.add(const Duration(hours: 5));
      expect(
        resetBuyNowCountdown(now, far),
        now.add(const Duration(minutes: 30)),
      );
      final near = now.add(const Duration(minutes: 10));
      expect(resetBuyNowCountdown(now, near), near);
    });
  });

  group('dòng thời gian đơn', () {
    test('đơn bán thường đang vận chuyển: hai mốc đầu đã xong', () {
      final t = orderTimeline(_order(OrderStatus.shipped));
      expect(t.cancelled, isFalse);
      expect(t.steps.map((s) => s.done), [true, true, false, false]);
      expect(t.steps[1].isCurrent, isTrue);
      expect(t.steps[2].isNext, isTrue);
      expect(t.steps.first.step, OrderStep.saleOrdered);
    });

    test('đơn đấu giá dùng bộ mốc riêng', () {
      final t = orderTimeline(
        _order(OrderStatus.inDelivery, type: OrderType.auction),
      );
      expect(t.steps.first.step, OrderStep.auctionWon);
      expect(t.steps[1].isCurrent, isTrue);
    });

    test('đơn hủy chỉ giữ mốc đầu và không có mốc kế tiếp', () {
      final t = orderTimeline(_order(OrderStatus.cancelledByBuyer));
      expect(t.cancelled, isTrue);
      expect(t.steps.map((s) => s.done), [true, false, false, false]);
      expect(t.steps.any((s) => s.isNext), isFalse);
    });

    test('khiếu nại đứng ở mốc Đã giao, hoàn tiền ở mốc cuối', () {
      expect(
        orderTimeline(_order(OrderStatus.disputed)).steps[2].isCurrent,
        isTrue,
      );
      expect(
        orderTimeline(_order(OrderStatus.refunded)).steps[3].isCurrent,
        isTrue,
      );
      expect(
        orderTimeline(_order(OrderStatus.inStorage, type: OrderType.auction))
            .steps[1]
            .isCurrent,
        isTrue,
      );
    });
  });
}
