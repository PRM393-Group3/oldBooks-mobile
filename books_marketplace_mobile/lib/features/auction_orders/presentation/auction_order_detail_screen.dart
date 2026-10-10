import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/util/idempotency.dart';
import '../../../core/util/server_clock.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../core/widgets/countdown_text.dart';
import '../../auctions/presentation/auction_errors.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../profile/application/address_providers.dart';
import '../../profile/domain/address.dart';
import '../../profile/presentation/address_picker.dart';
import '../../wallet/application/wallet_providers.dart';
import '../application/auction_order_providers.dart';
import '../domain/auction_order.dart';
import 'auction_order_text.dart';

/// Chi tiết đơn đấu giá: thông tin và thao tác chia theo `status` và
/// `postExpiry.status`. Người bán chỉ xem (không có địa chỉ, có hoa hồng).
class AuctionOrderDetailScreen extends ConsumerStatefulWidget {
  const AuctionOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<AuctionOrderDetailScreen> createState() =>
      _AuctionOrderDetailScreenState();
}

class _AuctionOrderDetailScreenState
    extends ConsumerState<AuctionOrderDetailScreen> {
  bool _busy = false;
  final _feeAction = IdempotentAction();
  final _storageAction = IdempotentAction();
  final _postExpiryAction = IdempotentAction();

  AuctionOrderController get _controller =>
      ref.read(auctionOrderProvider(widget.orderId).notifier);

  /// Chạy một thao tác; trả `true` nếu thành công. [retryAfterTopup]: thiếu
  /// tiền thì sau khi nạp tự gửi lại một lần (key mới, vì server đã trả lỗi).
  Future<bool> _run(
    IdempotentAction action,
    Future<void> Function(String key) body, {
    bool retryAfterTopup = false,
  }) async {
    if (_busy) return false;
    setState(() => _busy = true);
    var toppedUp = false;
    try {
      await body(action.key);
      action.settle();
      ref.invalidate(walletProvider);
      return true;
    } catch (e) {
      action.settle(e);
      if (!mounted) return false;
      if (e is ApiError && e.code == ApiErrorCode.auctionOrderAddressRequired) {
        AppSnackbar.apiError(context, e);
        setState(() => _busy = false);
        await _changeAddress();
        return false;
      }
      toppedUp = await handleAuctionError(context, e, onReload: _reload);
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
      if (toppedUp && retryAfterTopup && mounted) {
        await _run(action, body);
      }
    }
  }

  Future<void> _reload() async {
    try {
      await _controller.reload();
    } catch (_) {}
  }

  Future<void> _changeAddress() async {
    final l = context.l10n;
    final current = ref.read(auctionOrderProvider(widget.orderId)).value;
    final List<Address> addresses;
    try {
      addresses = await ref.read(addressesProvider.future);
    } catch (e) {
      if (mounted) AppSnackbar.apiError(context, e);
      return;
    }
    if (!mounted) return;
    if (addresses.isEmpty) {
      AppSnackbar.show(context, l.aoNoAddress);
      await context.push('/me/addresses');
      return;
    }
    final picked = await pickAddress(context, addresses);
    if (picked == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await _controller.setAddress(picked);
      if (mounted) AppSnackbar.success(context, l.aoAddressSaved);
    } catch (e) {
      if (mounted) await handleAuctionError(context, e, onReload: _reload);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (current?.address == null && mounted) _reload();
  }

  Future<void> _payShippingFee(AuctionOrder o) async {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    if (o.address == null) {
      AppSnackbar.show(context, l.aoNeedAddressFirst);
      return _changeAddress();
    }
    final fee = formatVnd(o.shippingFee, locale);
    final ok = await showConfirmDialog(
      context,
      title: l.aoPayFeeTitle,
      message: l.aoPayFeeBody(fee),
      confirmLabel: l.aoPayFeeConfirm(fee),
    );
    if (!ok || !mounted) return;
    final done = await _run(
      _feeAction,
      (key) => _controller.payShippingFee(idempotencyKey: key),
      retryAfterTopup: true,
    );
    if (done && mounted) AppSnackbar.success(context, l.aoFeeHeld);
  }

  Future<void> _storageChoice(AuctionOrder o, CollectionChoice choice) async {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    if (choice == CollectionChoice.redeliver && o.address == null) {
      AppSnackbar.show(context, l.aoNeedAddressFirst);
      return _changeAddress();
    }
    final ok = await showConfirmDialog(
      context,
      title: choice == CollectionChoice.pickup
          ? l.aoPickupTitle
          : l.aoRedeliverTitle,
      message: choice == CollectionChoice.pickup
          ? l.aoPickupBody
          : l.aoRedeliverBody(formatVnd(o.shippingFee, locale)),
      confirmLabel: l.confirm,
    );
    if (!ok || !mounted) return;
    final done = await _run(
      _storageAction,
      (key) => _controller.storageChoice(choice, idempotencyKey: key),
    );
    if (done && mounted) AppSnackbar.success(context, l.aoChoiceSaved);
  }

  Future<void> _postExpiry(AuctionOrder o, PostExpiryAction action) async {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final pe = o.postExpiry!;
    if (action == PostExpiryAction.redeliver && o.address == null) {
      AppSnackbar.show(context, l.aoNeedAddressFirst);
      return _changeAddress();
    }
    final (String title, String body) = switch (action) {
      PostExpiryAction.extend => (
        l.aoExtendTitle,
        l.aoExtendBody(formatVnd(pe.extensionFee, locale), pe.extensionDays),
      ),
      PostExpiryAction.pickup => (l.aoPickupTitle, l.aoPickupBody),
      PostExpiryAction.redeliver => (
        l.aoRedeliverTitle,
        l.aoRedeliverBody(formatVnd(o.shippingFee, locale)),
      ),
    };
    final ok = await showConfirmDialog(
      context,
      title: title,
      message: body,
      confirmLabel: l.confirm,
    );
    if (!ok || !mounted) return;
    final done = await _run(
      _postExpiryAction,
      (key) => _controller.postExpiry(action, idempotencyKey: key),
    );
    if (done && mounted) AppSnackbar.success(context, l.aoChoiceSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final value = ref.watch(auctionOrderProvider(widget.orderId));
    return value.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => AppPage(
        title: l.aoDetailTitle,
        scrollable: false,
        child: const AppLoadingView(),
      ),
      error: (e, _) => AppPage(
        title: l.aoDetailTitle,
        scrollable: false,
        child: e is ApiError && e.code == ApiErrorCode.auctionOrderNotFound
            ? AppEmptyView(
                icon: Icons.inventory_2_outlined,
                title: l.errAuctionOrderNotFound,
              )
            : AppErrorView(error: e, onRetry: _reload),
      ),
      data: _content,
    );
  }

  Widget _content(AuctionOrder o) {
    final l = context.l10n;
    final buyer = o.isBuyer;
    return AppPage(
      title: l.aoDetailTitle,
      onRefresh: _reload,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(order: o),
          const SizedBox(height: AppSpacing.md),
          if (buyer)
            _BuyerPanel(
              order: o,
              busy: _busy,
              onChangeAddress: _changeAddress,
              onPayFee: () => _payShippingFee(o),
              onStorageChoice: (c) => _storageChoice(o, c),
              onPostExpiry: (a) => _postExpiry(o, a),
              onComplain: () async {
                await context.push('/me/auction-orders/${o.id}/complain');
                _reload();
              },
            )
          else
            _SellerPanel(order: o),
          if (o.status == AuctionOrderStatus.disputed &&
              o.complaintId != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l.aoViewComplaint,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push('/me/complaints/${o.complaintId}'),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _MoneyCard(order: o),
          if (buyer) ...[
            const SizedBox(height: AppSpacing.md),
            _AddressCard(
              order: o,
              busy: _busy,
              onChange: o.status.canChangeAddress ? _changeAddress : null,
            ),
          ],
          if (o.delivery.carrier != null || o.delivery.attempts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _DeliveryCard(delivery: o.delivery),
          ],
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: () => context.push('/auctions/${o.auctionId}'),
            child: Text(l.aoViewAuction),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.order});

  final AuctionOrder order;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          height: 100,
          child: BookCover(
            url: order.thumbnailUrl,
            label: order.bookTitle,
            radius: 7,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTag(
                label: auctionOrderStatusLabel(l, order.status),
                tone: auctionOrderStatusTone(order.status),
              ),
              const SizedBox(height: 6),
              Text(
                order.bookTitle,
                style: context.text.titleMedium?.copyWith(
                  fontFamily: AppTypography.serifFamily,
                  fontSize: 18,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.aoWinningPrice(formatVnd(order.finalPrice, locale)),
                style: context.text.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (order.createdAt != null)
                Text(
                  formatDateTime(order.createdAt!, locale),
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _Tone { neutral, success, warning, error }

/// Thẻ thông tin có tiêu đề, nội dung và hàng nút tùy chọn.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    this.body,
    this.tone = _Tone.neutral,
    this.children = const [],
  });

  final String title;
  final String? body;
  final _Tone tone;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Color? bg, Color fg) = switch (tone) {
      _Tone.neutral => (null, colors.textPrimary),
      _Tone.success => (colors.successContainer, colors.onSuccessContainer),
      _Tone.warning => (colors.warningContainer, colors.onWarningContainer),
      _Tone.error => (colors.errorContainer, colors.onErrorContainer),
    };
    return AppCard(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.text.labelLarge?.copyWith(color: fg)),
          if (body != null && body!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              body!,
              style: context.text.bodySmall?.copyWith(color: fg, height: 1.5),
            ),
          ],
          for (final c in children) ...[const SizedBox(height: 8), c],
        ],
      ),
    );
  }
}

/// Đếm ngược tới [target] theo giờ server, dạng "Còn …".
class _Deadline extends StatelessWidget {
  const _Deadline({required this.target, required this.label});

  final DateTime target;
  final String Function(String left) label;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Countdown(
      target: target,
      daysHours: l.remainingDaysHours,
      builder: (context, left, expired) => Text(
        expired ? l.aoDeadlinePassed : label(left),
        style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BuyerPanel extends StatelessWidget {
  const _BuyerPanel({
    required this.order,
    required this.busy,
    required this.onChangeAddress,
    required this.onPayFee,
    required this.onStorageChoice,
    required this.onPostExpiry,
    required this.onComplain,
  });

  final AuctionOrder order;
  final bool busy;
  final VoidCallback onChangeAddress;
  final VoidCallback onPayFee;
  final ValueChanged<CollectionChoice> onStorageChoice;
  final ValueChanged<PostExpiryAction> onPostExpiry;
  final VoidCallback onComplain;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final o = order;
    String money(int v) => formatVnd(v, locale);

    switch (o.status) {
      case AuctionOrderStatus.awaitingShippingFee:
        final due = o.shippingFeeDueAt;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (o.address == null) ...[
              _Panel(
                title: l.aoAddressRequiredTitle,
                body: l.aoAddressRequiredBody,
                tone: _Tone.error,
                children: [
                  AppButton(
                    label: l.ckPickAddress,
                    loading: busy,
                    onPressed: onChangeAddress,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (!o.shippingFeeHeld)
              _Panel(
                title: due == null
                    ? l.aoFeeNeededTitle(money(o.shippingFee))
                    : l.aoFeeNeededBefore(
                        money(o.shippingFee),
                        formatDateTime(due, locale),
                      ),
                body: l.aoFeeNeededBody,
                tone: _Tone.warning,
                children: [
                  if (due != null) _Deadline(target: due, label: l.aoTimeLeft),
                  AppButton(
                    label: l.aoPayFeeButton,
                    loading: busy,
                    onPressed: onPayFee,
                  ),
                ],
              )
            else
              _Panel(
                title: l.aoFeeHeld,
                body: l.aoFeeHeldBody,
                tone: _Tone.success,
              ),
          ],
        );
      case AuctionOrderStatus.readyToShip:
        return _Panel(title: l.aoReadyTitle, body: l.aoReadyBody);
      case AuctionOrderStatus.inDelivery:
        return _Panel(
          title: l.aoInDeliveryTitle,
          body: l.aoInDeliveryBody(
            o.delivery.attemptCount,
            o.delivery.maxAttempts,
          ),
        );
      case AuctionOrderStatus.inStorage:
        final s = o.storage;
        return _Panel(
          title: l.aoInStorageTitle,
          body: l.aoInStorageBody(
            o.delivery.maxAttempts,
            money(s?.feePerDay ?? 0),
            money(s?.feeAccrued ?? 0),
          ),
          tone: _Tone.warning,
          children: [
            if (s?.expiresAt != null)
              _Deadline(target: s!.expiresAt!, label: l.aoStorageLeft),
            if (s?.choice != null)
              Text(
                s!.choice == CollectionChoice.pickup
                    ? l.aoChosenPickup
                    : l.aoChosenRedeliver,
                style: context.text.labelMedium,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l.aoPickup,
                      variant: AppButtonVariant.secondary,
                      loading: busy,
                      onPressed: () => onStorageChoice(CollectionChoice.pickup),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: AppButton(
                      label: l.aoRedeliver,
                      loading: busy,
                      onPressed: () =>
                          onStorageChoice(CollectionChoice.redeliver),
                    ),
                  ),
                ],
              ),
          ],
        );
      case AuctionOrderStatus.delivered || AuctionOrderStatus.pickedUp:
        final end = o.delivery.complaintWindowEndsAt;
        final canComplain = o.canComplainAt(ServerClock.now());
        return _Panel(
          title: o.status == AuctionOrderStatus.delivered
              ? l.aoDeliveredTitle
              : l.aoPickedUpTitle,
          body: l.aoComplaintWindowBody,
          tone: _Tone.success,
          children: [
            if (end != null && canComplain)
              _Deadline(target: end, label: l.aoComplaintLeft),
            if (canComplain)
              AppButton(
                label: l.aoComplain,
                variant: AppButtonVariant.secondary,
                onPressed: onComplain,
              ),
          ],
        );
      case AuctionOrderStatus.storageExpired:
        return _PostExpiryPanel(order: o, busy: busy, onAction: onPostExpiry);
      case AuctionOrderStatus.disputed:
        return _Panel(title: l.aoDisputedTitle, body: l.aoDisputedBody);
      case AuctionOrderStatus.completed ||
          AuctionOrderStatus.refunded ||
          AuctionOrderStatus.partiallyRefunded:
        return _Panel(
          title: auctionOrderStatusLabel(l, o.status),
          body: o.completedAt == null
              ? null
              : l.aoFinishedAt(formatDateTime(o.completedAt!, locale)),
          tone: _Tone.success,
        );
      case AuctionOrderStatus.unknown:
        return _Panel(title: l.aoUnsupportedStatus);
    }
  }
}

class _PostExpiryPanel extends StatelessWidget {
  const _PostExpiryPanel({
    required this.order,
    required this.busy,
    required this.onAction,
  });

  final AuctionOrder order;
  final bool busy;
  final ValueChanged<PostExpiryAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final pe = order.postExpiry;
    if (pe == null) {
      return _Panel(title: l.aoStatusStorageExpired, tone: _Tone.warning);
    }
    switch (pe.status) {
      case PostExpiryStatus.awaitingDecision:
        final deadline = pe.decisionDeadlineAt;
        return _Panel(
          title: l.aoPeAwaitingDecision,
          body: l.aoPeDecisionBody,
          tone: _Tone.warning,
          children: [
            if (deadline != null)
              _Deadline(target: deadline, label: l.aoDecisionLeft),
            if (pe.extensionsLeft > 0)
              AppButton(
                label: l.aoExtendButton(
                  formatVnd(pe.extensionFee, locale),
                  pe.extensionsLeft,
                ),
                loading: busy,
                onPressed: () => onAction(PostExpiryAction.extend),
              ),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l.aoPickup,
                    variant: AppButtonVariant.secondary,
                    loading: busy,
                    onPressed: () => onAction(PostExpiryAction.pickup),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: AppButton(
                    label: l.aoRedeliver,
                    variant: AppButtonVariant.secondary,
                    loading: busy,
                    onPressed: () => onAction(PostExpiryAction.redeliver),
                  ),
                ),
              ],
            ),
          ],
        );
      case PostExpiryStatus.extended:
        return _Panel(
          title: l.aoPeExtended,
          body: pe.extendedUntil == null
              ? null
              : l.aoExtendedUntil(formatDateTime(pe.extendedUntil!, locale)),
        );
      case PostExpiryStatus.awaitingLiquidation:
        return _Panel(
          title: l.aoPeAwaitingLiquidation,
          body: l.aoLiquidationBody,
          tone: _Tone.error,
        );
      case PostExpiryStatus.liquidated:
        return _Panel(
          title: l.aoPeLiquidated,
          body: l.aoLiquidatedBody(formatVnd(pe.liquidationNet, locale)),
        );
      case PostExpiryStatus.releasedToBuyer:
        return _Panel(
          title: l.aoPeReleased,
          body: pe.releasedAt == null
              ? null
              : formatDateTime(pe.releasedAt!, locale),
          tone: _Tone.success,
        );
      case PostExpiryStatus.unknown:
        return _Panel(title: l.aoUnsupportedStatus);
    }
  }
}

class _SellerPanel extends StatelessWidget {
  const _SellerPanel({required this.order});

  final AuctionOrder order;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _Panel(
      title: auctionOrderStatusLabel(l, order.status),
      body: order.status.isFinished ? l.aoSellerFinished : l.aoSellerInProgress,
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({required this.order});

  final AuctionOrder order;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final o = order;
    String money(int v) => formatVnd(v, locale);
    final rows = <(String, String)>[
      (l.aoMoneyFinal, money(o.finalPrice)),
      if (o.isBuyer) ...[
        (l.aoMoneyDeposit, money(o.depositAmount)),
        (l.aoMoneyShipping, money(o.shippingFee)),
        if (o.shippingFeeUnpaid > 0)
          (l.aoMoneyShippingUnpaid, money(o.shippingFeeUnpaid)),
        if ((o.storage?.feeAccrued ?? 0) > 0)
          (l.aoMoneyStorage, money(o.storage!.feeAccrued)),
      ] else if (o.commission != null) ...[
        (l.aoMoneyCommission, '−${money(o.commission!)}'),
        (l.aoMoneyNet, money(o.finalPrice - o.commission!)),
      ],
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.aoMoneyTitle.toUpperCase(),
            style: AppTypography.overline.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 9),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: context.text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (o.isBuyer)
            Text(
              l.aoMoneyNote,
              style: context.text.labelSmall?.copyWith(
                color: colors.textMuted,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.order,
    required this.busy,
    required this.onChange,
  });

  final AuctionOrder order;
  final bool busy;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final a = order.address;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.place_outlined, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: a == null
                ? Text(l.aoNoAddressYet, style: context.text.bodySmall)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${a.recipientName} · ${a.phone}',
                        style: context.text.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(a.fullLine, style: context.text.bodySmall),
                    ],
                  ),
          ),
          if (onChange != null)
            TextButton(
              onPressed: busy ? null : onChange,
              child: Text(a == null ? l.ckPickAddress : l.aoChangeAddress),
            ),
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.delivery});

  final AuctionDelivery delivery;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final d = delivery;
    final tracking = d.trackingNumber;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.aoDeliveryTitle.toUpperCase(),
            style: AppTypography.overline.copyWith(color: colors.textMuted),
          ),
          if (d.carrier != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${d.carrier}${tracking == null ? '' : ' · $tracking'}',
                    style: context.text.labelLarge,
                  ),
                ),
                if (tracking != null)
                  IconButton(
                    tooltip: l.copy,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: tracking));
                      if (context.mounted) {
                        AppSnackbar.success(context, l.copied);
                      }
                    },
                  ),
              ],
            ),
          ],
          for (final a in d.attempts)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    a.result == DeliveryResult.success
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    size: 18,
                    color: a.result == DeliveryResult.success
                        ? colors.success
                        : colors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.aoAttempt(a.round, a.attemptNo),
                          style: context.text.labelMedium,
                        ),
                        if (a.reason != null)
                          Text(a.reason!, style: context.text.bodySmall),
                        if (a.recordedAt != null)
                          Text(
                            formatDateTime(a.recordedAt!, locale),
                            style: context.text.labelSmall?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
