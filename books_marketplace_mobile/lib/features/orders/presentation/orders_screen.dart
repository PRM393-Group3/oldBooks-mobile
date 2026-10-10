import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_paged_list.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../application/order_providers.dart';
import '../domain/sale_order.dart';

AppTagTone orderTone(SaleOrderStatus s) => switch (s) {
  SaleOrderStatus.completed => AppTagTone.success,
  SaleOrderStatus.paidAwaitingShipment ||
  SaleOrderStatus.shipped ||
  SaleOrderStatus.delivered => AppTagTone.info,
  SaleOrderStatus.disputed => AppTagTone.warning,
  SaleOrderStatus.cancelledByBuyer ||
  SaleOrderStatus.cancelledSellerTimeout => AppTagTone.neutral,
  SaleOrderStatus.refunded ||
  SaleOrderStatus.partiallyRefunded => AppTagTone.brand,
  SaleOrderStatus.unknown => AppTagTone.neutral,
};

/// Đơn mua và đơn bán (bán thường), lọc theo trạng thái.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.ordersTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.soTabBuy),
              Tab(text: l.soTabSell),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OrderList(role: OrderRole.buyer),
            _OrderList(role: OrderRole.seller),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends ConsumerStatefulWidget {
  const _OrderList({required this.role});

  final OrderRole role;

  @override
  ConsumerState<_OrderList> createState() => _OrderListState();
}

class _OrderListState extends ConsumerState<_OrderList>
    with AutomaticKeepAliveClientMixin {
  SaleOrderStatus? _status;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = context.l10n;
    final filter = (role: widget.role, status: _status);
    final provider = saleOrdersProvider(filter);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return AppPagedList<SaleOrder>(
      value: state,
      onLoadMore: notifier.loadMore,
      onRefresh: () async {
        refreshOrders(ref);
        await notifier.reload();
      },
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen + 4,
        AppSpacing.sm,
        AppSpacing.screen + 4,
        AppSpacing.xl,
      ),
      separator: const SizedBox(height: 12),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final s in <SaleOrderStatus?>[
                  null,
                  ...SaleOrderStatus.filters,
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(s == null ? l.filterAll : s.label(l)),
                      selected: _status == s,
                      onSelected: (_) => setState(() => _status = s),
                    ),
                  ),
              ],
            ),
          ),
          // Đơn đấu giá có vòng đời riêng (kho gửi, lưu kho), xem ở màn khác.
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              onTap: () => context.push(
                '/me/auction-orders?role=${widget.role == OrderRole.seller ? 'seller' : 'buyer'}',
              ),
              child: Row(
                children: [
                  const Icon(Icons.gavel_outlined, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l.soAuctionOrdersLink,
                      style: context.text.labelLarge,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
      empty: AppEmptyView(icon: Icons.receipt_long_outlined, title: l.soEmpty),
      itemBuilder: (context, order) => _OrderCard(order: order),
    );
  }
}

/// Ghi chú ngắn dưới mỗi đơn, theo trạng thái.
String orderNote(AppLocalizations l, String locale, SaleOrder o) {
  switch (o.status) {
    case SaleOrderStatus.paidAwaitingShipment:
      final d = o.shipDeadlineAt;
      return d == null ? '' : l.soNoteShipBy(formatShortDateTime(d));
    case SaleOrderStatus.shipped:
      final s = o.shipment;
      return s == null ? '' : l.soNoteTracking(s.carrier, s.trackingNumber);
    case SaleOrderStatus.delivered:
      final d = o.complaintWindowEndsAt;
      return d == null ? '' : l.soNoteComplaintBy(formatShortDateTime(d));
    case SaleOrderStatus.disputed:
      return l.soNoteLocked;
    default:
      return '';
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final SaleOrder order;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final note = orderNote(l, locale, order);
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/me/orders/${order.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            height: 72,
            child: BookCover(
              url: order.book?.thumbnailUrl,
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
                        order.counterpartyName ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelSmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AppTag(
                      label: order.status.label(l),
                      tone: orderTone(order.status),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  order.title.isEmpty ? '—' : order.title,
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
                  formatVnd(order.totalAmount, locale),
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (note.isNotEmpty)
                  Text(
                    note,
                    style: context.text.labelSmall?.copyWith(
                      color: colors.textMuted,
                      height: 1.45,
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
