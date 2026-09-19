import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_paged_list.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../application/notification_providers.dart';
import '../domain/app_notification.dart';

/// Danh sách thông báo trong app. Tiêu đề bản địa hóa theo `type`; chi tiết
/// (lý do từ chối...) nằm ở màn hình tin đăng.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;

  Future<void> _markAll() async {
    try {
      await ref.read(notificationActionsProvider).markAllRead();
    } on ApiError catch (e) {
      if (mounted) AppSnackbar.apiError(context, e);
    }
  }

  Future<void> _open(AppNotification n) async {
    if (!n.isRead) {
      try {
        await ref.read(notificationActionsProvider).markRead(n.id);
      } on ApiError catch (e) {
        if (mounted) AppSnackbar.apiError(context, e);
      }
    }
    if (mounted && n.listingId != null) {
      context.push('/listings/${n.listingId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = notificationsProvider(_unreadOnly);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return AppPage(
      title: l.notificationsTitle,
      scrollable: false,
      actions: [TextButton(onPressed: _markAll, child: Text(l.markAllRead))],
      child: AppPagedList<AppNotification>(
        value: state,
        onLoadMore: notifier.loadMore,
        onRefresh: () async {
          ref.invalidate(unreadCountProvider);
          await notifier.reload();
        },
        header: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Wrap(
            spacing: AppSpacing.xs,
            children: [
              ChoiceChip(
                label: Text(l.filterAll),
                selected: !_unreadOnly,
                onSelected: (_) => setState(() => _unreadOnly = false),
              ),
              ChoiceChip(
                label: Text(l.unreadOnly),
                selected: _unreadOnly,
                onSelected: (_) => setState(() => _unreadOnly = true),
              ),
            ],
          ),
        ),
        empty: AppEmptyView(
          icon: Icons.notifications_none,
          title: l.emptyNotificationsTitle,
          message: l.emptyNotificationsMessage,
        ),
        separator: const SizedBox(height: AppSpacing.xs),
        itemBuilder: (context, n) =>
            _NotificationTile(notification: n, onTap: () => _open(n)),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final n = notification;

    final (IconData icon, Color bg, Color fg) = switch (n.type) {
      NotificationType.listingApproved => (
        Icons.check_circle_outline,
        colors.successContainer,
        colors.onSuccessContainer,
      ),
      NotificationType.listingRejected => (
        Icons.cancel_outlined,
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      NotificationType.listingClosed => (
        Icons.lock_outline,
        colors.surfaceMuted,
        colors.textSecondary,
      ),
      NotificationType.unknown => (
        Icons.notifications_none,
        colors.infoContainer,
        colors.onInfoContainer,
      ),
    };
    final title = n.type.title(l) ?? n.title;
    // Loại đã biết thì chi tiết ở màn hình tin; loại lạ thì hiện nội dung server.
    final body = n.type == NotificationType.unknown ? n.body : null;

    return Semantics(
      label: '${n.isRead ? '' : '${l.unreadOnly}. '}$title',
      button: true,
      excludeSemantics: true,
      child: Material(
        color: n.isRead ? colors.surface : colors.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: colors.divider),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: bg,
                  foregroundColor: fg,
                  child: Icon(icon),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: n.isRead
                              ? FontWeight.w400
                              : FontWeight.w700,
                        ),
                      ),
                      if (body != null && body.isNotEmpty)
                        Text(body, style: context.text.bodySmall),
                      if (n.createdAt != null)
                        Text(
                          formatDateTime(n.createdAt!, locale),
                          style: context.text.labelSmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!n.isRead)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
