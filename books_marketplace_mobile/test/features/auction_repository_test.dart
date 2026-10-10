import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/core/preview/preview_auctions.dart';
import 'package:books_marketplace_mobile/features/auction_orders/data/auction_order_repository.dart';
import 'package:books_marketplace_mobile/features/auction_orders/domain/auction_order.dart';
import 'package:books_marketplace_mobile/features/auctions/data/auction_repository.dart';
import 'package:books_marketplace_mobile/features/auctions/domain/auction.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late List<RequestOptions> seen;

  ApiClient client(ResponseBody Function(RequestOptions) handler) {
    seen = [];
    final adapter = FakeAdapter((o) {
      seen.add(o);
      return handler(o);
    });
    return ApiClient(
      Dio(BaseOptions(baseUrl: 'http://x'))..httpClientAdapter = adapter,
    );
  }

  final auctionJson = sampleAuctionJson(
    id: 'a1',
    title: 'Truyện Kiều',
    status: 'LIVE',
    currentPrice: 120000,
    live: {'minNextBid': 125000, 'sequence': 9, 'isLeading': true},
  );

  group('AuctionRepository', () {
    test('trả giá: POST body amount, header Idempotency-Key', () async {
      final repo = AuctionRepository(
        client((o) => jsonResponse(201, okBody(auctionJson))),
      );
      final a = await repo.placeBid('a1', amount: 125000, idempotencyKey: 'k1');
      expect(seen.single.method, 'POST');
      expect(seen.single.path, '/auctions/a1/bids');
      expect(seen.single.data, {'amount': 125000});
      expect(seen.single.headers['Idempotency-Key'], 'k1');
      expect(a.live!.sequence, 9);
      expect(a.isLeading, isTrue);
    });

    test(
      'mua ngay và đăng ký gửi Idempotency-Key, hủy đăng ký là DELETE',
      () async {
        final repo = AuctionRepository(
          client((o) => jsonResponse(200, okBody(auctionJson))),
        );
        await repo.buyNow('a1', idempotencyKey: 'k2');
        await repo.register('a1', idempotencyKey: 'k3');
        await repo.unregister('a1');
        expect(seen[0].path, '/auctions/a1/buy-now');
        expect(seen[0].headers['Idempotency-Key'], 'k2');
        expect(seen[1].path, '/auctions/a1/registration');
        expect(seen[1].headers['Idempotency-Key'], 'k3');
        expect(seen[2].method, 'DELETE');
        expect(seen[2].path, '/auctions/a1/registration');
      },
    );

    test('phiên của tôi gửi role, đọc tổng từ meta.totalItems', () async {
      final repo = AuctionRepository(
        client(
          (o) => jsonResponse(200, {
            ...okBody([
              {'id': 'a1', 'title': 'X', 'status': 'LIVE', 'startPrice': 1},
            ]),
            'meta': {'totalItems': 7},
          }),
        ),
      );
      final page = await repo.mine(
        role: AuctionRole.leading,
        page: 1,
        pageSize: 20,
      );
      expect(seen.single.path, '/me/auctions');
      expect(seen.single.queryParameters['role'], 'LEADING');
      expect(page.totalCount, 7);
      expect(page.items.single.status, AuctionStatus.live);
    });

    test('BID_TOO_LOW: đọc details.min_amount', () async {
      final repo = AuctionRepository(
        client(
          (o) => jsonResponse(
            422,
            errorBody(
              'BID_TOO_LOW',
              details: [
                {'field': 'min_amount', 'message': '130000'},
              ],
            ),
          ),
        ),
      );
      try {
        await repo.placeBid('a1', amount: 125000, idempotencyKey: 'k');
        fail('phải ném lỗi');
      } on ApiError catch (e) {
        expect(e.code, ApiErrorCode.bidTooLow);
        expect(e.detailAmount('min_amount'), 130000);
      }
    });

    test('dời lịch gửi choice và startAt UTC', () async {
      final repo = AuctionRepository(
        client((o) => jsonResponse(200, okBody(auctionJson))),
      );
      await repo.fallback(
        'a1',
        choice: FallbackChoice.reschedule,
        startAt: DateTime.utc(2026, 11, 1, 13),
      );
      expect(seen.single.data, {
        'choice': 'RESCHEDULE',
        'startAt': '2026-11-01T13:00:00.000Z',
      });
    });
  });

  group('AuctionOrderRepository', () {
    final orderJson = sampleAuctionOrderJson(
      id: 'o1',
      status: 'IN_STORAGE',
      storage: {'feePerDay': 5000, 'feeAccrued': 10000},
    );

    test('phí ship: POST không body, có Idempotency-Key', () async {
      final repo = AuctionOrderRepository(
        client((o) => jsonResponse(200, okBody(orderJson))),
      );
      await repo.payShippingFee('o1', idempotencyKey: 'k1');
      expect(seen.single.path, '/auction-orders/o1/shipping-fee');
      expect(seen.single.headers['Idempotency-Key'], 'k1');
      expect(seen.single.data, isNull);
    });

    test('chọn lưu kho và sau hết hạn gửi đúng body', () async {
      final repo = AuctionOrderRepository(
        client((o) => jsonResponse(200, okBody(orderJson))),
      );
      await repo.storageChoice(
        'o1',
        CollectionChoice.redeliver,
        idempotencyKey: 'k2',
      );
      await repo.postExpiry(
        'o1',
        PostExpiryAction.extend,
        idempotencyKey: 'k3',
      );
      await repo.setAddress('o1', 'addr1');
      expect(seen[0].data, {'choice': 'REDELIVER'});
      expect(seen[0].headers['Idempotency-Key'], 'k2');
      expect(seen[1].path, '/auction-orders/o1/post-expiry');
      expect(seen[1].data, {'action': 'EXTEND'});
      expect(seen[2].method, 'PUT');
      expect(seen[2].data, {'addressId': 'addr1'});
    });

    test('danh sách mặc định role BUYER', () async {
      final repo = AuctionOrderRepository(
        client(
          (o) => jsonResponse(200, {
            ...okBody([orderJson]),
            'meta': {'totalItems': 1},
          }),
        ),
      );
      final page = await repo.list(page: 1, pageSize: 20);
      expect(seen.single.queryParameters['role'], 'BUYER');
      expect(page.items.single.status, AuctionOrderStatus.inStorage);
    });
  });
}
