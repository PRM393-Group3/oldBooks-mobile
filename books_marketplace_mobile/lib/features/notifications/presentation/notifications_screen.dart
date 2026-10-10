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
import '../../sim/application/sim_providers.dart';
import '../../sim/presentation/sim_text.dart';
import '../application/notification_providers.dart';
import '../domain/app_notification.dart';

/// Danh sách thông báo trong app. `title`/`body` do server tạo sẵn; `type` chỉ
/// dùng chọn biểu tượng và điều hướng.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;

  Future<void> _markAll() async {
    ref.read(simProvider.notifier).markAllNotificationsRead();
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
    if (!mounted) return;
    // Thông báo khiếu nại ưu tiên khiếu nại (cũng có orderId); đơn hàng mở đơn.
    if (n.type.isWallet) {
      context.go('/wallet');
    } else if (n.complaintId != null) {
      context.push('/me/complaints/${n.complaintId}');
    } else if (n.orderId != null) {
      context.push('/me/orders/${n.orderId}');
    } else if (n.listingId != null) {
      context.push('/home/book/${n.listingId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = notificationsProvider(_unreadOnly);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final sim = ref.watch(simNotificationsProvider);
    final simNow = ref.watch(simNowProvider);
    final locale = Localizations.localeOf(context).toString();

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
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
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
            for (final n in sim)
              if (!_unreadOnly || !n.read)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _SimNotificationTile(
                    title: simNotificationText(l, locale, n).title,
                    body: simNotificationText(l, locale, n).body,
                    ago: agoText(l, simNow, n.time),
                    read: n.read,
                  ),
                ),
          ],
        ),
        empty: sim.isNotEmpty
            ? const SizedBox.shrink()
            : AppEmptyView(
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
      NotificationType.accountLocked ||
      NotificationType.withdrawalRejected ||
      NotificationType.withdrawalFailed ||
      NotificationType.listingRejected ||
      NotificationType.listingChangesRequested ||
      NotificationType.listingUnpublished => (
        switch (n.type) {
          NotificationType.accountLocked => Icons.lock_outline,
          NotificationType.listingChangesRequested => Icons.edit_note,
          NotificationType.listingRejected ||
          NotificationType.listingUnpublished => Icons.block,
          _ => Icons.error_outline,
        },
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      NotificationType.accountUnlocked ||
      NotificationType.listingApproved ||
      NotificationType.topupSucceeded ||
      NotificationType.withdrawalApproved ||
      NotificationType.withdrawalPaid => (
        switch (n.type) {
          NotificationType.accountUnlocked => Icons.lock_open,
          NotificationType.listingApproved => Icons.check_circle_outline,
          _ => Icons.account_balance_wallet_outlined,
        },
        colors.successContainer,
        colors.onSuccessContainer,
      ),
      NotificationType.orderTimeoutBuyer ||
      NotificationType.orderTimeoutSeller ||
      NotificationType.orderCancelledByBuyer ||
      NotificationType.complaintEscalated => (
        Icons.warning_amber_rounded,
        colors.warningContainer,
        colors.onWarningContainer,
      ),
      NotificationType.orderNew ||
      NotificationType.orderShipped ||
      NotificationType.orderDelivered ||
      NotificationType.orderCompleted ||
      NotificationType.orderShipReminder => (
        Icons.local_shipping_outlined,
        colors.successContainer,
        colors.onSuccessContainer,
      ),
      NotificationType.complaintOpened ||
      NotificationType.complaintSellerResponded ||
      NotificationType.complaintMessage ||
      NotificationType.complaintResolved => (
        Icons.gavel_outlined,
        colors.infoContainer,
        colors.onInfoContainer,
      ),
      NotificationType.passwordChanged => (
        Icons.vpn_key_outlined,
        colors.infoContainer,
        colors.onInfoContainer,
      ),
      NotificationType.unknown => (
        Icons.notifications_none,
        colors.infoContainer,
        colors.onInfoContainer,
      ),
    };
    // Nội dung do server dựng sẵn bằng tiếng Việt: hiển thị nguyên văn.
    final title = n.title;
    final body = n.body;

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
                      if (body.isNotEmpty)
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

/// Thông báo mô phỏng (đơn, ví, đấu giá): chỉ hiển thị, không có màn đích.
class _SimNotificationTile extends StatelessWidget {
  const _SimNotificationTile({
    required this.title,
    required this.body,
    required this.ago,
    required this.read,
  });

  final String title;
  final String body;
  final String ago;
  final bool read;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: title,
      child: Material(
        color: read ? colors.surface : colors.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: colors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: read ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ago,
                      style: context.text.labelSmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!read)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: colors.auction,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
