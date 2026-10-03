import '../../../core/network/api_client.dart';
import '../../../core/network/paged_result.dart';
import '../domain/app_notification.dart';

class NotificationRepository {
  NotificationRepository(this._api);
  final ApiClient _api;

  Future<PagedResult<AppNotification>> list({
    bool unreadOnly = false,
    required int page,
    required int pageSize,
  }) => _api.get(
    '/notifications',
    query: {
      if (unreadOnly) 'unreadOnly': true,
      'page': page,
      'pageSize': pageSize,
    },
    parse: (d) => PagedResult.fromJson(
      d,
      AppNotification.fromJson,
      page: page,
      pageSize: pageSize,
    ),
  );

  Future<int> unreadCount() =>
      _api.get('/notifications/unread-count', parse: _count);

  /// Trả về số chưa đọc còn lại. Id không phải của mình bị server bỏ qua.
  Future<int> markRead(List<String> ids) =>
      _api.post('/notifications/read', body: {'ids': ids}, parse: _count);

  Future<int> markAllRead() =>
      _api.post('/notifications/read', body: {'all': true}, parse: _count);

  static int _count(dynamic data) =>
      data is Map ? (data['count'] as num?)?.toInt() ?? 0 : 0;

  Future<NotificationSettings> getSettings() => _api.get(
    '/me/notification-settings',
    parse: NotificationSettings.fromJson,
  );

  /// Gửi một hoặc cả hai trường; trả về trạng thái đầy đủ.
  Future<NotificationSettings> updateSettings({
    bool? marketing,
    bool? auctionWatch,
  }) => _api.patch(
    '/me/notification-settings',
    body: {'marketing': ?marketing, 'auctionWatch': ?auctionWatch},
    parse: NotificationSettings.fromJson,
  );
}
