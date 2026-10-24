import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/widgets/app_paged_list.dart';
import '../../../core/widgets/app_state_views.dart';
import '../application/auction_providers.dart';
import '../domain/auction.dart';
import 'auction_card.dart';

String auctionRoleLabel(AppLocalizations l, AuctionRole r) => switch (r) {
  AuctionRole.seller => l.myAucTabSeller,
  AuctionRole.bidder => l.myAucTabBidder,
  AuctionRole.leading => l.myAucTabLeading,
  AuctionRole.winner => l.myAucTabWinner,
};

/// "Phiên của tôi": bốn tab theo vai trò (`GET /me/auctions?role=`). Mỗi tab
/// chỉ tải khi được mở.
class MyAuctionsScreen extends StatelessWidget {
  const MyAuctionsScreen({super.key, this.initialRole = AuctionRole.bidder});

  final AuctionRole initialRole;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: AuctionRole.values.length,
      initialIndex: AuctionRole.values.indexOf(initialRole),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.myAuctionsTitle),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final r in AuctionRole.values)
                Tab(text: auctionRoleLabel(l, r)),
            ],
          ),
        ),
        body: TabBarView(
          children: [for (final r in AuctionRole.values) _RoleList(role: r)],
        ),
      ),
    );
  }
}

class _RoleList extends ConsumerWidget {
  const _RoleList({required this.role});

  final AuctionRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final provider = myAuctionsProvider(role);
    return AppPagedList<AuctionSummary>(
      value: ref.watch(provider),
      onLoadMore: ref.read(provider.notifier).loadMore,
      onRefresh: ref.read(provider.notifier).reload,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen + 4,
        AppSpacing.md,
        AppSpacing.screen + 4,
        AppSpacing.xl,
      ),
      separator: const SizedBox(height: 12),
      header: role == AuctionRole.seller
          ? Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: OutlinedButton.icon(
                onPressed: () => context.go('/sell'),
                icon: const Icon(Icons.add),
                label: Text(l.myAucCreate),
              ),
            )
          : null,
      empty: AppEmptyView(
        icon: Icons.gavel_outlined,
        title: switch (role) {
          AuctionRole.seller => l.myAucEmptySeller,
          AuctionRole.bidder => l.myAuctionsEmpty,
          AuctionRole.leading => l.myAucEmptyLeading,
          AuctionRole.winner => l.myAucEmptyWinner,
        },
      ),
      itemBuilder: (context, a) => AuctionCard(
        auction: a,
        onTap: () => context.push('/auctions/${a.id}'),
      ),
    );
  }
}
