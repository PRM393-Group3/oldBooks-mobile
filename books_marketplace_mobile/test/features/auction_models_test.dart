import 'package:books_marketplace_mobile/core/navigation/notification_router.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/core/preview/preview_auctions.dart';
import 'package:books_marketplace_mobile/core/util/idempotency.dart';
import 'package:books_marketplace_mobile/features/auction_orders/domain/auction_order.dart';
import 'package:books_marketplace_mobile/features/auctions/domain/auction.dart';
import 'package:books_marketplace_mobile/features/auctions/domain/auction_event.dart';
import 'package:books_marketplace_mobile/features/notifications/domain/app_notification.dart';
import 'package:flutter_test/flutter_test.dart';

AuctionLiveEvent _event({
  int sequence = 10,
  String name = AuctionEventName.bidPlaced,
  String status = 'LIVE',
  int? amount = 130000,
}) => AuctionLiveEvent.fromJson(name, {
  'auctionId': 'a1',
  'sequence': sequence,
  'serverTime': '2026-10-20T08:10:05Z',
  'status': status,
  'currentPrice': amount,
  'leader': 'Tr***g',
  'bidCount': 5,
  'endAt': '2026-10-20T09:02:00Z',
  'countdownEndAt': null,
  'hardEndAt': null,
  'buyNowAvailable': false,
  'minNextBid': 135000,
  'amount': amount,
  'bidder': 'Tr***g',
});

AppNotification _notif(String type, Map<String, dynamic> data) =>
    AppNotification.fromJson({
      'id': 'n1',
      'type': type,
      'title': 't',
      'body': 'b',
      'isRead': false,
      'data': data,
    });

void main() {
  group('parse', () {
    test('AuctionDto đủ trường live, owner, đăng ký', () {
      final a = Auction.fromJson(
        sampleAuctionJson(
          id: 'a1',
          title: 'X',
          status: 'BUY_NOW_COUNTDOWN',
          currentPrice: 900000,
          myRegistration: {'status': 'CONFIRMED'},
          live: {
            'countdownEndAt': '2026-10-20T08:40:00Z',
            'hardEndAt': '2026-10-21T08:10:00Z',
            'isLeading': false,
            'minNextBid': 920000,
            'sequence': 4,
            'auctionOrderId': null,
          },
        ),
      );
      expect(a.status, AuctionStatus.buyNowCountdown);
      expect(a.deadline, DateTime.utc(2026, 10, 20, 8, 40));
      expect(a.minNextBid, 920000);
      expect(a.isConfirmedBidder, isTrue);
      expect(a.canBid, isTrue);
      expect(a.isSeller, isFalse);
    });

    test('trạng thái và vai trò lạ không làm crash', () {
      final a = Auction.fromJson({'id': 'a', 'status': 'SOMETHING_NEW'});
      expect(a.status, AuctionStatus.unknown);
      expect(a.live, isNull);
      final o = AuctionOrder.fromJson({
        'id': 'o',
        'status': 'WHATEVER',
        'postExpiry': {'status': 'NEW_THING'},
      });
      expect(o.status, AuctionOrderStatus.unknown);
      expect(o.postExpiry!.status, PostExpiryStatus.unknown);
      expect(BidKind.fromApi('X'), BidKind.unknown);
    });

    test('chưa có lượt: mức tối thiểu là giá khởi điểm', () {
      final a = Auction.fromJson(
        sampleAuctionJson(
          id: 'a',
          title: 'X',
          status: 'LIVE',
          startPrice: 50000,
        ),
      );
      expect(a.minNextBid, 50000);
    });

    test('đơn: cần làm gì và hạn khiếu nại', () {
      final noAddress = AuctionOrder.fromJson(
        sampleAuctionOrderJson(id: 'o', status: 'AWAITING_SHIPPING_FEE'),
      );
      expect(noAddress.needsBuyerAction, isTrue);
      final delivered = AuctionOrder.fromJson(
        sampleAuctionOrderJson(
          id: 'o',
          status: 'DELIVERED',
          delivery: {'complaintWindowEndsAt': '2026-10-10T00:00:00Z'},
        ),
      );
      expect(delivered.canComplainAt(DateTime.utc(2026, 10, 9)), isTrue);
      expect(delivered.canComplainAt(DateTime.utc(2026, 10, 11)), isFalse);
      final seller = AuctionOrder.fromJson(
        sampleAuctionOrderJson(
          id: 'o',
          status: 'DELIVERED',
          viewerRole: 'SELLER',
        ),
      );
      expect(seller.canComplainAt(DateTime.utc(2026, 10, 9)), isFalse);
    });

    test('số lần gia hạn còn lại không âm', () {
      final pe = PostExpiry.fromJson({
        'status': 'AWAITING_DECISION',
        'extensionCount': 3,
        'extensionMaxTimes': 2,
      });
      expect(pe.extensionsLeft, 0);
    });
  });

  group('reduceLive', () {
    final base = Auction.fromJson(
      sampleAuctionJson(
        id: 'a1',
        title: 'X',
        status: 'LIVE',
        currentPrice: 125000,
        live: {'sequence': 9, 'isLeading': true, 'minNextBid': 130000},
      ),
    );

    test('bỏ qua sự kiện trùng hoặc cũ', () {
      expect(
        identical(reduceLive(base, _event(sequence: 9), lastSequence: 9), base),
        isTrue,
      );
      expect(
        identical(reduceLive(base, _event(sequence: 3), lastSequence: 9), base),
        isTrue,
      );
    });

    test('gộp trạng thái đầy đủ, giữ isLeading', () {
      final next = reduceLive(base, _event(sequence: 10), lastSequence: 9);
      expect(next.currentPrice, 130000);
      expect(next.minNextBid, 135000);
      expect(next.live!.sequence, 10);
      expect(next.live!.bidCount, 5);
      expect(next.live!.endAt, DateTime.utc(2026, 10, 20, 9, 2));
      expect(next.isLeading, isTrue, reason: 'payload không mang isLeading');
    });

    test('đổi trạng thái theo sự kiện', () {
      final next = reduceLive(
        base,
        _event(
          sequence: 11,
          name: AuctionEventName.ended,
          status: 'ENDED_SOLD',
        ),
        lastSequence: 9,
      );
      expect(next.status, AuctionStatus.endedSold);
    });
  });

  group('IdempotentAction', () {
    test('giữ key khi mất mạng, đổi key sau lỗi server hoặc thành công', () {
      final a = IdempotentAction();
      final k1 = a.key;
      expect(a.key, k1);
      a.settle(const ApiError.network());
      expect(a.key, k1);
      a.settle(const ApiError(status: 422, code: 'BID_TOO_LOW'));
      final k2 = a.key;
      expect(k2, isNot(k1));
      a.settle();
      expect(a.key, isNot(k2));
    });
  });

  group('notificationTarget', () {
    test('thông báo phiên mở chi tiết phiên', () {
      expect(
        notificationTarget(_notif('AUCTION_OUTBID', {'auctionId': 'a1'})),
        const NotificationTarget(['/auctions/a1']),
      );
    });

    test('thắng phiên: mở phiên rồi tới đơn', () {
      expect(
        notificationTarget(
          _notif('AUCTION_WON', {'auctionId': 'a1', 'auctionOrderId': 'o1'}),
        ),
        const NotificationTarget(['/auctions/a1', '/me/auction-orders/o1']),
      );
    });

    test('thông báo đơn đấu giá ưu tiên đơn, kể cả khi có orderId', () {
      expect(
        notificationTarget(
          _notif('AUCTION_IN_STORAGE', {
            'auctionOrderId': 'o1',
            'orderId': 'x',
            'auctionId': 'a1',
          }),
        ),
        const NotificationTarget(['/me/auction-orders/o1']),
      );
    });

    test('thông báo chỉ dành cho admin bị bỏ qua', () {
      final n = _notif('AUCTION_LIQUIDATION_NEEDS_ADMIN', {
        'auctionOrderId': 'o1',
      });
      expect(n.type.isAdminOnly, isTrue);
      expect(notificationTarget(n), isNull);
    });

    test('loại cũ giữ nguyên điều hướng', () {
      expect(
        notificationTarget(_notif('ORDER_SHIPPED', {'orderId': 'x'})),
        const NotificationTarget(['/me/orders/x']),
      );
      expect(
        notificationTarget(_notif('TOPUP_SUCCEEDED', {})),
        const NotificationTarget(['/wallet'], switchTab: true),
      );
    });
  });
}
