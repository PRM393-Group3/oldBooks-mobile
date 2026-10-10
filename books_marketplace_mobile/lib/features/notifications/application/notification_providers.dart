import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/paged_result.dart';
import '../../../core/paging/paged_notifier.dart';
import '../../sim/application/sim_providers.dart';
import '../data/notification_repository.dart';
import '../domain/app_notification.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(apiClientProvider)),
);

class NotificationsNotifier extends PagedNotifier<AppNotification> {
  NotificationsNotifier(this.unreadOnly);
  final bool unreadOnly;

  @override
  Future<PagedResult<AppNotification>> fetchPage(int page) => ref
      .read(notificationRepositoryProvider)
      .list(
        unreadOnly: unreadOnly,
        page: page,
        pageSize: PagedNotifier.pageSize,
      );
}

final notificationsProvider = AsyncNotifierProvider.autoDispose
    .family<NotificationsNotifier, PagedState<AppNotification>, bool>(
      NotificationsNotifier.new,
    );

/// Số thông báo chưa đọc cho badge. Làm mới khi vào app, khi quay lại
/// foreground và sau khi đọc; không polling nền.
final unreadCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(notificationRepositoryProvider).unreadCount(),
);

/// Tổng chưa đọc: thông báo từ backend cộng thông báo mô phỏng (đơn, ví, đấu giá).
final totalUnreadProvider = Provider.autoDispose<int>(
  (ref) =>
      (ref.watch(unreadCountProvider).value ?? 0) +
      ref.watch(simUnreadCountProvider),
);

class NotificationActions {
  NotificationActions(this._ref);
  final Ref _ref;

  NotificationRepository get _repo => _ref.read(notificationRepositoryProvider);

  Future<void> markRead(String id) async {
    await _repo.markRead([id]);
    _refresh();
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    _refresh();
  }

  void _refresh() {
    _ref.invalidate(unreadCountProvider);
    _ref.invalidate(notificationsProvider);
  }
}

final notificationActionsProvider = Provider<NotificationActions>(
  NotificationActions.new,
);

/// Tùy chọn nhận push. Cập nhật lạc quan, lỗi thì trả về giá trị cũ.
class NotificationSettingsNotifier extends AsyncNotifier<NotificationSettings> {
  NotificationRepository get _repo => ref.read(notificationRepositoryProvider);

  @override
  Future<NotificationSettings> build() => _repo.getSettings();

  Future<void> change({bool? marketing, bool? auctionWatch}) async {
    final previous = state.value;
    if (previous == null) return;
    state = AsyncData(
      previous.copyWith(marketing: marketing, auctionWatch: auctionWatch),
    );
    try {
      state = AsyncData(
        await _repo.updateSettings(
          marketing: marketing,
          auctionWatch: auctionWatch,
        ),
      );
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      NotificationSettingsNotifier.new,
    );
