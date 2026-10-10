import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../../sim/application/sim_providers.dart';
import '../../sim/presentation/sim_text.dart';
import '../../sim/presentation/sim_ticker.dart';
import '../domain/order.dart';

/// Ghi chú ngắn dưới mỗi đơn trong danh sách, theo trạng thái.
String orderListNote(AppLocalizations l, String locale, Order o, DateTime now) {
  switch (o.status) {
    case OrderStatus.paidAwaitingShipment:
      return l.noteShipBy(formatShortDateTime(o.shipDeadline));
    case OrderStatus.shipped:
      return '${o.carrier ?? ''} · ${o.tracking ?? ''}';
    case OrderStatus.delivered || OrderStatus.pickedUp:
      final deadline = o.complaintDeadlineAt;
      return deadline == null
          ? ''
          : l.noteComplaintLeft(remainingText(l, deadline.difference(now)));
    case OrderStatus.inDelivery:
      return l.noteDeliveryAttempt(o.attempt, o.carrier ?? '');
    case OrderStatus.inStorage:
      final since = o.storageAt ?? now;
      final days = (now.difference(since).inHours / 24).ceil();
      return l.noteStorage(days < 1 ? 1 : days);
    case OrderStatus.readyToShip:
      return l.notePacking;
    case OrderStatus.disputed:
      return l.noteFundsLocked;
    default:
      return formatVnd(o.total, locale);
  }
}

/// Danh sách đơn mua.
class SimOrdersScreen extends ConsumerWidget {
  const SimOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final orders = ref.watch(ordersProvider);
    final now = ref.watch(simNowProvider);

    return SimTicker(
      child: AppPage(
        title: l.ordersTitle,
        scrollable: false,
        child: orders.isEmpty
            ? AppEmptyView(
                icon: Icons.receipt_long_outlined,
                title: l.ordersEmpty,
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen + 4,
                  AppSpacing.md,
                  AppSpacing.screen + 4,
                  AppSpacing.xl,
                ),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _OrderRow(
                  order: orders[i],
                  note: orderListNote(l, locale, orders[i], now),
                ),
              ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.note});

  final Order order;
  final String note;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/me/sim-orders/${order.id}'),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${order.id} · ${orderKindLabel(l, order)}',
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelSmall?.copyWith(
                          fontFamily: AppTypography.monoFamily,
                          color: colors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AppTag(
                      label: orderStatusLabel(l, order.status),
                      tone: orderStatusTone(order.status),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  order.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(
                    fontFamily: AppTypography.serifFamily,
                    fontSize: 15.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note,
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
