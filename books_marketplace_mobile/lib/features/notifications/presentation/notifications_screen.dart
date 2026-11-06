import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/notification_router.dart';
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
    notificationTarget(n)?.open(context);
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
        // Thông báo chỉ dành cho admin không hiển thị trên mobile.
        value: state.whenData(
          (s) => s.copyWith(
            items: s.items.where((n) => !n.type.isAdminOnly).toList(),
          ),
        ),
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
          ],
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
      NotificationType.accountLocked ||
      NotificationType.kycRejected ||
      NotificationType.withdrawalRejected ||
      NotificationType.withdrawalFailed ||
      NotificationType.listingRejected ||
      NotificationType.listingChangesRequested ||
      NotificationType.listingUnpublished => (
        switch (n.type) {
          NotificationType.accountLocked => Icons.lock_outline,
          NotificationType.kycRejected => Icons.gpp_bad_outlined,
          NotificationType.listingChangesRequested => Icons.edit_note,
          NotificationType.listingRejected ||
          NotificationType.listingUnpublished => Icons.block,
          _ => Icons.error_outline,
        },
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      NotificationType.accountUnlocked ||
      NotificationType.kycApproved ||
      NotificationType.listingApproved ||
      NotificationType.topupSucceeded ||
      NotificationType.withdrawalApproved ||
      NotificationType.withdrawalPaid => (
        switch (n.type) {
          NotificationType.accountUnlocked => Icons.lock_open,
          NotificationType.kycApproved => Icons.verified_outlined,
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
      NotificationType.auctionOutbid ||
      NotificationType.auctionLost ||
      NotificationType.auctionRejected ||
      NotificationType.auctionInboundTimeout ||
      NotificationType.auctionDeliveryFailed ||
      NotificationType.auctionStorageExpired ||
      NotificationType.auctionAwaitingLiquidation ||
      NotificationType.auctionShippingFeeNeeded ||
      NotificationType.auctionShippingFeeDeferred ||
      NotificationType.auctionNotEnough ||
      NotificationType.auctionEndedNoBid ||
      NotificationType.auctionFallbackTimeout ||
      NotificationType.returnFeeNeeded ||
      NotificationType.auctionInStorage => (
        Icons.gavel_outlined,
        colors.warningContainer,
        colors.onWarningContainer,
      ),
      NotificationType.auctionWon ||
      NotificationType.auctionSold ||
      NotificationType.auctionApproved ||
      NotificationType.auctionConfirmed ||
      NotificationType.auctionOrderDelivered ||
      NotificationType.auctionOrderCompleted ||
      NotificationType.auctionReleasedToBuyer ||
      NotificationType.auctionLiquidated ||
      NotificationType.auctionRegistrationRefunded => (
        Icons.emoji_events_outlined,
        colors.successContainer,
        colors.onSuccessContainer,
      ),
      NotificationType.auctionOrderDispatched ||
      NotificationType.returnDispatched ||
      NotificationType.returnReady => (
        Icons.local_shipping_outlined,
        colors.infoContainer,
        colors.onInfoContainer,
      ),
      NotificationType.auctionStarted ||
      NotificationType.auctionBuyNowStarted ||
      NotificationType.auctionInboundReceived ||
      NotificationType.auctionStorageExtended ||
      NotificationType.auctionLiquidationNeedsAdmin => (
        Icons.gavel_outlined,
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
