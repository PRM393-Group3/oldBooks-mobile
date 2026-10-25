import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../../core/widgets/countdown_text.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../wallet/application/wallet_providers.dart';
import '../application/order_providers.dart';
import '../domain/sale_order.dart';
import 'orders_screen.dart';

/// Chi tiết đơn bán thường: trạng thái, đếm ngược hạn, tiền, địa chỉ, vận đơn,
/// diễn biến và các nút theo `actions` của server.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(saleOrderProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: Text(l.soDetailTitle)),
      body: SafeArea(
        child: state.when(
          loading: () => const AppLoadingView(),
          error: (e, _) => AppErrorView(
            error: e,
            onRetry: () => ref.invalidate(saleOrderProvider(orderId)),
          ),
          data: (order) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(saleOrderProvider(orderId));
              await ref.read(saleOrderProvider(orderId).future);
            },
            child: _Body(order: order),
          ),
        ),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.order});

  final SaleOrder order;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _busy = false;

  Future<void> _act(
    Future<SaleOrder> Function() action,
    String successMessage,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      refreshOrders(ref, orderId: widget.order.id);
      // Hủy đơn hoàn tiền, hoàn tất chuyển tiền: số dư thay đổi.
      ref.read(walletProvider.notifier).refresh();
      ref.invalidate(walletTransactionsProvider);
      if (mounted) AppSnackbar.success(context, successMessage);
    } on ApiError catch (e) {
      // Sai trạng thái (`INVALID_STATE`): tải lại đơn để hiện đúng.
      if (e.needsReload) refreshOrders(ref, orderId: widget.order.id);
      if (mounted) AppSnackbar.apiError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmThen({
    required String title,
    required String message,
    required String confirmLabel,
    required bool destructive,
    required Future<SaleOrder> Function() action,
    required String success,
  }) async {
    final ok = await showConfirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      destructive: destructive,
    );
    if (ok && mounted) await _act(action, success);
  }

  Future<void> _ship() async {
    final l = context.l10n;
    final input = await showAppSheet<({String carrier, String tracking})>(
      context,
      builder: (sheet) => _ShipForm(sheetContext: sheet),
    );
    if (input == null || !mounted) return;
    await _act(
      () => ref
          .read(orderRepositoryProvider)
          .ship(
            widget.order.id,
            carrier: input.carrier,
            trackingNumber: input.tracking,
          ),
      l.soShipped,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final o = widget.order;
    final repo = ref.read(orderRepositoryProvider);
    final a = o.actions;

    String daysHours(int d, int h) => '$d ngày $h giờ';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.screen + 4),
      children: [
        // Sách
        AppCard(
          onTap: o.book?.listingId.isNotEmpty == true
              ? () => context.push('/home/book/${o.book!.listingId}')
              : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                height: 76,
                child: BookCover(
                  url: o.book?.thumbnailUrl,
                  label: o.title,
                  radius: 6,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTag(label: o.status.label(l), tone: orderTone(o.status)),
                    const SizedBox(height: 6),
                    Text(
                      o.title,
                      style: context.text.titleMedium?.copyWith(
                        fontFamily: AppTypography.serifFamily,
                        fontVariations: AppTypography.serifSemiBold,
                        height: 1.2,
                      ),
                    ),
                    if (o.book?.author != null)
                      Text(
                        o.book!.author!,
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
        const SizedBox(height: AppSpacing.sm),

        // Đếm ngược
        if (o.status == SaleOrderStatus.paidAwaitingShipment &&
            o.shipDeadlineAt != null)
          _CountdownBanner(
            target: o.shipDeadlineAt!,
            daysHours: daysHours,
            textFor: (remaining) => o.isSeller
                ? l.soCountdownShip(remaining)
                : l.soCountdownShipBuyer(remaining),
          ),
        if (o.status == SaleOrderStatus.delivered &&
            o.complaintWindowEndsAt != null)
          _CountdownBanner(
            target: o.complaintWindowEndsAt!,
            daysHours: daysHours,
            textFor: l.soCountdownComplaint,
          ),

        // Tiền
        _Section(
          children: [
            _Row(l.soPrice, formatVnd(o.price, locale)),
            _Row(l.soShipFee, formatVnd(o.shippingFee, locale)),
            _Row(l.soTotal, formatVnd(o.totalAmount, locale), bold: true),
            if (o.isSeller && o.sellerPayout != null)
              for (final e in o.sellerPayout!.entries)
                _Row(
                  _payoutLabel(l, e.key),
                  formatVnd(e.value, locale),
                  bold: _isNetPayout(e.key),
                ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Các bên + địa chỉ (người bán cần địa chỉ để gửi hàng)
        _Section(
          children: [
            if (o.seller != null) _Row(l.soSeller, o.seller!.name),
            if (o.buyer != null) _Row(l.soBuyer, o.buyer!.name),
          ],
        ),
        if (o.shippingAddress != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.soAddress,
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${o.shippingAddress!.recipientName} · ${o.shippingAddress!.phone}',
                  style: context.text.labelLarge,
                ),
                Text(
                  o.shippingAddress!.fullLine,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (o.shipment != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _Section(
            children: [
              _Row(l.soShipment, o.shipment!.carrier),
              _Row(l.soShipTracking, o.shipment!.trackingNumber),
              if (o.shipment!.shippedAt != null)
                _Row(
                  l.soStatusShipped,
                  formatDateTime(o.shipment!.shippedAt!, locale),
                ),
            ],
          ),
        ],

        // Diễn biến
        if (o.timeline.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(l.soTimeline, style: context.text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          for (final t in o.timeline)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, right: 10),
                    child: Icon(Icons.circle, size: 8, color: colors.primary),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.status.label(l), style: context.text.labelLarge),
                        if (t.at != null)
                          Text(
                            formatDateTime(t.at!, locale),
                            style: context.text.labelSmall?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        if (t.note != null)
                          Text(
                            t.note!,
                            style: context.text.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],

        // Nút theo `actions`
        const SizedBox(height: AppSpacing.md),
        if (o.complaintId != null) ...[
          AppButton(
            label: l.soViewComplaint,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push('/me/complaints/${o.complaintId}'),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (a.canComplain) ...[
          AppButton(
            label: l.soComplain,
            variant: AppButtonVariant.secondary,
            onPressed: _busy
                ? null
                : () => context.push('/me/orders/${o.id}/complain'),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (a.canComplete) ...[
          AppButton(
            label: l.soComplete,
            loading: _busy,
            onPressed: () => _confirmThen(
              title: l.soCompleteTitle,
              message: l.soCompleteBody,
              confirmLabel: l.soComplete,
              destructive: false,
              action: () => repo.complete(o.id),
              success: l.soCompleted,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (a.canConfirmReceived) ...[
          AppButton(
            label: l.soReceived,
            loading: _busy,
            onPressed: () => _confirmThen(
              title: l.soReceivedTitle,
              message: l.soReceivedBody,
              confirmLabel: l.soReceived,
              destructive: false,
              action: () => repo.confirmReceived(o.id),
              success: l.soReceivedDone,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (a.canShip) ...[
          AppButton(label: l.soShip, loading: _busy, onPressed: _ship),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (a.canCancel)
          AppButton(
            label: l.soCancel,
            variant: AppButtonVariant.danger,
            loading: _busy,
            onPressed: () => _confirmThen(
              title: l.soCancelTitle,
              message: l.soCancelBody,
              confirmLabel: l.soCancel,
              destructive: true,
              action: () => repo.cancel(o.id),
              success: l.soCancelled,
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  static bool _isNetPayout(String key) =>
      const {'amount', 'total', 'net', 'netAmount', 'payout'}.contains(key);

  static String _payoutLabel(AppLocalizations l, String key) => switch (key) {
    'price' => l.soPrice,
    'fee' || 'platformFee' => l.soPayoutFee,
    'shippingFee' => l.soShipFee,
    _ when _isNetPayout(key) => l.soPayout,
    _ => key,
  };
}

class _CountdownBanner extends StatelessWidget {
  const _CountdownBanner({
    required this.target,
    required this.daysHours,
    required this.textFor,
  });

  final DateTime target;
  final String Function(int days, int hours) daysHours;
  final String Function(String remaining) textFor;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Countdown(
        target: target,
        daysHours: daysHours,
        builder: (context, remaining, expired) => DecoratedBox(
          decoration: BoxDecoration(
            color: expired ? colors.errorContainer : colors.warningContainer,
            borderRadius: AppRadius.mdAll,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              textFor(expired ? l.soOverdue : remaining),
              style: context.text.labelMedium?.copyWith(
                color: expired
                    ? colors.onErrorContainer
                    : colors.onWarningContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return AppCard(child: Column(children: children));
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.text.bodySmall?.copyWith(color: colors.textMuted),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: context.text.bodySmall?.copyWith(
                fontWeight: bold ? FontWeight.w700 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipForm extends StatefulWidget {
  const _ShipForm({required this.sheetContext});

  final BuildContext sheetContext;

  @override
  State<_ShipForm> createState() => _ShipFormState();
}

class _ShipFormState extends State<_ShipForm> {
  final _carrier = TextEditingController();
  final _tracking = TextEditingController();
  bool _tried = false;

  @override
  void dispose() {
    _carrier.dispose();
    _tracking.dispose();
    super.dispose();
  }

  bool get _valid {
    final c = _carrier.text.trim().length;
    final t = _tracking.text.trim().length;
    return c >= 2 && c <= 50 && t >= 3 && t <= 50;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetTitle(l.soShip),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _carrier,
          maxLength: 50,
          maxLengthEnforcement:
              MaxLengthEnforcement.truncateAfterCompositionEnds,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l.soShipCarrier,
            hintText: 'GHN',
          ),
        ),
        TextField(
          controller: _tracking,
          maxLength: 50,
          maxLengthEnforcement:
              MaxLengthEnforcement.truncateAfterCompositionEnds,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(labelText: l.soShipTracking),
        ),
        if (_tried && !_valid)
          Text(
            l.soShipInvalid,
            style: context.text.labelSmall?.copyWith(
              color: context.colors.error,
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l.soShipSubmit,
          onPressed: () {
            if (!_valid) {
              setState(() => _tried = true);
              return;
            }
            Navigator.of(widget.sheetContext).pop((
              carrier: _carrier.text.trim(),
              tracking: _tracking.text.trim(),
            ));
          },
        ),
      ],
    );
  }
}
