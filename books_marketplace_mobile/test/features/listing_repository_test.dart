import 'dart:typed_data';

import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/core/network/api_error.dart';
import 'package:books_marketplace_mobile/core/network/blob_uploader.dart';
import 'package:books_marketplace_mobile/features/listings/data/listing_repository.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_enums.dart';
import 'package:books_marketplace_mobile/features/listings/domain/listing_query.dart';
import 'package:books_marketplace_mobile/features/notifications/data/notification_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

const _listing = {'id': 'L1', 'status': 'DRAFT'};

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
    test('search gửi bộ lọc và cursor, đọc nextCursor từ meta', () async {
      setup(
        (o) => jsonResponse(200, {
          'success': true,
          'data': [
            {'id': 'L1', 'title': 'A', 'status': 'PUBLISHED', 'price': 1000},
          ],
          'meta': {'pageSize': 20, 'hasNext': true, 'nextCursor': 'MHwx'},
          'traceId': 't',
        }),
      );
      final page = await ListingRepository(api).search(
        const ListingQuery(q: 'dac nhan', condition: BookCondition.good),
        cursor: 'abc',
      );

      expect(seen.single.path, '/listings');
      expect(seen.single.queryParameters, {
        'q': 'dac nhan',
        'condition': 'GOOD',
        'pageSize': 20,
        'cursor': 'abc',
      });
      expect(page.items.single.price, 1000);
      expect(page.hasNext, isTrue);
      expect(page.nextCursor, 'MHwx');
    });

    test('create gửi đủ trường; update dùng PATCH một phần', () async {
      setup(
        (o) => jsonResponse(o.method == 'POST' ? 201 : 200, okBody(_listing)),
      );
      final repo = ListingRepository(api);
      await repo.create(
        const ListingDraftInput(
          title: 'Đắc Nhân Tâm',
          author: 'Dale Carnegie',
          categoryId: 'c1',
          condition: BookCondition.good,
          price: 85000,
          description: 'Mới 90%',
        ),
      );
      await repo.update('L1', const ListingDraftInput(price: 90000));

      expect(seen[0].method, 'POST');
      expect(seen[0].data['categoryId'], 'c1');
      expect(seen[1].method, 'PATCH');
      expect(seen[1].path, '/listings/L1');
      expect(seen[1].data, {'price': 90000});
    });

    test(
      'ảnh: xin URL riêng của tin, PUT lên kho, rồi đặt danh sách',
      () async {
        setup((o) {
          if (o.path == '/listings/L1/photos/upload-url') {
            return jsonResponse(
              200,
              okBody({
                'blobName': 'u1/new.jpg',
                'uploadUrl': 'http://blob/public/u1/new.jpg?sig=1',
                'requiredHeaders': {'x-ms-blob-type': 'BlockBlob'},
              }),
            );
          }
          if (o.uri.host == 'blob') return jsonResponse(201, {});
          return jsonResponse(
            200,
            okBody([
              {'id': 'p0', 'url': 'http://blob/public/u1/old.jpg', 'order': 0},
              {'id': 'p1', 'url': 'http://blob/public/u1/new2.jpg', 'order': 1},
            ]),
          );
        });
        final plain = Dio(BaseOptions(baseUrl: 'http://x'))
          ..httpClientAdapter = FakeAdapter((o) {
            seen.add(o);
            return jsonResponse(201, {});
          });
        final repo = ListingRepository(api, BlobUploader(api, plain));

        final names = await repo.uploadPhotos('L1', [
          NewPhoto(
            bytes: Uint8List.fromList([1, 2]),
            fileName: 'a.jpg',
            contentType: 'image/jpeg',
          ),
        ]);
        final photos = await repo.setPhotos('L1', ['u1/old.jpg', names.single]);

        expect(names, ['u1/new.jpg']);
        expect(seen[0].data, {
          'fileName': 'a.jpg',
          'contentType': 'image/jpeg',
        });
        expect(
          (seen[0].data as Map).containsKey('visibility'),
          isFalse,
          reason: 'endpoint ảnh của tin không có visibility',
        );
        expect(seen.last.method, 'PUT');
        expect(seen.last.path, '/listings/L1/photos');
        expect(seen.last.data, {
          'blobNames': ['u1/old.jpg', 'u1/new.jpg'],
        });
        expect(photos.map((p) => p.blobName), ['u1/old.jpg', 'u1/new2.jpg']);
      },
    );

    test('submit, unpublish (không body), lỗi LISTING_INCOMPLETE', () async {
      setup(
        (o) => jsonResponse(
          200,
          okBody({..._listing, 'status': 'PENDING_REVIEW'}),
        ),
      );
      final repo = ListingRepository(api);
      expect((await repo.submit('L1')).status, ListingStatus.pendingReview);
      await repo.unpublish('L1');
      expect(seen[0].path, '/listings/L1/submit');
      expect(seen[1].path, '/listings/L1/unpublish');

      setup(
        (o) => jsonResponse(
          422,
          errorBody(
            'LISTING_INCOMPLETE',
            details: [
              {
                'field': 'photos',
                'message': 'Cần tối thiểu 4 ảnh (hiện có 2).',
              },
            ],
          ),
        ),
      );
      await expectLater(
        ListingRepository(api).submit('L1'),
        throwsA(
          isA<ApiError>()
              .having((e) => e.code, 'code', 'LISTING_INCOMPLETE')
              .having(
                (e) => e.fieldErrors['photos'],
                'photos',
                contains('4 ảnh'),
              ),
        ),
      );
    });

    test('mine gửi status/phân trang và đọc tổng từ meta', () async {
      setup(
        (o) => jsonResponse(200, {
          'success': true,
          'data': [_listing],
          'meta': {
            'page': 1,
            'pageSize': 20,
            'totalItems': 45,
            'hasNext': true,
          },
          'traceId': 't',
        }),
      );
      final page = await ListingRepository(api)
          .mine(status: ListingStatus.pendingReview, page: 1, pageSize: 20);
      expect(seen.single.path, '/me/listings');
      expect(seen.single.queryParameters, {
        'status': 'PENDING_REVIEW',
        'page': 1,
        'pageSize': 20,
      });
      expect(page.totalCount, 45);
      expect(page.hasMore, isTrue);

      await ListingRepository(api).mine(page: 1, pageSize: 20);
      expect(seen.last.queryParameters.containsKey('status'), isFalse);
    });
  });

  group('NotificationRepository', () {
    test('list, unreadCount, markRead, markAllRead', () async {
      setup((o) {
        if (o.path == '/notifications/unread-count') {
          return jsonResponse(200, okBody({'count': 3}));
        }
        if (o.method == 'POST') {
          return jsonResponse(200, okBody({'count': 0}));
        }
        return jsonResponse(
          200,
          okBody([
            {
              'id': 'n1',
              'type': 'ACCOUNT_LOCKED',
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
      await repo.markRead(['n1']);
      await repo.markAllRead();

      expect(page.items.single.isRead, isFalse);
      expect(seen.first.queryParameters['unreadOnly'], true);
      expect(count, 3);
      expect(seen[2].path, '/notifications/read');
      expect(seen[3].path, '/notifications/read');
    });

    test('list không gửi unreadOnly khi lấy tất cả', () async {
      setup((o) => jsonResponse(200, okBody(<dynamic>[])));
      await NotificationRepository(api).list(page: 1, pageSize: 20);
      expect(seen.single.queryParameters.containsKey('unreadOnly'), isFalse);
    });
  });
}
