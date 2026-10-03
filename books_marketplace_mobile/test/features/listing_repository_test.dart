import 'dart:convert';

import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/features/listings/data/listing_repository.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_input.dart';
import 'package:books_marketplace_mobile/features/notifications/data/notification_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

const _listing = {'id': 'L1', 'status': 'Draft'};

void main() {
  late List<RequestOptions> seen;
  late ApiClient api;

  void setup(ResponseBody Function(RequestOptions) handler) {
    seen = [];
    final adapter = FakeAdapter((o) {
      seen.add(o);
      return handler(o);
    });
    api = ApiClient(
      Dio(BaseOptions(baseUrl: 'http://x'))..httpClientAdapter = adapter,
    );
  }

  group('ListingRepository', () {
    test('mine gửi status và phân trang, đọc danh sách', () async {
      setup(
        (o) => jsonResponse(
          200,
          okBody({
            'items': [_listing],
            'totalCount': 1,
          }),
        ),
      );
      final page = await ListingRepository(api)
          .mine(status: ListingStatus.rejected, page: 2, pageSize: 20);

      expect(seen.single.path, '/listings/mine');
      expect(seen.single.queryParameters, {
        'status': 'Rejected',
        'page': 2,
        'pageSize': 20,
      });
      expect(page.items.single.id, 'L1');
    });

    test('mine không gửi status khi lấy tất cả', () async {
      setup((o) => jsonResponse(200, okBody(<dynamic>[])));
      await ListingRepository(api).mine(page: 1, pageSize: 20);
      expect(seen.single.queryParameters.containsKey('status'), isFalse);
    });

    test('mineSummary đọc counts, bỏ trạng thái lạ', () async {
      setup(
        (o) => jsonResponse(
          200,
          okBody({
            'counts': {'Draft': 2, 'PendingInspection': 1, 'Bogus': 9},
          }),
        ),
      );
      final counts = await ListingRepository(api).mineSummary();
      expect(counts, {
        ListingStatus.draft: 2,
        ListingStatus.pendingInspection: 1,
      });
    });

    test('browse gửi categoryId', () async {
      setup((o) => jsonResponse(200, okBody(<dynamic>[])));
      await ListingRepository(api)
          .browse(categoryId: 'c9', page: 1, pageSize: 20);
      expect(seen.single.path, '/listings');
      expect(seen.single.queryParameters['categoryId'], 'c9');
    });

    test(
      'create, saveBookInfo, saveImages, saveSaleMethod đúng đường dẫn và body',
      () async {
        setup((o) => jsonResponse(200, okBody(_listing)));
        final repo = ListingRepository(api);

        await repo.create();
        await repo.saveBookInfo(
          'L1',
          const BookInfoInput(
            title: 'A',
            author: 'B',
            categoryId: 'c',
            condition: BookCondition.good,
            description: 'd',
          ),
        );
        await repo.saveImages('L1', [
          (blobName: 'u1/a.png', type: ImageType.frontCover),
          (blobName: 'u1/b.png', type: ImageType.innerPage),
        ]);
        await repo.saveSaleMethod(
          'L1',
          const FixedPriceInput(price: 120000, quantity: 2),
        );

        expect(seen.map((o) => '${o.method} ${o.path}').toList(), [
          'POST /listings',
          'PUT /listings/L1/book-info',
          'PUT /listings/L1/images',
          'PUT /listings/L1/sale-method',
        ]);
        expect(jsonDecode(jsonEncode(seen[2].data)), {
          'images': [
            {'blobName': 'u1/a.png', 'type': 'FrontCover'},
            {'blobName': 'u1/b.png', 'type': 'InnerPage'},
          ],
        });
        expect(seen[3].data, {
          'method': 'FixedPrice',
          'fixedPrice': {'price': 120000, 'quantity': 2},
        });
      },
    );

    test('submit đọc listing và estimatedProcessingHours', () async {
      setup(
        (o) => jsonResponse(
          200,
          okBody({
            'listing': {'id': 'L1', 'status': 'PendingInspection'},
            'estimatedProcessingHours': 24,
          }),
        ),
      );
      final r = await ListingRepository(api).submit('L1');
      expect(r.listing.status, ListingStatus.pendingInspection);
      expect(r.result.estimatedProcessingHours, 24);
    });

    test('delete chấp nhận 204', () async {
      setup((o) => ResponseBody.fromString('', 204));
      await ListingRepository(api).delete('L1');
      expect(seen.single.method, 'DELETE');
      expect(seen.single.path, '/listings/L1');
    });
  });

  group('NotificationRepository', () {
    test('list, unreadCount, markRead, markAllRead', () async {
      setup((o) {
        if (o.path == '/notifications/unread-count') {
          return jsonResponse(200, okBody({'count': 3}));
        }
        if (o.method == 'POST') return ResponseBody.fromString('', 204);
        return jsonResponse(
          200,
          okBody([
            {
              'id': 'n1',
              'type': 'ListingRejected',
              'title': 't',
              'body': 'b',
              'isRead': false,
            },
          ]),
        );
      });
      final repo = NotificationRepository(api);

      final page = await repo.list(unreadOnly: true, page: 1, pageSize: 20);
      final count = await repo.unreadCount();
      await repo.markRead('n1');
      await repo.markAllRead();

      expect(page.items.single.isRead, isFalse);
      expect(seen.first.queryParameters['unreadOnly'], true);
      expect(count, 3);
      expect(seen[2].path, '/notifications/n1/read');
      expect(seen[3].path, '/notifications/read-all');
    });

    test('list không gửi unreadOnly khi lấy tất cả', () async {
      setup((o) => jsonResponse(200, okBody(<dynamic>[])));
      await NotificationRepository(api).list(page: 1, pageSize: 20);
      expect(seen.single.queryParameters.containsKey('unreadOnly'), isFalse);
    });
  });
}
