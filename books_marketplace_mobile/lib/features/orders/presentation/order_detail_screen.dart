import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dashed_button.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../sim/application/sim_providers.dart';
import '../../sim/application/sim_state.dart';
import '../../sim/domain/rules.dart';
import '../../sim/presentation/sim_text.dart';
import '../../sim/presentation/sim_ticker.dart';
import '../../wallet/presentation/wallet_sheets.dart';
import '../domain/order.dart';
import '../domain/order_timeline.dart';
import 'complaint_sheet.dart';

/// Chi tiết đơn: trạng thái, dòng thời gian, tiền và các thao tác khả dụng.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final order = ref.watch(orderProvider(orderId));
    if (order == null) {
      return AppPage(
        title: l.orderTitle(orderId),
        scrollable: false,
        child: AppEmptyView(
          icon: Icons.receipt_long_outlined,
          title: l.ordersEmpty,
        ),
      );
    }
    final now = ref.watch(simNowProvider);
    final locale = Localizations.localeOf(context).toString();

    return SimTicker(
      child: AppPage(
        title: l.orderTitle(order.id),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen + 4,
          AppSpacing.md + 2,
          AppSpacing.screen + 4,
          AppSpacing.lg,
        ),
        bottom: _Actions(order: order),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(order: order, now: now, locale: locale),
            const SizedBox(height: AppSpacing.md + 2),
            _ItemCard(order: order),
            const SizedBox(height: AppSpacing.md + 2),
            _Timeline(order: order),
            if (order.complaint != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _ComplaintCard(order: order, locale: locale),
            ],
            const SizedBox(height: AppSpacing.md + 2),
            _MoneyCard(order: order, locale: locale),
            if (order.status == OrderStatus.completed && !order.isAuction) ...[
              const SizedBox(height: AppSpacing.md + 2),
              _ReviewCard(order: order),
            ],
          ],
        ),
      ),
    );
  }
}

String _headline(AppLocalizations l, OrderStatus s) => switch (s) {
  OrderStatus.paidAwaitingShipment => l.headPaidAwaitingShipment,
  OrderStatus.shipped => l.headShipped,
  OrderStatus.delivered => l.headDelivered,
  OrderStatus.completed => l.headCompleted,
  OrderStatus.disputed => l.headDisputed,
  OrderStatus.cancelledByBuyer => l.headCancelled,
  OrderStatus.refunded => l.headRefunded,
  OrderStatus.partiallyRefunded => l.headPartiallyRefunded,
  OrderStatus.readyToShip => l.headReadyToShip,
  OrderStatus.inDelivery => l.headInDelivery,
  OrderStatus.inStorage => l.headInStorage,
  OrderStatus.pickedUp => l.headPickedUp,
};

String _note(AppLocalizations l, String locale, Order o, DateTime now) {
  final remaining = remainingText(
    l,
    (o.deliveredAt ?? now).add(complaintWindow).difference(now),
  );
  return switch (o.status) {
    OrderStatus.paidAwaitingShipment => l.detailNotePaid(
      formatShortDateTime(o.shipDeadline),
    ),
    OrderStatus.shipped => l.detailNoteShipped,
    OrderStatus.delivered ||
    OrderStatus.pickedUp => l.detailNoteDelivered(remaining),
    OrderStatus.completed => l.detailNoteCompleted,
    OrderStatus.disputed => l.detailNoteDisputed,
    OrderStatus.cancelledByBuyer => l.detailNoteCancelled,
    OrderStatus.refunded => l.detailNoteRefunded,
    OrderStatus.partiallyRefunded => l.detailNotePartiallyRefunded,
    OrderStatus.readyToShip => l.detailNoteReadyToShip(
      formatVnd(o.ship, locale),
    ),
    OrderStatus.inDelivery => l.detailNoteInDelivery(o.attempt),
    OrderStatus.inStorage => l.detailNoteInStorage,
  };
}

class _Header extends StatelessWidget {
  const _Header({required this.order, required this.now, required this.locale});

  final Order order;
  final DateTime now;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTag(
          label: orderStatusLabel(l, order.status),
          tone: orderStatusTone(order.status),
        ),
        const SizedBox(height: 6),
        Text(
          _headline(l, order.status),
          style: context.text.headlineMedium?.copyWith(
            fontSize: 24,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _note(l, locale, order, now),
          style: context.text.bodySmall?.copyWith(
            color: colors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final shipInfo = order.tracking != null
        ? '${order.carrier ?? ''} · ${order.tracking}'
        : order.isAuction
        ? l.shipFromWarehouse
        : l.shipNoTracking;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            height: 72,
            child: BookCover(
              url: order.coverUrl,
              hue: order.coverHue,
              label: order.title,
              radius: 6,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.title,
                  style: context.text.titleMedium?.copyWith(
                    fontFamily: AppTypography.serifFamily,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    if (order.author != null) order.author!,
                    if (order.seller.isNotEmpty) order.seller,
                  ].join(' · '),
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                Text(
                  shipInfo,
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textMuted,
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

String _stepLabel(AppLocalizations l, OrderStep s) => switch (s) {
  OrderStep.saleOrdered => l.stepSaleOrdered,
  OrderStep.saleShipped => l.stepSaleShipped,
  OrderStep.delivered => l.stepDelivered,
  OrderStep.saleCompleted => l.stepSaleCompleted,
  OrderStep.auctionWon => l.stepAuctionWon,
  OrderStep.auctionInDelivery => l.stepAuctionInDelivery,
  OrderStep.auctionReceived => l.stepAuctionReceived,
  OrderStep.auctionCompleted => l.stepAuctionCompleted,
};

class _Timeline extends StatelessWidget {
  const _Timeline({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final timeline = orderTimeline(order);
    final steps = timeline.steps;

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 14,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: steps[i].done
                              ? colors.primary
                              : colors.surface,
                          border: Border.all(
                            color: steps[i].done
                                ? colors.primary
                                : colors.border,
                            width: 2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: 2,
                          color: i == steps.length - 1
                              ? Colors.transparent
                              : (steps[i].done && steps[i + 1].done
                                    ? colors.primary
                                    : colors.divider),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeline.cancelled && i == 0
                              ? l.stepCancelled
                              : _stepLabel(l, steps[i].step),
                          style: context.text.bodyMedium?.copyWith(
                            fontWeight: steps[i].isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: steps[i].done
                                ? colors.textPrimary
                                : colors.textMuted,
                          ),
                        ),
                        Text(
                          steps[i].done && steps[i].time != null
                              ? formatShortDateTime(steps[i].time!)
                              : steps[i].isNext
                              ? l.stepNext
                              : '',
                          style: context.text.labelSmall?.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.order, required this.locale});

  final Order order;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final c = order.complaint!;
    final text = switch (c.status) {
      ComplaintStatus.open =>
        order.isAuction ? l.complaintTextOpenAuction : l.complaintTextOpenSale,
      ComplaintStatus.sellerResponded => l.complaintTextSellerResponded(
        formatVnd(c.offer ?? 0, locale),
      ),
      ComplaintStatus.escalated =>
        order.isAuction
            ? l.complaintTextEscalatedAuction
            : l.complaintTextEscalatedSale,
      ComplaintStatus.agreed => l.complaintTextAgreed(
        formatVnd(c.offer ?? 0, locale),
      ),
      ComplaintStatus.resolved => l.complaintTextResolved,
    };
    return AppCard(
      color: colors.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.complaintCardTitle(complaintStatusLabel(l, c.status)),
            style: context.text.labelLarge?.copyWith(
              color: colors.onErrorContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: context.text.bodySmall?.copyWith(
              color: colors.onErrorContainer,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({required this.order, required this.locale});

  final Order order;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final settled = !order.status.isOpen;
    final note = order.isAuction
        ? l.moneyNoteAuction
        : settled
        ? l.moneyNoteSettled
        : l.moneyNoteHeld;

    Widget row(String label, String value, {bool bold = false}) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: bold ? null : colors.textSecondary,
            fontWeight: bold ? FontWeight.w700 : null,
          ),
        ),
        Text(
          value,
          style: context.text.bodySmall?.copyWith(
            fontWeight: bold ? FontWeight.w700 : null,
          ),
        ),
      ],
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            order.isAuction ? l.moneyWinPrice : l.moneyBookPrice,
            formatVnd(order.price, locale),
          ),
          const SizedBox(height: AppSpacing.xs),
          row(l.moneyShipping, formatVnd(order.ship, locale)),
          const SizedBox(height: AppSpacing.xs),
          Divider(color: colors.divider),
          const SizedBox(height: AppSpacing.xs),
          row(l.moneyTotal, formatVnd(order.total, locale), bold: true),
          const SizedBox(height: AppSpacing.xs),
          Text(
            note,
            style: context.text.labelSmall?.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.reviewSeller, style: context.text.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (var n = 1; n <= 5; n++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Semantics(
                    button: true,
                    selected: n <= order.stars,
                    label: l.starLabel(n),
                    child: Material(
                      color: n <= order.stars
                          ? colors.warningContainer
                          : colors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.smAll,
                        side: BorderSide(color: colors.divider),
                      ),
                      child: InkWell(
                        borderRadius: AppRadius.smAll,
                        onTap: () =>
                            ref.read(simProvider.notifier).rate(order.id, n),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.star_rounded,
                            color: n <= order.stars
                                ? colors.warning
                                : colors.border,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            order.stars > 0 ? l.reviewNoteEdit : l.reviewNoteNew,
            style: context.text.labelSmall?.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final sim = ref.read(simProvider.notifier);
    final c = order.complaint;

    void run(SimOutcome Function() action) {
      final outcome = action();
      if (outcome is SimInsufficient) {
        showInsufficientSheet(context, outcome.needed);
      }
    }

    Widget primary(String label, VoidCallback onTap) =>
        AppButton(label: label, onPressed: onTap);
    Widget plain(String label, VoidCallback onTap) => AppButton(
      label: label,
      variant: AppButtonVariant.secondary,
      onPressed: onTap,
    );
    Widget simulate(String label, VoidCallback onTap) =>
        AppDashedButton(label: label, onPressed: onTap);
    Widget danger(String label, VoidCallback onTap) => SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.error,
          side: BorderSide(color: colors.error.withValues(alpha: 0.35)),
        ),
        child: Text(label),
      ),
    );

    final actions = <Widget>[];
    switch (order.status) {
      case OrderStatus.paidAwaitingShipment:
        actions
          ..add(
            simulate(
              l.actSimSellerShip,
              () => run(() => sim.simSellerShip(order.id)),
            ),
          )
          ..add(
            danger(
              l.actCancelOrder(formatVnd(order.total, locale)),
              () => run(() => sim.cancelOrder(order.id)),
            ),
          );
      case OrderStatus.shipped:
        actions.add(
          primary(l.actReceived, () => run(() => sim.markReceived(order.id))),
        );
      case OrderStatus.readyToShip:
        actions.add(
          simulate(
            l.actSimWarehouseShip,
            () => run(() => sim.simWarehouseShip(order.id)),
          ),
        );
      case OrderStatus.inDelivery:
        actions
          ..add(
            simulate(
              l.actSimDeliverOk,
              () => run(() => sim.simDeliverySucceeded(order.id)),
            ),
          )
          ..add(
            simulate(
              l.actSimDeliverFail,
              () => run(() => sim.simDeliveryFailed(order.id)),
            ),
          );
      case OrderStatus.inStorage:
        actions
          ..add(
            primary(
              l.actPickUp,
              () => run(() => sim.pickUpAtWarehouse(order.id)),
            ),
          )
          ..add(
            plain(
              l.actRedeliver(formatVnd(shippingFeeAuction, locale)),
              () => run(() => sim.redeliver(order.id)),
            ),
          );
      case OrderStatus.delivered || OrderStatus.pickedUp:
        actions
          ..add(
            primary(
              l.actCompleteOrder,
              () => run(() => sim.completeOrder(order.id)),
            ),
          )
          ..add(
            danger(l.actComplaint, () => showComplaintSheet(context, order.id)),
          );
      case OrderStatus.disputed when c != null:
        switch (c.status) {
          case ComplaintStatus.open:
            actions.add(
              simulate(
                l.actSimSellerOffer,
                () => run(() => sim.simSellerOffer(order.id)),
              ),
            );
          case ComplaintStatus.sellerResponded:
            actions
              ..add(
                primary(
                  l.actAcceptOffer(formatVnd(c.offer ?? 0, locale)),
                  () => run(() => sim.acceptOffer(order.id)),
                ),
              )
              ..add(
                plain(
                  l.actEscalate,
                  () => run(() => sim.escalateComplaint(order.id)),
                ),
              );
          case ComplaintStatus.escalated:
            actions.add(
              simulate(
                l.actSimAdmin,
                () => run(() => sim.simAdminResolve(order.id)),
              ),
            );
          case ComplaintStatus.agreed || ComplaintStatus.resolved:
            break;
        }
      default:
        break;
    }

    if (actions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          l.actNone,
          textAlign: TextAlign.center,
          style: context.text.bodySmall?.copyWith(color: colors.textMuted),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.xs),
          actions[i],
        ],
      ],
    );
  }
}
