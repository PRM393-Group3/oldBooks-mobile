import 'package:books_marketplace_mobile/core/network/api_client.dart';
import 'package:books_marketplace_mobile/features/notifications/data/notification_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late List<RequestOptions> seen;
  late NotificationRepository repo;

  void setup(ResponseBody Function(RequestOptions) handler) {
    seen = [];
    final adapter = FakeAdapter((o) {
      seen.add(o);
      return handler(o);
    });
    repo = NotificationRepository(
      ApiClient(
        Dio(BaseOptions(baseUrl: 'http://x'))..httpClientAdapter = adapter,
      ),
    );
  }

  test('markRead gửi ids, trả số chưa đọc còn lại', () async {
    setup((o) => jsonResponse(200, okBody({'count': 2})));
    expect(await repo.markRead(['a', 'b']), 2);
    expect(seen.single.method, 'POST');
    expect(seen.single.path, '/notifications/read');
    expect(seen.single.data, {
      'ids': ['a', 'b'],
    });
  });

  test('markAllRead gửi all:true', () async {
    setup((o) => jsonResponse(200, okBody({'count': 0})));
    expect(await repo.markAllRead(), 0);
    expect(seen.single.data, {'all': true});
  });

  test('unreadCount đọc data.count', () async {
    setup((o) => jsonResponse(200, okBody({'count': 3})));
    expect(await repo.unreadCount(), 3);
    expect(seen.single.path, '/notifications/unread-count');
  });

  test('settings: GET rồi PATCH chỉ gửi trường được đổi', () async {
    setup(
      (o) => jsonResponse(
        200,
        okBody({'marketing': o.method == 'GET', 'auctionWatch': true}),
      ),
    );
    expect((await repo.getSettings()).marketing, isTrue);
    final s = await repo.updateSettings(marketing: false);
    expect(s.marketing, isFalse);
    expect(seen[0].path, '/me/notification-settings');
    expect(seen[1].method, 'PATCH');
    expect(seen[1].data, {'marketing': false});
  });
}
