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

  Future<int> unreadCount() => _api.get(
    '/notifications/unread-count',
    parse: (data) => data is Map ? (data['count'] as num?)?.toInt() ?? 0 : 0,
  );

  Future<void> markRead(String id) =>
      _api.postNoContent('/notifications/$id/read');

  Future<void> markAllRead() => _api.postNoContent('/notifications/read-all');
}
