import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/util/format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_paged_list.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/app_tag.dart';
import '../../listings/presentation/widgets/book_tile.dart';
import '../application/auction_order_providers.dart';
import '../domain/auction_order.dart';
import 'auction_order_text.dart';

/// "Đơn đấu giá": tab Mua (đơn tôi thắng) và Bán (sách tôi bán), lọc theo nhóm.
class AuctionOrdersScreen extends StatelessWidget {
  const AuctionOrdersScreen({
    super.key,
    this.initialRole = OrderViewerRole.buyer,
  });

  final OrderViewerRole initialRole;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      initialIndex: initialRole == OrderViewerRole.buyer ? 0 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.aoTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.aoTabBuyer),
              Tab(text: l.aoTabSeller),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OrderList(role: OrderViewerRole.buyer),
            _OrderList(role: OrderViewerRole.seller),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends ConsumerStatefulWidget {
  const _OrderList({required this.role});

  final OrderViewerRole role;

  @override
  ConsumerState<_OrderList> createState() => _OrderListState();
}

class _OrderListState extends ConsumerState<_OrderList>
    with AutomaticKeepAliveClientMixin {
  AuctionOrderFilter _filter = AuctionOrderFilter.all;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = context.l10n;
    final provider = auctionOrdersProvider(widget.role);
    final value = ref
        .watch(provider)
        .whenData(
          (s) => s.copyWith(items: s.items.where(_filter.matches).toList()),
        );
    final labels = {
      AuctionOrderFilter.all: l.filterAll,
      AuctionOrderFilter.needsAction: l.aoFilterAction,
      AuctionOrderFilter.shipping: l.aoFilterShipping,
      AuctionOrderFilter.finished: l.aoFilterFinished,
    };

    return AppPagedList<AuctionOrder>(
      value: value,
      onLoadMore: ref.read(provider.notifier).loadMore,
      onRefresh: ref.read(provider.notifier).reload,
      header: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final f in AuctionOrderFilter.values)
              ChoiceChip(
                label: Text(labels[f]!),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
              ),
          ],
        ),
      ),
      empty: AppEmptyView(
        icon: Icons.inventory_2_outlined,
        title: l.aoEmpty,
        message: widget.role == OrderViewerRole.buyer
            ? l.aoEmptyBuyerHint
            : null,
      ),
      itemBuilder: (context, o) => AuctionOrderCard(
        order: o,
        onTap: () => context.push('/me/auction-orders/${o.id}'),
      ),
    );
  }
}

class AuctionOrderCard extends StatelessWidget {
  const AuctionOrderCard({super.key, required this.order, required this.onTap});

  final AuctionOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final o = order;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            height: 72,
            child: BookCover(
              url: o.thumbnailUrl,
              label: o.bookTitle,
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
                    Flexible(
                      child: AppTag(
                        label: auctionOrderStatusLabel(l, o.status),
                        tone: auctionOrderStatusTone(o.status),
                      ),
                    ),
                    if (o.needsBuyerAction) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  o.bookTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(
                    fontFamily: AppTypography.serifFamily,
                    fontVariations: AppTypography.serifSemiBold,
                    fontSize: 15.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.aoWinningPrice(formatVnd(o.finalPrice, locale)),
                  style: context.text.labelSmall?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
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
